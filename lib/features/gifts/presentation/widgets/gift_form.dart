import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../../../../shared/widgets/status_stepper.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';

/// One form for add (gift null) and edit. Add shows what the price leaves
/// in the person's budget; edit shows the dates once set.
Future<GiftModel?> showGiftForm(
  BuildContext context, {
  required RecipientModel recipient,
  required MoneyTriple money,
  required String currency,
  GiftModel? gift,
}) => showFormHost<GiftModel>(
  context,
  builder: (_) => _GiftForm(
    recipient: recipient,
    money: money,
    currency: currency,
    gift: gift,
  ),
);

class _GiftForm extends ConsumerStatefulWidget {
  const _GiftForm({
    required this.recipient,
    required this.money,
    required this.currency,
    required this.gift,
  });

  final RecipientModel recipient;
  final MoneyTriple money;
  final String currency;
  final GiftModel? gift;

  @override
  ConsumerState<_GiftForm> createState() => _GiftFormState();
}

class _GiftFormState extends ConsumerState<_GiftForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.gift?.name ?? '');
  late final _price = TextEditingController(
    text: widget.gift == null ? '' : widget.gift!.price.toStringAsFixed(2),
  );
  late final _store = TextEditingController(
    text: widget.gift?.storeName ?? widget.gift?.orderLink ?? '',
  );
  late GiftStatus _status = widget.gift?.status ?? GiftStatus.toBuy;
  late DateTime? _orderDate = widget.gift?.orderDate;
  late DateTime? _purchasedDate = widget.gift?.purchasedDate;
  double _entered = 0;

  bool get _editing => widget.gift != null;

  @override
  void initState() {
    super.initState();
    _entered = widget.gift?.price ?? 0;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _store.dispose();
    super.dispose();
  }

  String _m(double v) => formatMoney(v, currency: widget.currency);

  String? _leavesHint() {
    if (_editing) return null;
    final left = widget.money.remaining;
    final after = roundMoney(left - _entered);
    final base = '${widget.recipient.name} has ${_m(left)} left.';
    if (_entered <= 0) return base;
    return after < 0
        ? '$base This goes ${_m(-after)} over.'
        : '$base This leaves ${_m(after)}.';
  }

  Future<void> _pick(DateTime? current, ValueChanged<DateTime?> set) async {
    final year = ref.read(currentYearProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? ref.read(todayProvider),
      firstDate: DateTime(year - 1, 1, 1),
      lastDate: DateTime(year + 1, 12, 31),
    );
    if (picked != null) set(picked);
  }

  Future<void> _submit() async {
    final controller = ref.read(giftControllerProvider);
    final today = ref.read(todayProvider);
    final storeText = _store.text.trim();
    final isLink =
        storeText.startsWith('http://') || storeText.startsWith('https://');
    final draft =
        (widget.gift ??
                GiftModel(
                  id: '',
                  recipientId: widget.recipient.id,
                  name: '',
                  price: 0,
                  status: GiftStatus.toBuy,
                  createdAt: today,
                  updatedAt: today,
                ))
            .copyWith(
              name: _name.text.trim(),
              price: parseMoney(_price.text),
              storeName: isLink ? null : (storeText.isEmpty ? null : storeText),
              orderLink: isLink ? storeText : null,
              clearOrderDate: true,
              clearPurchasedDate: true,
            );

    // The status chosen decides the dates: stamped by rule, then any date
    // the user edited wins.
    var withStatus = draft.withStatus(_status, today: today);
    if (_editing) {
      withStatus = withStatus.copyWith(
        orderDate: _status != GiftStatus.toBuy ? _orderDate : null,
        purchasedDate: _status == GiftStatus.purchased ? _purchasedDate : null,
        clearOrderDate: _status == GiftStatus.toBuy,
        clearPurchasedDate: _status != GiftStatus.purchased,
      );
    }

    final saved = _editing
        ? await controller.updateGift(withStatus)
        : await controller.createGift(withStatus);
    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormScaffold(
      title: _editing ? 'Edit gift' : 'Add gift for ${widget.recipient.name}',
      formKey: _formKey,
      submitLabel: _editing ? 'Save' : 'Add gift',
      onSubmit: _submit,
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
          label: 'Price',
          hint: _leavesHint(),
          child: MoneyField(
            controller: _price,
            currency: widget.currency,
            validator: Validators.validatePrice,
            onChanged: (v) => setState(() => _entered = parseMoney(v)),
          ),
        ),
        LabeledField(
          label: 'Store or link',
          child: TextFormField(
            controller: _store,
            decoration: const InputDecoration(hintText: '(optional)'),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
        ),
        LabeledField(
          label: 'Status',
          child: GiftStatusSegmented(
            value: _status,
            onChanged: (s) => setState(() => _status = s),
          ),
        ),
        if (_editing && _status != GiftStatus.toBuy)
          _DateRow(
            label: 'Ordered on',
            value: _orderDate,
            onPick: () =>
                _pick(_orderDate, (d) => setState(() => _orderDate = d)),
            onClear: () => setState(() => _orderDate = null),
          ),
        if (_editing && _status == GiftStatus.purchased)
          _DateRow(
            label: 'Purchased on',
            value: _purchasedDate,
            onPick: () => _pick(
              _purchasedDate,
              (d) => setState(() => _purchasedDate = d),
            ),
            onClear: () => setState(() => _purchasedDate = null),
          ),
        if (_editing)
          Text(
            'Dates are stamped when the status changes; edit them here.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LabeledField(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value == null ? 'Set a date' : formatLongDate(value!),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: Space.sm),
            IconButton(
              tooltip: 'Clear $label',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
