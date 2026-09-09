import 'package:flutter/widgets.dart';

/// Layered, low-opacity shadow system that gives SkanSkin surfaces quiet depth.
///
/// Each level pairs a tight contact shadow with a wider ambient shadow, tinted
/// with the brand ink (`#0B1D27`) rather than pure black so elevation reads as
/// part of the palette. Shadows are used sparingly — only where hierarchy or
/// interactivity benefits from lift.
class AppElevation {
  AppElevation._();

  /// Resting lift for small interactive chips and subtle separation.
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A0B1D27), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x0F0B1D27),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: -3,
    ),
  ];

  /// Default resting elevation for feature cards that should float above the
  /// content sheet.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D0B1D27), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x140B1D27),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  /// Floating surfaces: dialogs, bottom sheets, transient overlays.
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x140B1D27), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(
      color: Color(0x1F0B1D27),
      blurRadius: 30,
      offset: Offset(0, 16),
      spreadRadius: -8,
    ),
  ];

  /// A single restrained teal glow reserved for the primary call to action, so
  /// the main action reads as tappable and important without shouting.
  static const List<BoxShadow> brand = [
    BoxShadow(color: Color(0x1A00706C), blurRadius: 3, offset: Offset(0, 2)),
    BoxShadow(
      color: Color(0x2E009B95),
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: -5,
    ),
  ];
}
