import 'package:flutter/material.dart';

class GeneralSizes {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

Widget smallSpacing() {
  return SizedBox(height: GeneralSizes.small);
}

Widget mediumSpacing() {
  return SizedBox(height: GeneralSizes.medium);
}

Widget largeSpacing() {
  return SizedBox(height: GeneralSizes.large);
}

const double borderRadiusS = 12.0;
const double borderRadiusM = 16.0;
const double borderRadiusL = 24.0;

class ScreenSizes {}

Widget horizontalSmallSpacing() {
  return SizedBox(width: GeneralSizes.small);
}

Widget horizontalMediumSpacing() {
  return SizedBox(width: GeneralSizes.medium);
}

Widget horizontalLargeSpacing() {
  return SizedBox(width: GeneralSizes.large);
}

Widget verticalSmallSpacing() {
  return SizedBox(height: GeneralSizes.small);
}

Widget verticalMediumSpacing() {
  return SizedBox(height: GeneralSizes.medium);
}

Widget verticalLargeSpacing() {
  return SizedBox(height: GeneralSizes.large);
}
