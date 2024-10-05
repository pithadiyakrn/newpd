
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:newuijewelsync/utilis/colorcode.dart';
import 'package:newuijewelsync/utilis/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilis/DynamicSize.dart';
import 'changepassword_page.dart';
import 'editprofile.dart';
import 'loginpage.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double defaultFontSizeall = 12.0;
  double defaultFontSizeheading = 16.0;

  var deviceWidth = 0.0;
  var screenWidth = 0.0;
  double screenHeight = 0;
  double defaultFontSize = 16.0;
  String image = '';
  String name = 'kr';
  String mobilenoumber = '';
  String email = '';
  bool notification = true;

  String noumber = '';
  String call = '';

  @override
  void initState() {
    fetchProfileData();
    fetchLinkData();
    // image = MyRoutes.logo;
    super.initState();
  }

  Future<void> fetchLinkData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        noumber = prefs.getString('whatsapp')?.replaceAll('"', '') ?? '';
        call = prefs.getString('call')?.replaceAll('"', '') ?? '';
      });
    } catch (e) {
      print('Error fetching social links: $e');
    }
  }



  void _launchWhatsApp(String number) async {
    final String whatsappUrl = "https://wa.me/$number";
    if (!await launchUrl(Uri.parse(whatsappUrl))) {
      print('Could not launch $whatsappUrl');
    }
  }

  void _launchCalling(String number) async {
    final String telUrl = "tel:$number";
    if (!await launchUrl(Uri.parse(telUrl))) {
      print('Could not launch $telUrl');
    }
  }



  Future<void> fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      String? logo = prefs.getString('logo');
      print(logo); // Print with double quotes
      image = logo!.replaceAll('"', ''); // Remove double quotes before assigning to image


      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            setState(() {
              name = responseData['data']['profile']['name'] ?? ''; // Assign an empty string if the name is null
              mobilenoumber = responseData['data']['profile']['phone'] ?? ''; // Assign an empty string if the phone number is null
              email = responseData['data']['profile']['email'] ?? ''; // Assign an empty string if the email is null

            });
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to fetch profile items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching trending items: $e');
    }
  }
  @override
  Widget build(BuildContext context) {

    bool isTablet(BuildContext context) {
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;
      return diagonalSize > 600;
    }
    defaultFontSizeheading = isTablet(context) ? 30.0 : 30.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 16.0;




    // deviceWidth = MediaQuery.of(context).size.width;
    // screenWidth = MediaQuery.of(context).size.width;
    // screenHeight = MediaQuery.of(context).size.height;
    double defaultFontSize = 16.0;
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body:WillPopScope(
          onWillPop: () async {
            // Check if on the home screen
            if (Navigator.of(context).canPop()) {
              // Navigate back if not on the home screen
              // Navigator.of(context).pop();
              return false; // Prevent default behavior
            } else {
              // If on the home screen, open previous page on right swipe
              return true; // Allow default behavior
            }
          },
          child:SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipOval(
                      child: image!.isNotEmpty
                          ? Image.network(
                        image,
                        width:  isTablet(context) ? 400.0 : DynamicSize.scale(context, 120),
                        height: isTablet(context) ? 400.0 : DynamicSize.scale(context, 120),
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/images/banner.jpg', // Provide a placeholder image asset path
                        width: isTablet(context) ? 400.0 : DynamicSize.scale(context, 120),
                        height: isTablet(context) ? 400.0 : DynamicSize.scale(context, 120),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),//image

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: DynamicSize.scale(context, 20)),
                              child: Text(
                                'Profile Details',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 20),
                                  fontWeight: FontWeight.w600,
                                  color: ColorCode.appcolorback,
                                ),
                              ),
                            ),//details
                            Padding(
                              padding: EdgeInsets.only(right: DynamicSize.scale(context, 20)),
                              child: GestureDetector(
                                onTap: () {
                                  // Your navigation code here
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()),);
                                  // context.pushNamed(RouteConst.editProfile);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10), vertical: DynamicSize.scale(context, 5)),
                                  decoration: BoxDecoration(
                                    // color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icon/editww.svg', // Path to your SVG asset

                                        // width: 20, // Width of the SVG
                                        // height: 20, // Height of the SVG
                                      ),
                                      SizedBox(width: 4), // Space between icon and text
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: DynamicSize.scale(context, 14),
                                          fontWeight: FontWeight.w500,
                                          color: ColorCode.appcolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ) // Edit icon with text

                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 10),
                                      color: ColorCode.appcolor,
                                    ),
                                  ),
                                  SizedBox(height: 4), // Space between label and value
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 14),
                                      color: ColorCode.containerlblcolor,
                                    ),
                                  ),
                                ],
                              ),
                            ), // first row
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mobile',
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 10),
                                      color: ColorCode.appcolor,
                                    ),
                                  ),
                                  SizedBox(height: 4), // Space between label and value
                                  Text(
                                    mobilenoumber,
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 14),
                                      color: ColorCode.containerlblcolor,
                                    ),
                                  ),
                                ],
                              ),
                            ), // second row
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 10),
                                      color: ColorCode.appcolor,
                                    ),
                                  ),
                                  SizedBox(height: 4), // Space between label and value
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 14),
                                      color: ColorCode.containerlblcolor,
                                    ),
                                  ),
                                ],
                              ),
                            ), // third row
                          ],
                        ),
                      ),


                      // ),
                    ],
                  ),//details
                  // SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Setting',
                              style: TextStyle(
                                fontSize: DynamicSize.scale(context, 20),
                                fontWeight: FontWeight.w600,
                                color: ColorCode.appcolorback,
                              ),
                            ),
                            // IconButton.filled(
                            //   padding: EdgeInsets.zero,
                            //   visualDensity: const VisualDensity(vertical: -2, horizontal: -2),
                            //   onPressed: () {
                            //     // context.pushNamed(RouteConst.editProfile);
                            //   },
                            //   icon: const Icon(
                            //     Icons.edit_note_rounded,
                            //     size: 24,
                            //   ),
                            // ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              leading:   SvgPicture.asset(
                                'assets/icon/notification.svg', // Path to your SVG asset
                                color: ColorCode.containerlblcolor, // Assuming ColorCode.hintColor is blue
                              ),
                              title: Text(
                                'Notification',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  color: ColorCode.containerlblcolor,

                                ),
                              ),
                              trailing: Switch(
                                value: true, // Replace 'true' with your toggle state variable
                                onChanged: (bool value) {
                                  // Update your toggle state variable here
                                },
                              ),
                            ),
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black,),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChangePassword()),),
                              leading: SvgPicture.asset(
                                'assets/icon/lock.svg', // Path to your SVG asset
                                color: ColorCode.containerlblcolor, // Assuming ColorCode.hintColor is blue
                              ),
                              title: Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  color: ColorCode.containerlblcolor,
                                ),
                              ),
                            ),
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black,),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async{
                                // Clear shared preferences
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear();

                                // Navigate to the login page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Loginpage()),
                                );
                              },
                              leading: SvgPicture.asset(
                                'assets/icon/logout.svg', // Path to your SVG asset
                                color: ColorCode.containerlblcolor, // Assuming ColorCode.hintColor is blue
                              ),
                              title: Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  color: ColorCode.containerlblcolor,
                                ),
                              ),
                            ),
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black,),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async{
                                // Clear shared preferences
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear();

                                // Navigate to the login page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Loginpage()),
                                );
                              },
                              leading: SvgPicture.asset(
                                'assets/icon/trash.svg', // Path to your SVG asset
                                color: ColorCode.containerlblcolor, // Assuming ColorCode.hintColor is blue
                              ),
                              title: Text(
                                'Delete Accoount',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  color: ColorCode.containerlblcolor,
                                ),
                              ),
                            ),
                            Divider(thickness: 0.5, height: 10, color: ColorCode.black,),
                            // ListTile(
                            //   visualDensity: const VisualDensity(vertical: -4),
                            //   contentPadding: EdgeInsets.zero,
                            //   onTap: () async{
                            //     // Clear shared preferences
                            //     SharedPreferences prefs = await SharedPreferences.getInstance();
                            //     await prefs.clear();
                            //
                            //     // Navigate to the login page
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(builder: (context) => Loginpage()),
                            //     );
                            //     // logout(context);
                            //   },
                            //   title: Text(
                            //     'Logout',
                            //     style: TextStyle(
                            //         fontSize: defaultFontSizeall,
                            //         color: Colors.redAccent
                            //     ),
                            //   ),
                            //   trailing:  Icon(
                            //     Icons.logout_rounded,
                            //     color: Colors.redAccent,
                            //   ),
                            // ),
                            //     Divider(thickness: 0.5, height: 10, color: ColorCode.black,),
                            // ListTile(
                            //
                            //   visualDensity: const VisualDensity(vertical: -4),
                            //   contentPadding: EdgeInsets.zero,
                            //   onTap: () async{
                            //     // Clear shared preferences
                            //     SharedPreferences prefs = await SharedPreferences.getInstance();
                            //     await prefs.clear();
                            //
                            //     // Navigate to the login page
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(builder: (context) => Loginpage()),
                            //     );
                            //   },
                            //   title: Text(
                            //     'Delete Account',
                            //     style: TextStyle(
                            //         fontSize: defaultFontSizeall,
                            //         color: Colors.redAccent
                            //     ),
                            //   ),
                            //   trailing: Icon(
                            //     Icons.logout_rounded,
                            //     color: Colors.redAccent,
                            //   ),
                            // ),


                          ],
                        ),

                      ],

                    ),
                  ),//setting cards
                  Padding(
                    padding: EdgeInsets.all(DynamicSize.scale(context, 8),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: DynamicSize.scale(context, 10)),
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: DynamicSize.scale(context, 20),
                              fontWeight: FontWeight.w600,
                              color: ColorCode.appcolorback,
                            ),
                          ),
                        ),//details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _launchWhatsApp(noumber);
                                  // print(instalink);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorCode.btncolor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icon/whatsapp-icon-logo-svgrepo-com.svg', // Path to your SVG asset
                                        height: DynamicSize.scale(context, 30),
                                        // color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
                                        child: Text(
                                          'Whatsapp',
                                          style: TextStyle(
                                            fontSize: DynamicSize.scale(context, 14),
                                            color: ColorCode.appcolorback,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: DynamicSize.scale(context, 10),),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _launchCalling(call);
                                  // print(instalink);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorCode.btncolor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/icon/calling.svg', // Path to your SVG asset
                                          color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(DynamicSize.scale(context, 10)),
                                        child: Text(
                                          'Call',
                                          style: TextStyle(
                                            fontSize: DynamicSize.scale(context, 14),
                                            color: ColorCode.appcolorback,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: DynamicSize.scale(context, 10),),




                      ],
                    ),
                  ),

                ],
              ),


            ),
          ),
        ));
  }
}
