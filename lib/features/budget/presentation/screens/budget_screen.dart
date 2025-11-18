import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/family_budget_model.dart';
import '../../data/repositories/budget_repository.dart';

// Providers
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final currentBudgetProvider = FutureProvider<FamilyBudgetModel?>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.getCurrentYearBudget();
});

final budgetStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.calculateOverallBudgetStats();
});

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(currentBudgetProvider);
    final statsAsync = ref.watch(budgetStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditBudgetDialog(context, ref, budgetAsync.valueOrNull),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentBudgetProvider);
          ref.invalidate(budgetStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Budget Overview
              budgetAsync.when(
                data: (budget) => statsAsync.when(
                  data: (stats) => _BudgetOverviewCard(
                    budget: budget,
                    stats: stats,
                  ),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _ErrorCard(message: 'Failed to load stats'),
                ),
                loading: () => const _LoadingCard(),
                error: (_, __) => const _ErrorCard(message: 'Failed to load budget'),
              ),
              const SizedBox(height: 24),

              // Spending Breakdown
              const SectionHeader(title: 'Spending Breakdown'),
              const SizedBox(height: 16),
              statsAsync.when(
                data: (stats) => budgetAsync.when(
                  data: (budget) => _SpendingBreakdownCard(
                    stats: stats,
                    budget: budget,
                  ),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _ErrorCard(message: 'Failed to load budget'),
                ),
                loading: () => const _LoadingCard(),
                error: (_, __) => const _ErrorCard(message: 'Failed to load stats'),
              ),
              const SizedBox(height: 24),

              // Category Details
              const SectionHeader(title: 'Category Details'),
              const SizedBox(height: 16),
              budgetAsync.when(
                data: (budget) => statsAsync.when(
                  data: (stats) => _CategoryDetailsGrid(
                    budget: budget,
                    stats: stats,
                  ),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _ErrorCard(message: 'Failed to load stats'),
                ),
                loading: () => const _LoadingCard(),
                error: (_, __) => const _ErrorCard(message: 'Failed to load budget'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, FamilyBudgetModel? budget) {
    if (budget == null) return;

    final giftController = TextEditingController(text: budget.giftBudgetTotal.toStringAsFixed(0));
    final mealEveController = TextEditingController(text: budget.mealBudgetEve.toStringAsFixed(0));
    final mealDayController = TextEditingController(text: budget.mealBudgetDay.toStringAsFixed(0));
    final decorationsController = TextEditingController(text: (budget.decorationsBudget ?? 0).toStringAsFixed(0));
    final activitiesController = TextEditingController(text: (budget.activitiesBudget ?? 0).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Budget',
          style: GoogleFonts.fraunces(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BudgetTextField(
                controller: giftController,
                label: 'Gifts Budget',
                icon: Icons.card_giftcard,
              ),
              const SizedBox(height: 16),
              _BudgetTextField(
                controller: mealEveController,
                label: 'Christmas Eve Meal',
                icon: Icons.restaurant,
              ),
              const SizedBox(height: 16),
              _BudgetTextField(
                controller: mealDayController,
                label: 'Christmas Day Meal',
                icon: Icons.restaurant_menu,
              ),
              const SizedBox(height: 16),
              _BudgetTextField(
                controller: decorationsController,
                label: 'Decorations',
                icon: Icons.park,
              ),
              const SizedBox(height: 16),
              _BudgetTextField(
                controller: activitiesController,
                label: 'Activities',
                icon: Icons.celebration,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedBudget = budget.copyWith(
                giftBudgetTotal: double.tryParse(giftController.text) ?? budget.giftBudgetTotal,
                mealBudgetEve: double.tryParse(mealEveController.text) ?? budget.mealBudgetEve,
                mealBudgetDay: double.tryParse(mealDayController.text) ?? budget.mealBudgetDay,
                decorationsBudget: double.tryParse(decorationsController.text),
                activitiesBudget: double.tryParse(activitiesController.text),
              );

              try {
                final repository = ref.read(budgetRepositoryProvider);
                await repository.updateBudget(updatedBudget);
                ref.invalidate(currentBudgetProvider);
                ref.invalidate(budgetStatsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update budget: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _BudgetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _BudgetTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: FrostedHearthColors.ember),
        prefixText: '\$ ',
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  final FamilyBudgetModel? budget;
  final Map<String, dynamic> stats;

  const _BudgetOverviewCard({
    required this.budget,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final totalBudget = budget?.totalBudget ?? 0.0;
    final totalSpent = (stats['totalSpent'] as double?) ?? 0.0;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: FrostedHearthGradients.winterNight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BUDGET ${budget?.year ?? DateTime.now().year}',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: FrostedHearthColors.iceAccent,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: remaining >= 0
                      ? FrostedHearthColors.success.withOpacity(0.2)
                      : FrostedHearthColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  remaining >= 0 ? 'On Track' : 'Over Budget',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 12,
                    color: remaining >= 0
                        ? FrostedHearthColors.success
                        : FrostedHearthColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.formatCurrency(totalSpent),
                      style: GoogleFonts.dmMono(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: FrostedHearthColors.frostGold,
                      ),
                    ),
                    Text(
                      'of ${AppDateUtils.formatCurrency(totalBudget)}',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        color: FrostedHearthColors.frostGold.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              EmberArcProgress(
                value: percentage,
                size: 80,
                centerText: '${(percentage * 100).toInt()}%',
                label: 'used',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Remaining budget indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: FrostedHearthColors.spruceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 14,
                    color: FrostedHearthColors.frostGold.withOpacity(0.8),
                  ),
                ),
                Text(
                  AppDateUtils.formatCurrency(remaining.abs()),
                  style: GoogleFonts.dmMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: remaining >= 0
                        ? FrostedHearthColors.success
                        : FrostedHearthColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final FamilyBudgetModel? budget;

  const _SpendingBreakdownCard({
    required this.stats,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{
      'Gifts': (stats['giftSpent'] as double?) ?? 0.0,
      'Meals': (stats['mealSpent'] as double?) ?? 0.0,
      'Decorations': (stats['decorationsSpent'] as double?) ?? 0.0,
      'Activities': (stats['activitiesSpent'] as double?) ?? 0.0,
      'Other': (stats['miscellaneousSpent'] as double?) ?? 0.0,
    };

    // Remove zero values
    categories.removeWhere((key, value) => value == 0);

    final total = categories.values.fold<double>(0, (a, b) => a + b);

    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where your money went',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          if (total > 0)
            BudgetStackedBar(
              categories: categories,
              total: total,
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 48,
                      color: FrostedHearthColors.inkLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No spending recorded yet',
                      style: GoogleFonts.sourceSerif4(
                        color: FrostedHearthColors.inkLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryDetailsGrid extends StatelessWidget {
  final FamilyBudgetModel? budget;
  final Map<String, dynamic> stats;

  const _CategoryDetailsGrid({
    required this.budget,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (budget == null) return const SizedBox.shrink();

    final categories = [
      _CategoryData(
        name: 'Gifts',
        icon: Icons.card_giftcard,
        budget: budget!.giftBudgetTotal,
        spent: (stats['giftSpent'] as double?) ?? 0.0,
        color: FrostedHearthColors.ember,
      ),
      _CategoryData(
        name: 'Meals',
        icon: Icons.restaurant,
        budget: budget!.totalMealBudget,
        spent: (stats['mealSpent'] as double?) ?? 0.0,
        color: FrostedHearthColors.winterBerry,
      ),
      _CategoryData(
        name: 'Decorations',
        icon: Icons.park,
        budget: budget!.decorationsBudget ?? 0,
        spent: (stats['decorationsSpent'] as double?) ?? 0.0,
        color: FrostedHearthColors.spruce,
      ),
      _CategoryData(
        name: 'Activities',
        icon: Icons.celebration,
        budget: budget!.activitiesBudget ?? 0,
        spent: (stats['activitiesSpent'] as double?) ?? 0.0,
        color: FrostedHearthColors.info,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(data: category);
      },
    );
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  final double budget;
  final double spent;
  final Color color;

  _CategoryData({
    required this.name,
    required this.icon,
    required this.budget,
    required this.spent,
    required this.color,
  });

  double get percentage => budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
  double get remaining => budget - spent;
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;

  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
              const Spacer(),
              Text(
                '${(data.percentage * 100).toInt()}%',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: data.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.name,
            style: GoogleFonts.sourceSerif4(
              fontSize: 12,
              color: FrostedHearthColors.inkLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppDateUtils.formatCurrency(data.spent),
            style: GoogleFonts.dmMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FrostedHearthColors.inkDark,
            ),
          ),
          const SizedBox(height: 8),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.percentage,
              backgroundColor: FrostedHearthColors.parchmentWarm,
              valueColor: AlwaysStoppedAnimation(data.color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${AppDateUtils.formatCurrency(data.budget)}',
            style: GoogleFonts.sourceSerif4(
              fontSize: 10,
              color: FrostedHearthColors.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: FrostedHearthColors.error),
              const SizedBox(height: 16),
              Text(message, style: TextStyle(color: FrostedHearthColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
