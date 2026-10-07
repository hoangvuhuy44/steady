import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/auth/auth_controller.dart';
import 'package:steady/screening/health_screening.dart';
import 'package:steady/nutrition/nutrition_strategy.dart';
import 'package:steady/state/steady_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'health_screening_test.dart' show screening, mealProfile;
import 'widget_test.dart' show tapVisible;

class FakeAuth extends AuthController {
  String? id;
  int revision = 0;
  bool fail = false, offline = false;
  Object? signInError;
  SocialAuthProvider? requestedProvider;
  Set<SocialAuthProvider> providers = {};
  @override
  Set<SocialAuthProvider> get socialProviders => providers;
  @override
  Future<void> signInWithProvider(SocialAuthProvider provider) async {
    requestedProvider = provider;
    if (fail) throw StateError('Could not open browser');
  }

  @override
  bool get configured => true;
  @override
  String? get userId => id;
  @override
  String? get email => id == null ? null : '$id@example.com';
  @override
  int get sessionRevision => revision;
  @override
  bool get connectionError => offline;
  void login(String value) {
    id = value;
    revision++;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (signInError != null) throw signInError!;
    if (fail) throw StateError('offline');
    login('first');
  }

  @override
  Future<bool> signUp(String email, String password) async => true;
  @override
  Future<void> signOut() async {
    id = null;
    revision++;
    notifyListeners();
  }
}

Future<void> enterScreeningValue(
  WidgetTester tester,
  String key,
  String value,
) async {
  final finder = find.byKey(ValueKey('screening-$key'));
  await tapVisible(tester, finder);
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('missing configuration cannot open home', (tester) async {
    await tester.pumpWidget(const SteadyApp(initialLocale: Locale('vi')));
    expect(find.byKey(const ValueKey('auth-unconfigured')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('auth-submit')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('auth-google')))
          .onPressed,
      isNull,
    );
  });
  testWidgets('email remains available when social providers are disabled', (
    tester,
  ) async {
    final auth = FakeAuth();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      SteadyApp(auth: auth, initialLocale: const Locale('en')),
    );
    for (final provider in ['google', 'facebook']) {
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(ValueKey('auth-$provider')))
            .onPressed,
        isNull,
      );
    }
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('auth-submit')))
          .onPressed,
      isNotNull,
    );
  });
  for (final provider in SocialAuthProvider.values) {
    testWidgets(
      '${provider.name} launches browser without bypassing screening',
      (tester) async {
        final auth = FakeAuth()..providers = {provider};
        addTearDown(auth.dispose);
        await tester.pumpWidget(
          SteadyApp(auth: auth, initialLocale: const Locale('en')),
        );
        await tapVisible(tester, find.byKey(ValueKey('auth-${provider.name}')));
        expect(auth.requestedProvider, provider);
        expect(find.byKey(const ValueKey('auth-browser')), findsOneWidget);
        expect(find.byKey(const ValueKey('screening-age')), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        auth.login('social-user');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('screening-age')), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      },
    );
  }
  testWidgets('social browser failure allows retry or email sign-in', (
    tester,
  ) async {
    final auth = FakeAuth()
      ..providers = {SocialAuthProvider.google}
      ..fail = true;
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      SteadyApp(auth: auth, initialLocale: const Locale('en')),
    );
    await tapVisible(tester, find.byKey(const ValueKey('auth-google')));
    expect(find.byKey(const ValueKey('auth-browser')), findsNothing);
    expect(find.byKey(const ValueKey('auth-error')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('auth-submit')))
          .onPressed,
      isNotNull,
    );
    auth.fail = false;
    await tapVisible(tester, find.byKey(const ValueKey('auth-google')));
    expect(find.byKey(const ValueKey('auth-browser')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-error')), findsNothing);
  });
  testWidgets('wrong credentials and rate limits explain the email failure', (
    tester,
  ) async {
    final auth = FakeAuth();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      SteadyApp(auth: auth, initialLocale: const Locale('en')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'password',
    );
    for (final code in [
      'invalid_credentials',
      'over_request_rate_limit',
      'email_not_confirmed',
    ]) {
      auth.signInError = AuthException('fixture', code: code);
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(
        find.text(switch (code) {
          'invalid_credentials' =>
            'Email or password is incorrect. Please try again.',
          'over_request_rate_limit' =>
            'Too many attempts. Please wait a few minutes and try again.',
          _ => 'Check your email to confirm your account, then return here to sign in.',
        }),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
    }
  });
  for (final code in ['vi', 'en']) {
    testWidgets('sign-in fits narrow screen with large text ($code)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final auth = FakeAuth()..providers = SocialAuthProvider.values.toSet();
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, initialLocale: Locale(code)),
      );
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'login validates, handles failure, and gates home behind screening',
    (tester) async {
      final auth = FakeAuth();
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, initialLocale: const Locale('en')),
      );
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('auth-email')),
        'first@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'test-password',
      );
      auth.fail = true;
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(
        find.text(
          'Could not sign in. Check your details and connection, then try again.',
        ),
        findsOneWidget,
      );
      auth.fail = false;
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(find.byKey(const ValueKey('screening-age')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      expect(find.text('Enter a value from 1 to 120'), findsOneWidget);
    },
  );
  testWidgets(
    'five screening steps require consent and generate a personalized menu',
    (tester) async {
      final auth = FakeAuth()..login('first');
      final store = SteadyStore();
      addTearDown(auth.dispose);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, store: store, initialLocale: const Locale('en')),
      );
      await tester.enterText(find.byKey(const ValueKey('screening-age')), '35');
      await tester.enterText(
        find.byKey(const ValueKey('screening-height')),
        '170',
      );
      await tester.enterText(
        find.byKey(const ValueKey('screening-weight')),
        '75,5',
      );
      await enterScreeningValue(tester, 'bodyFat', '20');
      await tapVisible(
        tester,
        find.byType(DropdownButtonFormField<BiologicalSex>),
      );
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('screening-conditions-known')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('screening-treatment-known')),
      );
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('screening-allergy-fish')),
      );
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      expect(find.text('General lifestyle support'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      expect(store.healthScreening, isNull);
      await tapVisible(tester, find.byKey(const ValueKey('screening-consent')));
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      expect(store.healthScreening!.weight, 75.5);
      expect(store.healthScreening!.bodyFat, 20);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Your 7-day plan'), findsOneWidget);
      expect(store.mealPlan, hasLength(7));
      expect(store.nutritionProfile!.exclusions, contains('fish'));
      expect(
        store.mealPlan
            .expand((day) => day)
            .any((meal) => meal.contains.contains('fish')),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('declining supports tracking while Meals stays paused', (
    tester,
  ) async {
    final auth = FakeAuth()..login('first');
    final store = SteadyStore();
    addTearDown(auth.dispose);
    addTearDown(store.dispose);
    await tester.pumpWidget(
      SteadyApp(auth: auth, store: store, initialLocale: const Locale('en')),
    );
    await tapVisible(tester, find.byKey(const ValueKey('screening-decline')));
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    expect(find.text('Meal planning is paused'), findsWidgets);
    expect(find.byKey(const ValueKey('meal-next')), findsNothing);
  });
  testWidgets(
    'refresh preserves screening; new session and account switch clear it',
    (tester) async {
      final auth = FakeAuth()..login('first');
      final store = SteadyStore();
      addTearDown(auth.dispose);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, store: store, initialLocale: const Locale('en')),
      );
      store.completeScreening(screening());
      await tester.pumpAndSettle();
      store.setNutritionProfile(mealProfile);
      auth.refresh();
      await tester.pumpAndSettle();
      expect(store.healthScreening, isNotNull);
      expect(find.byType(NavigationBar), findsOneWidget);
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(store.healthScreening, isNull);
      expect(store.mealPlan, isEmpty);
      auth.login('second');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screening-age')), findsOneWidget);
      store.completeScreening(
        screening(conditions: {HealthCondition.kidneyDisease}),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Meals'));
      await tester.pumpAndSettle();
      expect(find.text('Professional assessment needed'), findsOneWidget);
      auth.login('third');
      await tester.pumpAndSettle();
      expect(store.healthScreening, isNull);
      expect(find.byKey(const ValueKey('screening-age')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'signup with email confirmation stays outside authenticated app',
    (tester) async {
      final auth = FakeAuth();
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, initialLocale: const Locale('en')),
      );
      await tapVisible(tester, find.text('New to Steady? Create an account'));
      await tester.enterText(
        find.byKey(const ValueKey('auth-email')),
        'first@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'test-password',
      );
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(
        find.text(
          'Check your email to confirm your account, then return here to sign in.',
        ),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
    },
  );
  for (final code in ['vi', 'en']) {
    testWidgets('screening fits narrow screen with large text ($code)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final auth = FakeAuth()..login('first');
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(auth: auth, initialLocale: Locale(code)),
      );
      await enterScreeningValue(tester, 'age', '35');
      await enterScreeningValue(tester, 'height', '170');
      await enterScreeningValue(tester, 'weight', '75');
      for (var i = 0; i < 4; i++) {
        await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
        expect(tester.takeException(), isNull);
      }
      await tapVisible(tester, find.byKey(const ValueKey('screening-consent')));
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      expect(tester.takeException(), isNull);
    });
  }
}
