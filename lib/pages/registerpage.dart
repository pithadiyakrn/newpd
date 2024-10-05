import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/CustomTextbox.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/customdropdown.dart';
import '../utilis/routes.dart';
import 'editprofile.dart';
import 'loginpage.dart';


class CountryData {
  final int id;
  final String name;

  CountryData({required this.id, required this.name});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}//crate model country

class StatedData {
  final int id;
  final String name;

  StatedData({required this.id, required this.name});

  factory StatedData.fromJson(Map<String, dynamic> json) {
    return StatedData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}//crate model astate

class CityData {
  final int id;
  final String name;

  CityData({required this.id, required this.name});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}//crate model city

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {



  List<Option> _listcountry = [

  ];//country list
  List<Option> _liststate = [

  ];//state list
  List<Option> _listcity = [

  ];//city list

  double defaultFontSizeall = 20.0;
  double defaultFontSizeheading = 16.0;

  final TextEditingController _Countrydropd = TextEditingController();
  final TextEditingController _Statedropd = TextEditingController();
  final TextEditingController _Citydropd = TextEditingController();

  late List<CountryData> countries = [];//create country list
  late List<StatedData> States = [];//create country list
  late List<CityData> City = [];//create country list

  late int countryid = 101;
  late int stateid = 0;
  late int cityid = 0;

  late String? token;//tokan string
  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');//assign tokan value
    fetchcountry();//call country api
  }

  Future<void> ragister() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };
    final Map<String, dynamic> requestBody = {
      'code':code.text,
      'phone':phone.text,
      'email':email.text,
      'name':name.text,
      'password':password.text,
      'country_id':countryid.toString(),
      'state_id':stateid.toString(),
      'city_id':cityid.toString(),
      'address':address.text,
    };
    print('krn');
    print(address.text);
    final response = await http.post(Uri.parse('${MyRoutes.baseurl}register'), headers: headers,body: requestBody);
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      print(response.body.toString());
      print(response.statusCode.toString());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
      showCustomSnackBarusericon(context,'Registration Succesfull',ColorCode.appcolor,2000);

    }
    else if (response.statusCode == 302) {
      print(response.statusCode.toString());
    }
    else if (response.statusCode == 422) {
      var responseBody = jsonDecode(response.body);
      var message = responseBody['message'];
      showCustomSnackBarusericon(context,message,Colors.red,2000);
      print(message);
    }
    else {
      throw Exception('Failed to load states');
    }
  }//register methods


  Future<void> fetchcountry() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse('${MyRoutes.baseurl}countries'), headers: headers);
    // final response = await http.get(Uri.parse('https://gbjewelsync.com/api/catalogue/countries'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> countrylist = jsonDecode(response.body)['data'];
      print(countrylist);
      setState(() {
        _listcountry = countrylist.map((item) => Option(item['id'], item['name'])).toList();
        Map<int, String> countryNamesMap = {};
        countrylist.forEach((item) {
          countryNamesMap[item['id']] = item['name'];
        });

        if (countryid != null && countryNamesMap.containsKey(countryid)) {
          selectedCountryName = countryNamesMap[countryid];
          fetchstate(countryid);
          stateid = 0;
          cityid = 0;
        }
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }//fatch country methods

  Future<void> fetchstate(int countryId) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> requestBody = {
      'id': countryId.toString(),
    };
    final response = await http.post(Uri.parse('${MyRoutes.baseurl}states'), headers: headers,body: requestBody);
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> statelist = responseData['data'];
      setState(() {
        _liststate = statelist.map((item) => Option(item['id'], item['name'])).toList();
        Map<int, String> stateNamesMap = {};
        statelist.forEach((item) {
          stateNamesMap[item['id']] = item['name'];
        });
        if (stateid != null && stateNamesMap.containsKey(stateid)) {
          selectedStateName = stateNamesMap[stateid];
          fetchcity(stateid);
        }
      });
    } else {
      throw Exception('Failed to load states');
    }
  }//fatch state methods

  Future<void> fetchcity(int stateId) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> requestBody = {
      'id': stateId.toString(),
    };
    final response = await http.post(Uri.parse('${MyRoutes.baseurl}cities'), headers: headers,body: requestBody);
    // final response = await http.post(Uri.parse('https://gbjewelsync.com/api/catalogue/cities'), headers: headers,body: requestBody);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> citylist = responseData['data'];
      Map<int, String> cityNamesMap = {};
      citylist.forEach((item) {
        cityNamesMap[item['id']] = item['name'];
      });
      setState(() {
        _listcity = citylist.map((item) => Option(item['id'], item['name'])).toList();
        if (cityid != null && cityNamesMap.containsKey(cityid)) {
          selectedCityName = cityNamesMap[cityid];
        }
      });
    } else {
      throw Exception('Failed to load states');
    }
  }//fatch city methods

  TextEditingController code = TextEditingController(text: 'PDJ');
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController address = TextEditingController();
  bool _obscurePassword = true;//password show hide
  bool _obscurePasswordconfirm = true;//verify password show hide
  String? _selectedCountryCode;
  String? codeError;
  String? nameError;
  String? emailerror;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;


  Option? _selectedcountry;//selected country
  Option? _selectedstate;//selected state
  Option? _selectedcity;//selected city

  String? selectedCountryName;

  String? selectedStateName;

  String? selectedCityName;


  @override
  void initState() {
    super.initState();
    getToken();
  }
  @override
  Future<void> _showOptions(BuildContext context, List<Option> options, Option? selectedOption, Function(Option?) onSelect) async {
    Option? result = await showDialog<Option>(
      context: context,
      builder: (BuildContext context) {
        String filteredText = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                children: [
                  // Text('Select an Option'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        filteredText = value;
                      });
                    },
                    inputFormatters:  null,
                    style: TextStyle(color: ColorCode.appcolor,),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        color: ColorCode.appcolorback, // Set your label text color here
                        fontSize: DynamicSize.scale(context, 12), // Example font size adjustment
                      ),
                      hintText: 'Type to search...',
                    ),
                    cursorColor: ColorCode.appcolorback, // Set cursor color to red
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: options
                      .where((option) =>
                      option.name.toLowerCase().contains(filteredText.toLowerCase()))
                      .map((option) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(option);
                      },
                      child: ListTile(
                        title: Text(option.name),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );

    onSelect(result);
  }
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // CustomTextbox(
              //   labelText: 'Code',
              //   controller: code,
              //   textCapitalization: TextCapitalization.characters,
              //   onChanged: (value) {
              //     // Handle the quantity value here
              //     code.text = value;
              //     print('code: $value');
              //     setState(() {
              //       codeError = null; // Reset error if code is not empty
              //     });
              //   },
              //   errorMessage: codeError, // Pass error message as needed
              // ), // code
              SizedBox(height: 10),
              CustomTextbox(
                  labelText: 'Name',
                  controller: name,
                  errorMessage: nameError, // Pass error message as needed
                  onChanged: (value) {
                    // Handle the quantity value here
                    name.text = value;
                    setState(() {
                      nameError = null;
                    });
                    print('name: $value'
                    );
                  }

                // onChanged: (value) {
                //   // Handle the quantity value here
                //   name.text = value;
                //   print('name: $value');
                // },
              ),//name
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  // border: Border.all(width: 00.0,color: borderColor),
                  borderRadius: BorderRadius.circular(10), // Border radius
                  color: ColorCode.textboxanddropdownbackcolor,
                ),

                child: Row(
                  children: [
                    SizedBox(width: 10),
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
                      flagWidth: 30, // Adjust the flag width as needed
                    ),
                    Text('|', style: TextStyle(color: Colors.black)), // Add this to display
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomTextbox(
                        backgroundColor: Colors.transparent,
                        borderColor:Colors.transparent,
                        labelText: 'Phone No',
                        controller: phone,
                        useNumericKeyboard: true,
                        errorMessage: phoneError, // Pass error message as needed
                        onChanged: (value) {
                          // Handle the quantity value here
                          phone.text = value;
                          setState(() {
                            phoneError = null;
                          });
                          print('phone: $value');
                        },
                      ),
                    ),
                  ],
                ),
              ),//phone
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showOptions(context, _listcountry, _selectedcountry, (Option? option) {
                          if (option != null) {
                            setState(() {
                              _selectedcountry = option;
                              countryid = option.id; // Assigning the selected country ID
                              stateid = 0; // Assigning the selected country ID
                              cityid = 0; // Assigning the selected country ID
                              selectedCountryName = option.name;
                              selectedStateName = null;
                              selectedCityName = null;
                              print(countryid);
                              fetchstate(countryid);
                              fetchcity(stateid);
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 12), vertical: DynamicSize.scale(context, 12)),
                        decoration: BoxDecoration(
                          color: ColorCode.textboxanddropdownbackcolor,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          selectedCountryName ?? (_selectedcountry != null ? _selectedcountry!.name : 'Select Country'),
                          style: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),//country
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showOptions(context, _liststate, _selectedstate, (Option? option) {
                            if (option != null) {
                              setState(() {
                                _selectedstate = option;
                                stateid = option.id; // Assigning the selected country ID
                                stateid = option.id; // Assigning the selected country ID
                                selectedStateName = option.name;
                                selectedCityName = null;
                                print(stateid);
                                fetchcity(stateid);
                              });
                            }
                          });
                        },
                        child: Container(
                          width: DynamicSize.screenWidth(context)/2.5,
                          padding: EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 12), vertical: DynamicSize.scale(context, 12)),
                          decoration: BoxDecoration(
                            color: ColorCode.textboxanddropdownbackcolor,
                            // border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            selectedStateName ?? (_selectedstate != null ? _selectedstate!.name : 'Select State'),
                            style: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                          ),
                        ),
                      ),
                    ],
                  ),//state

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showOptions(context, _listcity, _selectedcity, (Option? option) {
                            if (option != null) {
                              setState(() {
                                _selectedcity = option;
                                cityid = option.id;
                                selectedCityName = option.name;
                              });
                            }
                          });
                        },
                        child: Container(
                          width: DynamicSize.screenWidth(context)/2.5,
                          padding: EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 12), vertical: DynamicSize.scale(context, 12)),
                          decoration: BoxDecoration(
                            color: ColorCode.textboxanddropdownbackcolor,
                            // border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            selectedCityName ?? (_selectedcity != null ? _selectedcity!.name : 'Select city'),
                            style: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                          ),
                        ),
                      ),
                    ],
                  ),//city
                ],
              ),//state and city


              SizedBox(height: 10),
              CustomTextbox(
                labelText: 'Address',
                controller: address,
                onChanged: (value) {
                  // Handle the quantity value here
                  address.text = value;
                  print('Address: $value');
                },
              ),//address
              SizedBox(height: 10),
              CustomTextbox(
                labelText: 'Enter Your Email',
                controller: email,
                errorMessage: emailerror, // Pass error message as needed
                // onChanged: (value) {
                //   email.text = value;
                //   setState(() {
                //     emailerror = null;
                //   });

                onChanged: (value) {
                  // Handle the quantity value here
                  email.text = value;
                  setState(() {
                    emailerror = null;
                  });
                  print('email: $value');
                },
              ),//email
              SizedBox(height: 10),
              CustomTextbox(
                suffixIcon: SvgPicture.asset(
                  _obscurePassword
                      ? 'assets/icon/eye.svg'
                      : 'assets/icon/eye-slash.svg',
                ),
                onSuffixPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });

                },
                labelText: 'password',
                controller: password,
                onChanged: (value) {
                  // Handle the quantity value here
                  password.text = value;
                  print('password: $value');
                  if (confirmPassword.text != password.text) {
                    setState(() {
                      passwordError = 'Passwords do not match.';
                    });
                  }else
                    setState(() {
                      passwordError = null;
                      confirmPasswordError = null;
                    });
                },
                errorMessage: passwordError, // Pass error message as needed
              ), // password
              SizedBox(height: 10),
              CustomTextbox(
                suffixIcon: SvgPicture.asset(
                  _obscurePasswordconfirm
                      ? 'assets/icon/eye.svg'
                      : 'assets/icon/eye-slash.svg',
                ),
                onSuffixPressed: () {
                  setState(() {
                    _obscurePasswordconfirm = !_obscurePasswordconfirm;
                  });

                },
                labelText: 'Verify password',
                controller: confirmPassword,
                onChanged: (value) {
                  // Handle the quantity value here
                  confirmPassword.text = value;
                  // Validate confirm password
                  if (password.text != confirmPassword.text) {
                    setState(() {
                      confirmPasswordError = 'Passwords do not match.';
                    });
                  }else
                    setState(() {
                      passwordError = null;
                      confirmPasswordError = null;
                    });
                  print('confirmPassword: $value');
                },
                errorMessage: confirmPasswordError, // Pass error message as needed
              ), // verify password
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // print(code.text);
                    print(phone.text);
                    print(email.text);
                    print(name.text);
                    print(password.text);
                    print(confirmPassword.text);
                    print(countryid.toString());
                    print(stateid.toString());
                    print(cityid.toString());
                    print(address.text);
                    print('Submit');
                    // Add your validation checks here
                    // Validate code
                    // if (code.text.isEmpty) {
                    //   setState(() {
                    //     codeError = 'Code cannot be empty.';
                    //   });
                    // }
                    if (name.text.isEmpty) {
                      setState(() {
                        nameError = 'Name cannot be empty.';
                      });
                    }
                    if (email.text.isEmpty) {
                      setState(() {
                        emailerror = 'Email cannot be empty.';
                      });
                    }

                    // Validate phone
                    if (phone.text.length < 10) {
                      setState(() {
                        phoneError = 'Phone number must be at least 10 digits.';
                      });
                    }
                    // Validate password
                    if (password.text.length < 6) {
                      setState(() {
                        passwordError = 'Password must be at least 6 characters.';
                      });
                    }

                    print(nameError);
                    print(phoneError);
                    print(passwordError);
                    print(emailerror);
                    // Check if any errors occurred
                    if (nameError == null && phoneError == null && passwordError == null && emailerror == null) {
                      FocusScope.of(context).unfocus();
                      // if (nameError == null && codeError == null && phoneError == null && passwordError == null) {
                      // All checks passed, call the register method
                      ragister();
                    }
                  },
                  child: Container(
                    // width: defaultFontSizeall * 100,
                    // height: defaultFontSizeall * 3,
                    decoration: BoxDecoration(
                      color: ColorCode.appcolorback,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Change text color according to your app theme
                            fontSize: DynamicSize.scale(context, 12), // Adjust font size as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        // Navigate to register page
                        Navigator.pushNamed(context, MyRoutes.login);
                      },
                      child: Text.rich(
                        TextSpan(
                            text: 'Alerdy have an account? ',
                            style:  TextStyle(
                                fontSize: DynamicSize.scale(context, 14),
                                fontWeight: FontWeight.w400,
                                color: ColorCode.hintColor,
                                // decoration: TextDecoration.underline,
                                decorationThickness: 1,
                                decorationColor: ColorCode.hintColor
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontSize: DynamicSize.scale(context, 14),
                                  fontWeight: FontWeight.w400,
                                  color: ColorCode.black,

                                  decorationColor: ColorCode.textColor,
                                  decorationThickness: 4,
                                ),
                              ),
                            ]

                        ),
                      )
                  ),
                ],
              ),
              SizedBox(height: 170),




            ],
          ),
        ),
      ),
    );
  }
}

