import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_theme.dart';
import '../../helper/general_sizes.dart';
import '../../widgets/custom_text.dart';
import '../logic/navigation_cubit.dart';

// ignore: must_be_immutable
class NavigationElements extends StatelessWidget {
  NavigationState index;
  NavigationState state;
  String title;
  IconData icon;
  NavigationElements({
    required this.index,
    required this.state,
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<NavigationCubit>().navigate(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadiusL + 6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: state == index ? AppColors.white : transparent,
                radius: 15,
                child: Icon(
                  icon,
                  color: state == index ? AppColors.primary : AppColors.black,
                ),
              ),
              CustomText(
                text: title,
                color: state == index ? AppColors.primary : AppColors.black,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
