import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/home/UI/home_screen.dart';
import '../../features/speed_test/UI/speed_test_screen.dart';
import '../../features/speed_test/logic/speed_test_cubit.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/speed-test',
      builder: (context, state) => BlocProvider(
        create: (_) => SpeedTestCubit(),
        child: const SpeedTestScreen(),
      ),
    ),
  ],
);
