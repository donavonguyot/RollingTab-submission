import 'package:flutter/material.dart';

/// Keep the Material slider's value-indicator portal in its own semantics tree.
/// Flutter 3.47 can otherwise serialize an orphan node during route changes:
/// https://github.com/flutter/flutter/issues/190357
/// This retains slider actions, focus, keyboard controls, and value indicators.
Widget sliderWithLocalOverlay(Slider slider) => Overlay.wrap(
  alwaysSizeToContent: true,
  clipBehavior: Clip.none,
  child: slider,
);
