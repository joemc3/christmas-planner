import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';

/// Create or edit a meal (Christmas Eve dinner, Christmas Day lunch, …).
class MealFormSheet extends ConsumerStatefulWidget {
  final MealModel? existing;
  final MealType? initialType;

  const MealFormSheet({super.key, this.existing, this.initialType});

  static Future<MealModel?> show(
    BuildContext context, {
    MealModel? existing,
    MealType? initialType,
  }) {
    return showFormSheet<MealModel>(
      context,
      MealFormSheet(existing: existing, initialType: initialType),
    );
  }

  @override
  ConsumerState<MealFormSheet> createState() => _MealFormSheetState();
}

class _MealFormSheetState extends ConsumerState<MealFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _guests;
  late final TextEditingController _budget;
  late final TextEditingController _location;
  late final TextEditingController _theme;
  late final TextEditingController _notes;
  late MealType _type;
  TimeOfDay? _time;
  late Set<String> _dietary;

  static String _defaultName(MealType type) => switch (type) {
    MealType.xmasEve => 'Christmas Eve dinner',
    MealType.xmasDay => 'Christmas Day lunch',
    MealType.other => '',
  };

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _type = m?.type ?? widget.initialType ?? MealType.xmasDay;
    _name = TextEditingController(text: m?.name ?? _defaultName(_type));
    _guests = TextEditingController(text: m?.guestCount.toString() ?? '');
    _budget = TextEditingController(
      text: m == null ? '' : m.budgetLimit.toStringAsFixed(0),
    );
    _location = TextEditingController(text: m?.location ?? '');
    _theme = TextEditingController(text: m?.theme ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');
    _time = m?.mealTime == null ? null : TimeOfDay.fromDateTime(m!.mealTime!);
    _dietary = {...?m?.dietaryRestrictions};
  }

  @override
  void dispose() {
    for (final c in [_name, _guests, _budget, _location, _theme, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final base =
        widget.existing ??
        MealModel(
          id: '',
          userId: '',
          type: _type,
          name: '',
          guestCount: 0,
          budgetLimit: 0,
          year: now.year,
          createdAt: now,
          updatedAt: now,
        );
    final model = MealModel(
      id: base.id,
      userId: base.userId,
      type: _type,
      name: _name.text.trim(),
      guestCount: int.tryParse(_guests.text.trim()) ?? 0,
      budgetLimit: parseMoney(_budget.text),
      mealTime: _time == null
          ? null
          : DateTime(1970, 1, 1, _time!.hour, _time!.minute),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      theme: _theme.text.trim().isEmpty ? null : _theme.text.trim(),
      dietaryRestrictions: _dietary.toList(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      year: base.year,
      createdAt: base.createdAt,
      updatedAt: now,
    );
    try {
      final controller = ref.read(mealControllerProvider);
      final saved = widget.existing == null
          ? await controller.createMeal(model)
          : await controller.updateMeal(model);
      ref.invalidate(mealByIdProvider(saved.id));
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: widget.existing == null ? 'New meal' : 'Edit meal',
      submitLabel: widget.existing == null ? 'Add meal' : 'Save changes',
      formKey: _formKey,
      onSubmit: _save,
      children: [
        SegmentedButton<MealType>(
          segments: [
            for (final t in MealType.values)
              ButtonSegment(value: t, label: Text(t.displayName)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() {
            final wasDefault = _name.text == _defaultName(_type);
            _type = s.first;
            if (wasDefault || _name.text.isEmpty) {
              _name.text = _defaultName(_type);
            }
          }),
        ),
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Meal',
            prefixIcon: Icon(Icons.restaurant_outlined),
          ),
          validator: (v) => Validators.validateName(v, fieldName: 'Meal name'),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _guests,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Guests',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _budget,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => Validators.validateBudget(v, required: false),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.schedule, size: 20),
                  ),
                  child: Text(
                    _time == null ? 'Not set' : _time!.format(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Where',
                  hintText: "Mum's place",
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _theme,
          decoration: const InputDecoration(
            labelText: 'Theme',
            hintText: 'Traditional roast, tapas night…',
          ),
        ),
        Text('Dietary needs', style: Theme.of(context).textTheme.bodySmall),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final d in AppConstants.dietaryRestrictions)
              FilterChip(
                label: Text(d),
                selected: _dietary.contains(d),
                onSelected: (on) => setState(() {
                  if (on) {
                    _dietary.add(d);
                  } else {
                    _dietary.remove(d);
                  }
                }),
              ),
          ],
        ),
        TextFormField(
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
