import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../../../../shared/widgets/status_stepper.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';

/// Guests and budget, edited together.
Future<MealModel?> showMealForm(
  BuildContext context, {
  required MealModel meal,
  required MoneyTriple money,
  required String currency,
}) => showFormHost<MealModel>(
  context,
  builder: (_) => _MealForm(meal: meal, money: money, currency: currency),
);

class _MealForm extends ConsumerStatefulWidget {
  const _MealForm({
    required this.meal,
    required this.money,
    required this.currency,
  });
  final MealModel meal;
  final MoneyTriple money;
  final String currency;

  @override
  ConsumerState<_MealForm> createState() => _MealFormState();
}

class _MealFormState extends ConsumerState<_MealForm> {
  final _formKey = GlobalKey<FormState>();
  late final _guests = TextEditingController(
    text: widget.meal.guestCount.toString(),
  );
  late final _budget = TextEditingController(
    text: widget.meal.hasBudget
        ? widget.meal.budgetLimit.toStringAsFixed(2)
        : '',
  );

  @override
  void dispose() {
    _guests.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormScaffold(
    title: 'Edit ${widget.meal.name}',
    formKey: _formKey,
    submitLabel: 'Save',
    onSubmit: () async {
      final navigator = Navigator.of(context);
      final saved = await ref
          .read(mealControllerProvider)
          .updateMeal(
            widget.meal.copyWith(
              guestCount: int.tryParse(_guests.text) ?? 0,
              budgetLimit: parseMoney(_budget.text),
            ),
          );
      navigator.pop(saved);
    },
    children: [
      LabeledField(
        label: 'Guests',
        child: WholeNumberField(controller: _guests, max: 200),
      ),
      LabeledField(
        label: 'Budget',
        hint:
            'Planned so far: ${formatMoney(widget.money.planned, currency: widget.currency)}',
        child: MoneyField(
          controller: _budget,
          currency: widget.currency,
          validator: Validators.validateBudget,
        ),
      ),
    ],
  );
}

/// Adds a menu item (item null) or edits one; delete lives here when editing.
Future<MealItemModel?> showMealItemForm(
  BuildContext context, {
  required MealModel meal,
  required MoneyTriple money,
  required String currency,
  MealItemModel? item,
}) => showFormHost<MealItemModel>(
  context,
  builder: (_) =>
      _ItemForm(meal: meal, money: money, currency: currency, item: item),
);

class _ItemForm extends ConsumerStatefulWidget {
  const _ItemForm({
    required this.meal,
    required this.money,
    required this.currency,
    required this.item,
  });
  final MealModel meal;
  final MoneyTriple money;
  final String currency;
  final MealItemModel? item;

  @override
  ConsumerState<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<_ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.itemName ?? '');
  late final _cost = TextEditingController(
    text: widget.item == null ? '' : widget.item!.cost.toStringAsFixed(2),
  );
  late MealItemStatus _status = widget.item?.status ?? MealItemStatus.toBuy;

  bool get _editing => widget.item != null;

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(mealControllerProvider);
    final today = ref.read(todayProvider);
    final draft =
        (widget.item ??
                MealItemModel(
                  id: '',
                  mealId: widget.meal.id,
                  itemName: '',
                  cost: 0,
                  status: MealItemStatus.toBuy,
                  createdAt: today,
                  updatedAt: today,
                ))
            .copyWith(
              itemName: _name.text.trim(),
              cost: parseMoney(_cost.text),
              status: _status,
            );
    final saved = _editing
        ? await controller.updateItem(draft)
        : await controller.createItem(draft);
    if (mounted) Navigator.of(context).pop(saved);
  }

  Future<void> _delete() async {
    await ref.read(mealControllerProvider).deleteItem(widget.item!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => FormScaffold(
    title: _editing ? 'Edit item' : 'Add to ${widget.meal.name}',
    formKey: _formKey,
    submitLabel: _editing ? 'Save' : 'Add item',
    onSubmit: _submit,
    leading: _editing
        ? TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
          )
        : null,
    children: [
      LabeledField(
        label: 'Name',
        child: TextFormField(
          controller: _name,
          autofocus: !_editing,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) => Validators.validateName(v, fieldName: 'Name'),
          textInputAction: TextInputAction.next,
        ),
      ),
      LabeledField(
        label: 'Cost',
        hint: widget.meal.hasBudget
            ? '${widget.meal.name} has '
                  '${formatMoney(widget.money.remaining, currency: widget.currency)} left.'
            : null,
        child: MoneyField(
          controller: _cost,
          currency: widget.currency,
          validator: Validators.validatePrice,
        ),
      ),
      LabeledField(
        label: 'Status',
        child: MealItemStatusSegmented(
          value: _status,
          onChanged: (s) => setState(() => _status = s),
        ),
      ),
    ],
  );
}
