import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../helper/general_sizes.dart';
import '../custom_text.dart';

class CustomDrawerButton extends StatelessWidget {
  const CustomDrawerButton({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    required this.onTap,
  });
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeneralSizes.medium,
        vertical: GeneralSizes.small,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: GeneralSizes.medium,
            vertical: GeneralSizes.small,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GeneralSizes.medium),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: color ?? AppColors.primary),
              horizontalMediumSpacing(),
              CustomText(
                text: title,
                color: color ?? Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
