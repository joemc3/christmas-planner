import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gifts/presentation/providers/gift_providers.dart';
import '../../../meals/presentation/providers/meal_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final giftsStream = ref.watch(giftsStreamProvider);
    final mealsStream = ref.watch(mealsStreamProvider);
    final giftStats = ref.watch(giftBudgetStatsProvider);

    final daysUntilChristmas = AppDateUtils.daysUntilChristmas();
    final daysUntilDeadline = AppDateUtils.daysUntilPreparationDeadline();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(giftsStreamProvider);
          ref.invalidate(mealsStreamProvider);
          ref.invalidate(giftBudgetStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              userProfile.when(
                data: (profile) => _WelcomeCard(
                  name: profile?.fullName ?? 'User',
                  daysUntilChristmas: daysUntilChristmas,
                ),
                loading: () => const _WelcomeCard(
                  name: 'User',
                  daysUntilChristmas: 0,
                ),
                error: (_, __) => const _WelcomeCard(
                  name: 'User',
                  daysUntilChristmas: 0,
                ),
              ),
              const SizedBox(height: 24),

              // Countdown Cards
              Row(
                children: [
                  Expanded(
                    child: _CountdownCard(
                      title: 'Days Until Christmas',
                      count: daysUntilChristmas,
                      icon: Icons.celebration,
                      color: AppTheme.christmasRed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CountdownCard(
                      title: 'Days Until Deadline',
                      count: daysUntilDeadline,
                      icon: Icons.alarm,
                      color: AppTheme.christmasGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Budget Overview
              giftStats.when(
                data: (stats) => _BudgetOverviewCard(
                  totalSpent: stats['totalSpent'] ?? 0.0,
                  totalPlanned: stats['totalPlanned'] ?? 0.0,
                ),
                loading: () => const _BudgetOverviewCard(
                  totalSpent: 0.0,
                  totalPlanned: 0.0,
                ),
                error: (_, __) => const _BudgetOverviewCard(
                  totalSpent: 0.0,
                  totalPlanned: 0.0,
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _QuickActionsGrid(
                onGiftsTap: () => context.push('/gifts'),
                onMealsTap: () => context.push('/meals'),
                onBudgetTap: () => context.push('/budget'),
                onCalendarTap: () => context.push('/calendar'),
                onShoppingTap: () => context.push('/shopping'),
              ),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              giftsStream.when(
                data: (gifts) => _RecentGiftsList(
                  gifts: gifts.take(5).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Failed to load recent gifts'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/gifts');
              break;
            case 2:
              context.push('/meals');
              break;
            case 3:
              context.push('/shopping');
              break;
            case 4:
              context.push('/calendar');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  final int daysUntilChristmas;

  const _WelcomeCard({
    required this.name,
    required this.daysUntilChristmas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.christmasGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            daysUntilChristmas > 0
                ? 'Christmas is $daysUntilChristmas days away!'
                : 'Merry Christmas!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _CountdownCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  final double totalSpent;
  final double totalPlanned;

  const _BudgetOverviewCard({
    required this.totalSpent,
    required this.totalPlanned,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalPlanned > 0 ? (totalSpent / totalPlanned) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gift Budget',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      AppDateUtils.formatCurrency(totalSpent),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.christmasRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Planned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      AppDateUtils.formatCurrency(totalPlanned),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppTheme.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 90 ? AppTheme.error : AppTheme.christmasGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}% of budget used',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onGiftsTap;
  final VoidCallback onMealsTap;
  final VoidCallback onBudgetTap;
  final VoidCallback onCalendarTap;
  final VoidCallback onShoppingTap;

  const _QuickActionsGrid({
    required this.onGiftsTap,
    required this.onMealsTap,
    required this.onBudgetTap,
    required this.onCalendarTap,
    required this.onShoppingTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _QuickActionCard(
          title: 'Gifts',
          icon: Icons.card_giftcard,
          color: AppTheme.christmasRed,
          onTap: onGiftsTap,
        ),
        _QuickActionCard(
          title: 'Meals',
          icon: Icons.restaurant,
          color: AppTheme.christmasGreen,
          onTap: onMealsTap,
        ),
        _QuickActionCard(
          title: 'Budget',
          icon: Icons.account_balance_wallet,
          color: AppTheme.christmasGold,
          onTap: onBudgetTap,
        ),
        _QuickActionCard(
          title: 'Calendar',
          icon: Icons.calendar_today,
          color: AppTheme.info,
          onTap: onCalendarTap,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentGiftsList extends StatelessWidget {
  final List gifts;

  const _RecentGiftsList({required this.gifts});

  @override
  Widget build(BuildContext context) {
    if (gifts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.card_giftcard, size: 48, color: AppTheme.lightGrey),
              const SizedBox(height: 16),
              Text(
                'No gifts yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('Start adding gifts to your list'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gifts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Text(gift.name ?? 'Gift'),
            subtitle: Text(AppDateUtils.formatCurrency(gift.price ?? 0.0)),
            trailing: Chip(
              label: Text(gift.status?.toString() ?? 'To Buy'),
              backgroundColor: AppTheme.lightGrey,
            ),
          );
        },
      ),
    );
  }
}
