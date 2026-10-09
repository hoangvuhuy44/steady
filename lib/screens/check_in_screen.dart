import 'package:flutter/material.dart';

import '../l10n/formatters.dart';

import '../models/activity_type.dart';
import '../state/steady_store.dart';
import '../widgets/activity_status.dart';

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
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          ActivityStatus(store: widget.store),
          Text(
            l.checkIn,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l.whatDidYouDo,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            l.activity,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
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
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                l.duration,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                l.minutesValue(minutes.round()),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
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
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.manualActivity)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            key: const ValueKey('activity-save'),
            onPressed: widget.store.canLogActivity ? save : null,
            icon: const Icon(Icons.check),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                widget.store.activitySaving ? l.activitySaving : l.saveActivity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
