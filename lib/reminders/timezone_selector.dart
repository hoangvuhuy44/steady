import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../time/device_timezone.dart';
import '../time/iana_data.dart' as data;

class TimezoneSelector extends StatefulWidget {
  const TimezoneSelector({
    super.key,
    required this.controller,
    required this.enabled,
  });
  final TextEditingController controller;
  final bool enabled;

  @override
  State<TimezoneSelector> createState() => _TimezoneSelectorState();
}

class _TimezoneSelectorState extends State<TimezoneSelector> {
  bool loading = false;
  String? error;
  bool get vi => Localizations.localeOf(context).languageCode == 'vi';
  String t(String vn, String en) => vi ? vn : en;

  Future<void> useDevice() async {
    final previous = widget.controller.text;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final id = await readDeviceTimezone();
      if (!mounted || !widget.enabled || widget.controller.text != previous) {
        return;
      }
      widget.controller.text = id;
    } catch (_) {
      if (mounted) {
        setState(
          () => error = t(
            'Không đọc được múi giờ thiết bị. Hãy chọn trong danh sách.',
            'Could not read the device timezone. Choose one from the list.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> choose() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _TimezoneDialog(selected: widget.controller.text, vi: vi),
    );
    if (!mounted || !widget.enabled || selected == null) return;
    widget.controller.text = selected;
    setState(() => error = null);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        key: const ValueKey('reminder-timezone'),
        controller: widget.controller,
        enabled: widget.enabled && !loading,
        readOnly: true,
        onTap: choose,
        decoration: InputDecoration(
          labelText: t('Múi giờ nhắc tập', 'Reminder timezone'),
          suffixIcon: const Icon(Icons.expand_more),
        ),
      ),
      TextButton.icon(
        key: const ValueKey('use-device-timezone'),
        onPressed: widget.enabled && !loading ? useDevice : null,
        icon: const Icon(Icons.my_location),
        label: Text(
          t(
            'Dùng múi giờ hiện tại của thiết bị',
            'Use current device timezone',
          ),
        ),
      ),
      if (loading) const LinearProgressIndicator(),
      if (error != null) Text(error!, key: const ValueKey('timezone-error')),
      Text(
        t(
          'Lưu giờ nhắc để áp dụng. Khi đi sang múi giờ khác, chọn lại múi giờ thiết bị và lưu.',
          'Save reminder times to apply. When travelling to another timezone, select the device timezone again and save.',
        ),
      ),
    ],
  );
}

class _TimezoneDialog extends StatefulWidget {
  const _TimezoneDialog({required this.selected, required this.vi});
  final String selected;
  final bool vi;
  @override
  State<_TimezoneDialog> createState() => _TimezoneDialogState();
}

class _TimezoneDialogState extends State<_TimezoneDialog> {
  late final List<String> zones;
  final instant = DateTime.now().toUtc();
  String query = '';
  @override
  void initState() {
    super.initState();
    data.initializeTimeZones();
    zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  String offset(String id) {
    final minutes = tz.TZDateTime.from(
      instant,
      tz.getLocation(id),
    ).timeZoneOffset.inMinutes;
    return 'UTC${minutes < 0 ? '-' : '+'}${(minutes.abs() ~/ 60).toString().padLeft(2, '0')}:${(minutes.abs() % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final matches = zones
        .where(
          (id) => id
              .toLowerCase()
              .replaceAll('_', ' ')
              .contains(query.toLowerCase().replaceAll('_', ' ').trim()),
        )
        .toList();
    return AlertDialog(
      title: Text(widget.vi ? 'Chọn múi giờ' : 'Choose timezone'),
      content: SizedBox(
        width: 420,
        height: 400,
        child: Column(
          children: [
            TextField(
              key: const ValueKey('timezone-search'),
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                labelText: widget.vi
                    ? 'Tìm thành phố / múi giờ'
                    : 'Search city / timezone',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        widget.vi
                            ? 'Không tìm thấy múi giờ'
                            : 'No timezones found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final id = matches[index];
                        return ListTile(
                          title: Text(id),
                          subtitle: Text(
                            '${offset(id)} · ${widget.vi ? 'hiện tại' : 'currently'}',
                          ),
                          trailing: id == widget.selected
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.vi ? 'Hủy' : 'Cancel'),
        ),
      ],
    );
  }
}
