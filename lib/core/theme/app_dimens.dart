import 'package:flutter/widgets.dart';

/// SkanSkin spacing, radius and responsive layout tokens.
class AppDimens {
  AppDimens._();

  // Radius scale
  // MVC/Bootstrap: 6px default, 8px rounded-3, 14px card token, 16px modal.
  static const double rSmall = 8;
  static const double rControl = 12;
  static const double rCard = 16;
  static const double rDialog = 20;
  static const double rSheet = 28;
  static const double rFull = 999;

  static const BorderRadius brSmall = BorderRadius.all(Radius.circular(rSmall));
  static const BorderRadius brControl = BorderRadius.all(
    Radius.circular(rControl),
  );
  static const BorderRadius brCard = BorderRadius.all(Radius.circular(rCard));
  static const BorderRadius brDialog = BorderRadius.all(
    Radius.circular(rDialog),
  );
  static const BorderRadius brSheet = BorderRadius.all(Radius.circular(rSheet));
  static const BorderRadius brSheetTop = BorderRadius.vertical(
    top: Radius.circular(rSheet),
  );
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(rFull));

  // Spacing scale (4px grid)
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  // Responsive mobile content gutters.
  static const double pageGutterSmall = 16;
  static const double pageGutterNormal = 20;
  static const double pageGutterLarge = 24;
  static const double maxContentWidth = 560;

  static double pageGutterFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return pageGutterSmall;
    if (width >= 430) return pageGutterLarge;
    return pageGutterNormal;
  }

  // Compatibility aliases retained so feature layouts do not need to change in
  // this foundation stage. Every alias maps onto the consolidated scales above.
  static const double rSm = rSmall;
  static const double rMd = rControl;
  static const double rLg = rControl;
  static const double rXl = rCard;
  static const double r2xl = rCard;
  static const double r3xl = rDialog;
  static const BorderRadius brSm = brSmall;
  static const BorderRadius brMd = brControl;
  static const BorderRadius brLg = brControl;
  static const BorderRadius brXl = brCard;
  static const BorderRadius br2xl = brCard;
  static const BorderRadius br3xl = brDialog;
  static const double s2 = s4;
  static const double s6 = s8;
  static const double s10 = s12;
  static const double gutter = pageGutterNormal;
}
