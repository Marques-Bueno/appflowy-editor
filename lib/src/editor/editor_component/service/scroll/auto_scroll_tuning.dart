import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';

class AppFlowyAutoScrollTuning {
  const AppFlowyAutoScrollTuning._({
    required this.velocityScalar,
    required this.minimumAutoScrollDelta,
    required this.maximumAutoScrollDelta,
    required this.animationDuration,
    required this.selectionDragEdgeOffset,
  });

  final double velocityScalar;
  final double minimumAutoScrollDelta;
  final double maximumAutoScrollDelta;
  final Duration animationDuration;
  final double selectionDragEdgeOffset;

  static const desktop = AppFlowyAutoScrollTuning._(
    velocityScalar: 0.9,
    minimumAutoScrollDelta: 0.35,
    maximumAutoScrollDelta: 18.0,
    animationDuration: Duration(milliseconds: 16),
    selectionDragEdgeOffset: 320,
  );

  static const mobile = AppFlowyAutoScrollTuning._(
    velocityScalar: 0.15,
    minimumAutoScrollDelta: 0.07,
    maximumAutoScrollDelta: 3.5,
    animationDuration: Duration.zero,
    selectionDragEdgeOffset: 200,
  );

  static AppFlowyAutoScrollTuning current() {
    return PlatformExtension.isDesktopOrWeb ? desktop : mobile;
  }
}
