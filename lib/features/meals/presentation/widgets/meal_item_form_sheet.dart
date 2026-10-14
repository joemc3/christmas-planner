import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../data/models/meal_item_model.dart';
import '../providers/meal_providers.dart';

/// Create or edit a dish / ingredient for a meal.
class MealItemFormSheet extends ConsumerStatefulWidget {
  final String mealId;
  final MealItemModel? existing;

  const MealItemFormSheet({super.key, required this.mealId, this.existing});

  static Future<MealItemModel?> show(
    BuildContext context, {
    required String mealId,
    MealItemModel? existing,
  }) {
    return showFormSheet<MealItemModel>(
      context,
      MealItemFormSheet(mealId: mealId, existing: existing),
    );
  }

  @override
  ConsumerState<MealItemFormSheet> createState() => _MealItemFormSheetState();
}

class _MealItemFormSheetState extends ConsumerState<MealItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _cost;
  late final TextEditingController _actualCost;
  late final TextEditingController _store;
  late final TextEditingController _recipe;
  late final TextEditingController _prep;
  late final TextEditingController _cook;
  late final TextEditingController _assigned;
  late final TextEditingController _notes;
  String? _category;
  MealItemStatus _status = MealItemStatus.toBuy;

  @override
  void initState() {
    super.initState();
    final i = widget.existing;
    _name = TextEditingController(text: i?.itemName ?? '');
    _quantity = TextEditingController(text: i?.quantity ?? '');
    _cost = TextEditingController(
      text: i == null ? '' : i.cost.toStringAsFixed(2),
    );
    _actualCost = TextEditingController(
      text: i?.actualCost?.toStringAsFixed(2) ?? '',
    );
    _store = TextEditingController(text: i?.storeName ?? '');
    _recipe = TextEditingController(text: i?.recipeLink ?? '');
    _prep = TextEditingController(text: i?.prepTime?.toString() ?? '');
    _cook = TextEditingController(text: i?.cookTime?.toString() ?? '');
    _assigned = TextEditingController(text: i?.assignedTo ?? '');
    _notes = TextEditingController(text: i?.notes ?? '');
    _category = i?.category;
    _status = i?.status ?? MealItemStatus.toBuy;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _quantity,
      _cost,
      _actualCost,
      _store,
      _recipe,
      _prep,
      _cook,
      _assigned,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final now = DateTime.now();
    final base = widget.existing;
    final model = MealItemModel(
      id: base?.id ?? '',
      mealId: widget.mealId,
      itemName: _name.text.trim(),
      description: base?.description,
      quantity: _opt(_quantity),
      cost: parseMoney(_cost.text),
      actualCost: _actualCost.text.trim().isEmpty
          ? null
          : parseMoney(_actualCost.text),
      status: _status,
      storeName: _opt(_store),
      category: _category,
      recipeLink: _opt(_recipe),
      prepTime: int.tryParse(_prep.text.trim()),
      cookTime: int.tryParse(_cook.text.trim()),
      assignedTo: _opt(_assigned),
      notes: _opt(_notes),
      createdAt: base?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      final controller = ref.read(mealControllerProvider);
      final saved = base == null
          ? await controller.createMealItem(model)
          : await controller.updateMealItem(model);
      ref.invalidate(mealBudgetStatsProvider(widget.mealId));
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: widget.existing == null ? 'Add to the menu' : 'Edit item',
      submitLabel: widget.existing == null ? 'Add' : 'Save changes',
      formKey: _formKey,
      onSubmit: _save,
      children: [
        TextFormField(
          controller: _name,
          autofocus: widget.existing == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Dish or ingredient',
            prefixIcon: Icon(Icons.restaurant_menu),
          ),
          validator: (v) => Validators.validateName(v, fieldName: 'Item'),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Course'),
                items: [
                  for (final c in AppConstants.mealCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _quantity,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: '2 kg, serves 8',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Est. cost',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => Validators.validatePrice(v, required: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _actualCost,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Paid',
                  hintText: 'optional',
                ),
                validator: (v) => Validators.validatePrice(v, required: false),
              ),
            ),
          ],
        ),
        DropdownButtonFormField<MealItemStatus>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            for (final s in MealItemStatus.values)
              DropdownMenuItem(value: s, child: Text(s.value)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prep,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prep (min)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cook,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cook (min)'),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _assigned,
          decoration: const InputDecoration(
            labelText: 'Who is bringing / making it',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        TextFormField(
          controller: _store,
          decoration: const InputDecoration(
            labelText: 'Store',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        ),
        TextFormField(
          controller: _recipe,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Recipe link',
            prefixIcon: Icon(Icons.link),
          ),
          validator: (v) => Validators.validateUrl(v),
        ),
        TextFormField(
          controller: _notes,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
