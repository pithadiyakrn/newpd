import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

class ThankYouPage extends StatefulWidget {

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

Color themeColor = const Color(0xFF43D19E);

class _ThankYouPageState extends State<ThankYouPage> {

  Color textColor = const Color(0xFF32567A);

  void initState() {
    super.initState();
    Timer(
      Duration(milliseconds: 7000),
          () async {
            await Navigator.pushReplacementNamed(context, MyRoutes.dashboard);
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
      // Return false to disable the back button
      return false;

    },
    child: Scaffold(


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/icon/thankyou.svg",
                fit: BoxFit.contain,
              ),
            ),
          //   child: Image.asset(
            //     "assets/icon/order-placed-purchased-icon.svg",
            //     fit: BoxFit.contain,
            //   ),
            // ),
            SizedBox(height: DynamicSize.scale(context,10)),
            Text(
              "Thank You for Ordering!",
              style: TextStyle(
                color: ColorCode.appcolorback,
                fontWeight: FontWeight.w600,
                fontSize: DynamicSize.scale(context, 12),
              ),
            ),
            SizedBox(height: DynamicSize.scale(context,10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context,35)),
              child: Text(
                "You will be redirected to the homepage shortly or continue shopping",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorCode.containerlblcolor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 100),

            GestureDetector(
              onTap: () async{
                await Navigator.pushReplacementNamed(context, MyRoutes.dashboard);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 500,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorCode.appcolorback,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorCode.btntextcolor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    )
    );
  }
}
