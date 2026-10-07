import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../screens/screening_screen.dart';
import '../screens/sign_in_screen.dart';
import '../state/steady_store.dart';
import 'auth_controller.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.auth,
    required this.store,
    required this.locale,
    required this.onLanguageChanged,
    required this.child,
  });
  final AuthController auth;
  final SteadyStore store;
  final Locale? locale;
  final ValueChanged<Locale?> onLanguageChanged;
  final Widget child;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late int revision;
  bool signingOut = false;
  @override
  void initState() {
    super.initState();
    revision = widget.auth.sessionRevision;
    widget.store.beginSession();
    widget.auth.addListener(authChanged);
  }

  void authChanged() {
    if (revision != widget.auth.sessionRevision) {
      revision = widget.auth.sessionRevision;
      widget.store.beginSession();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.auth.removeListener(authChanged);
    super.dispose();
  }

  Future<void> signOut() async {
    if (signingOut) return;
    setState(() => signingOut = true);
    try {
      await widget.auth.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.authSignOutError)));
      }
    } finally {
      if (mounted) setState(() => signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auth.userId == null) {
      return SignInScreen(
        auth: widget.auth,
        locale: widget.locale,
        onLanguageChanged: widget.onLanguageChanged,
      );
    }
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        if (widget.store.screeningRequired) {
          return ScreeningScreen(
            key: ValueKey('screening-$revision'),
            initial: widget.store.healthScreening,
            onCompleted: widget.store.completeScreening,
            onDeclined: widget.store.declineScreening,
            onSignOut: signOut,
          );
        }
        return Column(
          children: [
            if (widget.auth.connectionError)
              MaterialBanner(
                content: Text(context.l10n.authOffline),
                actions: [
                  TextButton(
                    onPressed: signOut,
                    child: Text(context.l10n.signOut),
                  ),
                ],
              ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
