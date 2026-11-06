import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../recipes/recipe_filter.dart';
import '../theme/steady_spacing.dart';
import 'food_profile.dart';
import 'food_strings.dart';
import 'menu_controller.dart';

class FoodQuestionnaire extends StatefulWidget {
  const FoodQuestionnaire({super.key, required this.controller});
  final DailyMenuController controller;
  @override
  State<FoodQuestionnaire> createState() => _FoodQuestionnaireState();
}

class _FoodQuestionnaireState extends State<FoodQuestionnaire> {
  int step = 0;
  bool saving = false;
  String? message;
  late final FoodProfile initial = widget.controller.profile ?? FoodProfile();
  late final Set<String> allergies = {...initial.allergies};
  late bool noAllergies =
      widget.controller.profile != null && allergies.isEmpty;
  late FoodDiet diet = initial.diet;
  late FoodGoal goal = initial.goal;
  late int? offset = initial.utcOffsetMinutes;
  late final customAllergies = TextEditingController(
    text: allergies.difference(RecipeFilter.allergyLabels.toSet()).join(', '),
  );
  late final intolerances = TextEditingController(
    text: initial.intolerances.join(', '),
  );
  late final favorites = TextEditingController(
    text: initial.favorites.join(', '),
  );
  late final dislikes = TextEditingController(
    text: initial.dislikes.join(', '),
  );
  late final medicalAvoid = TextEditingController(
    text: initial.medicalAvoid.join(', '),
  );
  late final medicalNote = TextEditingController(text: initial.medicalNote);
  late final budget = TextEditingController(
    text: initial.dailyBudget?.toString() ?? '',
  );
  late final minutes = TextEditingController(
    text: initial.maxMinutes?.toString() ?? '',
  );

  String t(String vi, String en) => foodText(context, vi, en);
  Set<String> terms(TextEditingController c) => c.text
      .split(RegExp(r'[,;\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
  Widget input(
    String key,
    TextEditingController c,
    String label, {
    bool number = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      maxLength: number ? 9 : 500,
      decoration: InputDecoration(labelText: label),
      keyboardType: number ? TextInputType.number : TextInputType.text,
    ),
  );

  Future<void> next() async {
    setState(() => message = null);
    if (step == 0 &&
        !noAllergies &&
        allergies.isEmpty &&
        terms(customAllergies).isEmpty) {
      setState(
        () => message = t(
          'Hãy chọn dị ứng hoặc “Không có”.',
          'Select an allergy or “None”.',
        ),
      );
      return;
    }
    if (step < 4) {
      setState(() => step++);
      return;
    }
    int? parse(TextEditingController c) =>
        c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());
    if ([budget, minutes].any(
      (c) => c.text.trim().isNotEmpty && (parse(c) == null || parse(c)! <= 0),
    )) {
      setState(
        () => message = t(
          'Ngân sách và thời gian phải là số nguyên lớn hơn 0, hoặc để trống.',
          'Budget and time must be positive whole numbers, or blank.',
        ),
      );
      return;
    }
    setState(() => saving = true);
    final success = await widget.controller.saveProfile(
      FoodProfile(
        allergies: noAllergies
            ? {}
            : {
                ...allergies.intersection(RecipeFilter.allergyLabels.toSet()),
                ...terms(customAllergies),
              },
        intolerances: terms(intolerances),
        favorites: terms(favorites),
        dislikes: terms(dislikes),
        medicalAvoid: terms(medicalAvoid),
        medicalNote: medicalNote.text.trim(),
        diet: diet,
        goal: goal,
        dailyBudget: parse(budget),
        maxMinutes: parse(minutes),
        utcOffsetMinutes: offset,
      ),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        saving = false;
        message = t(
          'Chưa lưu được. Quay lại và tải lại để kiểm tra kết nối hoặc xung đột dữ liệu.',
          'Could not save. Go back and reload to check connection or a data conflict.',
        );
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      customAllergies,
      intolerances,
      favorites,
      dislikes,
      medicalAvoid,
      medicalNote,
      budget,
      minutes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      t('Dị ứng và không dung nạp', 'Allergies and intolerances'),
      t('Chế độ ăn và mục tiêu', 'Diet and goal'),
      t('Khẩu vị', 'Preferences'),
      t('Ngân sách và thời gian', 'Budget and time'),
      t('Giới hạn được chỉ định', 'Prescribed restrictions'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Cá nhân hóa thực đơn', 'Meal preferences')),
      ),
      body: ListView(
        padding: SteadySpacing.screen,
        children: [
          Text(
            '${step + 1}/5 · ${titles[step]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (step == 0) ...[
            Text(
              t(
                'Dị ứng khác với không dung nạp và không thích. Dị ứng và không dung nạp được loại trừ bắt buộc; không thích chỉ ảnh hưởng xếp hạng.',
                'Allergies differ from intolerances and dislikes. Allergies and intolerances are mandatory exclusions; dislikes affect ranking.',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  key: const ValueKey('food-allergy-none'),
                  label: Text(t('Không có', 'None')),
                  selected: noAllergies,
                  onSelected: (v) => setState(() {
                    noAllergies = v;
                    if (v) {
                      allergies.clear();
                      customAllergies.clear();
                    }
                  }),
                ),
                for (final label in RecipeFilter.allergyLabels)
                  FilterChip(
                    key: ValueKey('food-allergy-$label'),
                    label: Text(context.l10n.allergen(label)),
                    selected: allergies.contains(label),
                    onSelected: (v) => setState(() {
                      noAllergies = false;
                      v ? allergies.add(label) : allergies.remove(label);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('food-custom-allergies'),
              controller: customAllergies,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: t(
                  'Dị ứng khác (cách nhau bằng dấu phẩy)',
                  'Other allergies (comma separated)',
                ),
              ),
              onChanged: (v) {
                if (v.trim().isNotEmpty && noAllergies) {
                  setState(() => noAllergies = false);
                }
              },
            ),
            input(
              'food-intolerances',
              intolerances,
              t('Không dung nạp (nếu có)', 'Intolerances (optional)'),
            ),
            Text(
              t(
                'Dữ liệu thiếu hoặc dị ứng chưa nhận diện sẽ chặn gợi ý. Thành phần không bảo đảm không nhiễm chéo; kiểm tra nhãn và nơi chế biến.',
                'Missing data or unrecognized allergies block suggestions. Ingredients do not guarantee absence of cross-contact; check labels and preparation.',
              ),
            ),
          ],
          if (step == 1) ...[
            DropdownButtonFormField<FoodDiet>(
              initialValue: diet,
              isExpanded: true,
              decoration: InputDecoration(labelText: t('Chế độ ăn', 'Diet')),
              items: [
                DropdownMenuItem(
                  value: FoodDiet.unrestricted,
                  child: Text(t('Không hạn chế', 'Unrestricted')),
                ),
                DropdownMenuItem(
                  value: FoodDiet.vegetarian,
                  child: Text(t('Ăn chay', 'Vegetarian')),
                ),
                DropdownMenuItem(
                  value: FoodDiet.vegan,
                  child: Text(t('Thuần chay', 'Vegan')),
                ),
              ],
              onChanged: (v) => setState(() => diet = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FoodGoal>(
              initialValue: goal,
              isExpanded: true,
              decoration: InputDecoration(labelText: t('Mục tiêu', 'Goal')),
              items: [
                DropdownMenuItem(
                  value: FoodGoal.maintain,
                  child: Text(t('Duy trì cân nặng', 'Maintain weight')),
                ),
                DropdownMenuItem(
                  value: FoodGoal.loseWeight,
                  child: Text(t('Giảm cân', 'Lose weight')),
                ),
                DropdownMenuItem(
                  value: FoodGoal.buildMuscle,
                  child: Text(t('Tăng cơ', 'Build muscle')),
                ),
              ],
              onChanged: (v) => setState(() => goal = v!),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                'Mục tiêu chỉ dùng xếp hạng khi có dinh dưỡng đáng tin cậy. Không tính nhu cầu calorie hay đưa ra chế độ điều trị.',
                'Goals affect ranking only with reliable nutrition. No calorie requirements or treatment plans are inferred.',
              ),
            ),
          ],
          if (step == 2) ...[
            Text(
              t(
                'Nhập tên nguyên liệu, cách nhau bằng dấu phẩy.',
                'Enter ingredient names, separated by commas.',
              ),
            ),
            input(
              'food-favorites',
              favorites,
              t('Nguyên liệu yêu thích', 'Favorite ingredients'),
            ),
            input(
              'food-dislikes',
              dislikes,
              t('Nguyên liệu không thích', 'Disliked ingredients'),
            ),
          ],
          if (step == 3) ...[
            input(
              'food-budget',
              budget,
              t(
                'Ngân sách mỗi ngày (VND, có thể để trống)',
                'Daily budget (VND, optional)',
              ),
              number: true,
            ),
            input(
              'food-minutes',
              minutes,
              t(
                'Thời gian tối đa mỗi bữa (phút, có thể để trống)',
                'Maximum minutes per meal (optional)',
              ),
              number: true,
            ),
            Text(
              t(
                'Ngân sách và thời gian là ưu tiên mềm. Thực đơn có thể vượt ưu tiên; ứng dụng sẽ ghi rõ.',
                'Budget and time are preferences. Menus may exceed them; the app will show this.',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: offset ?? 9999,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t('Múi giờ thực đơn', 'Menu time zone'),
              ),
              items: [
                DropdownMenuItem(
                  value: 9999,
                  child: Text(
                    t(
                      'Theo thiết bị (tự đổi giờ mùa hè)',
                      'Device (includes daylight saving)',
                    ),
                  ),
                ),
                for (final v in {
                  for (var v = -720; v <= 840; v += 15) v,
                  ?offset,
                }.toList()..sort())
                  DropdownMenuItem(
                    value: v,
                    child: Text(
                      'UTC${v < 0 ? '-' : '+'}${(v.abs() ~/ 60).toString().padLeft(2, '0')}:${(v.abs() % 60).toString().padLeft(2, '0')}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => offset = v == 9999 ? null : v),
            ),
            Text(
              t(
                'UTC là độ lệch cố định, không tự đổi giờ mùa hè.',
                'UTC offsets are fixed and do not adjust for daylight saving.',
              ),
            ),
          ],
          if (step == 4) ...[
            Text(
              t(
                'Chỉ ghi giới hạn đã được chuyên gia y tế chỉ định, nếu có. Không cần cung cấp bệnh sử.',
                'Record only restrictions prescribed by a healthcare professional, if any. No medical history is needed.',
              ),
            ),
            input(
              'food-medical-avoid',
              medicalAvoid,
              t(
                'Nguyên liệu phải tránh theo chỉ định',
                'Prescribed ingredient exclusions',
              ),
            ),
            input(
              'food-medical-note',
              medicalNote,
              t(
                'Chỉ định khác (tùy chọn)',
                'Other prescribed restrictions (optional)',
              ),
            ),
            Text(
              t(
                'Nội dung tự do không được chẩn đoán hay tự diễn giải. Khi có chỉ định khác, ứng dụng tạm dừng gợi ý vì chưa kiểm tra được giới hạn này. Giới hạn theo chất dinh dưỡng cần dữ liệu chuyên môn đã xác minh.',
                'Free text is never diagnosed or interpreted automatically. Other prescribed restrictions pause suggestions because they cannot yet be checked. Nutrient limits require verified professional data.',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                'Khách: lưu trên thiết bị. Tài khoản: lưu riêng trên Supabase; không gộp với hồ sơ khách.',
                'Guests: saved on this device. Accounts: saved privately in Supabase; guest data is not merged.',
              ),
            ),
          ],
          if (message != null)
            Text(message!, key: const ValueKey('food-form-error')),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('food-next'),
            onPressed: saving ? null : next,
            child: Text(
              saving
                  ? t('Đang lưu…', 'Saving…')
                  : step == 4
                  ? t('Lưu hồ sơ', 'Save preferences')
                  : t('Tiếp tục', 'Continue'),
            ),
          ),
          if (step > 0)
            TextButton(
              onPressed: saving
                  ? null
                  : () => setState(() {
                      step--;
                      message = null;
                    }),
              child: Text(t('Quay lại', 'Back')),
            ),
        ],
      ),
    );
  }
}
