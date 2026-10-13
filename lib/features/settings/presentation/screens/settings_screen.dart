import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider).signOut();
    if (context.mounted) context.go('/login');
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete your account?',
        message:
            'All recipients, gifts, meals and budgets will be deleted. '
            'This cannot be undone.',
        confirmText: 'Delete everything',
        isDestructive: true,
        icon: Icons.warning_amber_rounded,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authControllerProvider).deleteAccount();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final profile = userProfile.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(profile?.fullName ?? 'Your name'),
            accountEmail: Text(
              profile?.email ?? ref.watch(currentUserProvider)?.email ?? '',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: FrostedHearthColors.frostGold,
              child: Text(
                (profile?.fullName?.isNotEmpty ?? false)
                    ? profile!.fullName![0].toUpperCase()
                    : '🎄',
                style: const TextStyle(
                  fontSize: 32,
                  color: FrostedHearthColors.spruce,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: FrostedHearthGradients.winterNight,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            subtitle: Text(
              profile == null
                  ? 'Name, currency, default shipping time'
                  : '${profile.currency} · '
                        '${profile.defaultShippingDays}-day default shipping',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: profile == null
                ? null
                : () => showFormSheet<void>(context, _ProfileSheet(profile)),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Budget'),
            subtitle: const Text('Totals for gifts, meals and extras'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text(
              '${AppConstants.appName} ${AppConstants.appVersion}',
            ),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: AppConstants.appVersion,
              applicationIcon: const Icon(
                Icons.card_giftcard,
                color: FrostedHearthColors.ember,
                size: 40,
              ),
              children: const [
                Text(
                  'Plan gifts, meals, budget and deadlines for the holidays. '
                  'Open source, built with Flutter and Supabase.',
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text(
              'Sign out',
              style: TextStyle(color: AppTheme.error),
            ),
            onTap: () => _signOut(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('Delete account'),
            textColor: FrostedHearthColors.inkMedium,
            iconColor: FrostedHearthColors.inkMedium,
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const _ProfileSheet(this.profile);

  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _shipping;
  late String _currency;

  static const _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NZD'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.fullName ?? '');
    _shipping = TextEditingController(
      text: widget.profile.defaultShippingDays.toString(),
    );
    _currency = _currencies.contains(widget.profile.currency)
        ? widget.profile.currency
        : _currencies.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _shipping.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.profile.copyWith(
      fullName: _name.text.trim(),
      currency: _currency,
      defaultShippingDays: int.tryParse(_shipping.text.trim()) ?? 7,
    );
    try {
      await ref.read(authControllerProvider).updateUserProfile(updated);
      ref.invalidate(userProfileProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'Profile',
      formKey: _formKey,
      onSubmit: _save,
      children: [
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => Validators.validateName(v),
        ),
        DropdownButtonFormField<String>(
          initialValue: _currency,
          decoration: const InputDecoration(labelText: 'Currency'),
          items: [
            for (final c in _currencies)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => _currency = v ?? _currency),
        ),
        TextFormField(
          controller: _shipping,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Default shipping time (days)',
            helperText: 'Used to work out the last safe day to order online',
            prefixIcon: Icon(Icons.local_shipping_outlined),
          ),
          validator: (v) {
            final n = int.tryParse(v ?? '');
            if (n == null || n < 0 || n > 60) return 'Enter 0 to 60 days';
            return null;
          },
        ),
      ],
    );
  }
}
