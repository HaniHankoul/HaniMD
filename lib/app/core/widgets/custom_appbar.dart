import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: AppBar(
        title: CustomText(
          text: title,
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xffFCF7F5),
        shape: RoundedRectangleBorder(),
      ),
    );
  }
}

PreferredSizeWidget customAppbar(String title) {
  return PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: AppBar(
      title: CustomText(
        text: title,
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xffFCF7F5),
      shape: RoundedRectangleBorder(),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
  );
}
