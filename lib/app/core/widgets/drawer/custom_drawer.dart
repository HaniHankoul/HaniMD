import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app_theme.dart';
import '../../helper/general_sizes.dart';
import '../../navigation/logic/navigation_cubit.dart';
import '../custom_text.dart';
import 'drawer_button.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * .65,
      backgroundColor: AppColors.primaryLight,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GeneralSizes.medium,
                vertical: GeneralSizes.large,
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: GeneralSizes.small),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(GeneralSizes.medium),
                ),
                child: Column(
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primaryLight.withAlpha(
                            500,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 25,
                            color: AppColors.primary,
                          ),
                        ),
                        title: CustomText(
                          text: 'اسم المستخدم',
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text: 'البريد الإلكتروني',
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<NavigationCubit>().navigate(
                          NavigationState.profile,
                        );
                        Navigator.pop(context);
                        context.go('/');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: GeneralSizes.medium,
                          vertical: GeneralSizes.small / 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            GeneralSizes.large,
                          ),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: CustomText(
                          text: 'تعديل الملف الشخصي',
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(child: Column(children: [])),
            ),
            CustomDrawerButton(
              onTap: () {},
              title: 'تسجيل الخروج ',
              icon: Icons.door_back_door,
              color: Colors.red,
            ),
            verticalMediumSpacing(),
          ],
        ),
      ),
    );
  }
}
