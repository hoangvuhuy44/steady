import 'package:flutter/material.dart';

import '../models/activity_type.dart';
import '../state/steady_store.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    super.key,
    required this.store,
    required this.onSaved,
  });

  final SteadyStore store;
  final VoidCallback onSaved;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  ActivityType selectedType = ActivityType.walk;
  double minutes = 30;

  void save() {
    final wasAlreadyCheckedIn = widget.store.checkedInToday;
    final pointsEarned = wasAlreadyCheckedIn ? 5 : 20;

    widget.store.logActivity(selectedType, minutes.round());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedType.label} logged. +$pointsEarned points',
        ),
      ),
    );

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          'Check in',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'What did you do today?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ActivityType.values.map((type) {
            return ChoiceChip(
              selected: type == selectedType,
              onSelected: (_) => setState(() => selectedType = type),
              avatar: Icon(type.icon, size: 18),
              label: Text(type.label),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${minutes.round()} min',
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
          label: '${minutes.round()} min',
          onChanged: (value) => setState(() => minutes = value),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(Icons.verified_outlined, color: colors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'For the first MVP, check-ins are manual. HealthKit / Google Health Connect verification can come later.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: save,
          icon: const Icon(Icons.check),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Save activity'),
          ),
        ),
      ],
    );
  }
}
