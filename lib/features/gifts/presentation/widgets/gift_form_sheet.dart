import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../data/models/gift_model.dart';
import '../providers/gift_providers.dart';

/// Create or edit a gift for [recipientId]. Returns the saved model.
class GiftFormSheet extends ConsumerStatefulWidget {
  final String recipientId;
  final GiftModel? existing;

  const GiftFormSheet({super.key, required this.recipientId, this.existing});

  static Future<GiftModel?> show(
    BuildContext context, {
    required String recipientId,
    GiftModel? existing,
  }) {
    return showFormSheet<GiftModel>(
      context,
      GiftFormSheet(recipientId: recipientId, existing: existing),
    );
  }

  @override
  ConsumerState<GiftFormSheet> createState() => _GiftFormSheetState();
}

class _GiftFormSheetState extends ConsumerState<GiftFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _actualPrice;
  late final TextEditingController _store;
  late final TextEditingController _link;
  late final TextEditingController _tracking;
  late final TextEditingController _notes;
  GiftStatus _status = GiftStatus.toBuy;
  String? _category;
  int _priority = 0;
  bool _isSurprise = true;
  DateTime? _orderDate;
  DateTime? _expectedDelivery;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _name = TextEditingController(text: g?.name ?? '');
    _price = TextEditingController(
      text: g == null ? '' : g.price.toStringAsFixed(2),
    );
    _actualPrice = TextEditingController(
      text: g?.actualPrice?.toStringAsFixed(2) ?? '',
    );
    _store = TextEditingController(text: g?.storeName ?? '');
    _link = TextEditingController(text: g?.orderLink ?? '');
    _tracking = TextEditingController(text: g?.trackingNumber ?? '');
    _notes = TextEditingController(text: g?.notes ?? '');
    _status = g?.status ?? GiftStatus.toBuy;
    _category = g?.category;
    _priority = g?.priority ?? 0;
    _isSurprise = g?.isSurprise ?? true;
    _orderDate = g?.orderDate;
    _expectedDelivery = g?.expectedDeliveryDate;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _price,
      _actualPrice,
      _store,
      _link,
      _tracking,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _emptyToNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _pickDate(
    DateTime? current,
    ValueChanged<DateTime?> onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final base =
        widget.existing ??
        GiftModel(
          id: '',
          recipientId: widget.recipientId,
          name: '',
          price: 0,
          status: GiftStatus.toBuy,
          createdAt: now,
          updatedAt: now,
        );
    final actual = _actualPrice.text.trim().isEmpty
        ? null
        : parseMoney(_actualPrice.text);

    // copyWith cannot clear a field, so build the nullable ones explicitly.
    final model = GiftModel(
      id: base.id,
      recipientId: base.recipientId,
      name: _name.text.trim(),
      description: base.description,
      price: parseMoney(_price.text),
      actualPrice: actual,
      status: _status,
      orderLink: _emptyToNull(_link),
      storeName: _emptyToNull(_store),
      trackingNumber: _emptyToNull(_tracking),
      orderDate: _orderDate,
      expectedDeliveryDate: _expectedDelivery,
      actualDeliveryDate: base.actualDeliveryDate,
      wrappedDate: base.wrappedDate,
      category: _category,
      imageUrl: base.imageUrl,
      priority: _priority,
      notes: _emptyToNull(_notes),
      isSurprise: _isSurprise,
      createdAt: base.createdAt,
      updatedAt: now,
    );

    try {
      final controller = ref.read(giftControllerProvider);
      final saved = widget.existing == null
          ? await controller.createGift(model)
          : await controller.updateGift(model);
      ref.invalidate(giftByIdProvider(saved.id));
      ref.invalidate(giftBudgetStatsProvider);
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: widget.existing == null ? 'New gift' : 'Edit gift',
      submitLabel: widget.existing == null ? 'Add gift' : 'Save changes',
      formKey: _formKey,
      onSubmit: _save,
      children: [
        TextFormField(
          controller: _name,
          autofocus: widget.existing == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Gift',
            prefixIcon: Icon(Icons.card_giftcard),
          ),
          validator: (v) => Validators.validateName(v),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Planned price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => Validators.validatePrice(v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _actualPrice,
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
        DropdownButtonFormField<GiftStatus>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            for (final s in GiftStatus.values)
              DropdownMenuItem(value: s, child: Text(s.value)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in AppConstants.giftCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
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
            ),
          ],
        ),
        TextFormField(
          controller: _store,
          decoration: const InputDecoration(
            labelText: 'Store',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        ),
        TextFormField(
          controller: _link,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Product link',
            prefixIcon: Icon(Icons.link),
          ),
          validator: (v) => Validators.validateUrl(v),
        ),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Ordered on',
                value: _orderDate,
                onTap: () => _pickDate(
                  _orderDate,
                  (d) => setState(() => _orderDate = d),
                ),
                onClear: () => setState(() => _orderDate = null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                label: 'Expected delivery',
                value: _expectedDelivery,
                onTap: () => _pickDate(
                  _expectedDelivery,
                  (d) => setState(() => _expectedDelivery = d),
                ),
                onClear: () => setState(() => _expectedDelivery = null),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _tracking,
          decoration: const InputDecoration(
            labelText: 'Tracking number',
            prefixIcon: Icon(Icons.local_shipping_outlined),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Keep it a surprise'),
          subtitle: const Text('Hide from shared views'),
          value: _isSurprise,
          onChanged: (v) => setState(() => _isSurprise = v),
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined, size: 20)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          value == null ? 'Not set' : AppDateUtils.formatDate(value!),
          style: value == null
              ? Theme.of(context).inputDecorationTheme.hintStyle
              : null,
        ),
      ),
    );
  }
}
