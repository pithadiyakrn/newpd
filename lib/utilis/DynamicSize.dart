import 'package:flutter/cupertino.dart';

class DynamicSize {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double shortDimension(BuildContext context) =>
      MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.height;

  static double longDimension(BuildContext context) =>
      MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.width;

  static double guidelineBaseWidth = 350;
  static double guidelineBaseHeight = 680;

  static double scale(BuildContext context, double size) =>
      (shortDimension(context) / guidelineBaseWidth) * size;

  static double verticalScale(BuildContext context, double size) =>
      (longDimension(context) / guidelineBaseHeight) * size;

  static double moderateScale(BuildContext context, double size,
      {double factor = 0.5}) =>
      size + (scale(context, size) - size) * factor;

  static EdgeInsets textFieldContentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: scale(context, 10),
      vertical: verticalScale(context, 10),
    );
  }
}