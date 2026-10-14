import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';

/// Adds a person (recipient null) or edits one. Returns the saved row.
Future<RecipientModel?> showRecipientForm(
  BuildContext context, {
  required String planId,
  required String currency,
  RecipientModel? recipient,
  double spentSoFar = 0,
}) => showFormHost<RecipientModel>(
  context,
  builder: (_) => _RecipientForm(
    planId: planId,
    currency: currency,
    recipient: recipient,
    spentSoFar: spentSoFar,
  ),
);

class _RecipientForm extends ConsumerStatefulWidget {
  const _RecipientForm({
    required this.planId,
    required this.currency,
    required this.recipient,
    required this.spentSoFar,
  });

  final String planId;
  final String currency;
  final RecipientModel? recipient;
  final double spentSoFar;

  @override
  ConsumerState<_RecipientForm> createState() => _RecipientFormState();
}

class _RecipientFormState extends ConsumerState<_RecipientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.recipient?.name ?? '');
  late final _budget = TextEditingController(
    text: widget.recipient == null || widget.recipient!.budgetLimit == 0
        ? ''
        : widget.recipient!.budgetLimit.toStringAsFixed(2),
  );

  bool get _editing => widget.recipient != null;

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(giftControllerProvider);
    final name = _name.text.trim();
    final budget = parseMoney(_budget.text);
    final saved = _editing
        ? await controller.updateRecipient(
            widget.recipient!.copyWith(name: name, budgetLimit: budget),
          )
        : await controller.createRecipient(
            planId: widget.planId,
            name: name,
            budgetLimit: budget,
          );
    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) => FormScaffold(
    title: _editing ? 'Edit person' : 'Add person',
    formKey: _formKey,
    submitLabel: _editing ? 'Save' : 'Add person',
    onSubmit: _submit,
    children: [
      LabeledField(
        label: 'Name',
        child: TextFormField(
          controller: _name,
          autofocus: !_editing,
          textCapitalization: TextCapitalization.words,
          validator: Validators.validateName,
          textInputAction: TextInputAction.next,
        ),
      ),
      LabeledField(
        label: 'Budget',
        hint: _editing
            ? 'Spent so far: ${formatMoney(widget.spentSoFar, currency: widget.currency)}'
            : null,
        child: MoneyField(
          controller: _budget,
          currency: widget.currency,
          validator: Validators.validateBudget,
        ),
      ),
    ],
  );
}
