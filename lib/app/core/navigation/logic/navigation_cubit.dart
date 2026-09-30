import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationState { home, profile, settings, questions, favourites }

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.home);
  void navigate(NavigationState state) {
    emit(state);
  }
}
