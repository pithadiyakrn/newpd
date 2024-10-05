
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newuijewelsync/pages/thankyouscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utilis/AnimatedSnackBar.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

class DynamicForm extends StatefulWidget {
  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  bool _isPlacingOrder = false;

  bool isGestureEnabled = false;
  List<dynamic> formDataList = [];
  Map<int, dynamic> formData = {};

  Map<int, dynamic> instructions = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  String remarks = ''; // Variable to hold remarks

  dynamic dropdownValueFrom = [];
  dynamic dropdownValueTo = [];

  Future<void> _fetchItemsDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}order/instruction'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final List<
              dynamic> instructionsData = responseData['data']['instructions'];
          instructionsData.sort((a, b) =>
              a['position'].compareTo(b['position']));

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
  }

  Map<String, String> generateRequestBodyString(Map<String, dynamic> requestBody) {
    Map<String, String> bodyString = {};
    requestBody.forEach((key, value) {
      bodyString[key] = value;
    });
    return bodyString;
  }

  Map<String, dynamic> generateRequestBody() {
    Map<String, dynamic>? body = {};

    instructions.forEach((key, value) {
      // if (value['control_type'] == 3) {
      //   // For range dropdowns
      //   var dropdownValues = value['value'];
      //   if (dropdownValues != null) {
      //     String name = value['name'] is String ? value['name'] : '';
      //     String nameWithUnderscores = name.replaceAll(' ', '_');
      //     body['instruction[${nameWithUnderscores}_from]'] =
      //         dropdownValues[0]?.toString() ?? ''; // Convert to string
      //     body['instruction[${nameWithUnderscores}_to]'] =
      //         dropdownValues[1]?.toString() ?? ''; // Convert to string
      //   } else {
      //     String name = value['name'] is String ? value['name'] : '';
      //     String nameWithUnderscores = name.replaceAll(' ', '_');
      //     body['instruction[${nameWithUnderscores}_from]'] = '';
      //     body['instruction[${nameWithUnderscores}_to]'] = '';
      //   }
      //
      //   String nameWithHyphens = (value['name'] is String
      //       ? value['name']
      //       : '').replaceAll(' ', '-');
      //   body['instruction[$nameWithHyphens]'] =
      //       value['control_type']?.toString() ?? ''; // Convert to string
      //
      //
      //   // if (dropdownValues != null) {
      //   //   body['instruction[${value['name']}_from]'] = dropdownValues[0].toString(); // Convert to string
      //   //   body['instruction[${value['name']}_to]'] = dropdownValues[1].toString(); // Convert to string
      //   // } else {
      //   //   body['instruction[${value['name']}_from]'] = '';
      //   //   body['instruction[${value['name']}_to]'] = '';
      //   // }
      //   //
      //   // body['instruction[${value['name']}_control_type'] = value['control_type'].toString(); // Convert to string
      // }

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
          body['instruction[${nameWithUnderscores}_from]'] = str1;
          body['instruction[${nameWithUnderscores}_to]'] = str2;

          // Print the values explicitly
          print('${name} from value is $str1');
          print('${name} to value is $str2');
        } else {
          String name = value['name'] is String ? value['name'] : '';
          String nameWithUnderscores = name.replaceAll(' ', '_');
          body['instruction[${nameWithUnderscores}_from]'] = '';
          body['instruction[${nameWithUnderscores}_to]'] = '';
        }

        String nameWithHyphens = (value['name'] is String ? value['name'] : '').replaceAll(' ', '-');
        body['instruction[$nameWithHyphens]'] = value['control_type']?.toString() ?? ''; // Convert to string
      }


      else {
        // For other control types
        String name = value['name'].replaceAll(' ', '_'); // Replace spaces with underscores
        // Ensure value is converted to string if it's an integer
        var valueToUse = value['value'];
        if (valueToUse == null) {
          valueToUse = ''; // Convert null value to string "null"
        } else if (valueToUse is int) {
          valueToUse = valueToUse.toString();
        }
        body['instruction[$name]'] = valueToUse;
        body['instruction[${value['name']}_control_type'] = value['control_type'].toString(); // Convert to string


      }
    });

    body['remark'] = remarks;

    return body!;
  }

  addToOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      print('k');
      Map<String, dynamic>? requestBody = generateRequestBody(); // Generate the request body
      Map<String, String>? requestBodyString = generateRequestBodyString(requestBody);
      print(requestBodyString!);
      print('k');
      if (token != null && requestBodyString != null) {
        final response = await http.post(
            Uri.parse('${MyRoutes.baseurl}order/place-order'),
            headers: {
              // 'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $token',
              'Accept':"application/json"
            },
            body: requestBodyString
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          print(requestBody);
          Navigator.pushReplacementNamed(context, MyRoutes.thankyou);

          if (responseData['status'] == true) {

          } else {
            print('API response status is false.');
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
          print('Failed to fetch trending items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null or request body is null.');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
    print('Adding item to order');
  }
  void initState() {
    super.initState();
    _fetchItemsDetails();
    // Start a timer to enable the GestureDetector after 2 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        isGestureEnabled = true;
      });
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Instruction',style: TextStyle(
            fontWeight: FontWeight.w400,
            color: ColorCode.appcolorback
        ),),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey, // Set form key
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorCode.textboxanddropdownbackcolor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Padding(

                  padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
                  child: TextFormField(
                    cursorColor: ColorCode.appcolor,
                    decoration: InputDecoration(

                      hintStyle: TextStyle(color: ColorCode.appcolorback),
                      hintText: 'Remarks',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        remarks = value;
                      });
                    },

                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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

            Center(
              child: GestureDetector(
                onTap: _onPlaceOrder,
                child: Padding(
                  padding: EdgeInsets.all(DynamicSize.scale(context, 12)),
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
            ),

            // GestureDetector(
            //   onTap: isGestureEnabled ? () async {
            //     if (_formKey.currentState!.validate()) {
            //       addToOrder(); // Pass formData to addToorder method
            //
            //     }
            //   } : null, // If disabled, onTap is set to null
            //   // onTap: () async{
            //   //   if (_formKey.currentState!.validate()) {
            //   //     Navigator.pushReplacementNamed(context, MyRoutes.thankyou);
            //   //     // formDataList =   printFormData() as List; // Populate formData with form data
            //   //     addToOrder(); // Pass formData to addToorder method
            //   //   } else {}
            //   // },
            //   child: Padding(
            //     padding:  EdgeInsets.all(DynamicSize.scale(context, 2)),
            //     child: Container(
            //       width: 500,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         color: ColorCode.appcolorback,
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: Center(
            //         child: Text(
            //           'Place Order',
            //           style: TextStyle(
            //             fontWeight: FontWeight.w800,
            //             color: ColorCode.btntextcolor,
            //             fontSize: DynamicSize.scale(context, 14),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // //
            // // Padding(
            // //   padding: const EdgeInsets.all(16.0),
            // //   child: ElevatedButton(
            // //     onPressed: () async {
            // //       if (_formKey.currentState!.validate()) {
            // //
            // //         // formDataList =   printFormData() as List; // Populate formData with form data
            // //         await addToOrder(); // Pass formData to addToorder method
            // //       } else {}
            // //     },
            // //     child: Text('Save'),
            // //   ),
            // // ),
            //
            // // GestureDetector(
            // //   onTap: () async{
            // //
            // //     if (_formKey.currentState!.validate()) {
            // //       Navigator.pushReplacementNamed(context, MyRoutes.thankyou);
            // //       // formDataList =   printFormData() as List; // Populate formData with form data
            // //       addToOrder(); // Pass formData to addToorder method
            // //     } else {}
            // //   },
            // //   child: Container(
            // //     width: 500,
            // //     height: 50,
            // //     decoration: BoxDecoration(
            // //       color: ColorCode.appcolorback,
            // //       borderRadius: BorderRadius.circular(20),
            // //     ),
            // //     child: Center(
            // //       child: Text(
            // //         'Place Order',
            // //         style: TextStyle(
            // //           fontWeight: FontWeight.bold,
            // //           color: ColorCode.btntextcolor,
            // //           fontSize: 20,
            // //         ),
            // //       ),
            // //     ),
            // //   ),
            // // ),

          ],
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

  List<dynamic> printFormData() {
    List<dynamic> formDataList = [];
    instructions.forEach((key, value) {
      if (value['control_type'] == 3) {
        // For range dropdowns, add both dropdown labels to formDataList
        var dropdownValues = value['value'];
        formDataList.add({
          'instruction[${value['name']}_from]': dropdownValues[0],
          'instruction[${value['name']}_to]': dropdownValues[1]
        });
      } else {
        // For other control types, add the value to formDataList
        formDataList.add({'instruction[${value['name']}]': value['value']});
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
      // Handle null instruction or missing key
      return Container();
    }

    final int? id = instruction['id'];
    final String? name = instruction['name'];
    final int? controlType = instruction['control_type'];
    final bool? isRequired = instruction['is_require'] != null ? instruction['is_require'] == 1 : false;

    final List<dynamic>? values = instruction['values']; // Make values nullable

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
    Color borderColor = Colors.black ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Container(

          decoration: BoxDecoration(
            color: ColorCode.textboxanddropdownbackcolor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(

            padding: const EdgeInsets.all(2.0),
            child: Padding(
              padding: const EdgeInsets.only( left: 8.0),
              child: TextFormField(
                cursorColor: ColorCode.appcolor,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: ColorCode.appcolorback),
                  hintText: 'Enter Here',
                  // hintText: labelText,
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
    if (isRequired == true) {
      name += ' *'; // Add asterisk to label text for required fields
    }
    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = Colors.black ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    dynamic dropdownValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Container(
          decoration: BoxDecoration(
            color: ColorCode.textboxanddropdownbackcolor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
            child: DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                  // hintText: '$name',
                  hintText: 'Select',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: ColorCode.appcolorback)
              ),

              items: values.map<DropdownMenuItem<dynamic>>((value) {
                return DropdownMenuItem<dynamic>(
                  value: value['id'] != null ? value['id'] : '', // Use 'id' as the value
                  child: Text(value['id'] != null ? value['id'] : '',style: TextStyle(color: ColorCode.appcolorback),), // Display 'id' as the text
                );
              }).toList(),
              onChanged:(value) {
                setState(() {
                  dropdownValue = value; // Update dropdown1 value
                  // Update the 'value' field in the instruction object
                  if (instructions.containsKey(id)) {
                    instructions[id]['value'] = [dropdownValue];
                  } else {
                    instructions[id] = {'id': id, 'name': name, 'value': [dropdownValue]};
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
  }//dropdown 2

  Widget _buildRangeDropdown(int id, String name, List<dynamic> values, bool isRequired) {
    String namelocal  = "select";
    namelocal = name;
    if (isRequired == true) {
      namelocal  = name + ' *';
      // name += ' *'; // Add asterisk to label text for required fields
    }
    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = Colors.black ?? (brightness == Brightness.light ? ColorCode.appcolor : Colors.white);

    // dynamic dropdownValueFrom;
    // dynamic dropdownValueTo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(namelocal,style:TextStyle(fontWeight: FontWeight.w500,color: ColorCode.appcolorback),), // Label displaying the name
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorCode.textboxanddropdownbackcolor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),

                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
                    child: DropdownButtonFormField<dynamic>(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: ColorCode.appcolorback),
                        hintText: 'Select From',
                        // hintText: '$name From',
                        border: InputBorder.none,
                      ),
                      items: values.map<DropdownMenuItem<dynamic>>((value) {
                        return DropdownMenuItem<dynamic>(
                          value: value['id'] != null ? value['id'] : '', // Use 'id' as the value
                          child: Text(value['id'] != null ? value['id'] : ''), // Display 'id' as the text
                        );
                      }).toList(),
                      // value: dropdownValueFrom, // Set the value of the dropdown
                      onChanged: (value) {
                        setState(() {
                          // dropdownValueFrom = value;
                          dropdownValueFrom.add(MapEntry(name, value));
                          // print(dropdownValueFrom);
                          // Update the 'value' field in the instruction object
                          if (instructions.containsKey(id)) {
                            instructions[id]['value'] = [dropdownValueFrom];
                          } else {
                            instructions[id] = {'id': id, 'name': name, 'value': [dropdownValueFrom]};
                          }

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
                    color: ColorCode.textboxanddropdownbackcolor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 0,top: 2,bottom: 2),
                    child: DropdownButtonFormField<dynamic>(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: ColorCode.appcolorback),
                        hintText: 'Select To',
                        // hintText: '$name To',
                        border: InputBorder.none,
                      ),
                      items: values.map<DropdownMenuItem<dynamic>>((value) {
                        return DropdownMenuItem<dynamic>(
                          value: value['id'] != null ? value['id'] : '', // Use 'id' as the value
                          child: Text(value['id'] != null ? value['id'] : ''), // Display 'id' as the text
                        );
                      }).toList(),
                      // value: dropdownValueTo, // Set the value of the dropdown
                      onChanged: (value) {
                        setState(() {
                          // dropdownValueTo = value;
                          dropdownValueTo.add(MapEntry(name, value));
                          // print(dropdownValueTo);

                          if (instructions.containsKey(id)) {
                            instructions[id]['value'] = [dropdownValueTo];
                          } else {
                            instructions[id] = {'id': id, 'name': name, 'value': [dropdownValueTo]};
                          }
                          // When the 'to' dropdown changes, ensure the 'from' dropdown is different

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
        ),
      ],
    );
  }


}

void main() {
  runApp(MaterialApp(
    home: DynamicForm(),
  ));}
