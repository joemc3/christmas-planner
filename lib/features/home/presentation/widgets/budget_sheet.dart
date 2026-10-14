import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../../../plan/data/models/plan_model.dart';
import '../../../plan/presentation/providers/plan_providers.dart';

/// Edits the master gift budget for the year.
Future<void> showBudgetSheet(
  BuildContext context,
  WidgetRef ref,
  PlanModel plan,
  String currency,
) => showFormHost(
  context,
  builder: (_) => _BudgetForm(plan: plan, currency: currency),
);

class _BudgetForm extends ConsumerStatefulWidget {
  const _BudgetForm({required this.plan, required this.currency});
  final PlanModel plan;
  final String currency;

  @override
  ConsumerState<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.plan.giftBudgetTotal > 0
        ? widget.plan.giftBudgetTotal.toStringAsFixed(2)
        : '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormScaffold(
    title: 'Gift budget ${widget.plan.year}',
    formKey: _formKey,
    submitLabel: 'Save',
    onSubmit: () async {
      final navigator = Navigator.of(context);
      await ref
          .read(planControllerProvider)
          .updateGiftBudget(widget.plan.id, parseMoney(_amount.text));
      navigator.pop();
    },
    children: [
      LabeledField(
        label: 'Budget for all gifts',
        child: MoneyField(
          controller: _amount,
          currency: widget.currency,
          autofocus: true,
          validator: Validators.validateBudget,
        ),
      ),
    ],
  );
}
