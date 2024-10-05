
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:newuijewelsync/pages/product_listing_page.dart';
import 'package:newuijewelsync/utilis/colorcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Categories.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/routes.dart';

class FilterPage extends StatefulWidget {

  final int? categoryId;
  late final String? selectedGendersStr;
  late final String? selectedBrandsStr;
  late final String? selectedCollectionsStr;
  late final String? grosswtStr;
  late final String? netwtStr;
  final String? preSelectedCategory; // New parameter for pre-selected category


  FilterPage({this.categoryId,this.selectedGendersStr,this.selectedBrandsStr,this.selectedCollectionsStr,this.grosswtStr,this.netwtStr,this.preSelectedCategory});

  @override
  _FilterPageState createState() => _FilterPageState();
  List genderselected = [];
  List brandselected = [];
  List collectionselected = [];

}


class _FilterPageState extends State<FilterPage> {


  int phoneortablet = 1;

  bool showGrossWeightSlider = false;
  bool showNetWeightSlider = false;
  void toggleGrossWeightSlider(bool show) {
    setState(() {
      showGrossWeightSlider = show;
    });
  }
  void toggleNetWeightSlider(bool show) {
    setState(() {
      showNetWeightSlider = show;
    });
  }
  var deviceWidth = 0.0;
  var screenWidth = 0.0;
  double screenHeight = 0;
  double defaultFontSize = 16.0;
  Map<String, List<Map<String, dynamic>>> data = {};
  String selectedCategory = '';
  List<Map<String, dynamic>> selectedArray = [];
  double grossWeightMin = 0;
  double grossWeightMax = 200;
  double grossWeightStart = 0;
  double grossWeightEnd = 200;
  double netWeightMin = 0;
  double netWeightMax = 200;
  double netWeightStart = 0;
  double netWeightEnd = 200;

  void updateGrossWeightValues(double start, double end) {
    setState(() {
      grossWeightStart = start;
      grossWeightEnd = end;
    });
  }//// Function to update gross weight slider values
  void updateNetWeightValues(double start, double end) {
    setState(() {
      netWeightStart = start;
      netWeightEnd = end;
    });
  } // Function to update net weight slider values
  @override
  void initState()  {
    super.initState();
    fetchData();

  }
  void fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}filters'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            setState(() {
              data = {
                'genders': List<Map<String, dynamic>>.from(responseData['data']['genders']),
                'brands': List<Map<String, dynamic>>.from(responseData['data']['brands']),
                'collections': List<Map<String, dynamic>>.from(responseData['data']['collections']),

              };
            });

            // Set checked items in the gender list
            List<int> checkedGenderIds = [];
            data['genders']!.forEach((gender) {
              if (widget.selectedGendersStr!.contains(gender['id'].toString())) {
                gender['isChecked'] = true;
                checkedGenderIds.add(gender['id']);
              }
            });


            // Set checked items in the brands list
            List<int> checkedBrandIds = [];
            data['brands']!.forEach((brand) {
              if (widget.selectedBrandsStr!.contains(brand['id'].toString())) {
                brand['isChecked'] = true;
                checkedBrandIds.add(brand['id']);
              }
            });

            // Set checked items in the collections list
            List<int> checkedCollectionIds = [];
            data['collections']!.forEach((collection) {
              if (widget.selectedCollectionsStr!.contains(collection['id'].toString())) {
                collection['isChecked'] = true;
                checkedCollectionIds.add(collection['id']);
              }
            });
            // Update selectedGendersStr
            widget.selectedGendersStr = checkedGenderIds.join(',');
            // Update selectedBrandsStr
            widget.selectedBrandsStr = checkedBrandIds.join(',');
            // Update selectedCollectionsStr
            widget.selectedCollectionsStr = checkedCollectionIds.join(',');

          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  void setSelectedArray(String category) {
    setState(() {
      selectedCategory = category;
      selectedArray = data[category]!;

    });
  }
  void clearSelections() {
    setState(() {
      fetchData();
      selectedArray.forEach((item) {
        item['isChecked'] = false;
      });
    });
  }
  void saveSelections() {
    List<int> selectedGenders = [];
    List<int> selectedBrands = [];
    List<int> selectedCollections = [];

    // Iterate through selected data and add to respective lists
    for (var item in data['brands'] ?? []) {
      if (item['isChecked'] == true) {
        selectedBrands.add(item['id']);
      }
    }
    for (var item in data['genders'] ?? []) {
      if (item['isChecked'] == true) {
        selectedGenders.add(item['id']);
      }

    }

    for (var item in data['collections'] ?? []) {
      if (item['isChecked'] == true) {
        selectedCollections.add(item['id']);
      }
    }



    // Other iterations for brands and collections

    // Convert the lists into comma-separated strings
    String selectedGendersStr = selectedGenders.join(',');
    String selectedBrandsStr = selectedBrands.join(',');
    String selectedCollectionsStr = selectedCollections.join(',');


    String grosswtString = '${grossWeightStart.toStringAsFixed(3)}, ${grossWeightEnd.toStringAsFixed(3)}';
    print(grosswtString);
    String netwtString = '${netWeightStart.toStringAsFixed(3)}, ${netWeightEnd.toStringAsFixed(3)}';
    print(netwtString);
    print('kkkk' + widget.categoryId.toString());
    // Pass the selected values to the destination screen or function
    // In this example, I'm assuming you're navigating to the `ProductListingPage`
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ItemListScreen(
          categoryId: widget.categoryId,
          selectedGendersStr: selectedGendersStr,
          selectedBrandsStr: selectedBrandsStr,
          selectedCollectionsStr: selectedCollectionsStr,
          grosswtStr: grosswtString,
          netwtStr: netwtString,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      return diagonalSize > 600;
    }
    isTablet(context) ? phoneortablet = 2 : phoneortablet = 1;//phone hoy to 1 ane tablet hoy to 2

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey,
              child: _buildLeftSide(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: ColorCode.white.withOpacity(0.8),
              child: _buildRightSide(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical:  phoneortablet == 1 ? DynamicSize.scale(context,12) : DynamicSize.scale(context, 0),horizontal:  phoneortablet == 1 ? DynamicSize.scale(context,12) : DynamicSize.scale(context, 0)), // Add padding for better touch area
              // padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 12),horizontal: DynamicSize.scale(context, 12)), // Add padding for better touch area
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorCode.addtocartbtnbackcolor, // Border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: clearSelections,
                    child: Padding(
                      padding:  EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 50)),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: DynamicSize.scale(context, 12),
                          color: ColorCode.appcolorback,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical:  phoneortablet == 1 ? DynamicSize.scale(context,12) : DynamicSize.scale(context, 0),horizontal:  phoneortablet == 1 ? DynamicSize.scale(context,12) : DynamicSize.scale(context, 0)), // Add padding for better touch area

              // padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 12),horizontal: DynamicSize.scale(context, 12)), // Add padding for better touch area
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorCode.addtocartbtnbackcolor, // Border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: saveSelections,
                    child: Padding(
                      padding:  EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 50)),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: DynamicSize.scale(context, 12),
                          color: ColorCode.appcolorback,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ElevatedButton(
            //   onPressed: clearSelections,
            //   child: Text('Clear',style: TextStyle(fontSize: DynamicSize.scale(context, 20),color: ColorCode.appcolorback),),
            // ),
            // ElevatedButton(
            //   onPressed: saveSelections,
            //   child: Text('Save',style: TextStyle(fontSize: DynamicSize.scale(context, 20),color: ColorCode.appcolorback),),
            // ),
          ],
        ),
      ),
    );
  }
  Widget _buildLeftSide() {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            setSelectedArray('genders');
            toggleGrossWeightSlider(false); // Hide gross weight slider
            toggleNetWeightSlider(false); // Hide net weight slider
          },
          child: Container(
            child: ListTile(
              title: Text('Genders', style: TextStyle(color: selectedCategory == 'genders' ? Colors.white : Colors.black, fontSize: DynamicSize.scale(context, 12))),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setSelectedArray('brands');
            toggleGrossWeightSlider(false); // Hide gross weight slider
            toggleNetWeightSlider(false); // Hide net weight slider
          },
          child: Container(
            // color: selectedCategory == 'brands' ? Colors.red : Colors.transparent,
            child: ListTile(
              title: Text('Brands', style: TextStyle(color: selectedCategory == 'brands' ? Colors.white : Colors.black, fontSize: DynamicSize.scale(context, 12))),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setSelectedArray('collections');
            toggleGrossWeightSlider(false); // Hide gross weight slider
            toggleNetWeightSlider(false); // Hide net weight slider
          },
          child: Container(
            // color: selectedCategory == 'collections' ? Colors.red : Colors.transparent,
            child: ListTile(
              title: Text('Collections', style: TextStyle(color: selectedCategory == 'collections' ? Colors.white : Colors.black, fontSize: DynamicSize.scale(context, 12))),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = 'Gross Weight';
            });
            toggleGrossWeightSlider(true); // Show gross weight slider
            toggleNetWeightSlider(false); // Hide net weight slider
          },
          child: Container(
            // color: selectedCategory == 'Gross Weight' ? Colors.red : Colors.transparent,
            child: ListTile(
              title: Text('Gross Weight', style: TextStyle(color: selectedCategory == 'Gross Weight' ? Colors.white : Colors.black, fontSize: DynamicSize.scale(context, 12))),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = 'Net Weight';
            });
            toggleGrossWeightSlider(false); // Hide gross weight slider
            toggleNetWeightSlider(true); // Show net weight slider
          },
          child: Container(
            // color: selectedCategory == 'Net Weight' ? Colors.red : Colors.transparent,
            child: ListTile(
              title: Text('Net Weight', style: TextStyle(color: selectedCategory == 'Net Weight' ? Colors.white : Colors.black, fontSize: DynamicSize.scale(context, 12))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightSide() {
    if (showGrossWeightSlider) {
      return Column(
        children: [
          Text(
            'Gross Weight',
            style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
          ),
          RangeSlider(
            values: RangeValues(grossWeightStart, grossWeightEnd),
            min: grossWeightMin,
            max: grossWeightMax,
            onChanged: (RangeValues values) {
              updateGrossWeightValues(values.start, values.end);
            },
            divisions: ((grossWeightMax - grossWeightMin) / 0.01).toInt(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
              grossWeightStart.toStringAsFixed(3),
                style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
              ),
              Text(
                grossWeightEnd.toStringAsFixed(3),
                style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
              ),
            ],
          ),
        ],
      );
    } else if (showNetWeightSlider) {
      return Column(
        children: [
          Text(
            'Net Weight',
            style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
          ),
          RangeSlider(
            values: RangeValues(netWeightStart, netWeightEnd),
            min: netWeightMin,
            max: netWeightMax,
            onChanged: (RangeValues values) {
              updateNetWeightValues(values.start, values.end);
            },
            divisions: ((grossWeightMax - grossWeightMin) / 0.01).toInt(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                netWeightStart.toStringAsFixed(3),
                style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
              ),
              Text(
                netWeightEnd.toStringAsFixed(3),
                style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
              ),
            ],
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: selectedArray.length,
        itemBuilder: (context, index) {
          return Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ),
              ),
            ),
            child: CheckboxListTile(
              title: Text(selectedArray[index]['name'], style: TextStyle(color: ColorCode.textColor, fontSize: DynamicSize.scale(context, 12))),
              value: selectedArray[index]['isChecked'] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  selectedArray[index]['isChecked'] = value;
                });
              },
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: ColorCode.textColor,
            ),
          );
        },
      );
    }
  }
}
