import 'package:flutter/material.dart';

import '../../core/domain/statuses.dart';
import '../../core/theme/app_theme.dart';

class StepperCell {
  const StepperCell({
    required this.icon,
    required this.label,
    required this.fill,
    required this.onFill,
  });

  final IconData icon;
  final String label;
  final Color fill;
  final Color onFill;
}

/// A bordered pill of 44 px cells, one per state. Cells up to the reached
/// one fill with their state's colour. Tapping a later cell moves forward;
/// earlier cells do nothing on the row (moving back is done in the form).
class StatusStepperRow extends StatelessWidget {
  const StatusStepperRow({
    super.key,
    required this.cells,
    required this.reached,
    required this.onForward,
    this.enabled = true,
    this.lateFirstCell = false,
  });

  final List<StepperCell> cells;
  final int reached;
  final ValueChanged<int>? onForward;
  final bool enabled;

  /// On or after the ordering date, a To Buy gift shows its first cell in
  /// the error container.
  final bool lateFirstCell;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(Radii.stepper),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.stepper - 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < cells.length; i++)
              _Cell(
                cell: cells[i],
                filled: i <= reached,
                late: lateFirstCell && i == 0 && reached == 0,
                current: i == reached,
                onTap: enabled && onForward != null && i > reached
                    ? () => onForward!(i)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.cell,
    required this.filled,
    required this.late,
    required this.current,
    required this.onTap,
  });

  final StepperCell cell;
  final bool filled;
  final bool late;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = late
        ? scheme.errorContainer
        : filled
        ? cell.fill
        : Colors.transparent;
    final fg = late
        ? scheme.onErrorContainer
        : filled
        ? cell.onFill
        : scheme.onSurfaceVariant;
    return Semantics(
      button: onTap != null,
      selected: current,
      label: onTap == null ? cell.label : 'Mark ${cell.label}',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Motion.state,
            width: 44,
            height: 44,
            color: bg,
            child: Icon(cell.icon, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}

List<StepperCell> giftCells(ColorScheme scheme) => [
  StepperCell(
    icon: Icons.sell_rounded,
    label: 'To Buy',
    fill: scheme.secondaryContainer,
    onFill: scheme.onSecondaryContainer,
  ),
  StepperCell(
    icon: Icons.local_shipping_rounded,
    label: 'Ordered',
    fill: scheme.tertiaryContainer,
    onFill: scheme.onTertiaryContainer,
  ),
  StepperCell(
    icon: Icons.check_rounded,
    label: 'Purchased',
    fill: scheme.primary,
    onFill: scheme.onPrimary,
  ),
];

List<StepperCell> mealItemCells(ColorScheme scheme) => [
  StepperCell(
    icon: Icons.sell_rounded,
    label: 'To Buy',
    fill: scheme.secondaryContainer,
    onFill: scheme.onSecondaryContainer,
  ),
  StepperCell(
    icon: Icons.check_rounded,
    label: 'Purchased',
    fill: scheme.primary,
    onFill: scheme.onPrimary,
  ),
];

/// The three-cell row stepper for a gift.
class GiftStepperRow extends StatelessWidget {
  const GiftStepperRow({
    super.key,
    required this.status,
    required this.onForward,
    this.enabled = true,
    this.late = false,
  });

  final GiftStatus status;
  final ValueChanged<GiftStatus>? onForward;
  final bool enabled;
  final bool late;

  @override
  Widget build(BuildContext context) => StatusStepperRow(
    cells: giftCells(Theme.of(context).colorScheme),
    reached: status.index,
    enabled: enabled,
    lateFirstCell: late,
    onForward: onForward == null
        ? null
        : (i) => onForward!(GiftStatus.values[i]),
  );
}

/// The two-cell row stepper for a menu item.
class MealItemStepperRow extends StatelessWidget {
  const MealItemStepperRow({
    super.key,
    required this.status,
    required this.onForward,
    this.enabled = true,
  });

  final MealItemStatus status;
  final ValueChanged<MealItemStatus>? onForward;
  final bool enabled;

  @override
  Widget build(BuildContext context) => StatusStepperRow(
    cells: mealItemCells(Theme.of(context).colorScheme),
    reached: status.index,
    enabled: enabled,
    onForward: onForward == null
        ? null
        : (i) => onForward!(MealItemStatus.values[i]),
  );
}

/// The form control: any state selectable, icon and label per segment.
class GiftStatusSegmented extends StatelessWidget {
  const GiftStatusSegmented({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final GiftStatus value;
  final ValueChanged<GiftStatus> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<GiftStatus>(
    segments: const [
      ButtonSegment(
        value: GiftStatus.toBuy,
        icon: Icon(Icons.sell_rounded),
        label: Text('To Buy'),
      ),
      ButtonSegment(
        value: GiftStatus.ordered,
        icon: Icon(Icons.local_shipping_rounded),
        label: Text('Ordered'),
      ),
      ButtonSegment(
        value: GiftStatus.purchased,
        icon: Icon(Icons.check_rounded),
        label: Text('Purchased'),
      ),
    ],
    selected: {value},
    showSelectedIcon: false,
    onSelectionChanged: (s) => onChanged(s.first),
  );
}

class MealItemStatusSegmented extends StatelessWidget {
  const MealItemStatusSegmented({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MealItemStatus value;
  final ValueChanged<MealItemStatus> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<MealItemStatus>(
    segments: const [
      ButtonSegment(
        value: MealItemStatus.toBuy,
        icon: Icon(Icons.sell_rounded),
        label: Text('To Buy'),
      ),
      ButtonSegment(
        value: MealItemStatus.purchased,
        icon: Icon(Icons.check_rounded),
        label: Text('Purchased'),
      ),
    ],
    selected: {value},
    showSelectedIcon: false,
    onSelectionChanged: (s) => onChanged(s.first),
  );
}
