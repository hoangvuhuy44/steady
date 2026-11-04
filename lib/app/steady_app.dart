import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';
import '../screens/check_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/recipes_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../state/language_preferences.dart';
import '../state/steady_store.dart';
import '../theme/steady_theme.dart';
import '../reminders/native_reminders.dart';
import '../reminders/reminder_controller.dart';
import '../personalization/menu_controller.dart';
import '../personalization/menu_repository.dart';
import '../personalization/daily_menu_screen.dart';

class SteadyApp extends StatefulWidget {
  const SteadyApp({
    super.key,
    this.initialLocale,
    this.languagePreferences,
    this.store,
    this.auth,
    this.reminderDevice,
    this.menuRepository,
  });
  final Locale? initialLocale;
  final LanguagePreferences? languagePreferences;
  final SteadyStore? store;
  final AuthController? auth;
  final NativeReminderDevice? reminderDevice;
  final MenuRepository? menuRepository;

  @override
  State<SteadyApp> createState() => _SteadyAppState();
}

class _SteadyAppState extends State<SteadyApp> with WidgetsBindingObserver {
  late final SteadyStore store = widget.store ?? SteadyStore();
  late final AuthController auth = widget.auth ?? UnconfiguredAuthController();
  late final LanguagePreferences preferences =
      widget.languagePreferences ?? LanguagePreferences();
  late Locale? locale = widget.initialLocale;
  final navigatorKey = GlobalKey<NavigatorState>();
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  Future<void> pendingSave = Future.value();
  int selectedIndex = 0;
  late int sessionRevision;
  Timer? dayRefreshTimer;
  ReminderController? reminders;
  int reminderRevision = 0;
  DailyMenuController? dailyMenu;

  void configureDailyMenu() {
    dailyMenu?.dispose();
    final repository =
        widget.menuRepository ??
        (auth is SupabaseAuthController && auth.userId != null
            ? SupabaseMenuRepository(
                (auth as SupabaseAuthController).client,
                auth.userId!,
              )
            : auth.userId == null
            ? GuestMenuRepository()
            : null);
    dailyMenu = repository == null
        ? null
        : DailyMenuController(repository: repository);
    if (dailyMenu != null) unawaited(dailyMenu!.refresh());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleDayRefresh();
    sessionRevision = auth.sessionRevision;
    auth.addListener(syncSession);
    configureDailyMenu();
    unawaited(store.setActivityUser(auth.userId));
    unawaited(configureReminders());
    widget.reminderDevice?.onTap = openWorkout;
    final payload = widget.reminderDevice?.initialPayload;
    if (payload != null) openWorkout(payload);
  }

  Future<void> configureReminders() async {
    final revision = ++reminderRevision;
    final previous = reminders;
    reminders = null;
    previous?.dispose();
    try {
      await widget.reminderDevice?.stop();
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || revision != reminderRevision) return;
        messengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text(
              'Could not cancel previous workout reminders. Reopen the app to retry.',
            ),
          ),
        );
      });
      return;
    }
    if (!mounted || revision != reminderRevision) return;
    if (auth is SupabaseAuthController &&
        auth.userId != null &&
        widget.reminderDevice != null) {
      final controller = ReminderController(
        api: SupabaseReminderApi(
          (auth as SupabaseAuthController).client,
          auth.userId!,
        ),
        device: widget.reminderDevice!,
        cache: PreferencesReminderCache(auth.userId!),
        isOwner: () => mounted && revision == reminderRevision,
      );
      setState(() => reminders = controller);
      await controller.refresh();
    }
  }

  void openWorkout(String? payload) {
    if (payload != 'check-in' || auth.userId == null) return;
    final revision = reminderRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != reminderRevision) return;
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      setState(() => selectedIndex = 1);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void scheduleDayRefresh() {
    dayRefreshTimer?.cancel();
    dayRefreshTimer = Timer(store.timeUntilNextDay, () {
      store.refreshActivityDate();
      unawaited(dailyMenu?.ensureDay());
      scheduleDayRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      store.refreshActivityDate();
      // Refresh account preferences too, so changes from another device are
      // validated before a resumed menu becomes visible.
      unawaited(dailyMenu?.refresh());
      scheduleDayRefresh();
      if (reminders?.busy == false) unawaited(reminders!.refresh());
    } else {
      dayRefreshTimer?.cancel();
    }
  }

  void syncSession() {
    if (sessionRevision != auth.sessionRevision) {
      sessionRevision = auth.sessionRevision;
      store.beginSession();
      configureDailyMenu();
      unawaited(store.setActivityUser(auth.userId));
      unawaited(configureReminders());
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      });
    } else {
      setState(() {});
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
    dayRefreshTimer?.cancel();
    dailyMenu?.dispose();
    ++reminderRevision;
    reminders?.dispose();
    widget.reminderDevice?.onTap = null;
    WidgetsBinding.instance.removeObserver(this);
    auth.removeListener(syncSession);
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
      navigatorKey: navigatorKey,
      home: appContent(),
    );
  }

  Widget appContent() => AnimatedBuilder(
    animation: Listenable.merge([store, ?dailyMenu]),
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
        if (dailyMenu?.profile != null)
          DailyMenuScreen(controller: dailyMenu!)
        else
          RecipesScreen(
            onDailyMenu: dailyMenu == null
                ? null
                : () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => DailyMenuScreen(controller: dailyMenu!),
                    ),
                  ),
          ),
        RewardsScreen(store: store),
        ProfileScreen(
          store: store,
          locale: locale,
          onLanguageChanged: changeLanguage,
          auth: auth,
          reminders: reminders,
          dailyMenu: dailyMenu,
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
