import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SocialAuthProvider { google, facebook }

const authCallbackUrl = 'io.steady.app://login-callback/';

/// Drop callback parameters, including their delimiters, before another OAuth
/// attempt so the redirect matches the URL registered with Supabase exactly.
String webAuthRedirectUrl(Uri appUrl) =>
    appUrl.toString().split(RegExp(r'[?#]')).first;

/// No health details or application permissions are stored in auth metadata.
abstract class AuthController extends ChangeNotifier {
  bool get configured;
  String? get userId;
  String? get email;
  int get sessionRevision;
  bool get connectionError;
  bool get initializationFailed => false;
  Set<SocialAuthProvider> get socialProviders => const {};
  Future<void> signInWithProvider(SocialAuthProvider provider) async =>
      throw StateError('Social sign-in is not configured');
  Future<void> signIn(String email, String password);

  /// True when email confirmation is needed before a session can start.
  Future<bool> signUp(String email, String password);
  Future<void> signOut();
}

class UnconfiguredAuthController extends AuthController {
  UnconfiguredAuthController({this.initializationFailed = false});
  @override
  final bool initializationFailed;
  @override
  bool get configured => false;
  @override
  String? get userId => null;
  @override
  String? get email => null;
  @override
  int get sessionRevision => 0;
  @override
  bool get connectionError => false;
  @override
  Future<void> signIn(String email, String password) async =>
      throw StateError('Supabase is not configured');
  @override
  Future<bool> signUp(String email, String password) async =>
      throw StateError('Supabase is not configured');
  @override
  Future<void> signOut() async {}
}

class SupabaseAuthController extends AuthController {
  SupabaseAuthController(
    this.client, {
    Set<SocialAuthProvider> socialProviders = const {},
  }) : _socialProviders = Set.unmodifiable(socialProviders) {
    _acceptSession(client.auth.currentSession);
    _subscription = client.auth.onAuthStateChange.listen(
      (state) {
        _connectionError = false;
        _acceptSession(state.session);
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        // Offline refresh errors must not become unhandled zone exceptions.
        _connectionError = true;
        notifyListeners();
      },
    );
  }
  final SupabaseClient client;
  final Set<SocialAuthProvider> _socialProviders;
  late final StreamSubscription<AuthState> _subscription;
  String? _identity, _userId, _email;
  int _revision = 0;
  bool _connectionError = false;

  void _acceptSession(Session? session) {
    String? identity;
    if (session != null) {
      // session_id stays stable during token refresh and repeated signedIn events.
      final claims = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(session.accessToken.split('.')[1]),
          ),
        ),
      ) as Map<String, dynamic>;
      identity =
          '${session.user.id}:${claims['session_id'] ?? session.user.id}';
    }
    if (identity != _identity) _revision++;
    _identity = identity;
    _userId = session?.user.id;
    _email = session?.user.email;
  }

  @override
  bool get configured => true;
  @override
  String? get userId => _userId;
  @override
  String? get email => _email;
  @override
  int get sessionRevision => _revision;
  @override
  bool get connectionError => _connectionError;
  @override
  Set<SocialAuthProvider> get socialProviders {
    // Native callbacks are registered for these platforms in this project.
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return const {};
    }
    return _socialProviders;
  }

  String get _redirectTo =>
      kIsWeb ? webAuthRedirectUrl(Uri.base) : authCallbackUrl;

  @override
  Future<void> signInWithProvider(SocialAuthProvider provider) async {
    if (!socialProviders.contains(provider)) {
      throw StateError('Social sign-in is not configured');
    }
    final launched = await client.auth.signInWithOAuth(
      provider == SocialAuthProvider.google
          ? OAuthProvider.google
          : OAuthProvider.facebook,
      redirectTo: _redirectTo,
      scopes: provider == SocialAuthProvider.facebook ? 'email' : null,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
    if (!launched) throw StateError('Could not open the sign-in browser');
    // Launching a browser is not authentication. The SDK's callback event
    // updates the session only after Supabase validates the OAuth response.
  }

  @override
  Future<void> signIn(String email, String password) async {
    final result = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _acceptSession(result.session);
    _connectionError = false;
    notifyListeners();
  }

  @override
  Future<bool> signUp(String email, String password) async {
    final result = await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectTo,
    );
    if (result.session != null) {
      _acceptSession(result.session);
      _connectionError = false;
      notifyListeners();
    }
    return result.session == null;
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut(scope: SignOutScope.local);
    _acceptSession(null);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
