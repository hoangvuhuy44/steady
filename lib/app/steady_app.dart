import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_gate.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';
import '../screens/check_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/meals_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../state/language_preferences.dart';
import '../state/steady_store.dart';
import '../theme/steady_theme.dart';

class SteadyApp extends StatefulWidget {
  const SteadyApp({
    super.key,
    this.initialLocale,
    this.languagePreferences,
    this.store,
    this.auth,
    this.requireAuthentication = true,
  });
  final Locale? initialLocale;
  final LanguagePreferences? languagePreferences;
  final SteadyStore? store;
  final AuthController? auth;

  /// Explicit opt-out for isolated UI previews and legacy component tests only.
  final bool requireAuthentication;
  @override
  State<SteadyApp> createState() => _SteadyAppState();
}

class _SteadyAppState extends State<SteadyApp> {
  late final SteadyStore store = widget.store ?? SteadyStore();
  late final AuthController auth = widget.auth ?? UnconfiguredAuthController();
  late final LanguagePreferences preferences =
      widget.languagePreferences ?? LanguagePreferences();
  late Locale? locale = widget.initialLocale;
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  Future<void> pendingSave = Future.value();
  int selectedIndex = 0;
  late int sessionRevision;

  @override
  void initState() {
    super.initState();
    sessionRevision = auth.sessionRevision;
    auth.addListener(resetNavigationForSession);
    store.addListener(openGeneratedPlan);
  }

  bool wasScreeningRequired = false;
  void openGeneratedPlan() {
    final finished = wasScreeningRequired && !store.screeningRequired;
    wasScreeningRequired = store.screeningRequired;
    if (finished && store.nutritionProfile?.strategy != null && mounted) {
      setState(() => selectedIndex = 2);
    }
  }

  void resetNavigationForSession() {
    if (sessionRevision != auth.sessionRevision) {
      sessionRevision = auth.sessionRevision;
      setState(() => selectedIndex = 0);
    }
  }

  void changeLanguage(Locale? value) {
    setState(() => locale = value);
    // Serialize writes so quick changes cannot persist out of order.
    pendingSave = pendingSave.then((_) async {
      try {
        await preferences.save(value);
      } catch (_) {
        final currentContext = messengerKey.currentContext;
        if (mounted && currentContext != null && currentContext.mounted) {
          messengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(currentContext.l10n.languageSaveError)),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    auth.removeListener(resetNavigationForSession);
    store.removeListener(openGeneratedPlan);
    if (widget.store == null) store.dispose();
    if (widget.auth == null) auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Steady',
      theme: SteadyTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scaffoldMessengerKey: messengerKey,
      home: widget.requireAuthentication
          ? AuthGate(
              auth: auth,
              store: store,
              locale: locale,
              onLanguageChanged: changeLanguage,
              child: appContent(),
            )
          : appContent(),
    );
  }

  Widget appContent() => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final l = context.l10n;
      final screens = [
        HomeScreen(
          store: store,
          onCheckIn: () => setState(() => selectedIndex = 1),
        ),
        CheckInScreen(
          store: store,
          onSaved: () => setState(() => selectedIndex = 0),
        ),
        MealsScreen(store: store),
        RewardsScreen(store: store),
        ProfileScreen(
          store: store,
          locale: locale,
          onLanguageChanged: changeLanguage,
          auth: widget.requireAuthentication ? auth : null,
        ),
      ];
      return Scaffold(
        key: ValueKey('app-session-${auth.sessionRevision}'),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: IndexedStack(index: selectedIndex, children: screens),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => selectedIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l.today,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle),
              label: l.checkIn,
            ),
            NavigationDestination(
              icon: const Icon(Icons.restaurant_outlined),
              selectedIcon: const Icon(Icons.restaurant),
              label: l.meals,
            ),
            NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined),
              selectedIcon: const Icon(Icons.emoji_events),
              label: l.rewards,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l.profile,
            ),
          ],
        ),
      );
    },
  );
}
