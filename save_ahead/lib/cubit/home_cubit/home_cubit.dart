import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_ahead/cubit/home_cubit/home_states.dart';
import 'package:save_ahead/shared/local/database/sqflite_db.dart';

class HomeCubit extends Cubit<HomeStates> {

  HomeCubit() : super(InitHomeState()){
    calculateTotalSaved();
  }

  static HomeCubit get(context) => BlocProvider.of(context);

  SqfliteDB sqfliteDB = SqfliteDB();
  double totalSaved = 0.0;

  Future<void> calculateTotalSaved() async {
    totalSaved = await sqfliteDB.getTotalSavedAmount();
    emit(CalculateTotalSavedState());
  }

}