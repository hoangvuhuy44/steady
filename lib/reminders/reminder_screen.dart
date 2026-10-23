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
  String t(String vietnamese, String english) => vi ? vietnamese : english;
  ReminderSettings get draft => ReminderSettings(
    morning: morning.text,
    evening: evening.text,
    timezone: timezone.text,
  );
  @override
  void initState() {
    super.initState();
    if (widget.controller?.busy == true) {
      widget.controller!.addListener(initialLoaded);
    }
  }

  void initialLoaded() {
    final c = widget.controller!;
    if (c.busy) return;
    c.removeListener(initialLoaded);
    morning.text = c.settings.morning;
    evening.text = c.settings.evening;
    timezone.text = c.settings.timezone;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(initialLoaded);
    morning.dispose();
    evening.dispose();
    timezone.dispose();
    super.dispose();
  }

  Future<void> test(bool demo) async {
    final queued = await widget.controller!.test(demo: demo);
    if (mounted && queued) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            demo
                ? t(
                    'Đã đặt hai lượt thử sau 1 và 3 phút trên thiết bị này.',
                    'Two tests scheduled for this device in 1 and 3 minutes.',
                  )
                : t(
                    'Đã xếp hàng gửi thử. Chờ scheduler chạy (khoảng 1 phút).',
                    'Test queued. Allow about a minute for the scheduler.',
                  ),
          ),
        ),
      );
    }
  }

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
                  'Đăng nhập để lưu lịch nhắc tập. Push hỗ trợ app Android/iOS đã cấu hình Firebase; bản web chưa hỗ trợ.',
                  'Sign in to save reminders. Push requires a configured Android/iOS app; web is not supported.',
                ),
              ),
            )
          : AnimatedBuilder(
              animation: c,
              builder: (context, _) {
                final status = switch (c.permission) {
                  ReminderPermission.unsupported => t(
                    'Thiết bị không hỗ trợ hoặc chưa cấu hình FCM.',
                    'Device unsupported or FCM is not configured.',
                  ),
                  ReminderPermission.denied => t(
                    'Bị từ chối. Bấm bật để thử lại hoặc mở Cài đặt thông báo của hệ thống.',
                    'Permission denied. Try enabling again or open system notification settings.',
                  ),
                  ReminderPermission.unknown => t(
                    'Chưa cấp quyền thông báo.',
                    'Notification permission not granted yet.',
                  ),
                  ReminderPermission.granted =>
                    c.settings.enabled && c.registered
                        ? t(
                            'Đã bật trên thiết bị này.',
                            'Enabled on this device.',
                          )
                        : t(
                            'Đã cấp quyền; nhắc tập đang tắt hoặc thiết bị chưa đăng ký.',
                            'Permission granted; reminders are off or this device is not registered.',
                          ),
                };
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      status,
                      key: const ValueKey('reminder-status'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        'Nhắc hằng ngày theo múi giờ đã chọn. Hai giờ phải khác nhau. Tắt nhắc sẽ tắt trên mọi thiết bị của tài khoản.',
                        'Daily in the selected timezone. Choose two different times. Turning reminders off applies to all your devices.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: morning,
                      enabled: !c.busy,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: t('Giờ sáng (HH:mm)', 'Morning (HH:mm)'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: evening,
                      enabled: !c.busy,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: t(
                          'Giờ chiều tối (HH:mm)',
                          'After work (HH:mm)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timezone,
                      enabled: !c.busy,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: t('Múi giờ IANA', 'IANA timezone'),
                        hintText: 'Asia/Ho_Chi_Minh',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (c.error != null)
                      Text(
                        c.error == 'invalid'
                            ? t(
                                'Nhập giờ HH:mm hợp lệ, hai giờ khác nhau và múi giờ IANA.',
                                'Enter valid, distinct HH:mm times and an IANA timezone.',
                              )
                            : t(
                                'Chưa lưu/gửi được. Kiểm tra mạng, migration backend, cấu hình FCM và múi giờ. Lượt thử cách nhau ít nhất 60 giây.',
                                'Could not save/send. Check connectivity, backend migration, FCM configuration and timezone. Tests require a 60-second gap.',
                              ),
                        key: const ValueKey('reminder-error'),
                      ),
                    if (c.busy) const LinearProgressIndicator(),
                    FilledButton(
                      onPressed:
                          c.busy ||
                              c.permission == ReminderPermission.unsupported
                          ? null
                          : () => c.enable(draft),
                      child: Text(
                        t('Bật nhắc tập', 'Enable workout reminders'),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: c.busy ? null : () => c.save(draft),
                      child: Text(t('Lưu giờ nhắc', 'Save reminder times')),
                    ),
                    if (c.settings.enabled)
                      OutlinedButton(
                        onPressed: c.busy ? null : c.disable,
                        child: Text(t('Tắt nhắc tập', 'Turn reminders off')),
                      ),
                    OutlinedButton(
                      onPressed: c.busy || !c.registered
                          ? null
                          : () => test(false),
                      child: Text(
                        t('Gửi thông báo thử', 'Send test notification'),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: c.busy || !c.registered
                          ? null
                          : () => test(true),
                      child: Text(
                        t(
                          'Demo: sau 1 phút và 3 phút',
                          'Demo: in 1 and 3 minutes',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        'Thông báo mở màn hình ghi nhận buổi tập. Lượt đã xếp hàng chưa có nghĩa điện thoại đã hiển thị. Cần mạng và cho phép thông báo trong hệ thống.',
                        'Notifications open workout check-in. Queued does not mean displayed. Connectivity and system notification permission are required.',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
