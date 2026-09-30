import 'package:flutter/material.dart';

import '../app_theme.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  CustomText({
    super.key,
    required this.text,
    this.color = AppColors.textPrimary,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
  });
  final String text;
  Color color = AppColors.textPrimary;
  double fontSize = 20;
  FontWeight fontWeight = FontWeight.normal;
  @override
  Widget build(BuildContext context) {
    return Text(
      textDirection: TextDirection.rtl,
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'cairo',
      ),
    );
  }
}
