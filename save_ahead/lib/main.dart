import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_ahead/cubit/bottom_nav_bar_cubit/bottom_nav_bar_cubit.dart';
import 'package:save_ahead/modules/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavBarCubit()),
      ],
      child: MaterialApp(
        title: 'Save Ahead',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        ),
        home: const SplashScreen(),
      ),
    );
  }
}