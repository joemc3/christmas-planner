import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/money_triple_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../shared/widgets/tag.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../providers/home_data.dart';
import '../widgets/budget_sheet.dart';
import '../widgets/ordering_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(homeDataProvider);
    final year =
        ref.watch(selectedYearProvider) ?? ref.watch(currentYearProvider);
    final readOnly = ref.watch(readOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Christmas $year'),
        actions: [
          if (readOnly)
            const Padding(
              padding: EdgeInsets.only(right: Space.lg),
              child: Tag(label: 'Read only', icon: Icons.lock_rounded),
            )
          else
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: ReadableColumn(
        child: asyncList(
          data,
          errorMessage: "Couldn't load your plan.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          data: (d) => _HomeBody(data: d),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final gm = data.giftMoney;
    final mm = data.mealMoney;

    String giftsTrailing() {
      if (!data.hasRecipients) return 'No one yet';
      return '${gm.purchasedCount} of ${gm.plannedCount} bought';
    }

    String mealsTrailing() {
      if (data.mealItemCount == 0) return 'No items yet';
      return '${mm.purchasedCount} of ${mm.plannedCount} bought';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xxxl),
      children: [
        if (data.readOnly) ...[
          Text("Last year's plan", style: theme.textTheme.headlineSmall),
          const SizedBox(height: Space.sm),
          Text(
            '${gm.plannedCount} ${gm.plannedCount == 1 ? 'gift' : 'gifts'} for '
            '${data.recipientCount} ${data.recipientCount == 1 ? 'person' : 'people'}.',
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            'The ordering date was ${formatDayMonthYear(data.startBy)}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: () =>
                  ref.read(selectedYearProvider.notifier).select(null),
              child: Text('Back to ${ref.read(currentYearProvider)}'),
            ),
          ),
        ] else ...[
          OrderingBanner(data: data),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Icon(
                Icons.park_rounded,
                size: 18,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: Space.sm),
              Text(
                '${data.daysToChristmas} days to Christmas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        SectionHeader(
          title: 'Gifts',
          trailing: giftsTrailing(),
          action: IconButton(
            tooltip: 'Open Gifts',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => context.go('/gifts'),
          ),
        ),
        if (!gm.hasBudget && !data.readOnly)
          MoneyTripleView(
            money: gm,
            currency: currency,
            size: MoneySize.home,
            unsetLabel: 'No gift budget yet',
            setLabel: 'Set budget',
            onSetBudget: () =>
                showBudgetSheet(context, ref, data.plan, currency),
          )
        else
          MoneyTripleView(
            money: gm,
            currency: currency,
            size: MoneySize.home,
            onEditBudget: data.readOnly
                ? null
                : () => showBudgetSheet(context, ref, data.plan, currency),
          ),
        if (!data.hasRecipients && !data.readOnly) ...[
          const SizedBox(height: Space.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => context.go('/gifts'),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add a person'),
            ),
          ),
        ],
        SectionHeader(
          title: 'Meals',
          trailing: mealsTrailing(),
          action: IconButton(
            tooltip: 'Open Meals',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => context.go('/meals'),
          ),
        ),
        if (!mm.hasBudget && !data.readOnly)
          MoneyTripleView(
            money: mm,
            currency: currency,
            size: MoneySize.home,
            unsetLabel: 'No meal budgets yet',
            setLabel: 'Set budgets',
            onSetBudget: () => context.go('/meals'),
          )
        else
          MoneyTripleView(
            money: mm,
            currency: currency,
            size: MoneySize.home,
            budgetLabel: 'Eve and Day',
          ),
        if (!data.readOnly && data.previousYears.isNotEmpty) ...[
          const SizedBox(height: Space.xxl),
          for (final y in data.previousYears)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(selectedYearProvider.notifier).select(y),
                icon: const Icon(Icons.history_rounded),
                label: Text('Christmas $y, read only'),
              ),
            ),
        ],
      ],
    );
  }
}
