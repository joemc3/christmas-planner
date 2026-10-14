import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';

/// Create or edit a gift recipient. Returns the saved model.
class RecipientFormSheet extends ConsumerStatefulWidget {
  final RecipientModel? existing;

  const RecipientFormSheet({super.key, this.existing});

  static Future<RecipientModel?> show(
    BuildContext context, {
    RecipientModel? existing,
  }) {
    return showFormSheet<RecipientModel>(
      context,
      RecipientFormSheet(existing: existing),
    );
  }

  @override
  ConsumerState<RecipientFormSheet> createState() => _RecipientFormSheetState();
}

class _RecipientFormSheetState extends ConsumerState<RecipientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _budget;
  late final TextEditingController _interests;
  late final TextEditingController _notes;
  String? _relationship;
  String? _ageGroup;
  int _priority = 0;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _name = TextEditingController(text: r?.name ?? '');
    _budget = TextEditingController(
      text: r == null ? '' : r.budgetLimit.toStringAsFixed(0),
    );
    _interests = TextEditingController(text: r?.interests.join(', ') ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
    _relationship = r?.relationship;
    _ageGroup = r?.ageGroup;
    _priority = r?.priority ?? 0;
  }

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    _interests.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final interests = _interests.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final base =
        widget.existing ??
        RecipientModel(
          id: '',
          userId: '',
          name: '',
          budgetLimit: 0,
          createdAt: now,
          updatedAt: now,
        );
    final model = base.copyWith(
      name: _name.text.trim(),
      relationship: _relationship,
      ageGroup: _ageGroup,
      interests: interests,
      budgetLimit: parseMoney(_budget.text),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      priority: _priority,
    );

    try {
      final controller = ref.read(recipientControllerProvider);
      final saved = widget.existing == null
          ? await controller.createRecipient(model)
          : await controller.updateRecipient(model);
      ref.invalidate(recipientByIdProvider(saved.id));
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: widget.existing == null ? 'New recipient' : 'Edit recipient',
      submitLabel: widget.existing == null ? 'Add recipient' : 'Save changes',
      formKey: _formKey,
      onSubmit: _save,
      children: [
        TextFormField(
          controller: _name,
          autofocus: widget.existing == null,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => Validators.validateName(v),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: [
                  for (final r in AppConstants.relationships)
                    DropdownMenuItem(value: r, child: Text(r)),
                ],
                onChanged: (v) => setState(() => _relationship = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(labelText: 'Age group'),
                items: [
                  for (final a in AppConstants.ageGroups)
                    DropdownMenuItem(value: a, child: Text(a)),
                ],
                onChanged: (v) => setState(() => _ageGroup = v),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _budget,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Gift budget for this person',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0',
          ),
          validator: (v) => Validators.validateBudget(v, required: false),
        ),
        TextFormField(
          controller: _interests,
          decoration: const InputDecoration(
            labelText: 'Interests',
            hintText: 'Lego, hiking, coffee (comma separated)',
            prefixIcon: Icon(Icons.interests_outlined),
          ),
        ),
        DropdownButtonFormField<int>(
          initialValue: _priority,
          decoration: const InputDecoration(labelText: 'Priority'),
          items: [
            for (var i = 0; i < AppConstants.priorities.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(AppConstants.priorities[i]),
              ),
          ],
          onChanged: (v) => setState(() => _priority = v ?? 0),
        ),
        TextFormField(
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Sizes, wish-list links, things to avoid…',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
