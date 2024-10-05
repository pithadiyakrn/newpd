import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:newuijewelsync/pages/AddCustomOrderScreen.dart';
import 'package:newuijewelsync/pages/customorderscreen.dart';
import 'package:newuijewelsync/pages/dashboard.dart';
import 'package:newuijewelsync/pages/home_page.dart';
import 'package:newuijewelsync/pages/loginpage.dart';
import 'package:newuijewelsync/pages/order_page.dart';
import 'package:newuijewelsync/pages/splash_screen.dart';
import 'package:newuijewelsync/pages/whishlist_page.dart';
import 'package:newuijewelsync/utilis/routes.dart';
import 'package:newuijewelsync/utilis/themes.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'pages/cart_page.dart';
import 'pages/category_page.dart';
import 'pages/orderinstructions.dart';
import 'pages/registerpage.dart';
import 'pages/search_page.dart';
import 'pages/thankyouscreen.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    // Register method channel handler

    const MethodChannel channel = MethodChannel('screenshot_channel');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshotTaken') {
        // Print message when a screenshot is taken
        print('Screenshot captured');
      }
    });
    WakelockPlus.enable();
    runApp(MyApp());
  });
  // // Block the application from taking screenshots
  FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return MaterialApp(

              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0, // Set the desired text scale factor here
                  ),
                  child: child!,
                );
              },
              themeMode: ThemeMode.light,
              theme: Mytheme.lighttheme(context),
              darkTheme: Mytheme.darktheme(context),
              debugShowCheckedModeBanner: false,
              initialRoute: MyRoutes.splash,
              routes: {
                "/": (context) => SplashScreen(),
                MyRoutes.splash: (context) => SplashScreen(),
                MyRoutes.login: (context) => Loginpage(),
                MyRoutes.register: (context) => RegisterPage(),
                MyRoutes.dashboard: (context) => Dashboard(),
                MyRoutes.home: (context) => HomePage(),
                MyRoutes.categories: (context) => CategoryPage(),
                MyRoutes.cart: (context) => CartPage(),
                MyRoutes.wishlist: (context) => WishlistPage(),
                // MyRoutes.profile: (context) => ProfilePage(),
                // MyRoutes.menu: (context) => SearchPage(),
                MyRoutes.serch: (context) => SearchPage(),
                // MyRoutes.productList: (context) => ItemListScreen(),
                // // MyRoutes.filter: (context) => SelectionPage(),
                // MyRoutes.Productdetails: (context) => ProductDetails(),
                MyRoutes.CustomOrders: (context) => CustomOrders(),
                MyRoutes.addCustomOrders: (context) => addcustomeorderPage(),
                MyRoutes.order: (context) => OrderPage(),
                MyRoutes.orderinstructions: (context) => DynamicForm(),
                MyRoutes.thankyou: (context) => ThankYouPage(),
              },
            );
          },
        );
      },
    );
  }
}






//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//       routes: {
//         MyRoutes.wishlist: (context) => WishlistPage(),
//         MyRoutes.cart: (context) => CartPage(),
//       },
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int cartQuantity = 0; // Initialize cartQuantity to 0
//   bool _isDropdownVisible = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchcartcount(); // Fetch the cart count when the widget is initialized
//   }
//
//   Future<void> _fetchcartcount() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('access_token');
//       if (token != null) {
//         final response = await http.get(
//           Uri.parse('${MyRoutes.baseurl}cart/count'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//         if (response.statusCode == 200) {
//           final responseData = jsonDecode(response.body);
//           if (responseData['status'] == true) {
//             int totalItems = int.parse(responseData['data']['total_items']);
//             setState(() {
//               cartQuantity = totalItems;
//             });
//           } else {
//             print('Failed to fetch cart count: ${responseData['status']}');
//           }
//         } else {
//           print('Failed to fetch cart count. Status code: ${response.statusCode}');
//         }
//       } else {
//         print('Access token is null.');
//       }
//     } catch (e) {
//       print('Error fetching cart count: $e');
//     }
//   }
//
//   void _toggleDropdown() {
//     setState(() {
//       _isDropdownVisible = !_isDropdownVisible;
//     });
//   }
//
//   void _hideDropdown() {
//     setState(() {
//       _isDropdownVisible = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(context),
//       body: GestureDetector(
//         onTap: _hideDropdown, // Hide the dropdown when tapping outside
//         child: Stack(
//           children: [
//             Center(child: Text('Your content here')),
//             if (_isDropdownVisible) _buildDropdownMenu(context),
//           ],
//         ),
//       ),
//     );
//   }
//
//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       centerTitle: false,
//       automaticallyImplyLeading: false,
//       toolbarHeight: 56.0, // or use toolbarheight variable if you have one
//       leading: IconButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => MenuPage()),
//           );
//         },
//         icon: Icon(Icons.menu, color: Colors.black),
//       ),
//       actions: [
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             PopupMenuButton<String>(
//               onSelected: (String result) {
//                 setState(() {
//                   // Handle selected option here
//                   print(result);
//                 });
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 PopupMenuItem<String>(
//                   value: 'karan',
//                   child: Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.green, // Set the background color to green
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text('karan', style: TextStyle(color: Colors.white)), // Set text color to white for better contrast
//                   ),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'shyam',
//                   child: Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.green, // Set the background color to green
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text('shyam', style: TextStyle(color: Colors.white)), // Set text color to white for better contrast
//                   ),
//                 ),
//               ],
//               child: SvgPicture.asset(
//                 'assets/icon/heartfilled.svg', // Replace this with your SVG asset path
//                 width: 24.0, // Adjust the width as needed
//                 height: 24.0, // Adjust the height as needed
//                 color: Color.fromRGBO(90, 45, 71, 1), // Apply color styling
//               ),
//             ),
//             SizedBox(width: 10),
//             GestureDetector(
//               onTap: _toggleDropdown,
//               child: Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/icon/shoppingcart.svg', // Replace this with your SVG asset path
//                     width: 24.0, // Adjust the width as needed
//                     height: 24.0, // Adjust the height as needed
//                     color: Color.fromRGBO(90, 45, 71, 1), // Apply color styling
//                   ),
//                   if (cartQuantity > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Color.fromRGBO(255, 204, 195, 1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         constraints: BoxConstraints(
//                           minWidth: 12,
//                           minHeight: 12,
//                         ),
//                         child: Text(
//                           '$cartQuantity',
//                           style: TextStyle(
//                             color: ColorCode.appcolorback,
//                             fontWeight: FontWeight.w800,
//                             fontSize: DynamicSize.scale(context, 3),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 10),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdownMenu(BuildContext context) {
//     return Positioned(
//       top: kToolbarHeight + 10, // Adjust based on the height of the AppBar
//       right: 10,
//       child: Material(
//         elevation: 5,
//         color: Colors.transparent, // Transparent background for the dropdown
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           width: 200,
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey, // Add a slight color to see the dropdown
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: Text("Gross Weight",style: TextStyle(color: Colors.red),),
//                 onTap: () {
//                   // Handle Gross Weight tap
//                 },
//               ),
//               ListTile(
//                 title: Text("Net Weight"),
//                 onTap: () {
//                   // Handle Net Weight tap
//                 },
//               ),
//               ListTile(
//                 title: Text("Go to Cart"),
//                 onTap: () {
//                   Navigator.pushNamed(context, MyRoutes.cart);
//                   _hideDropdown(); // Hide dropdown after navigating
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MenuPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Menu Page'),
//       ),
//       body: Center(child: Text('Menu Page')),
//     );
//   }
// }
//
// class WishlistPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Wishlist Page'),
//       ),
//       body: Center(child: Text('Wishlist Page')),
//     );
//   }
// }
//
// class CartPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Cart Page'),
//       ),
//       body: Center(child: Text('Cart Page')),
//     );
//   }
// }
//
// class MyRoutes {
//   static const String wishlist = '/wishlist';
//   static const String cart = '/cart';
//   static const String baseurl = 'https://yourapi.com/'; // Update with your actual base URL
// }
//
// class ColorCode {
//   static const appcolorback = Color(0xFF5A2D47); // Update with your actual color
// }
//
// class DynamicSize {
//   static double scale(BuildContext context, double size) {
//     return size;
//   }
// }

//
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       // App is in the foreground
//       print("Home screen is focused");
//     } else if (state == AppLifecycleState.paused) {
//       // App is in the background
//       print("Home screen is unfocused");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Screen'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: Text('Navigate to Another Screen'),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AnotherScreen()),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class AnotherScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Another Screen'),
//       ),
//       body: Center(
//         child: Text('This is another screen'),
//       ),
//     );
//   }
// }
