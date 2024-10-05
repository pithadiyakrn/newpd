import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newuijewelsync/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utilis/AnimatedSnackBarlogin.dart';
import '../utilis/CustomTextbox.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';
import 'product_details_page.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key); // Fix the constructor syntax

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}
var deviceWidth = 0.0;
var screenWidth = 0.0;
double screenHeight = 0;
double defaultFontSize = 16.0;

class _ChangePasswordState extends State<ChangePassword> {
  bool _isShowPassword = true;
  bool _isNShowPassword = true;
  bool _isCShowPassword = true;

  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nPasswordCtrl = TextEditingController();
  final TextEditingController _cPasswordCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>(debugLabel: 'Form State');

  void updatepassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}profile/update-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'current_password': _passwordCtrl.text,
            'password': _nPasswordCtrl.text,
            'password_confirmation': _cPasswordCtrl.text,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          showCustomSnackBarusericon(context,'Password changed Successfully',ColorCode.appcolor,2000);
          Navigator.of(context).pop();
          // showToastMessage(context,'Password changed Successfully',backColor: Colors.green);
          print(responseData);
          if (responseData['status'] == true) {

          } else {
            print('API response status is false.');
          }
        } else {

          showCustomSnackBarusericon(context,'INVALID PASSWORD',Colors.red,2000);
          print('Failed to fetch items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
    // Add your logic to add the item to the wishlist

    // You can call an API here or perform any other necessary action
  }// Method to add item to cart


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorCode.textColor,
          ),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorCode.textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: DynamicSize.scale(context, 10)),
                CustomTextbox(
                  suffixIcon: Padding(
                    padding:  EdgeInsets.all(DynamicSize.scale(context, 16)),
                    child: SvgPicture.asset(
                      _isShowPassword ? 'assets/icon/eye-slash.svg' : 'assets/icon/eye.svg',
                    ),
                  ),
                  onSuffixPressed: () {
                    setState(() {
                      _isShowPassword = !_isShowPassword;
                    });
                  },
                  obscureText: _isShowPassword,
                  labelText: 'Password',
                  onChanged: (value) {
                  },

                  controller: _passwordCtrl,
                ), // Old password
                SizedBox(height: DynamicSize.scale(context, 10)),
                CustomTextbox(
                  suffixIcon: Padding(
                    padding:  EdgeInsets.all(DynamicSize.scale(context, 16)),
                    child: SvgPicture.asset(
                      _isNShowPassword ? 'assets/icon/eye-slash.svg' : 'assets/icon/eye.svg',
                    ),
                  ),
                  onSuffixPressed: () {
                    setState(() {
                      _isNShowPassword = !_isNShowPassword;
                    });
                  },
                  obscureText: _isNShowPassword,
                  labelText: 'New Password',
                  onChanged: (value) {
                    // Handle password changes
                  },
                  controller: _nPasswordCtrl,
                ), // New password
                SizedBox(height: DynamicSize.scale(context, 10)),
                CustomTextbox(
                  suffixIcon: Padding(
                    padding:  EdgeInsets.all(DynamicSize.scale(context, 16)),
                    child: SvgPicture.asset(
                      _isCShowPassword ? 'assets/icon/eye-slash.svg' : 'assets/icon/eye.svg',
                    ),
                  ),
                  onSuffixPressed: () {
                    setState(() {
                      _isCShowPassword = !_isCShowPassword;

                    });
                  },
                  obscureText: _isCShowPassword,
                  labelText: 'Confirm Password',
                  onChanged: (value) {
                    // Handle password changes
                  },

                  controller: _cPasswordCtrl,
                ), // Confirm password
                SizedBox(height: DynamicSize.scale(context, 10)),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_passwordCtrl.text.isEmpty ||
                          _nPasswordCtrl.text.isEmpty ||
                          _cPasswordCtrl.text.isEmpty) {
                        // Display snackbar for empty fields
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all required fields!',style: TextStyle(fontSize: 12),),
                          ),


                        );
                      } else {
                        if (_nPasswordCtrl.text == _cPasswordCtrl.text) {
                          // Passwords match, proceed with save action
                          print('Old Password: ${_passwordCtrl.text}');
                          print('New Password: ${_nPasswordCtrl.text}');
                          print('Confirm Password: ${_cPasswordCtrl.text}');
                          FocusScope.of(context).unfocus();
                          updatepassword();

                          // Additional action to save passwords
                        } else {
                          // Passwords don't match, show an error message
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text('Passwords do not match!',style: TextStyle(fontSize: 12),),
                          //   ),
                          // );
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Row(
                          //       children: [
                          //         Icon(
                          //           Icons.error, // Choose the icon you want to display
                          //           color: Colors.white, // Set the color of the icon
                          //         ),
                          //         SizedBox(width: 8), // Add some space between the icon and the text
                          //         Text(
                          //           'Passwords do not match!',
                          //           style: TextStyle(fontSize: 12, color: Colors.white), // Change text color if needed
                          //         ),
                          //       ],
                          //     ),
                          //     backgroundColor: Colors.red, // Set the background color
                          //     duration: Duration(seconds: 5), // Set the duration for how long the SnackBar will be displayed
                          //   ),
                          // );
                          showCustomSnackBarusericon(context,'Password Not Match ',Colors.red,2000);

                        }
                      }
                    },
                    child: Container(
                      width: 1000,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ColorCode.appcolorback,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorCode.btntextcolor,
                            fontSize: DynamicSize.scale(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

