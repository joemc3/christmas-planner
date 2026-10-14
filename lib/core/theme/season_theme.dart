import 'package:flutter/material.dart';

/// The things Material does not name: the ordering-date card, its alert
/// state, the brass ribbon, and the large money style. One value per theme.
@immutable
class SeasonTheme extends ThemeExtension<SeasonTheme> {
  const SeasonTheme({
    required this.heroSurface,
    required this.onHero,
    required this.heroMuted,
    required this.alertSurface,
    required this.onAlert,
    required this.alertMuted,
    required this.ribbon,
    required this.ribbonEdge,
    required this.moneyLarge,
    required this.moneyHome,
  });

  final Color heroSurface;
  final Color onHero;
  final Color heroMuted;
  final Color alertSurface;
  final Color onAlert;
  final Color alertMuted;
  final Color ribbon;
  final Color ribbonEdge;

  /// Remaining on detail headers: 40/48, tabular figures.
  final TextStyle moneyLarge;

  /// Remaining on Home: 36/44.
  final TextStyle moneyHome;

  static SeasonTheme of(BuildContext context) =>
      Theme.of(context).extension<SeasonTheme>()!;

  @override
  SeasonTheme copyWith({
    Color? heroSurface,
    Color? onHero,
    Color? heroMuted,
    Color? alertSurface,
    Color? onAlert,
    Color? alertMuted,
    Color? ribbon,
    Color? ribbonEdge,
    TextStyle? moneyLarge,
    TextStyle? moneyHome,
  }) => SeasonTheme(
    heroSurface: heroSurface ?? this.heroSurface,
    onHero: onHero ?? this.onHero,
    heroMuted: heroMuted ?? this.heroMuted,
    alertSurface: alertSurface ?? this.alertSurface,
    onAlert: onAlert ?? this.onAlert,
    alertMuted: alertMuted ?? this.alertMuted,
    ribbon: ribbon ?? this.ribbon,
    ribbonEdge: ribbonEdge ?? this.ribbonEdge,
    moneyLarge: moneyLarge ?? this.moneyLarge,
    moneyHome: moneyHome ?? this.moneyHome,
  );

  @override
  SeasonTheme lerp(ThemeExtension<SeasonTheme>? other, double t) {
    if (other is! SeasonTheme) return this;
    return SeasonTheme(
      heroSurface: Color.lerp(heroSurface, other.heroSurface, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      heroMuted: Color.lerp(heroMuted, other.heroMuted, t)!,
      alertSurface: Color.lerp(alertSurface, other.alertSurface, t)!,
      onAlert: Color.lerp(onAlert, other.onAlert, t)!,
      alertMuted: Color.lerp(alertMuted, other.alertMuted, t)!,
      ribbon: Color.lerp(ribbon, other.ribbon, t)!,
      ribbonEdge: Color.lerp(ribbonEdge, other.ribbonEdge, t)!,
      moneyLarge: TextStyle.lerp(moneyLarge, other.moneyLarge, t)!,
      moneyHome: TextStyle.lerp(moneyHome, other.moneyHome, t)!,
    );
  }
}
