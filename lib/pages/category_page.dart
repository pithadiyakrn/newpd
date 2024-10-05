import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newuijewelsync/pages/product_listing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Categories.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}categories'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            final List<dynamic> categoriesData =
            responseData['data']['categories'];

            setState(() {
              categories = categoriesData
                  .map((data) => Category.fromJson(data))
                  .toList();
            });
          } else {
            // Handle cases where 'status' is false
            print('API response status is false.');
          }
        } else {
          // Handle unsuccessful API response
          print(
              'Failed to fetch categories. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching categories: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    bool isTablet(BuildContext context) {
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;
      return diagonalSize > 600;
    }


    return Scaffold(
        appBar: AppBar(
          title: Text('Category'),
          centerTitle: false,
          automaticallyImplyLeading: true, // Turn off the back button
        ),

        body:WillPopScope(
          onWillPop: () async {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popAndPushNamed(MyRoutes.dashboard);
              return false; // Prevent default behavior
            } else {
              return true; // Allow default behavior
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 600 ? 3 : 3; // Use 2 for phones, 3 for tablets
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.0, // Set to 0 to remove horizontal spacing
                  mainAxisSpacing: 1.0,
                  childAspectRatio: 0.85, // Adjust this to control the card height
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  Category item = categories[index];
                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(isTablet(context) ? 10.0 : 10.0), // No padding inside the ListTile
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0), // Set the border radius to 10
                              child: Container(
                                width: isTablet(context) ? DynamicSize.scale(context, 75) : DynamicSize.scale(context, 76),
                                height: isTablet(context) ? DynamicSize.scale(context, 75) : DynamicSize.scale(context, 60),
                                child: Image.network(
                                  item.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // Add spacing between image and text
                          Center(
                            child: Text(
                              item.name ?? '',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: DynamicSize.scale(context, 12),
                                color: ColorCode.appcolor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        print('Category ID: ${item.id}');
                        // Pass the category ID to the next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemListScreen(categoryId: item.id,title: item.name,suncategoryid: item.subCategories.first.id,),
                          ),
                        );
                      },
                    ),
                  );
                },
              );

            },
          ),
        ));
  }
}
