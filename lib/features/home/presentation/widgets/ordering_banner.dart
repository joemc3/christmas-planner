import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/season_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/ribbon_card.dart';
import '../providers/home_data.dart';

/// The ordering-date card in its three states: before (ribboned evergreen),
/// on or after with gifts to order (ribboned cranberry, up to three gift
/// links), all ordered (quiet).
class OrderingBanner extends StatelessWidget {
  const OrderingBanner({super.key, required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final season = SeasonTheme.of(context);
    final date = formatDayMonth(data.startBy);

    switch (data.orderingState) {
      case HomeOrderingState.before:
        final days = data.daysToStart;
        return RibbonCard(
          color: season.heroSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                days == 1 ? '1 day from today' : '$days days from today',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: season.heroMuted,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                'Start ordering by $date.',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: season.onHero,
                ),
              ),
              const SizedBox(height: Space.md),
              Text(
                'Gifts arrive by 10 December with ${data.shippingDays} '
                'shipping days.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: season.heroMuted,
                ),
              ),
            ],
          ),
        );

      case HomeOrderingState.needsOrdering:
        final n = data.needingOrder.length;
        final past = -data.daysToStart;
        final shown = data.needingOrder.take(3).toList();
        final more = n - shown.length;
        return RibbonCard(
          color: season.alertSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                past == 0
                    ? 'Today is the ordering date'
                    : past == 1
                    ? '1 day past the ordering date'
                    : '$past days past the ordering date',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: season.alertMuted,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                n == 1
                    ? '1 gift still needs ordering.'
                    : '$n gifts still need ordering.',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: season.onAlert,
                ),
              ),
              const SizedBox(height: Space.md),
              for (final item in shown)
                InkWell(
                  onTap: () => context.go(
                    '/gifts/${item.recipient.id}/gift/${item.gift.id}',
                  ),
                  borderRadius: BorderRadius.circular(Radii.field),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: season.onAlert,
                              ),
                              children: [
                                TextSpan(
                                  text: item.gift.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' · ${item.recipient.name}',
                                  style: TextStyle(color: season.alertMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: season.alertMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              if (more > 0)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: season.onAlert),
                  onPressed: () => context.go('/gifts'),
                  child: Text('and $more more'),
                ),
            ],
          ),
        );

      case HomeOrderingState.allOrdered:
        return Container(
          padding: const EdgeInsets.all(Space.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(Radii.hero),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.hasGifts
                    ? 'Every gift is ordered.'
                    : 'Nothing to order yet.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: Space.xs),
              Text(
                'The ordering date was $date.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );

      case HomeOrderingState.readOnly:
        return const SizedBox.shrink();
    }
  }
}
