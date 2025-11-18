import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Frosted glass card with blur effect
class FrostedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final VoidCallback? onTap;

  const FrostedCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FrostedHearthColors.snow.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FrostedHearthColors.frostGold.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Arc progress indicator for budget displays
class EmberArcProgress extends StatelessWidget {
  final double value;
  final double size;
  final String? label;
  final String? centerText;
  final Color? color;

  const EmberArcProgress({
    super.key,
    required this.value,
    this.size = 120,
    this.label,
    this.centerText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background arc
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: 1.0,
              color: FrostedHearthColors.parchmentWarm,
              strokeWidth: 8,
            ),
          ),
          // Progress arc with gradient
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: FrostedHearthTiming.slow,
            curve: FrostedHearthCurves.gentle,
            builder: (context, animatedValue, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ArcPainter(
                  progress: animatedValue,
                  color: color ?? FrostedHearthColors.ember,
                  strokeWidth: 8,
                  gradient: true,
                ),
              );
            },
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText ?? '${(value * 100).toInt()}%',
                style: GoogleFonts.dmMono(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w600,
                  color: FrostedHearthColors.inkDark,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: size * 0.09,
                    color: FrostedHearthColors.inkLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool gradient;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient) {
      paint.shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: pi * 1.5,
        colors: [
          FrostedHearthColors.emberGlow,
          FrostedHearthColors.ember,
          FrostedHearthColors.winterBerry,
        ],
      ).createShader(rect);
    } else {
      paint.color = color;
    }

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Magical countdown display for dashboard
class MagicalCountdown extends StatelessWidget {
  final int daysRemaining;
  final String title;
  final String subtitle;

  const MagicalCountdown({
    super.key,
    required this.daysRemaining,
    this.title = 'Christmas Eve',
    this.subtitle = 'days remaining',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: FrostedHearthGradients.winterNight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Stack(
        children: [
          // Star field background
          Positioned.fill(
            child: CustomPaint(
              painter: _StarFieldPainter(),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FrostedHearthColors.iceAccent,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: daysRemaining),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, _) {
                    return Text(
                      value.toString(),
                      style: GoogleFonts.dmMono(
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
                        color: FrostedHearthColors.frostGold,
                        height: 0.9,
                      ),
                    );
                  },
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: FrostedHearthColors.frostGold.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                // Decorative line
                Container(
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FrostedHearthColors.ember,
                        FrostedHearthColors.emberGlow.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();

    for (var i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.2;

      paint.color = FrostedHearthColors.frostGold.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stacked bar for budget visualization
class BudgetStackedBar extends StatelessWidget {
  final Map<String, double> categories;
  final double total;

  const BudgetStackedBar({
    super.key,
    required this.categories,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      FrostedHearthColors.ember,
      FrostedHearthColors.winterBerry,
      FrostedHearthColors.spruce,
      FrostedHearthColors.frostGoldDark,
      FrostedHearthColors.success,
      FrostedHearthColors.info,
    ];

    if (categories.isEmpty || total <= 0) {
      return Container(
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: FrostedHearthColors.parchmentWarm,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The stacked bar
        Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: FrostedHearthColors.parchmentWarm,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: categories.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percentage = category.value / total;

                return Expanded(
                  flex: (percentage * 1000).toInt().clamp(1, 1000),
                  child: Container(
                    color: colors[index % colors.length],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: categories.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${category.key}: \$${category.value.toStringAsFixed(0)}',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 13,
                    color: FrostedHearthColors.inkMedium,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Enchanted shopping item with animated strikethrough
class EnchantedShoppingItem extends StatelessWidget {
  final String name;
  final bool isChecked;
  final VoidCallback onToggle;
  final String? category;
  final String? price;

  const EnchantedShoppingItem({
    super.key,
    required this.name,
    required this.isChecked,
    required this.onToggle,
    this.category,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: FrostedHearthTiming.normal,
        curve: FrostedHearthCurves.gentle,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked
              ? FrostedHearthColors.success.withOpacity(0.08)
              : FrostedHearthColors.snow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? FrostedHearthColors.success.withOpacity(0.3)
                : FrostedHearthColors.parchmentWarm,
          ),
        ),
        child: Row(
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: FrostedHearthTiming.quick,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked
                    ? FrostedHearthColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? FrostedHearthColors.success
                      : FrostedHearthColors.inkLight,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Item name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 16,
                      color: isChecked
                          ? FrostedHearthColors.inkLight
                          : FrostedHearthColors.inkDark,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (price != null)
                    Text(
                      price!,
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        color: FrostedHearthColors.inkLight,
                      ),
                    ),
                ],
              ),
            ),
            // Category tag
            if (category != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: FrostedHearthColors.spruce.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category!,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 11,
                    color: FrostedHearthColors.spruce,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom navigation bar with floating pill style
class HearthNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HearthNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: FrostedHearthColors.spruce,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.card_giftcard_rounded,
            label: 'Gifts',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.restaurant_rounded,
            label: 'Meals',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.shopping_bag_rounded,
            label: 'Shop',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Events',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: FrostedHearthTiming.quick,
        curve: FrostedHearthCurves.playful,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? FrostedHearthColors.ember.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? FrostedHearthColors.frostGoldBright
                  : FrostedHearthColors.frostGold.withOpacity(0.6),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.fraunces(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FrostedHearthColors.frostGoldBright,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText!,
                style: GoogleFonts.sourceSerif4(
                  fontSize: 14,
                  color: FrostedHearthColors.ember,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FrostedHearthColors.parchmentWarm,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: FrostedHearthColors.inkLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FrostedHearthColors.inkMedium,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
