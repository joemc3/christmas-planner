import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/season_theme.dart';

/// A filled card wrapped by two crossing brass bands. One per screen.
class RibbonCard extends StatelessWidget {
  const RibbonCard({
    super.key,
    required this.color,
    required this.child,
    this.semanticsLabel,
  });

  final Color color;
  final Widget child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final season = SeasonTheme.of(context);
    final laptop = WindowSize.of(context).isAtLeastMedium;
    final band = laptop ? 14.0 : 12.0;
    final padding = laptop
        ? const EdgeInsets.fromLTRB(32, 64, 120, 32)
        : const EdgeInsets.fromLTRB(24, 56, 72, 24);

    final edge = BorderSide(color: season.ribbonEdge, width: 2);

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.hero),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: color)),
            Positioned(
              top: 0,
              bottom: 0,
              right: 36,
              width: band,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: season.ribbon,
                    border: Border(left: edge, right: edge),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 24,
              height: band,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: season.ribbon,
                    border: Border(top: edge, bottom: edge),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
