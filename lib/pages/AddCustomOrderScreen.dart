
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';




class cetegoryData {
  final int id;
  final String name;

  cetegoryData({required this.id, required this.name});

  factory cetegoryData.fromJson(Map<String, dynamic> json) {
    return cetegoryData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}//crate model cetegoryData

class purityData {
  final int id;
  final String name;

  purityData({required this.id, required this.name});

  factory purityData.fromJson(Map<String, dynamic> json) {
    return purityData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}//crate model purityData



class addcustomeorderPage extends StatefulWidget {
  const addcustomeorderPage({Key? key}) : super(key: key);

  @override
  _addcustomeorderPageState createState() => _addcustomeorderPageState();
}

class _addcustomeorderPageState extends State<addcustomeorderPage> {

  purityData? selectedPurity;

  late int fontsizethere = 14;

  List<dynamic> formDataList = [];
  Map<int, dynamic> formData = {};

  Map<int, dynamic> instructions = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key

  Future<void> _fetchItemsDetails(String itemid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}customize-orders/$itemid/get-instructions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final List<dynamic> instructionsData = responseData['data'];
          instructionsData.sort((a, b) => a['position'].compareTo(b['position']));

          for (var item in instructionsData) {
            // Check if 'values' is not null and is a String
            if (item['values'] != null && item['values'] is String) {
              String dropdownValues = item['values']; // Get dropdown values as string
              print('Dropdown values for ${item['name']}: $dropdownValues');
            } else {
              print('No dropdown values for ${item['name']}');
            }
          }
          print(responseData.toString());
          print(instructionsData);
          setState(() {
            instructions.clear(); // Clear previous instructions
            for (var instruction in instructionsData) {
              instructions[instruction['id']] = instruction;
            }
          });
        } else {
          print('Failed to fetch items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }//fetch dynamic values

  Map<String, String> generateRequestBodyString(Map<String, dynamic> requestBody) {
    Map<String, String> bodyString = {};
    requestBody.forEach((key, value) {
      bodyString[key] = value;
    });
    return bodyString;
  }

  // Map<String, dynamic> generateRequestBody() {
  //   Map<String, dynamic>? body = {};
  //
  //   instructions.forEach((key, value) {
  //     if (value['control_type'] == 3) {
  //       // For range dropdowns
  //       var dropdownValues = value['value'];
  //       if (dropdownValues != null) {
  //         String name = value['name'] is String ? value['name'] : '';
  //         String nameWithUnderscores = name.replaceAll(' ', '_');
  //         String fromValue = dropdownValues[0]?.toString() ?? ''; // Convert to string
  //         String toValue = dropdownValues[1]?.toString() ?? ''; // Convert to string
  //
  //         // Check if from and to values are the same, then adjust the 'to' value
  //         if (fromValue == toValue) {
  //           // int adjustedToValue = int.parse(fromValue) + 2; // Increment 'from' by 2 to get a different 'to'
  //           body['instructions[${nameWithUnderscores}_from]'] = fromValue;
  //           body['instructions[${nameWithUnderscores}_to]'] = toValue;
  //         } else {
  //           body['instruction[${nameWithUnderscores}_from]'] = fromValue;
  //           body['instruction[${nameWithUnderscores}_to]'] = toValue;
  //         }
  //       } else {
  //         String name = value['name'] is String ? value['name'] : '';
  //         String nameWithUnderscores = name.replaceAll(' ', '_');
  //         body['instructions[${nameWithUnderscores}_from]'] = '';
  //         body['instructions[${nameWithUnderscores}_to]'] = '';
  //       }
  //
  //       String nameWithHyphens = (value['name'] is String ? value['name'] : '').replaceAll(' ', '-');
  //       body['instructions[$nameWithHyphens]'] = value['control_type']?.toString() ?? ''; // Convert to string
  //     }
  //
  //
  //     else {
  //       // For other control types
  //       String name = value['name'].replaceAll(' ', '_'); // Replace spaces with underscores
  //       // Ensure value is converted to string if it's an integer
  //       var valueToUse = value['value'];
  //       if (valueToUse == null) {
  //         valueToUse = ''; // Convert null value to string "null"
  //       } else if (valueToUse is int) {
  //         valueToUse = valueToUse.toString();
  //       }
  //       body['instructions[$name]'] = valueToUse;
  //       body['instructions[${value['name']}_control_type'] = value['control_type'].toString(); // Convert to string
  //
  //
  //     }
  //   });
  //
  //   // instructions.forEach((key, value) {
  //   //   if (value['control_type'] == 3) {
  //   //     // For range dropdowns
  //   //     var dropdownValues = value['value'];
  //   //     if (dropdownValues != null) {
  //   //       String name = value['name'] is String ? value['name'] : '';
  //   //       String nameWithUnderscores = name.replaceAll(' ', '_');
  //   //       String fromValue = dropdownValues[0]?.toString() ?? ''; // Convert to string
  //   //       String toValue = dropdownValues[1]?.toString() ?? ''; // Convert to string
  //   //
  //   //       // Check if from and to values are the same, then adjust the 'to' value
  //   //       if (fromValue == toValue) {
  //   //         int adjustedToValue = int.parse(fromValue) + 2; // Increment 'from' by 2 to get a different 'to'
  //   //         body['instruction[${nameWithUnderscores}_from]'] = fromValue;
  //   //         body['instruction[${nameWithUnderscores}_to]'] = adjustedToValue.toString();
  //   //       } else {
  //   //         body['instruction[${nameWithUnderscores}_from]'] = fromValue;
  //   //         body['instruction[${nameWithUnderscores}_to]'] = toValue;
  //   //       }
  //   //     } else {
  //   //       String name = value['name'] is String ? value['name'] : '';
  //   //       String nameWithUnderscores = name.replaceAll(' ', '_');
  //   //       body['instruction[${nameWithUnderscores}_from]'] = '';
  //   //       body['instruction[${nameWithUnderscores}_to]'] = '';
  //   //     }
  //   //
  //   //     String nameWithHyphens = (value['name'] is String ? value['name'] : '').replaceAll(' ', '-');
  //   //     body['instruction[$nameWithHyphens]'] = value['control_type']?.toString() ?? ''; // Convert to string
  //   //   } else {
  //   //     // For other control types
  //   //     String name = value['name'].replaceAll(' ', '_'); // Replace spaces with underscores
  //   //     // Ensure value is converted to string if it's an integer
  //   //     var valueToUse = value['value'];
  //   //     if (valueToUse == null) {
  //   //       valueToUse = ''; // Convert null value to empty string
  //   //     } else if (valueToUse is int) {
  //   //       valueToUse = valueToUse.toString(); // Convert integer value to string
  //   //     }
  //   //     body['instruction[$name]'] = valueToUse;
  //   //     body['instruction[${value['name']}_control_type'] = value['control_type'].toString(); // Convert to string
  //   //   }
  //   // });
  //
  //   // body['remark'] = remarks;
  //
  //   return body!;
  // }


  dynamic dropdownValueFrom = [];
  dynamic dropdownValueTo = [];


  Map<String, dynamic> generateRequestBody() {
    Map<String, dynamic> body = {};

    instructions.forEach((key, value) {
      if (value['control_type'] == 3) {
        // For range dropdowns
        var dropdownValues = value['value'];
        if (dropdownValues != null) {
          String name = value['name'] is String ? value['name'] : '';
          String nameWithUnderscores = name.replaceAll(' ', '_');

          var str1 = "";
          for (var entry in dropdownValueFrom.reversed.toList()) {
            if (entry.key == name) {
              str1 = entry.value;
              break;
            }
          }

          var str2 = "";
          for (var entry in dropdownValueTo.reversed.toList()) {
            if (entry.key == name) {
              str2 = entry.value;
              break;
            }
          }

          // Use actual from and to values
          body['instructions[${nameWithUnderscores}_from]'] = str1;
          body['instructions[${nameWithUnderscores}_to]'] = str2;

          // Print the values explicitly
          print('${name} from value is $str1');
          print('${name} to value is $str2');
        } else {
          String name = value['name'] is String ? value['name'] : '';
          String nameWithUnderscores = name.replaceAll(' ', '_');
          body['instructions[${nameWithUnderscores}_from]'] = '';
          body['instructions[${nameWithUnderscores}_to]'] = '';
        }

        String nameWithHyphens = (value['name'] is String ? value['name'] : '').replaceAll(' ', '-');
        body['instructions[$nameWithHyphens]'] = value['control_type']?.toString() ?? ''; // Convert to string
      } else {
        // For other control types
        String name = value['name'].replaceAll(' ', '_'); // Replace spaces with underscores
        // Ensure value is converted to string if it's an integer
        var valueToUse = value['value'];
        if (valueToUse == null) {
          valueToUse = ''; // Convert null value to string "null"
        } else if (valueToUse is int) {
          valueToUse = valueToUse.toString();
        }
        body['instructions[$name]'] = valueToUse;
        body['instructions[${value['name']}_control_type]'] = value['control_type'].toString(); // Convert to string
      }
    });

    return body;
  }


  addToOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        Map<String, dynamic> requestBody = generateRequestBody(); // Generate the request body
        Map<String, String> requestBodyString = generateRequestBodyString(requestBody);


        requestBodyString['subname'] = subname.text;
        requestBodyString['reference_name'] = refreancename.text;
        requestBodyString['remark'] = remarks.text;
        requestBodyString['approx_gross_weight'] = approxgrosswt.text;
        requestBodyString['description'] = descriptions.text;
        requestBodyString['remark'] = remarks.text;
        requestBodyString['due_date'] = duedatebackend.text;
        // requestBodyString['due_date'] = "2024-05-05";
        requestBodyString['category_id'] = categoryid.toString();
        requestBodyString['purity_id'] = purityid.toString();
        requestBodyString['quantity'] = qty.text;
        requestBodyString['pcs'] = pcs.text;

        var request = http.MultipartRequest('POST', Uri.parse('${MyRoutes.baseurl}customize-orders'));

        // Add image files
        for (int i = 0; i < _imageFiles.length; i++) {
          var imageFile = _imageFiles[i];
          request.files.add(await http.MultipartFile.fromPath(
            'images[$i]',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'), // Adjust the content type as needed
          ));
        }

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        });



        request.fields.addAll(requestBodyString);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);


        // if (response.statusCode == 302) {
        //   // Handle redirection
        //   var redirectUrl = response.headers['location'];
        //   print('Redirecting to: $redirectUrl');
        //   // Resend the request to the new location
        //   response = await http.post(Uri.parse(redirectUrl!), headers: {
        //     'Authorization': 'Bearer $token',
        //     'Accept': 'application/json',
        //   }, body: requestBodyString);
        // }
        if (response.statusCode == 200) {

          print(requestBodyString.toString());
          print(response.body);
          print(requestBodyString);


          print('genrated body');
          print(generateRequestBodyString);
          Navigator.pushReplacementNamed(context, MyRoutes.thankyou);




          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            // Handle success
          } else {
            print('API response status is false.');
            print(responseData);
          }
        } else {


          final Map<String, dynamic> responseData = jsonDecode(response.body);
          //
          print(responseData);
          print(requestBody);
          String responseDataString = response.statusCode.toString() + responseData.toString();

          int maxLength = responseDataString.length < 300 ? responseDataString.length : 300;
          String  errorhere = responseDataString.substring(0, maxLength).toString();

          showCustomSnackBar(context,errorhere,Colors.red,2000);
          setState(() {
            _isPlacingOrder = false;
          });
          print('Failed to place order. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error placing order: $e');
    }
    print('Adding item to order');
  }



  late List<cetegoryData> category = [];//create country list
  late List<purityData> purity = [];//create country list


  late int categoryid = 1;
  late int purityid = 1;

  bool _isPlacingOrder = false;

  late DateTime _selectedDate;

  Future<void> fetchcategory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}customize-orders/create'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            final Map<String, dynamic> data = responseData['data'];

            final List<dynamic> categoryListData = data['categories'];
            final List<dynamic> purityListData = data['purities'];

            setState(() {
              category = categoryListData.map((item) => cetegoryData.fromJson(item)).toList();
              purity = purityListData.map((item) => purityData.fromJson(item)).toList();
            });
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to fetch trending items. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching trending items: $e');
    }
  }//fetchcateegory and purity dropdown


  TextEditingController subname = TextEditingController();
  TextEditingController refreancename = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController approxgrosswt = TextEditingController();
  TextEditingController descriptions = TextEditingController();
  TextEditingController duedate = TextEditingController();
  TextEditingController duedatebackend = TextEditingController();
  TextEditingController pcs = TextEditingController();
  TextEditingController qty = TextEditingController();
  final TextEditingController categorydp = TextEditingController();
  final TextEditingController purityydp = TextEditingController();
  final TextEditingController selectedDateController = TextEditingController();


  String? selectedCategory; // Define a variable to store the selected category

  List<File> _imageFiles = []; // List to store selected image files

  String? selectedValue;
  List<String> items = ["Brazil", "Italy", "Tunisia", 'Canada'];

  Future<void> _getImage(ImageSource source) async {
    if (_imageFiles.length < 5) {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path)); // Add the picked image file to the list
        });
      }
    } else {
      // Show an error message or toast indicating that the maximum limit has been reached
      // You can use Fluttertoast or any other package for showing toast messages

    }
  }

  @override
  void initState() {
    super.initState();
    fetchcategory();
    _selectedDate = DateTime.now();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Orders',style: TextStyle(
            fontWeight: FontWeight.w400,
            color: ColorCode.appcolorback
        ),),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey, // Set form key
        child: SingleChildScrollView(

          padding:  EdgeInsets.all( DynamicSize.scale(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback,
                        style: TextStyle(
                          color: ColorCode.appcolorback, // Set the text color
                          fontWeight: FontWeight.w400,
                          // fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: ColorCode.appcolorback,
                          ),
                          hintText: 'Sub Name',
                          border: InputBorder.none, // Remove the default underline
                        ),
                        onChanged: (value) {
                          setState(() {
                            subname.text = value;
                            print(subname.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ), //subname
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        decoration: InputDecoration(

                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Refrance Name',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            refreancename.text = value;
                            print(refreancename.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//refrance
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        decoration: InputDecoration(

                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Approx Gross Weight',
                          border: InputBorder.none,
                        ),


                        onChanged: (value) {
                          setState(() {
                            approxgrosswt.text = value;
                            print(approxgrosswt.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//approx_grosswts
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        decoration: InputDecoration(

                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Desctiprions',
                          border: InputBorder.none,
                        ),

                        onChanged: (value) {
                          setState(() {
                            descriptions.text = value;
                            print(descriptions.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//descriptions
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        decoration: InputDecoration(

                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Remarks',
                          border: InputBorder.none,
                        ),

                        onChanged: (value) {
                          setState(() {
                            remarks.text = value;
                            print(remarks.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//remarks
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        readOnly: true, // Make the text field read-only
                        controller: duedate,
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: ColorCode.appcolorback, // Header background color
                                    onPrimary: Colors.white, // Header text color
                                    onSurface: Colors.black, // Body text color
                                  ),
                                  buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary, // Text color of buttons
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selectedDate != null) {
                            setState(() {
                              // Format the selected date to display as dd-mm-yyyy
                              String formattedDate = '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}';
                              String formattedDatebackednd = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                              duedate.text = formattedDate; // Update the text field with the selected date
                              duedatebackend.text = formattedDatebackednd; // Update the text field with the selected date
                            });
                          }
                        },
                        style: TextStyle(color: ColorCode.appcolor), // Change text color to blue
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Due Date',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Due Date is required'; // Return error message if no due date is selected
                          }
                          return null; // Return null if the value is valid
                        },
                      ),
                    ),
                  ),
                ],
              ),//duedate
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: DropdownButtonFormField<cetegoryData>(

                        decoration: InputDecoration(

                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Select Category',
                          border: InputBorder.none,
                        ),
                        // value: selectedCategory, // Use the selected category as value
                        items: category.map<DropdownMenuItem<cetegoryData>>((cetegoryData data) {
                          return DropdownMenuItem<cetegoryData>(
                            value: data, // Use the value directly
                            child: Text(data.name,style: TextStyle(color: ColorCode.appcolorback),), // Display the name of the category
                          );
                        }).toList(),
                        onChanged: (cetegoryData? value) {
                          setState(() {
                            if (value != null) {
                              categoryid = value.id;
                              _fetchItemsDetails(value.id.toString()); // Fetch items based on the selected category's ID
                            }
                            // selectedCategory = value; // Update the selected category
                            // You can also access the selected category's ID here: value?.id
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category'; // Return error message if no category is selected
                          }
                          return null; // Return null if the value is valid
                        },
                      ),
                    ),
                  ),
                ],
              ),//category
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: DropdownButtonFormField<purityData>(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Select Purity',
                          border: InputBorder.none,
                        ),
                        // value: selectedCategory, // Use the selected category as value
                        items: purity.map<DropdownMenuItem<purityData>>((purityData data) {
                          return DropdownMenuItem<purityData>(
                            value: data, // Use the value directly
                            child: Text(data.name,style: TextStyle(color: ColorCode.appcolorback),), // Display the name of the category
                          );
                        }).toList(),
                        onChanged: (purityData? value) {
                          setState(() {
                            purityid = value!.id;
                            // You can also access the selected category's ID here: value?.id
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a Purity'; // Return error message if no category is selected
                          }
                          return null; // Return null if the value is valid
                        },
                      ),
                    ),
                  ),
                ],
              ),//purity
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Pcs',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            pcs.text = value;
                            print(pcs.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//pcs
              SizedBox(height: DynamicSize.scale(context, 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorCode.textboxanddropdownbackcolor,
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only( left:DynamicSize.scale(context, 8)),
                      child: TextFormField(
                        cursorColor: ColorCode.appcolorback, // Set the cursor color
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: ColorCode.appcolorback,),
                          hintText: 'Qty',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            qty.text = value;
                            print(qty.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),//qty
              SizedBox(height: DynamicSize.scale(context, 10)),
              Container(
                height: 100, // Adjust the height as needed

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length + 1, // Plus 1 for the "Add Image" container
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 10); // Add horizontal space between containers
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      // Display "Add Image" container
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Select Image Source",style: TextStyle(color: ColorCode.appcolorback)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _getImage(ImageSource.camera);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Camera",style: TextStyle(color: ColorCode.appcolorback),),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _getImage(ImageSource.gallery);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Gallery",style: TextStyle(color: ColorCode.appcolorback),),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          // color: Colors.grey, // Customize container color
                          child: Center(
                            child: Image.asset(
                              'assets/icon/image-upload.png', // Replace 'add_image_icon.png' with your asset image path
                              width: 100, // Adjust width of the asset image
                              height: 100, // Adjust height of the asset image
                              // color: Colors.blue, // Customize image color if needed
                            ),
                          ),
                        ),

                      );
                    } else {
                      // Display image containers
                      bool showCloseButton = true; // Control the visibility of the close button
                      final imageIndex = index - 1; // Adjust index to match _imageFiles list
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Toggle the visibility of the close button
                            showCloseButton = !showCloseButton;
                          });
                        },
                        child: Stack(
                          children: [
                            Image.file(
                              _imageFiles[imageIndex],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            if (showCloseButton) // Display close button conditionally
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/icon/imageremove.svg', // Path to your SVG asset
                                    width: 20, // Width of the SVG
                                    height: 20, // Height of the SVG
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      // Remove the image from the list
                                      _imageFiles.removeAt(imageIndex);
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: DynamicSize.scale(context, 10)),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // Disable scrolling
                        itemCount: instructions.length,
                        itemBuilder: (context, index) {
                          final instruction = instructions.values.elementAt(index);
                          return _buildFormField(instruction);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Center(
              //   child: GestureDetector(
              //
              //
              //
              //     onTap: () {
              //       print(_formKey);
              //       if (_formKey.currentState != null && _formKey.currentState!.validate()) {
              //         print('kk');
              //         Navigator.pushReplacementNamed(context, MyRoutes.thankyou);
              //         addToOrder(); // Pass formData to addToorder method
              //       } else {
              //         print('here else parts');
              //       }
              //     },
              //     child: Container(
              //       width: 1000,
              //       height: 50,
              //       decoration: BoxDecoration(
              //         color: ColorCode.appcolorback,
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Center(
              //         child: Text(
              //           'Place Order',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: ColorCode.btntextcolor,
              //             fontSize: 20,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Center(
                child: GestureDetector(
                  onTap: _onPlaceOrder,
                  child: Container(
                    width: 1000,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ColorCode.appcolorback,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: _isPlacingOrder
                            ? SpinKitThreeBounce(
                          color: ColorCode.btntextcolor,
                          size: 20.0,
                          key: ValueKey('loading'),
                        )
                            : Text(
                          'Place Order',
                          key: ValueKey('text'),
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
              ),
              SizedBox(height: DynamicSize.scale(context, 10)),
            ],
          ),
        ),
      ),
    );
  }
  void _onPlaceOrder() {


    // Your form validation logic here
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (!_isPlacingOrder) {
        setState(() {
          _isPlacingOrder = true;
        });
        addToOrder(); // Pass formData to addToorder method
      } else {
        print('Form is not valid');
      }
    }
  }

  // List<dynamic> printFormData() {
  //   List<dynamic> formDataList = [];
  //   instructions.forEach((key, value) {
  //
  //     if (value['control_type'] == 3) {
  //       // For range dropdowns, add both dropdown labels to formDataList
  //       var dropdownValues = value['value'];
  //       formDataList.add({
  //         'instructions[${value['name']}_from]': dropdownValues[0],
  //         'instructions[${value['name']}_to]': dropdownValues[1]
  //       });
  //     } else {
  //       // For other control types, add the value to formDataList
  //       formDataList.add({'instructions[${value['name']}]': value['value']});
  //     }
  //   });
  //
  //   // Print formDataList to console
  //   formDataList.forEach((formData) {
  //     formData.forEach((key, value) {
  //       print('$key = $value');
  //     });
  //   });
  //
  //   return formDataList;
  // }

  List<dynamic> printFormData() {
    List<dynamic> formDataList = [];
    instructions.forEach((key, value) {
      if (value['control_type'] == 3) {
        // For range dropdowns, add both dropdown labels to formDataList
        var dropdownValues = value['value'];
        formDataList.add({
          'instructions[${value['name']}_from]': dropdownValues[0],
          'instructions[${value['name']}_to]': dropdownValues[1]
        });

        // Print the dropdown values explicitly
        print('${value['name']} from value is ${dropdownValues[0]}');
        print('${value['name']} to value is ${dropdownValues[1]}');
      } else {
        // For other control types, add the value to formDataList
        formDataList.add({'instructions[${value['name']}]': value['value']});
      }
    });

    // Print formDataList to console
    formDataList.forEach((formData) {
      formData.forEach((key, value) {
        print('$key = $value');
      });
    });

    return formDataList;
  }



  Widget _buildFormField(dynamic instruction) {
    if (instruction == null || instruction['id'] == null) {
      return Container();
    }

    final int? id = instruction['id'];
    final String? name = instruction['name'];
    final int? controlType = instruction['control_type'];
    final bool? isRequired = instruction['is_require'] != null ? instruction['is_require'] == 1 : false;

    // Ensure that values is a List<dynamic> or null
    List<String>? values = instruction['values'] != null ? instruction['values'].split(',') : null;

    String labelText = name ?? '';

    switch (controlType) {
      case 1:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildTextBox(id!, labelText, isRequired as bool),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildDropdown(id!, labelText, values ?? [], isRequired as bool),
        );
      case 3:
      // Assuming _buildRangeDropdown is implemented
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildRangeDropdown(id!, labelText, values ?? [], isRequired as bool),
        );
      default:
        return Container(); // Placeholder for other control types
    }
  }


  Widget _buildTextBox(int id, String labelText, bool isRequired) {
    if (isRequired == true) {
      labelText += ' *'; // Add asterisk to label text for required fields
    }
    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = ColorCode.bordercolordyanimic ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: ColorCode.textboxanddropdownbackcolor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextFormField(
                cursorColor: ColorCode.appcolorback,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: ColorCode.appcolorback,),
                  hintText: labelText,
                  border: InputBorder.none,
                ),
                validator: isRequired ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                } : null,
                onChanged: (value) {
                  setState(() {
                    // Update the 'value' field in the instruction object
                    if (instructions.containsKey(id)) {
                      instructions[id]['value'] = value;
                    } else {
                      instructions[id] = {'id': id, 'name': labelText, 'value': value};
                    }
                    print(instructions[id]['value'] = value);
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }//textfilds 1

  Widget _buildDropdown(int id, String name, List<dynamic> values, bool isRequired) {

    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = ColorCode.bordercolordyanimic ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    dynamic dropdownValue;

    if (isRequired == true) {
      name += ' *'; // Add asterisk to label text for required fields
      print(dropdownValue.toString());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: ColorCode.textboxanddropdownbackcolor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
            child: DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                hintStyle: TextStyle(color: ColorCode.appcolorback,),
                hintText: 'Select $name',
                border: InputBorder.none,
              ),
              items: values.map<DropdownMenuItem<dynamic>>((value) {
                return DropdownMenuItem<dynamic>(
                  value: value, // Use the value directly
                  child: Text(value.toString(),style: TextStyle(color: ColorCode.appcolorback,),), // Display the value as the text
                );
              }).toList(),
              onChanged:(value) {
                setState(() {
                  dropdownValue = value; // Assign the selected value
                  // Update the 'value' field in the instruction object
                  if (instructions.containsKey(id)) {
                    instructions[id]['value'] = dropdownValue;
                  } else {
                    instructions[id] = {'id': id, 'name': name, 'value': dropdownValue};
                  }
                  print(instructions[id]['value'] = value);
                });
              },
              validator: isRequired ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              } : null,
            ),
          ),
        ),
      ],
    );
  }//dropdown

  Widget _buildRangeDropdown(int id, String name, List<dynamic> values, bool isRequired) {
    String namelocal  = "select";
    namelocal = name;
    if (isRequired == true) {
      namelocal = name + ' *';
      // name += ' *'; // Add asterisk to label text for required fields
    }
    // if (isRequired == true) {
    //   name += ' *'; // Add asterisk to label text for required fields
    // }
    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = ColorCode.bordercolordyanimic ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    // dynamic dropdownValueFrom;
    // dynamic dropdownValueTo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(namelocal,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: ColorCode.textboxanddropdownbackcolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
                  child: DropdownButtonFormField<dynamic>(

                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: ColorCode.appcolorback,),
                      hintText: '$name From',
                      border: InputBorder.none,
                    ),
                    items: values.map<DropdownMenuItem<dynamic>>((value) {
                      return DropdownMenuItem<dynamic>(
                        value: value, // Use the value directly
                        child: Text(value.toString(),style: TextStyle(color: ColorCode.appcolorback,),), // Display the value as the text
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        // dropdownValueFrom = value;
                        dropdownValueFrom.add(MapEntry(name, value));
                        // Update the 'value' field in the instruction object
                        if (instructions.containsKey(id)) {
                          instructions[id]['value'] = [dropdownValueFrom ?? dropdownValueTo, dropdownValueTo];
                        } else {
                          instructions[id] = {'id': id, 'name': name, 'value': [dropdownValueFrom ?? dropdownValueTo, dropdownValueTo]};
                        }
                        print(dropdownValueFrom);

                      });
                    },
                    validator: isRequired ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    } : null,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10), // Add spacing between dropdowns
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: ColorCode.textboxanddropdownbackcolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
                  child: DropdownButtonFormField<dynamic>(
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: ColorCode.appcolorback,),
                      hintText: '$name To',
                      border: InputBorder.none,
                    ),
                    items: values.map<DropdownMenuItem<dynamic>>((value) {
                      return DropdownMenuItem<dynamic>(
                        value: value, // Use the value directly
                        child: Text(value.toString(),style: TextStyle(color: ColorCode.appcolorback,),), // Display the value as the text
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        // dropdownValueTo = value;
                        dropdownValueTo.add(MapEntry(name, value));
                        if (instructions.containsKey(id)) {
                          instructions[id]['value'] = [dropdownValueFrom ?? dropdownValueTo, dropdownValueTo];
                        } else {
                          instructions[id] = {'id': id, 'name': name, 'value': [dropdownValueFrom ?? dropdownValueTo, dropdownValueTo]};

                        }
                        print(dropdownValueTo);

                      });
                    },
                    validator: isRequired ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    } : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}