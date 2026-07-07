import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_ahead/cubit/navigation_cubit/navigation_states.dart';

class NavigationCubit extends Cubit<NavigationStates> {

  NavigationCubit() : super(InitNavigationState());

  static NavigationCubit get(context) => BlocProvider.of(context);

  int bottomNavBarIndex = 0;
  int screenIndex = 0;
  List<int> screenIndexHistory = [0];

  void changeBottomNavBarIndex(int index) {
    bottomNavBarIndex = index;
    screenIndex = index;
    screenIndexHistory.clear();
    screenIndexHistory.add(index);
    emit(ChangeBottomNavBarIndexState());
  }

  void changeScreenIndex(int index) {
    screenIndex = index;
    screenIndexHistory.add(index);
    emit(ChangeScreenIndexState());
  }

  void goBackToPreviousScreen() {
    if (screenIndexHistory.length > 1) {
      screenIndexHistory.removeLast();
      screenIndex = screenIndexHistory.last;
      emit(ChangeScreenIndexState());
    } else {
      exit(0);
    }
  }

}