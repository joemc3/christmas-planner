import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/ordering.dart' as ordering;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/widgets/confirm.dart';
import '../../../../shared/widgets/form_host.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../plan/presentation/providers/plan_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ReadableColumn(
        child: asyncList(
          profile,
          errorMessage: "Couldn't load your settings.",
          onRetry: () => ref.invalidate(userProfileProvider),
          skeletonCount: 3,
          data: (p) =>
              p == null ? const SizedBox.shrink() : _SettingsForm(profile: p),
        ),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName ?? '');
  late final _shipping = TextEditingController(
    text: widget.profile.defaultShippingDays.toString(),
  );
  late String _currency = currencies.containsKey(widget.profile.currency)
      ? widget.profile.currency
      : currencies.keys.first;
  late int _shippingDays = widget.profile.defaultShippingDays;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _shipping.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(authControllerProvider)
          .updateUserProfile(
            widget.profile.copyWith(
              fullName: _name.text.trim(),
              currency: _currency,
              defaultShippingDays: int.tryParse(_shipping.text) ?? 7,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved.')));
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final ok = await confirm(
      context,
      title: 'Delete your account?',
      body:
          'This deletes your account and every plan, person, gift and meal in it.',
      actionLabel: 'Delete account',
    );
    if (!ok) return;
    try {
      await ref.read(authControllerProvider).deleteAccount();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = ref.watch(currentYearProvider);
    final mode = ref.watch(themeModeProvider);
    final startBy = ordering.startOrderingBy(year, _shippingDays);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xxxl),
        children: [
          LabeledField(
            label: 'Your name',
            child: TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: Validators.validateName,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Signed in as ${widget.profile.email}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.lg),
          LabeledField(
            label: 'Currency',
            child: DropdownButtonFormField<String>(
              initialValue: _currency,
              items: [
                for (final e in currencies.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _currency = v ?? _currency),
            ),
          ),
          const SizedBox(height: Space.lg),
          LabeledField(
            label: 'Shipping days',
            hint:
                'How long your orders usually take. It moves the ordering '
                'date: with $_shippingDays days, start ordering by '
                '${formatDayMonth(startBy)}.',
            child: WholeNumberField(
              controller: _shipping,
              min: ordering.minShippingDays,
              max: ordering.maxShippingDays,
              onChanged: (v) => setState(() => _shippingDays = v),
            ),
          ),
          const SizedBox(height: Space.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ),
          const SectionHeader(title: 'Theme'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: Space.xxxl),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: Space.md),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: _deleteAccount,
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
  }
}
