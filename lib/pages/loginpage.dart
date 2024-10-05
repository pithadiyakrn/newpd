import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utilis/AnimatedSnackBarlogin.dart';
import '../utilis/CustomTextbox.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';
import 'package:http/http.dart' as http;

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  int phoneortablet = 1;

  TextEditingController code = TextEditingController(text: 'PDJ');
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  late String _selectedCountryCode = 'IN'; // Declare and initialize _selectedCountryCode here
  bool _obscurePassword = true;
  bool changebutton = false;
  movetohome(BuildContext context) async {
    if (
    code.text != null &&
        phone.text != null &&
        password.text != null &&
        code.text!.isNotEmpty &&
        phone.text!.isNotEmpty &&
        password.text!.isNotEmpty) {
      setState(() {
        changebutton = true;
      });

      final Map<String, dynamic> data = {
        "code": code.text!,
        "login_key": phone.text!,
        "password": password.text!,
      };

      final response = await http.post(

        Uri.parse('${MyRoutes.baseurl}login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        print(response);
        // API call successful, parse and save the token
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        final String token = responseData['access_token'];
        final String logo = responseData['vendor']['logo'];

        // Save data to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', responseData['access_token']);
        prefs.setString('vendor', jsonEncode(responseData['vendor']));
        prefs.setString('user', jsonEncode(responseData['user']));
        prefs.setString('status', jsonEncode(responseData['status']));

        prefs.setString('twitter', jsonEncode(responseData['vendor']['twitter'])) ?? '';
        prefs.setString('facebook', jsonEncode(responseData['vendor']['facebook']))?? '';
        prefs.setString('instagram', jsonEncode(responseData['vendor']['instagram']))?? '';
        prefs.setString('whatsapp', jsonEncode(responseData['vendor']['whatsapp']))?? '';
        prefs.setString('youtube', jsonEncode(responseData['vendor']['youtube']))?? '';

        prefs.setString('call', jsonEncode(responseData['vendor']['contact_person_phone']))?? '';
        prefs.setString('whatsapp', jsonEncode(responseData['vendor']['whatsapp']))?? '';
        prefs.setString('app_share_link', jsonEncode(responseData['vendor']['app_share_link']))?? 'https://play.google.com/store/games?hl=en';


        prefs.setString('logo', responseData['vendor']['logo']);


        // print(logo);

        // Set userLoggedIn flag to true
        prefs.setBool('userLoggedIn', true);



        MyRoutes.logo = responseData['vendor']['logo']?? '';


        MyRoutes.facebook = responseData['vendor']['facebook']?? '';
        MyRoutes.instagram = responseData['vendor']['instagram']?? '';
        MyRoutes.whatsapp = responseData['vendor']['whatsapp']?? '';
        MyRoutes.youtube = responseData['vendor']['youtube'] ?? '';
        MyRoutes.twitter = responseData['vendor']['twitter'] ?? '';


        print("here");



        // Navigate to home page
        // await Navigator.pushNamed(context, MyRoutes.dashboard);
        await Navigator.pushReplacementNamed(context, MyRoutes.dashboard);
      } else {

        showCustomSnackBarusericon(context,'INVALID USERNAME AND PASSWORD',Colors.red,2000);

      }

      setState(() {
        changebutton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;
      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }

    // isTablet(context) ? _crossaxixcount = 4 : _crossaxixcount = 2;
    isTablet(context) ? phoneortablet = 2 : phoneortablet = 1;//phone hoy to 1 ane tablet hoy to 2

    bool _isLoading = false;

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                // padding:  EdgeInsets.all(DynamicSize.scale(context, 10)),
                padding:  EdgeInsets.all(DynamicSize.scale(context, 10)),
                child: Column(
                  children: [
                    //
                    // ImageViewer(url: 'https://gbjewelsync.com/media/various/login-frame.png', height: size.height/3.2, width: double.infinity,),

                    Image.network(
                      'https://gbjewelsync.com/media/various/login-frame.png',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      // height:phoneortablet == 1 ? DynamicSize.scale(context,380) : DynamicSize.scale(context, 280),
                    ),
                    // Image.asset(
                    //   'assets/icon/welcome_image.png',
                    //   fit: BoxFit.fill,
                    //   width: double.infinity,
                    //   height:phoneortablet == 1 ? DynamicSize.scale(context,380) : DynamicSize.scale(context, 280),
                    // ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: phoneortablet == 1 ? DynamicSize.scale(context, 20) : 30,
                        // fontSize: DynamicSize.scale(context, 20),
                        color: ColorCode.appcolorback,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DynamicSize.scale(context, 40),
                      ),
                      child: Center(
                        child: Text(
                          'We\'re so glad to see you again. Thank you For choosing to us our services.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            // fontSize: phoneortablet == 1 ? DynamicSize.scale(context, 12) : 30,
                            fontSize:DynamicSize.scale(context, 12),
                            // height: 14.52 / DynamicSize.scale(context, 12),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    // CustomTextbox(
                    //   controller: code,
                    //   textCapitalization: TextCapitalization.characters,
                    //   labelText: 'Code',
                    //   onChanged: (value) {
                    //     // Handle the quantity value here
                    //     code.text = value;
                    //     print('code: $value');
                    //   },
                    // ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.0, color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                        color: ColorCode.textboxanddropdownbackcolor,
                      ),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryCode = value.dialCode!;
                              });
                            },
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: false,
                            showFlag: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            flagWidth: 30,
                            textStyle: TextStyle(color: ColorCode.containerlblcolor),
                            padding: EdgeInsets.all(0),
                          ),
                          // Icon(Icons.arrow_drop_down, color: ColorCode.containerlblcolor),
                          // Text('|', style: TextStyle(color: ColorCode.countrysepratedcolor, fontWeight: FontWeight.w900)),
                          SizedBox(width: 1),
                          Expanded(
                            child: CustomTextbox2(
                              backgroundColor: Colors.transparent,
                              labelText: 'Phone No.',
                              controller: phone,
                              useNumericKeyboard: true,
                              borderColor: Colors.transparent,
                              onChanged: (value) {
                                phone.text = value;
                                print('Phone: $value');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    CustomTextbox(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          _obscurePassword ? 'assets/icon/eye-slash.svg' : 'assets/icon/eye.svg',
                        ),
                      ),
                      onSuffixPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      obscureText: _obscurePassword,
                      labelText: 'Password',
                      controller: password,
                      onChanged: (value) {
                        password.text = value;
                        print('Password: $value');
                      },
                    ),
                    SizedBox(height: DynamicSize.scale(context, 8)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });

                        print('Code is ' + code.text);
                        print('Phone is ' + phone.text);
                        print('Password is ' + password.text);
                        FocusScope.of(context).unfocus();
                        movetohome(context);
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorCode.appcolorback,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: DynamicSize.scale(context, 14),
                                height: 16.94 / DynamicSize.scale(context, 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: DynamicSize.scale(context, 2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, MyRoutes.register);
                            },
                            child: Text.rich(
                              TextSpan(
                                  text: 'Don’t have an Account? ',
                                  style: TextStyle(
                                      fontSize: DynamicSize.scale(context, 12),
                                      fontWeight: FontWeight.w400,
                                      color: ColorCode.appcolor,
                                      decorationThickness: 1,
                                      decorationColor: ColorCode.appcolor),
                                  children: [
                                    TextSpan(
                                      text: 'Register',
                                      style: TextStyle(
                                        fontSize: DynamicSize.scale(context, 12),
                                        fontWeight: FontWeight.w400,
                                        color: ColorCode.black,
                                        decorationColor: ColorCode.textColor,
                                        decorationThickness: 4,
                                      ),
                                    ),
                                  ]),
                            )),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
