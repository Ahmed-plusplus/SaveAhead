import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_ahead/cubit/bottom_nav_bar_cubit/bottom_nav_bar_states.dart';

class BottomNavBarCubit extends Cubit<BottomNavBarStates> {

  BottomNavBarCubit() : super(InitBottomNavBarState());

  static BottomNavBarCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  void changeBottomNavBarIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarIndexState());
  }

}