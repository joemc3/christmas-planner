import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_data.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/recipient_form.dart';
import '../widgets/rows.dart';
import 'recipient_screen.dart';

/// Which person the expanded (list plus detail) layout shows on the right.
final selectedRecipientIdProvider = NotifierProvider<_Selected, String?>(
  _Selected.new,
);

class _Selected extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

/// B2: the people.
class GiftsScreen extends ConsumerWidget {
  const GiftsScreen({super.key});

  Future<void> _addPerson(BuildContext context, WidgetRef ref) async {
    final plan = ref.read(selectedPlanProvider).asData?.value;
    if (plan == null) return;
    final currency =
        ref.read(userProfileProvider).asData?.value?.currency ?? 'USD';
    await showRecipientForm(context, planId: plan.id, currency: currency);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipients = ref.watch(recipientsProvider);
    final readOnly = ref.watch(readOnlyProvider);
    final expanded = WindowSize.of(context).isExpanded;

    final list = Scaffold(
      appBar: AppBar(
        title: const Text('Gifts'),
        actions: [
          if (expanded && !readOnly)
            Padding(
              padding: const EdgeInsets.only(right: Space.lg),
              child: FilledButton.icon(
                onPressed: () => _addPerson(context, ref),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add person'),
              ),
            ),
        ],
      ),
      floatingActionButton: expanded || readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addPerson(context, ref),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add person'),
            ),
      body: asyncList(
        recipients,
        errorMessage: "Couldn't load your people.",
        onRetry: () => ref.invalidate(ensuredPlanProvider),
        data: (people) => people.isEmpty
            ? Center(
                child: EmptyState(
                  message: 'Add the first person you are buying for.',
                  actionLabel: readOnly ? null : 'Add person',
                  actionIcon: Icons.person_add_rounded,
                  onAction: readOnly ? null : () => _addPerson(context, ref),
                ),
              )
            : _PeopleList(people: people, expanded: expanded),
      ),
    );

    if (!expanded) return list;

    final selectedId = ref.watch(selectedRecipientIdProvider);
    return Row(
      children: [
        SizedBox(width: 420, child: list),
        const VerticalDivider(),
        Expanded(
          child: selectedId == null
              ? const Center(child: Text('Choose a person'))
              : RecipientScreen(recipientId: selectedId, embedded: true),
        ),
      ],
    );
  }
}

class _PeopleList extends ConsumerWidget {
  const _PeopleList({required this.people, required this.expanded});
  final List<RecipientModel> people;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final home = ref.watch(homeDataProvider).asData?.value;
    final toOrder = home == null
        ? const <String, int>{}
        : needingOrderByRecipient(home);
    final selectedId = ref.watch(selectedRecipientIdProvider);

    final total = home?.giftMoney;
    final needing = home?.needingOrder ?? const [];
    final needingNames = {for (final n in needing) n.recipient.name}.join(', ');

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (total != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
            child: GiftsTotalLine(money: total, currency: currency),
          ),
        if (needing.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    '${needing.length} ${needing.length == 1 ? 'gift needs' : 'gifts need'} '
                    'ordering: $needingNames',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        for (final r in people) ...[
          RecipientRow(
            recipient: r,
            money: ref.watch(recipientMoneyProvider(r)),
            currency: currency,
            toOrder: toOrder[r.id] ?? 0,
            selected: expanded && selectedId == r.id,
            onTap: () {
              if (expanded) {
                ref.read(selectedRecipientIdProvider.notifier).select(r.id);
              } else {
                context.go('/gifts/${r.id}');
              }
            },
          ),
          const Divider(),
        ],
      ],
    );
  }
}
