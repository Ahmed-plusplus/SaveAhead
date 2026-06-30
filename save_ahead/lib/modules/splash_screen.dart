import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:lottie/lottie.dart';
import 'package:save_ahead/modules/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ValueNotifier<String> notifier = ValueNotifier("");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String text = 'Plan ... Save ... Pay on time';
    int duration = (3000 / text.length).toInt();
    _showTextAnimated(text, duration, 1);
    Future.delayed(Duration(seconds: 6), () => _navigateScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('assets/jsons/save_money.json'),
            const SizedBox(height: 20,),
            const Text('Save Ahead', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, child) {
                return Text(value, style: TextStyle(fontSize: 20, color: Colors.grey), textAlign: TextAlign.start,);
              }
            )
          ],
        ),
      ),
    );
  }

  void _showTextAnimated(String text, int duration, int length) {
    Future.delayed(Duration(milliseconds: duration), () {
      notifier.value = text.substring(0, length);
      if(length == text.length) {
        return;
      }
      _showTextAnimated(text, duration, length + 1);
    },);
  }

  void _navigateScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
  }
}
