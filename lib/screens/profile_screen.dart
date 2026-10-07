import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../l10n/formatters.dart';
import '../widgets/screening_result_card.dart';
import '../state/steady_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.store,
    required this.locale,
    required this.onLanguageChanged,
    this.auth,
  });
  final SteadyStore store;
  final Locale? locale;
  final ValueChanged<Locale?> onLanguageChanged;
  final AuthController? auth;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          l.profile,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth?.email ?? l.member,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(l.memberGoal),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (store.screeningEnforced) ...[
          ScreeningResultCard(assessment: store.screeningAssessment),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('profile-screening'),
            onPressed: store.requestScreening,
            icon: const Icon(Icons.assignment_outlined),
            label: Text(l.screeningEdit),
          ),
          const SizedBox(height: 18),
        ],
        if (auth != null) ...[
          OutlinedButton.icon(
            key: const ValueKey('profile-sign-out'),
            onPressed: () async {
              try {
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
          const SizedBox(height: 18),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.language,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l.languageHelp),
                const SizedBox(height: 16),
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
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l.weeklyTarget),
                subtitle: Text(l.fiveDays),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: Text(l.reminders),
                subtitle: Text(l.notConnected),
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
