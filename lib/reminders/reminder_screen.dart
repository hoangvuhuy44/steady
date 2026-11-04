import 'package:flutter/material.dart';

import 'reminder_controller.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key, this.controller});
  final ReminderController? controller;
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final morning = TextEditingController(
    text: widget.controller?.settings.morning ?? '07:00',
  );
  late final evening = TextEditingController(
    text: widget.controller?.settings.evening ?? '18:30',
  );
  late final timezone = TextEditingController(
    text: widget.controller?.settings.timezone ?? 'Asia/Ho_Chi_Minh',
  );
  bool get vi => Localizations.localeOf(context).languageCode == 'vi';
  String t(String vn, String en) => vi ? vn : en;
  ReminderSettings? _lastSettings;
  ReminderSettings get draft => ReminderSettings(
    morning: morning.text,
    evening: evening.text,
    timezone: timezone.text,
  );
  @override
  void initState() {
    super.initState();
    _lastSettings = widget.controller?.settings;
    widget.controller?.addListener(loaded);
  }

  void loaded() {
    final c = widget.controller!;
    if (c.busy) return;
    final last = _lastSettings;
    _lastSettings = c.settings;
    if (last?.morning == c.settings.morning &&
        last?.evening == c.settings.evening &&
        last?.timezone == c.settings.timezone) {
      return;
    }
    morning.text = c.settings.morning;
    evening.text = c.settings.evening;
    timezone.text = c.settings.timezone;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(loaded);
    morning.dispose();
    evening.dispose();
    timezone.dispose();
    super.dispose();
  }

  Future<void> test() async {
    final shown = await widget.controller!.test();
    if (mounted && shown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(
              'Đã yêu cầu hệ điều hành hiển thị thông báo thử.',
              'Local test sent to the operating system.',
            ),
          ),
        ),
      );
    }
  }

  String errorText(String code) => switch (code) {
    'invalid' => t(
      'Nhập hai giờ HH:mm hợp lệ, khác nhau và múi giờ IANA hợp lệ.',
      'Enter valid, distinct HH:mm times and an IANA timezone.',
    ),
    'permission' => t(
      'Chưa được cấp quyền thông báo. Bật quyền trong Cài đặt hệ thống rồi thử lại.',
      'Notification permission denied. Enable notifications in system settings and retry.',
    ),
    'cache' => t(
      'Không lưu được trên máy. Kiểm tra dung lượng và thử lại.',
      'Could not save on this device. Check storage and retry.',
    ),
    'sync' => t(
      'Chưa đồng bộ được Supabase. Lịch trên máy vẫn dùng được; ứng dụng sẽ thử lại.',
      'Supabase sync failed. Local reminders remain available; sync will retry.',
    ),
    'unsupported' => t(
      'Thông báo cục bộ hỗ trợ Android và iOS.',
      'Local notifications support Android and iOS.',
    ),
    _ => t(
      'Không hẹn/hiển thị được thông báo trên máy. Thử lại và kiểm tra cài đặt hệ thống.',
      'Could not schedule/show local notifications. Retry and check system settings.',
    ),
  };
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: AppBar(title: Text(t('Nhắc tập', 'Workout reminders'))),
      body: c == null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t(
                  'Đăng nhập để lưu lịch nhắc tập. Thông báo cục bộ hỗ trợ Android/iOS.',
                  'Sign in to save reminders. Local notifications support Android/iOS.',
                ),
              ),
            )
          : AnimatedBuilder(
              animation: c,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    c.registered
                        ? t(
                            'Đã bật trên thiết bị này.',
                            'Enabled on this device.',
                          )
                        : c.settings.enabled
                        ? t(
                            'Lịch yêu cầu bật; chưa hẹn thành công trên máy này.',
                            'Reminders requested; this device is not scheduled.',
                          )
                        : t('Nhắc tập đang tắt.', 'Reminders are off.'),
                    key: const ValueKey('reminder-status'),
                  ),
                  Text(
                    c.pendingSync
                        ? t(
                            'Có thay đổi đang chờ đồng bộ.',
                            'Changes pending synchronization.',
                          )
                        : t(
                            'Không có thay đổi cục bộ chờ gửi.',
                            'No local changes pending upload.',
                          ),
                    key: const ValueKey('reminder-sync'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t(
                      'Lịch đã hẹn hoạt động khi offline hoặc app chạy nền. Android có thể nhắc muộn khi tiết kiệm pin. Thay đổi từ máy khác áp dụng sau đồng bộ.',
                      'Scheduled reminders work offline and in the background. Android may delay delivery during battery saving. Changes from other devices apply after synchronization.',
                    ),
                  ),
                  TextField(
                    controller: morning,
                    enabled: !c.busy,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: t('Giờ sáng (HH:mm)', 'Morning (HH:mm)'),
                    ),
                  ),
                  TextField(
                    controller: evening,
                    enabled: !c.busy,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: t('Giờ chiều tối (HH:mm)', 'Evening (HH:mm)'),
                    ),
                  ),
                  TextField(
                    controller: timezone,
                    enabled: !c.busy,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: t('Múi giờ IANA', 'IANA timezone'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (c.error != null)
                    Text(
                      errorText(c.error!),
                      key: const ValueKey('reminder-error'),
                    ),
                  if (c.busy) const LinearProgressIndicator(),
                  FilledButton(
                    onPressed: c.busy ? null : () => c.enable(draft),
                    child: Text(t('Bật nhắc tập', 'Enable workout reminders')),
                  ),
                  OutlinedButton(
                    onPressed: c.busy ? null : () => c.save(draft),
                    child: Text(t('Lưu giờ nhắc', 'Save reminder times')),
                  ),
                  OutlinedButton(
                    onPressed: c.busy ? null : c.disable,
                    child: Text(t('Tắt nhắc tập', 'Turn reminders off')),
                  ),
                  OutlinedButton(
                    onPressed: c.busy ? null : test,
                    child: Text(
                      t('Gửi thông báo thử', 'Send test notification'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: c.busy ? null : c.refresh,
                    child: Text(t('Đồng bộ ngay', 'Sync now')),
                  ),
                ],
              ),
            ),
    );
  }
}
