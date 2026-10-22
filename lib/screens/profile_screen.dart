import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';
import '../reminders/reminder_controller.dart';
import '../reminders/reminder_screen.dart';
import '../personalization/menu_controller.dart';
import '../personalization/daily_menu_screen.dart';
import '../personalization/food_strings.dart';

import '../auth/auth_controller.dart';
import '../l10n/formatters.dart';
import 'sign_in_screen.dart';
import '../state/steady_store.dart';
import '../widgets/activity_goal.dart';
import '../widgets/brand/steady_section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.store,
    required this.locale,
    required this.onLanguageChanged,
    this.auth,
    this.reminders,
    this.dailyMenu,
  });
  final SteadyStore store;
  final Locale? locale;
  final ValueChanged<Locale?> onLanguageChanged;
  final AuthController? auth;
  final ReminderController? reminders;
  final DailyMenuController? dailyMenu;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = context.l10n;
    return ListView(
      padding: SteadySpacing.screen,
      children: [
        SteadySectionHeader(
          title: l.profile,
          icon: SteadyBrandIcon.consistency,
        ),
        const SizedBox(height: SteadySpacing.xl),
        Card(
          child: Padding(
            padding: SteadySpacing.card,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: SteadySpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth?.userId == null
                            ? l.guest
                            : (auth?.email ?? l.member),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: SteadySpacing.xs),
                      Text(l.localActivityStorage),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SteadySpacing.lg),
        if (auth?.connectionError == true) Text(l.authOffline),
        if (auth != null && auth!.userId == null) ...[
          FilledButton.icon(
            key: const ValueKey('profile-sign-in'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => SignInScreen(
                  auth: auth!,
                  locale: locale,
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            ),
            icon: const Icon(Icons.login),
            label: Text(l.signIn),
          ),
          const SizedBox(height: SteadySpacing.lg),
        ],
        if (auth?.userId != null) ...[
          OutlinedButton.icon(
            key: const ValueKey('profile-sign-out'),
            onPressed: () async {
              try {
                await reminders?.detach();
                await auth!.signOut();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.authSignOutError)),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(l.signOut),
          ),
          const SizedBox(height: SteadySpacing.lg),
        ],
        Card(
          child: Padding(
            padding: SteadySpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate),
                    const SizedBox(width: SteadySpacing.md),
                    Expanded(
                      child: Text(
                        l.language,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SteadySpacing.sm),
                Text(l.languageHelp),
                const SizedBox(height: SteadySpacing.lg),
                DropdownButtonFormField<String>(
                  key: ValueKey('language-${locale?.languageCode ?? 'system'}'),
                  initialValue: locale?.languageCode ?? 'system',
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.language),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(l.systemLanguage),
                    ),
                    const DropdownMenuItem(
                      value: 'vi',
                      child: Text('Tiếng Việt'),
                    ),
                    const DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onLanguageChanged(
                        value == 'system' ? null : Locale(value),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SteadySpacing.lg),
        Card(
          child: Column(
            children: [
              ActivityGoal(metrics: store.activityMetrics),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: Text(l.reminders),
                subtitle: Text(
                  Localizations.localeOf(context).languageCode == 'vi'
                      ? 'Hằng ngày · 07:00 và 18:30 · Có thể chỉnh'
                      : 'Daily · 07:00 and 18:30 · Customizable',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => ReminderScreen(controller: reminders),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const ValueKey('profile-food-preferences'),
                leading: const Icon(Icons.restaurant_menu),
                title: Text(
                  foodText(
                    context,
                    'Hồ sơ ăn uống và thực đơn',
                    'Food preferences and daily menu',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: dailyMenu == null
                    ? null
                    : () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              DailyMenuScreen(controller: dailyMenu!),
                        ),
                      ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: Text(l.healthData),
                subtitle: Text(l.manualCheckIns),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
