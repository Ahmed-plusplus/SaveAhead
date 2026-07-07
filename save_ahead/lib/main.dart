import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_ahead/cubit/home_cubit/home_cubit.dart';
import 'package:save_ahead/cubit/navigation_cubit/navigation_cubit.dart';
import 'package:save_ahead/modules/splash_screen.dart';
import 'package:save_ahead/shared/bloc_observer.dart';
import 'package:save_ahead/shared/local/database/sqflite_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  // await SqfliteDB.createDB();
  Bloc.observer = MyBlocObserver();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => HomeCubit()),
      ],
      child: MaterialApp(
        title: 'Save Ahead',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const SplashScreen(),
      ),
    );
  }

  ThemeData appTheme() => ThemeData(
    scaffoldBackgroundColor: Color(0xDD386485),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: Color(0xDD386485),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF386485),
      selectedItemColor: Colors.white70,
    ),
    primaryColor: Colors.white,
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white,),
      labelMedium: TextStyle(color: Colors.white,),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: MaterialStateProperty.all<Color>(Color(0xDD386485)),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
  );
}