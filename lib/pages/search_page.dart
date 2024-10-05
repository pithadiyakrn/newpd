
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newuijewelsync/pages/product_listing_page.dart';
import 'package:newuijewelsync/utilis/colorcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utilis/DynamicSize.dart';
import '../utilis/routes.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  String serchresult = '';
  List<String> _searchSuggestions = [];
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    String searchText = _searchController.text;
    print('Search text changed: $searchText');
    // You can perform any actions here, such as updating the UI or filtering search suggestions
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            color: ColorCode.appcolorback, // Set the text color to red

          ),
        ),

        actions: [

        ],

        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
        child: Container(
          decoration: BoxDecoration(
            color: ColorCode.textboxanddropdownbackcolor, // Set the background color
            borderRadius: BorderRadius.circular(5), // Add border radius
          ),
          child: SizedBox(
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                // Ensure _fetchSearchSuggestions returns a valid list
                return await _fetchSearchSuggestions(textEditingValue.text);
              },
              onSelected: (String selected) {
                // Handle when a suggestion is selected
                _searchController.text = selected;
                _fetchTrendingItems(selected);
                print('Selected item: $selected'); // Print the selected item
                String serchresult = selected.toString();
                print('this is ' + serchresult);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemListScreen(
                      title: serchresult,
                      serch: serchresult,
                    ),
                  ),
                );
              },

              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return Container(

                  decoration: BoxDecoration(

                    // color: ColorCode.textboxanddropdownbackcolor, // Match the fill color to the background
                    borderRadius: BorderRadius.circular(5), // Add border radius
                  ),
                  child: TextField(
                    controller: textEditingController,
                    cursorColor: ColorCode.appcolorback,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Hide the underline
                      contentPadding: EdgeInsets.all(8.0), // Optional: adjust padding
                      hintText: 'Search By Category, products & more...', // Add hint text
                      hintStyle: TextStyle(
                        fontSize: DynamicSize.scale(context, 10),
                        color: ColorCode.homepagefontcolorfont,
                      ),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      // color: ColorCode.textboxanddropdownbackcolor,
                      child: ListView.builder(
                        padding: EdgeInsets.all(DynamicSize.scale(context, 10),),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            leading: SvgPicture.asset(
                              'assets/icon/searchicon.svg', // Your SVG icon asset path
                            ),
                            title: Text(
                              option,
                              style: TextStyle(
                                color: ColorCode.appcolorback, // Set the suggestion font color to green
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),

    );
  }


  Future<List<String>> _fetchSearchSuggestions(String query) async {
    List<String> suggestions = [];

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}search-suggestions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'search': query, // Pass the search query to the API
            'order_by': 'trending',
            'in_order': 'DESC',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            suggestions = List<String>.from(responseData['suggestions']);
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to fetch search suggestions. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching search suggestions: $e');
    }

    return suggestions;
  }
  Future<void> _fetchTrendingItems(String searchQuery) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}search-suggestions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'search': searchQuery,
            'order_by': 'trending',
            'in_order': 'DESC',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            print(responseData);
            final List<
                dynamic> suggestions = responseData['suggestions'];
            print(suggestions);
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
  }
}

