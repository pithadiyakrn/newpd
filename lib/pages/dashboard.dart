// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:newuijewelsync/pages/cart_page.dart';
// // import 'package:newuijewelsync/pages/category_page.dart';
// // import 'package:newuijewelsync/pages/home_page.dart';
// // import 'package:newuijewelsync/pages/menu_page.dart';
// // import 'package:newuijewelsync/pages/profile_page.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Dashboard(),
// //     );
// //   }
// // }
// //
// // class Dashboard extends StatefulWidget {
// //   final int? initialIndex;
// //   // int initialIndex = 0;
// //
// //   Dashboard({this.initialIndex}); // Constructor to receive categoryId (optional)
// //
// //   @override
// //   _DashboardState createState() => _DashboardState();
// // }
// //
// // class _DashboardState extends State<Dashboard> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
// //   int _selectedIndex = 0;
// //   DateTime? _lastPressedAt;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedIndex = widget.initialIndex ?? 0 ;
// //   }
// //
// //
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         final now = DateTime.now();
// //         if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
// //           _lastPressedAt = now;
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text('Press again to exit')),
// //           );
// //           return false; // Do not exit the app
// //         }
// //         return true; // Exit the app
// //       },
// //       child: Scaffold(
// //         key: _scaffoldKey,
// //         body: _getBodyContent(_selectedIndex),
// //         bottomNavigationBar: BottomNavigationBar(
// //           currentIndex: _selectedIndex,
// //           selectedItemColor: Colors.black,
// //           unselectedItemColor: Colors.grey,
// //           onTap: (int index) {
// //             setState(() {
// //               _selectedIndex = index;
// //             });
// //           },
// //           items: [
// //             BottomNavigationBarItem(
// //               icon: SvgPicture.asset(
// //                 'assets/icon/home-2.svg',
// //                 width: 24,
// //                 height: 24,
// //               ),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: SvgPicture.asset(
// //                 'assets/icon/category.svg',
// //                 width: 24,
// //                 height: 24,
// //               ),
// //               label: 'Category',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: SvgPicture.asset(
// //                 'assets/icon/cart.svg',
// //                 width: 24,
// //                 height: 24,
// //               ),
// //               label: 'Cart',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: SvgPicture.asset(
// //                 'assets/icon/user.svg',
// //                 width: 24,
// //                 height: 24,
// //               ),
// //               label: 'You',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _getBodyContent(int index) {
// //     switch (index) {
// //       case 0:
// //         return HomePage();
// //       case 1:
// //         return CategoryPage();
// //       case 2:
// //         return CartPage();
// //       case 3:
// //         return ProfilePage();
// //       default:
// //         return Container();
// //     }
// //   }
// // }
// //
// //
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:newuijewelsync/pages/cart_page.dart';
// import 'package:newuijewelsync/pages/category_page.dart';
// import 'package:newuijewelsync/pages/home_page.dart';
// import 'package:newuijewelsync/pages/profile_page.dart';
//
//
// import 'package:flutter/services.dart';
//
// void exitApp() {
//   SystemNavigator.pop();
// }
// void main() {
//   runApp(MyApp());
// }
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Dashboard(),
//     );
//   }
// }
//
// class Dashboard extends StatefulWidget {
//   final int? initialIndex;
//
//   Dashboard({this.initialIndex});
//
//   @override
//   _DashboardState createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   int _selectedIndex = 0;
//   DateTime? _lastPressedAt;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex ?? 0;
//   }
//
//
//
//   Future<bool> _onWillPop() async {
//     final now = DateTime.now();
//     if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
//       exitApp();
//       _lastPressedAt = now;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Press again to exit')),
//
//       );
//       return true;
//
//     }
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         key: _scaffoldKey,
//         body: _getBodyContent(_selectedIndex),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.grey,
//           onTap: (int index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           items: [
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icon/home-2.svg',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icon/category.svg',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Category',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icon/cart.svg',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Cart',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icon/user.svg',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'You',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _getBodyContent(int index) {
//     switch (index) {
//       case 0:
//         return HomePage();
//       case 1:
//         return CategoryPage();
//       case 2:
//         return CartPage();
//       case 3:
//         return ProfilePage();
//       default:
//         return Container();
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newuijewelsync/pages/cart_page.dart';
import 'package:newuijewelsync/pages/category_page.dart';
import 'package:newuijewelsync/pages/home_page.dart';
import 'package:newuijewelsync/pages/profile_page.dart';
import 'dart:io';

import 'package:newuijewelsync/utilis/routes.dart'; // Import for exit method

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  final int? initialIndex;

  Dashboard({this.initialIndex});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int _selectedIndex = 0;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }


  // Future<bool> _onWillPop() async {
  //   final now = DateTime.now();
  //   // Navigator.pop(context, MyRoutes.dashboard);
  //
  //   if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
  //     _lastPressedAt = now;
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Image.asset(
  //               'assets/images/appicon.png', // Path to your image asset
  //               width: 24,
  //               height: 24,
  //             ),
  //             SizedBox(width: 8), // Space between icon and text
  //             Text('Press Back again to Exit'),
  //
  //
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     return false; // Do not exit the app
  //   }
  //   exit(0); // Exit the app
  // }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (_selectedIndex == 0) {
      if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
        _lastPressedAt = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png', // Path to your image asset
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8), // Space between icon and text
                Text('Press Back again to Exit'),
              ],
            ),
          ),
        );
        return false; // Do not exit the app
      }
      exit(0); // Exit the app
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Dashboard(initialIndex: 0),
        ),
            (route) => false,
      );
      return false; // Do not exit the app
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: _getBodyContent(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icon/home-2.svg',
                width: 24,
                height: 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icon/category.svg',
                width: 24,
                height: 24,
              ),
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icon/cart.svg',
                width: 24,
                height: 24,
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icon/user.svg',
                width: 24,
                height: 24,
              ),
              label: 'You',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBodyContent(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return CategoryPage();
      case 2:
        return CartPage();
      case 3:
        return ProfilePage();
      default:
        return Container();
    }
  }
}
