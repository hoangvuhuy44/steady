import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';

import '../models/activity_type.dart';
import '../state/steady_store.dart';
import '../widgets/activity_status.dart';
import '../widgets/brand/steady_section_header.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, required this.store, required this.onSaved});

  final SteadyStore store;
  final VoidCallback onSaved;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  ActivityType selectedType = ActivityType.walk;
  double minutes = 30;

  Future<void> save() async {
    final type = selectedType;
    final duration = minutes.round();
    final pointsEarned = await widget.store.logActivity(type, duration);
    if (!mounted || pointsEarned == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.activitySaved(context.l10n.activityName(type), duration),
        ),
      ),
    );

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = context.l10n;

    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => SingleChildScrollView(
        padding: SteadySpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ActivityStatus(store: widget.store),
            SteadySectionHeader(
              title: l.checkIn,
              subtitle: l.whatDidYouDo,
              icon: SteadyBrandIcon.activity,
            ),
            const SizedBox(height: SteadySpacing.xl),
            Text(
              l.activity,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: SteadySpacing.md),
            Wrap(
              spacing: SteadySpacing.md,
              runSpacing: SteadySpacing.md,
              children: ActivityType.values.map((type) {
                return ChoiceChip(
                  selected: type == selectedType,
                  onSelected: widget.store.activitySaving
                      ? null
                      : (_) => setState(() => selectedType = type),
                  avatar: Icon(type.icon, size: 18),
                  label: Text(l.activityName(type)),
                );
              }).toList(),
            ),
            const SizedBox(height: SteadySpacing.xxl),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  l.duration,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  l.minutesValue(minutes.round()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: minutes,
              min: 10,
              max: 120,
              divisions: 22,
              label: l.minutesValue(minutes.round()),
              onChanged: widget.store.activitySaving
                  ? null
                  : (value) => setState(() => minutes = value),
            ),
            const SizedBox(height: SteadySpacing.md),
            Card(
              child: Padding(
                padding: SteadySpacing.card,
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, color: colors.primary),
                    const SizedBox(width: SteadySpacing.md),
                    Expanded(child: Text(l.manualActivity)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SteadySpacing.xxl),
            FilledButton.icon(
              key: const ValueKey('activity-save'),
              onPressed: widget.store.canLogActivity ? save : null,
              icon: const Icon(Icons.check),
              label: Text(
                widget.store.activitySaving ? l.activitySaving : l.saveActivity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
