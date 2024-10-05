import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilis/CustomTextbox.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

import 'package:http/http.dart' as http;



import 'dashboard.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

var deviceWidth = 0.0;
var screenWidth = 0.0;
late double screenHeight = 0;
late double defaultFontSize = 16.0;

class Option {
  int id;
  String name;
  Option(this.id, this.name);
}

class _EditProfilePageState extends State<EditProfilePage> {

  int phoneortablet = 1;
  TextEditingController code = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  String? _selectedCountryCode;
  String? codeError;
  String? nameError;
  String? phoneError;

  List<Option> _listcountry = [
    Option(1, 'Option 1A'),
    Option(2, 'Option 2A'),
    Option(3, 'Option 3A'),
  ];//country list
  List<Option> _liststate = [
    Option(1, 'Option 1A'),
    Option(2, 'Option 2A'),
    Option(3, 'Option 3A'),
  ];//state list
  List<Option> _listcity = [
    Option(1, 'Option 1A'),
    Option(2, 'Option 2A'),
    Option(3, 'Option 3A'),
  ];//city list
  Option? _selectedcountry;//selected country
  Option? _selectedstate;//selected state
  Option? _selectedcity;//selected city
  double defaultFontSizeall = 12.0;
  double defaultFontSizeheading = 12.0;

  late List<Option> countries = [];//create country list
  late List<Option> States = [];//create country list
  late List<Option> City = [];//create country list

  late int countryid = 1;
  String? selectedCountryName;
  late int stateid = 1;
  String? selectedStateName;
  late int cityid = 1;
  String? selectedCityName;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String? token;//tokan string
  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');//assign tokan value
    fetchcountry();//call country api
  }//fetch methods
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


  Future<void> fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

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
              getToken();


              code.text = responseData['data']['profile']['code'] ?? '';
              name.text = responseData['data']['profile']['name'] ?? '';
              phone.text = responseData['data']['profile']['phone'] ?? '';
              email.text = responseData['data']['profile']['email'] ?? '';
              email.text = responseData['data']['profile']['email'] ?? '';

              countryid = responseData['data']['profile']['country_id'] ?? 1;
              stateid = responseData['data']['profile']['state_id'] ?? 1;
              cityid = responseData['data']['profile']['city_id'] ?? 1;
              _selectedcountry?.id = countryid;
              _selectedstate?.id = stateid;
              _selectedcity?.id = cityid;

              address.text = responseData['data']['profile']['address'] ?? '';

              print('Country ID: $countryid');
              print('Country Name: $selectedCountryName');
              print('State ID: $stateid');
              print('State Name: $selectedStateName');
              print('City ID: $cityid');
              print('City Name: $selectedCityName');
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
  }//fetch profile

  updateprofile(String name,String address,String countryid,String stateid,String cityid) async {
  try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}profile/update-details'),
          // Uri.parse('https://gbjewelsync.com/api/catalogue/profile/update-details'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': '$name',
            'address': '$address',
            'country_id': '$countryid',
            'state_id': '$stateid',
            'city_id': '$cityid',
          }),
        );
        print(response.statusCode);
        if (response.statusCode == 200) {

          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          if (responseData['status'] == true) {

          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to fetch trending items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching trending items: $e');
    }

    // Add your logic to add the item to the wishlist
    print('Adding item ${name} to wishlist');
    // You can call an API here or perform any other necessary action
  }// update profile
  @override
  void initState()  {
    fetchProfileData();
    fetchcountry();
    super.initState();

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


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorCode.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomTextbox(
              //   labelText: 'Enter Code',
              //   controller: code,
              //   onChanged: (value) {
              //     // Handle the quantity value here
              //     code.text = value;
              //     print('code: $value');
              //     setState(() {
              //       codeError = null; // Reset error if code is not empty
              //     });
              //   },
              //   enabled: false,
              //   errorMessage: codeError, // Pass error message as needed
              // ), // code
              SizedBox(height: DynamicSize.scale(context, 14)),
              CustomTextbox(
                labelText: 'Enter Name',
                controller: name,
                onChanged: (value) {
                  // Handle the quantity value here
                  name.text = value;
                  print('code: $value');
                  setState(() {
                    nameError = null; // Reset error if code is not empty
                  });
                },
                errorMessage: nameError, // Pass error message as needed
              ), // code
              SizedBox(height: DynamicSize.scale(context, 14)),
              Container(

                child: Row(
                  children: [

                    Expanded(
                      child: CustomTextbox(
                        borderColor:Colors.transparent,
                        labelText: 'phone',
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
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              ),//phone
              SizedBox(height: DynamicSize.scale(context, 14)),
              CustomTextbox(
                labelText: 'Enter Your Email',
                controller: email,
                onChanged: (value) {
                  // Handle the quantity value here
                  email.text = value;
                  print('email: $value');
                },
                enabled: false,
              ),//email
              SizedBox(height: DynamicSize.scale(context, 14)),
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
                              selectedCountryName = option.name;
                              selectedStateName = null;
                              selectedCityName = null;
                              print(countryid);
                              fetchstate(countryid);
                            });
                          }
                        });
                      },
                      child: Container(
                        // width: DynamicSize.screenWidth(context)/2.5,
                        padding: EdgeInsets.symmetric(horizontal:  phoneortablet == 1 ? DynamicSize.scale(context, 16) : DynamicSize.scale(context, 10), vertical:  phoneortablet == 1 ? DynamicSize.scale(context, 15) : DynamicSize.scale(context, 5),),
                        decoration: BoxDecoration(
                          color: ColorCode.textboxanddropdownbackcolor,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          selectedCountryName ?? (_selectedcountry != null ? _selectedcountry!.name : 'Select Country'),
                          style: TextStyle(fontSize: phoneortablet == 1 ? DynamicSize.scale(context, 14) : DynamicSize.scale(context, 7),color: ColorCode.appcolor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),//country
              SizedBox(height: DynamicSize.scale(context, 14)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
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
                        // width: DynamicSize.screenWidth(context)/2.5,
                        padding: EdgeInsets.symmetric(horizontal:  phoneortablet == 1 ? DynamicSize.scale(context, 16) : DynamicSize.scale(context, 10), vertical:  phoneortablet == 1 ? DynamicSize.scale(context, 15) : DynamicSize.scale(context, 5),),

                        decoration: BoxDecoration(
                          color: ColorCode.textboxanddropdownbackcolor,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          selectedStateName ?? (_selectedstate != null ? _selectedstate!.name : 'Select State'),
                          style: TextStyle(fontSize: phoneortablet == 1 ? DynamicSize.scale(context, 14) : DynamicSize.scale(context, 7),color: ColorCode.appcolor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),//state
              SizedBox(height: DynamicSize.scale(context, 14)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
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
                        // width: DynamicSize.screenWidth(context)/2.5,
                        padding: EdgeInsets.symmetric(horizontal:  phoneortablet == 1 ? DynamicSize.scale(context, 16) : DynamicSize.scale(context, 10), vertical:  phoneortablet == 1 ? DynamicSize.scale(context, 15) : DynamicSize.scale(context, 5),),

                        decoration: BoxDecoration(
                          color: ColorCode.textboxanddropdownbackcolor,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          selectedCityName ?? (_selectedcity != null ? _selectedcity!.name : 'Select city'),
                          style: TextStyle(fontSize: phoneortablet == 1 ? DynamicSize.scale(context, 14) : DynamicSize.scale(context, 7),color: ColorCode.appcolor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),//city
              SizedBox(height: DynamicSize.scale(context, 14)),
              CustomTextbox(
                labelText: 'Address',
                controller: address,
                onChanged: (value) {
                  // Handle the quantity value here
                  address.text = value;
                  print('Address: $value');
                },
              ),//address
              SizedBox(height: DynamicSize.scale(context, 28)),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save profile changes
                    print(countryid);
                    print(stateid);
                    print(cityid);
                    print('kkk');
                    print(_selectedcountry?.id);
                    print(_selectedcountry?.name);
                    print(_selectedstate?.id);
                    print(_selectedstate?.name);
                    print(_selectedcity?.id);
                    print(_selectedcity?.name);
                    print(countryid);
                    print(selectedCountryName);
                    await updateprofile(name.text, address.text, countryid.toString(), stateid.toString(), cityid.toString());
                    // Navigate back after saving changes
                    // await Navigator.pushReplacementNamed(context, MyRoutes.dashboard());
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));
                    // context.pushNamed(RouteConst.editProfile);
                  }


                },
                child: Container(
                  width: DynamicSize.scale(context, 2000),
                  // height: DynamicSize.scale(context, 40),
                  decoration: BoxDecoration(
                    color: ColorCode.appcolorback,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding:  EdgeInsets.all(DynamicSize.scale(context, 16)),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ColorCode.btntextcolor,
                          fontSize: DynamicSize.scale(context, 12),
                        ),
                      ),
                    ),
                  ),
                ),

              )],

          ),
        ),
      ),
    );
  }
}

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