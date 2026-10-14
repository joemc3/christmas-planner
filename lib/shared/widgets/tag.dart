import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A small labelled pill: "Over budget", "2 to order", "Read only".
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  /// The cranberry tag for problems.
  factory Tag.alert(BuildContext context, String label, {IconData? icon}) {
    final scheme = Theme.of(context).colorScheme;
    return Tag(
      label: label,
      icon: icon,
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.secondaryContainer;
    final fg = foreground ?? scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.tag),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: Space.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
