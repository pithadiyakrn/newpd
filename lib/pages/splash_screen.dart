import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'home_page.dart';
import 'loginpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(milliseconds: 2000),
          () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool userLoggedIn = prefs.getBool('userLoggedIn') ?? false;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => userLoggedIn ? Dashboard() : Loginpage(),
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 239, 230),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(

          child: Image.asset('assets/images/logo.png'),
          // child: Lottie.asset('assets/images/final.json'),
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     // Image.network(
          //     //   'https://www.candere.com/media/catalog/product/G/R/GR00103__1.jpeg',
          //     //   width: 200.0,
          //     //   height: 200.0,
          //     //   fit: BoxFit.contain,
          //     // ),
          //     Lottie.asset(`assets/images/final.json`),
          //   ],
          // ),
        ),
      ),
    );
  }
}
