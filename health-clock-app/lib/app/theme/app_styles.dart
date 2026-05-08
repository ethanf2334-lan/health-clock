import 'package:flutter/material.dart';

class AppStyles {
  const AppStyles._();

  // 8pt spacing grid.
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 40.0;

  static const double screenMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double compactControlPadding = 8.0;
  static const double bottomSafeAreaBase = 8.0;

  // iOS corner radii.
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // iOS touch targets and controls.
  static const double minTouchTarget = 44.0;
  static const double primaryButtonHeight = 48.0;
  static const double listRowHeight = 52.0;
  static const double compactListRowHeight = 48.0;
  static const double iconTouchTarget = 44.0;
  static const double avatarS = 32.0;
  static const double iconContainerM = 40.0;
  static const double iconContainerL = 44.0;
  static const double bottomNavIconBoxWidth = 32.0;
  static const double bottomNavIconBoxHeight = 24.0;

  // Hairline dividers.
  static const double dividerThin = 0.5;
  static const double borderRegular = 1.0;

  // Soft iOS-style elevation for white surfaces on light backgrounds.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 18.0,
      offset: Offset(0, 6.0),
    ),
  ];

  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12.0,
      offset: Offset(0, 3.0),
    ),
  ];

  // iOS Dynamic Type mapping. Font family is intentionally omitted so iOS
  // resolves to SF Pro / San Francisco.
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.4,
    height: 1.12,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.2,
    height: 1.18,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.1,
    height: 1.22,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
    height: 1.25,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.30,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
    height: 1.42,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.34,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.32,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
    height: 1.28,
  );

  // Semantic app roles. These keep screens consistent without making every
  // custom header as large as an iOS Large Title.
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.22,
  );

  static const TextStyle sheetTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.25,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.30,
  );

  static const TextStyle controlLabel = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.30,
  );

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: screenMargin);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets pillInsets =
      EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS);
}
