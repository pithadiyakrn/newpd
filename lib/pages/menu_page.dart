
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newuijewelsync/utilis/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import 'htmlview.dart';
import 'package:http/http.dart' as http;


class MenuPage extends StatefulWidget {
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {


  String facebooklink = '';
  String youtubelink = '';
  String instalink = '';
  String Twitterlink = '';
  String noumber = '';
  String app_share_link = '';
  String call = '';

  String terms_and_conditions = '<p>No, you most likely need a privacy policy, especially if your website, mobile app, or desktop app collects user information and falls under regional laws like the GDPR or CCPA.</p>\r\n\r\n<p>Even if you don&rsquo;t fall under any legal jurisdictions, consumers today expect to see privacy policies and may only trust your business if one is posted.</p>\r\n\r\n<h3>What laws require a privacy policy?</h3>\r\n\r\n<p>Technically, no federal law in America requires a privacy policy besides COPPA, which is for businesses that target children under 13.</p>\r\n\r\n<p>But a privacy policy can help you meet the legal requirements of data privacy laws like the CCPA, GDPR, and PIPEDA.</p>\r\n\r\n<h3>What should my privacy policy include?</h3>\r\n\r\n<p>The exact details you should include in your privacy policy will depend on what kind of business you conduct and with whom.</p>\r\n\r\n<p>That said, most privacy policies include clauses about the information you collect from users, how and why you gather that data, how you use it, any third party you share it with, and what your users&rsquo; rights are over their data.</p>\r\n\r\n<p>Remember, cookies and other similar forms of data tracking are considered personal data and should also be outlined in your policy.</p>';

  @override
  void initState() {
    fetchSettings();
    fetchLinkData();
    super.initState();
  }

  double defaultFontSizeall = 16.0;
  double defaultFontSizeheading = 16.0;

  Future<void> fetchSettings() async {
    Stopwatch stopwatch = Stopwatch()..start(); // Start the stopwatch
    try {
      // Simulate fetching the access token from somewhere
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {

        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}settings'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        // Handle response
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == true) {
            final settings = responseData['data']['settings'];
            setState(() {
              terms_and_conditions = settings['terms_and_conditions'];
            });
            print('Terms and conditions fetched successfully');
          } else {
            print('API call was not successful');
          }
        } else {
          print('Failed to fetch settings. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
      print('fetchSettings took: ${stopwatch.elapsedMilliseconds} milliseconds');
    } catch (e) {
      print('Error fetching settings: $e');
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> fetchLinkData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        facebooklink = prefs.getString('facebook')?.replaceAll('"', '') ?? '';
        instalink = prefs.getString('instagram')?.replaceAll('"', '') ?? '';
        youtubelink = prefs.getString('whatsapp')?.replaceAll('"', '') ?? '';
        noumber = prefs.getString('whatsapp')?.replaceAll('"', '') ?? '';
        call = prefs.getString('call')?.replaceAll('"', '') ?? '';

        Twitterlink = prefs.getString('twitter')?.replaceAll('"', '') ?? '';
        app_share_link = prefs.getString('app_share_link')?.replaceAll('"', '') ?? 'www.krn.com';
      });
    } catch (e) {
      print('Error fetching social links: $e');
    }
  }

  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      if (!await launch(url)) {
        print('Could not launch $url');
      }
    } else {
      print('URL is empty');
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



  @override
  Widget build(BuildContext context) {

    bool isTablet(BuildContext context) {
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;
      return diagonalSize > 600;
    }
    defaultFontSizeheading = isTablet(context) ? 20.0 : 18.0;
    defaultFontSizeall = isTablet(context) ? 20.0 : 16.0;

    return Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate back to the previous page
                },
                child: Icon(Icons.close,color: ColorCode.appcolor,),
              ),
              Spacer(), // Use Spacer to push the text to the center
              Text(
                'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: ColorCode.appcolorback, // Adjust the font size as needed
                ),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),

        body: WillPopScope(
            onWillPop: () async {
              // Check if on the home screen
              if (Navigator.of(context).canPop()) {
                // Navigate back if not on the home screen
                Navigator.of(context).pushReplacementNamed(MyRoutes.dashboard);
                return false; // Prevent default behavior
              } else {
                // If on the home screen, open previous page on right swipe
                return false; // Allow default behavior
              }
            },
            child:ListView(
              padding: EdgeInsets.all(DynamicSize.scale(context, 8),),

              children: [
                Padding(
                  padding: EdgeInsets.all(DynamicSize.scale(context, 8),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            // color: Colors.grey.shade200
                          ),
                          child:  Text(
                            'Orders',
                            style: TextStyle(
                                fontSize: DynamicSize.scale(context, 20),
                                fontWeight: FontWeight.w500,
                                color: ColorCode.appcolorback
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pushNamed(context, MyRoutes.order);
                            },
                            title:  Text(
                              'Orders',
                              style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.containerlblcolor
                              ),
                            ),
                            trailing:  Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: ColorCode.containerlblcolor,
                            ),
                          ),
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26,),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              print('k');
                              Navigator.pushNamed(context, MyRoutes.CustomOrders);
                            },
                            title: Text(
                              'Custom Order',
                              style: TextStyle(
                                fontSize: DynamicSize.scale(context, 14),
                                fontWeight: FontWeight.w500,
                                color: ColorCode.containerlblcolor,
                              ),
                            ),
                            trailing:  Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: ColorCode.containerlblcolor,
                            ),
                          ),
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26,),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pushNamed(context, MyRoutes.wishlist);
                            },
                            title:  Text(
                              'Wishlist',
                              style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.containerlblcolor
                              ),
                            ),
                            trailing:  Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: ColorCode.containerlblcolor,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),//order


                Padding(
                  padding: EdgeInsets.all(DynamicSize.scale(context, 8),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            // color: Colors.grey.shade200
                          ),
                          child:  Text(
                            'Spread the World',
                            style: TextStyle(
                                fontSize: DynamicSize.scale(context, 20),
                                fontWeight: FontWeight.w500,
                                color: ColorCode.appcolorback
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              _launchURL(app_share_link);
                            },
                            leading:SvgPicture.asset('assets/icon/share.svg', width: 24, height: 24,color: ColorCode.containerlblcolor,),
                            title:  Text(
                              'Share App',
                              style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.containerlblcolor
                              ),
                            ),

                          ),
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26,),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              _launchURL(app_share_link);
                            },
                            leading:SvgPicture.asset('assets/icon/star.svg', width: 24, height: 24,color: ColorCode.containerlblcolor,),
                            title:  Text(
                              'Rating Us',
                              style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.containerlblcolor
                              ),
                            ),

                          ),
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26,),
                          ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HtmlDisplay(htmlContent: terms_and_conditions,)),
                              );
                              // Navigator.pushNamed(context, MyRoutes.order);
                            },
                            leading:SvgPicture.asset('assets/icon/document-text.svg', width: 24, height: 24,color: ColorCode.containerlblcolor,),
                            title:  Text(
                              'Terms & Condition',
                              style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.containerlblcolor
                              ),
                            ),

                          ),
                        ],
                      ),
                    ],
                  ),
                ),//spred the words
                const SizedBox(height: 10,),

                Padding(
                  padding: EdgeInsets.all(DynamicSize.scale(context, 8),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            // color: Colors.grey.shade200
                          ),
                          child: Text(
                            'Follow Us',
                            style: TextStyle(
                                fontSize: DynamicSize.scale(context, 20),
                                fontWeight: FontWeight.w500,
                                color: ColorCode.appcolorback
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _launchURL(facebooklink);
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
                                      'assets/icon/facebookicon.svg', // Path to your SVG asset
                                      color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
                                      child: Text(
                                        'Facebook',
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
                                _launchURL(instalink);
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
                                        'assets/icon/instaicon.svg', // Path to your SVG asset
                                        color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(DynamicSize.scale(context, 10)),
                                      child: Text(
                                        'Instagram',
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // _launchURL(instalink);
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
                                      'assets/icon/youtubeicon.svg', // Path to your SVG asset
                                      color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
                                      child: Text(
                                        'Youtube',
                                        style: TextStyle(
                                            fontSize: DynamicSize.scale(context, 15),
                                            color: ColorCode.appcolorback,
                                            fontWeight: FontWeight.w600
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
                                _launchURL(Twitterlink);
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
                                      'assets/icon/x.svg', // Path to your SVG asset
                                      color: ColorCode.appcolorback, // Assuming ColorCode.hintColor is blue
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
                                      child: Text(
                                        'Twitter',
                                        style: TextStyle(
                                          fontSize: DynamicSize.scale(context, 15),
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
                      )




                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(DynamicSize.scale(context, 8),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            // color: Colors.grey.shade200
                          ),
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                                fontSize: DynamicSize.scale(context, 20),
                                fontWeight: FontWeight.w500,
                                color: ColorCode.appcolorback
                            ),
                          ),
                        ),
                      ),
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
            )
        ));
  }
}


void main() {
  runApp(MaterialApp(
    home: MenuPage(),
  ));
}