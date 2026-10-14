import 'package:flutter/widgets.dart';

/// Material window-size classes as the design decisions set them:
/// below 840 a phone layout; 840 and up a rail and dialogs; 1200 and up
/// list plus detail for Gifts and Meals.
abstract final class Breakpoints {
  static const double medium = 840;
  static const double expanded = 1200;
}

enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.expanded) return WindowSize.expanded;
    if (width >= Breakpoints.medium) return WindowSize.medium;
    return WindowSize.compact;
  }

  bool get isCompact => this == WindowSize.compact;
  bool get isAtLeastMedium => this != WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;
}

/// Horizontal gutter: 16 on phone, 32 on larger windows.
double gutterOf(BuildContext context) =>
    WindowSize.of(context).isCompact ? 16 : 32;

/// Readable width for a single column of content on a wide window.
const double readableWidth = 640;
