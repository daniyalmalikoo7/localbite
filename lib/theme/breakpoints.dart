import 'package:flutter/widgets.dart';

/// Material 3 window size classes.
enum WindowClass {
  /// Phones in portrait.
  compact,

  /// Large phones in landscape, small tablets.
  medium,

  /// Tablets and desktop windows — wide enough for a two-pane layout.
  expanded,
}

extension WindowSizing on BuildContext {
  WindowClass get windowClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 600) return WindowClass.compact;
    if (width < 840) return WindowClass.medium;
    return WindowClass.expanded;
  }

  /// True on a phone held in landscape, where vertical space is the scarce
  /// dimension and tall hero sections need to collapse.
  bool get isShortViewport => MediaQuery.sizeOf(this).height < 560;

  /// Wide enough to show the vendor list and detail side by side.
  bool get usesTwoPane => windowClass == WindowClass.expanded;
}
