import 'package:flutter/material.dart';

import '../../core/theme/season_theme.dart';

/// The mark: a rounded square in the hero colour with a vertical brass band
/// at 58–70% across and a horizontal one at 34–46% down. Also the favicon.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final season = SeasonTheme.of(context);
    return Semantics(
      label: 'Christmas Planner',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: season.heroSurface)),
              Positioned(
                left: size * 0.58,
                width: size * 0.12,
                top: 0,
                bottom: 0,
                child: ColoredBox(color: season.ribbon),
              ),
              Positioned(
                top: size * 0.34,
                height: size * 0.12,
                left: 0,
                right: 0,
                child: ColoredBox(color: season.ribbon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
