import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../screens/recipes_screen.dart';
import '../theme/steady_spacing.dart';
import 'daily_menu_engine.dart';
import 'food_catalog.dart';
import 'food_profile.dart';
import 'food_questionnaire.dart';
import 'food_strings.dart';
import 'menu_controller.dart';

class DailyMenuScreen extends StatelessWidget {
  const DailyMenuScreen({super.key, required this.controller});
  final DailyMenuController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      String t(String vi, String en) => foodText(context, vi, en);
      final p = controller.profile;
      final day = controller.menu;
      final nutrition = DailyMenuEngine.dailyNutrition(day);
      final completeCost = day.every((r) => r?.estimatedCost != null);
      final cost = day.fold<int>(0, (sum, r) => sum + (r?.estimatedCost ?? 0));
      return Scaffold(
        appBar: AppBar(title: Text(t('Thực đơn hôm nay', 'Today’s menu'))),
        body: ListView(
          key: const ValueKey('daily-menu'),
          padding: SteadySpacing.screen,
          children: [
            if (controller.busy) const LinearProgressIndicator(),
            if (controller.error != null) ...[
              Text(
                t(
                  'Chưa tải/lưu được thực đơn. Kiểm tra kết nối, migration backend hoặc dữ liệu vừa thay đổi trên thiết bị khác. Thực đơn cũ đang được ẩn.',
                  'Could not load/save the menu. Check connection, backend migration, or changes from another device. The previous menu is hidden.',
                ),
                key: const ValueKey('daily-menu-error'),
              ),
              OutlinedButton(
                onPressed: controller.busy ? null : controller.refresh,
                child: Text(t('Tải lại', 'Reload')),
              ),
            ],
            if (!controller.busy &&
                controller.loaded &&
                controller.error == null) ...[
              FilledButton.icon(
                key: const ValueKey('food-profile-edit'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => FoodQuestionnaire(controller: controller),
                  ),
                ),
                icon: const Icon(Icons.tune),
                label: Text(
                  p == null
                      ? t('Thiết lập thực đơn', 'Set up my menu')
                      : t('Chỉnh hồ sơ ăn uống', 'Edit food preferences'),
                ),
              ),
              if (p == null)
                Text(
                  t(
                    'Trả lời 5 bước ngắn để nhận một món cho mỗi bữa sáng, trưa và tối.',
                    'Complete 5 short steps to receive one breakfast, lunch and dinner.',
                  ),
                ),
              if (p != null) ...[
                Text(
                  '${controller.localDate} · ${p.utcOffsetMinutes == null ? t('Múi giờ thiết bị', 'Device time zone') : 'UTC ${p.utcOffsetMinutes! / 60}'}',
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    'Công thức và chi phí hiện tại là dữ liệu mẫu. Thông tin thành phần không bảo đảm không nhiễm chéo; kiểm tra nhãn, gia vị, nước sốt và nơi chế biến.',
                    'Current recipes and costs are sample data. Ingredient information does not guarantee absence of cross-contact; check labels, seasonings, sauces and preparation.',
                  ),
                ),
                if (p.medicalNote.trim().isNotEmpty)
                  Text(
                    t(
                      'Chưa thể kiểm tra chỉ định y tế trong nội dung tự do. Cần thực đơn được chuyên gia xác nhận.',
                      'Free-text medical restrictions cannot be checked. A professionally reviewed plan is needed.',
                    ),
                  ),
                if (day.any((r) => r == null))
                  Text(
                    t(
                      'Chưa đủ món có dữ liệu phù hợp với giới hạn bắt buộc. Giữ nguyên dị ứng và kiêng ăn. Có thể chỉnh khẩu vị, ngân sách hoặc thời gian; nếu thiếu dữ liệu, cần bổ sung công thức đã xác minh.',
                      'Not enough recipes with data to meet mandatory restrictions. Allergy and diet limits remain active. You may change preferences, budget or time; missing evidence requires verified recipes.',
                    ),
                    key: const ValueKey('daily-menu-shortage'),
                  ),
                for (var slot = 0; slot < 3; slot++)
                  _mealCard(context, slot, day[slot], p),
                if (completeCost)
                  Text(
                    '${t('Tổng chi phí mẫu/ngày', 'Total sample daily cost')}: ${context.l10n.money(cost)}',
                  ),
                if (completeCost &&
                    p.dailyBudget != null &&
                    cost > p.dailyBudget!)
                  Text(
                    t(
                      'Vượt ngân sách ưu tiên. Bạn có thể đổi món hoặc chỉnh ngân sách.',
                      'Above your preferred budget. You can swap meals or edit your budget.',
                    ),
                  ),
                Text(
                  nutrition == null
                      ? t(
                          'Chưa đủ dữ liệu dinh dưỡng đáng tin cậy để tính tổng ngày hoặc đánh giá mục tiêu.',
                          'Insufficient reliable nutrition to total the day or assess your goal.',
                        )
                      : '${t('Tổng ngày', 'Daily total')}: ${nutrition.kcal.round()} kcal · ${nutrition.protein.round()} g protein · ${nutrition.carbs.round()} g carbs · ${nutrition.fat.round()} g fat',
                ),
                if (nutrition != null)
                  Text(
                    t(
                      'Tổng này không xác nhận đạt mục tiêu cá nhân.',
                      'This total does not confirm that your personal goal is met.',
                    ),
                  ),
              ],
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: Text(t('Công thức tham khảo', 'Recipe catalogue')),
                    ),
                    body: const RecipesScreen(),
                  ),
                ),
              ),
              child: Text(
                t('Xem kho công thức tham khảo', 'Browse recipe catalogue'),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _mealCard(
    BuildContext context,
    int slot,
    FoodRecipe? recipe,
    FoodProfile p,
  ) {
    String t(String vi, String en) => foodText(context, vi, en);
    final reasons = <String>[];
    if (recipe != null) {
      reasons.add(
        t(
          'Phù hợp bữa ${dailySlots[slot].toLowerCase()}',
          'Listed for ${context.l10n.mealSlot(dailySlots[slot]).toLowerCase()}',
        ),
      );
      if (p.favorites.any(
        (f) => recipe.ingredientNames.any(
          (i) => FoodNames.matchesPreference(f, i),
        ),
      )) {
        reasons.add(
          t('có nguyên liệu yêu thích', 'includes a favorite ingredient'),
        );
      }
      if (p.maxMinutes != null &&
          recipe.preparationMinutes != null &&
          recipe.preparationMinutes! <= p.maxMinutes!) {
        reasons.add(
          t('trong thời gian ưu tiên', 'within preferred cooking time'),
        );
      }
      if (recipe.nutrition?.usable == true && p.goal == FoodGoal.buildMuscle) {
        reasons.add(
          t(
            'ưu tiên protein theo dữ liệu dinh dưỡng',
            'protein considered from nutrition data',
          ),
        );
      }
    }
    Future<void> swap({bool dislike = false}) async {
      final success = await controller.swap(slot, dislike: dislike);
      if (!success && context.mounted && controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t(
                'Chưa có món thay thế phù hợp. Giới hạn bắt buộc được giữ nguyên.',
                'No suitable alternative. Mandatory restrictions remain active.',
              ),
            ),
          ),
        );
      }
    }

    return Card(
      key: ValueKey('daily-slot-$slot'),
      child: Padding(
        padding: SteadySpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.mealSlot(dailySlots[slot]),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (recipe == null)
              Text(t('Chưa có món phù hợp.', 'No suitable meal available.')),
            if (recipe != null) ...[
              if (recipe.imageUrl != null)
                Image.network(
                  recipe.imageUrl!,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              Text(
                context.l10n.mealName(recipe.meal),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${t('Khẩu phần công thức', 'Recipe servings')}: ${recipe.servings}${recipe.sample ? t(' · Dữ liệu mẫu', ' · Sample data') : ''}',
              ),
              if (recipe.preparationMinutes != null)
                Text(
                  '${recipe.preparationMinutes} ${t('phút (ước tính)', 'min (estimated)')}',
                ),
              if (p.maxMinutes != null &&
                  recipe.preparationMinutes != null &&
                  recipe.preparationMinutes! > p.maxMinutes!)
                Text(
                  t(
                    'Vượt thời gian ưu tiên.',
                    'Above your preferred cooking time.',
                  ),
                ),
              if (recipe.estimatedCost != null)
                Text(
                  '${t('Ước tính', 'Estimated')}: ${context.l10n.money(recipe.estimatedCost!)}',
                ),
              if (recipe.nutrition?.usable == true)
                Text(
                  '${recipe.nutrition!.kcal.round()} kcal · ${recipe.nutrition!.protein.round()} g protein · ${recipe.nutrition!.carbs.round()} g carbs · ${recipe.nutrition!.fat.round()} g fat\n${t('Nguồn', 'Source')}: ${recipe.nutrition!.source}',
                ),
              Text(reasons.join(' · ')),
              Text(
                recipe.auditable
                    ? t(
                        'Đã có dữ liệu thành phần để đối chiếu; không chứng nhận an toàn dị ứng.',
                        'Ingredient data available for checks; not an allergy safety certification.',
                      )
                    : t(
                        'Thành phần chưa xác minh đầy đủ.',
                        'Ingredient information is unverified.',
                      ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(meal: recipe.meal),
                  ),
                ),
                child: Text(
                  t('Nguyên liệu và cách nấu', 'Ingredients and preparation'),
                ),
              ),
            ],
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  key: ValueKey('daily-swap-$slot'),
                  onPressed: controller.busy ? null : swap,
                  child: Text(t('Đổi món', 'Swap meal')),
                ),
                if (recipe != null)
                  TextButton(
                    key: ValueKey('daily-dislike-$slot'),
                    onPressed: controller.busy
                        ? null
                        : () => swap(dislike: true),
                    child: Text(
                      t('Không thích món này', 'I dislike this meal'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
