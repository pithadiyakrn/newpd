import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newuijewelsync/pages/menu_page.dart';
import 'package:newuijewelsync/pages/product_listing_page.dart';
import 'package:newuijewelsync/pages/search_page.dart';
import 'package:newuijewelsync/utilis/DynamicSize.dart';

// import 'package:newuijewelsync/pages/search_page.dart';
import 'package:newuijewelsync/utilis/colorcode.dart';

import 'package:newuijewelsync/utilis/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/BannerSlider.dart';
import '../models/Categories.dart';
import '../utilis/AnimatedSnackBar.dart';
import 'product_details_page.dart';
import 'thankyouscreen.dart';



class HomePage extends StatefulWidget
{



  var deviceWidth = 0.0;
  var screenWidth = 0.0;
  double screenHeight = 0;
  double defaultFontSize = 16.0;




  String name = '12345678901234567890';
  // double? screenWidth ;
  // double? screenHeight;
  // double?  defaultFontSize;
  // HomePage({this.screenHeight, this.screenWidth, this.defaultFontSize});
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  int phoneortablet = 1;

  int cartQuantity = 0;
  double cartgrosswt = 0.00;

  // bool isTablet(BuildContext context) {
  //   final double diagonalSize = MediaQuery.of(context).size.shortestSide;
  //   return diagonalSize > 600;
  // }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _selectedIndex = 0; // Define and initialize _selectedIndex

  List<Category> categories = [];//create categpris list

  List<TrendingItem> trendingItems = [];

  Future<void> _fetchcartcount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}cart/count'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            int totalItems = int.parse(responseData['data']['total_items']);
            String totwt = responseData['data']['total_gross_weight'];
            setState(() {
              cartQuantity = totalItems;
              cartgrosswt = double.parse(totwt);
            });
            print(cartQuantity.toString());
            print(cartgrosswt.toString());
          } else {
            print('Failed to fetch cart count: ${responseData['status']}');
          }
        } else {
          print('Failed to fetch cart count. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching cart count: $e');
    }
  }

  Future<void> fetchTrendingItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}items'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'order_by': 'trending',
            'in_order': 'DESC',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            final List<dynamic> trendingData = responseData['data']['items']['data'];
            print(token);
            print(responseData);
            setState(() {
              // Limit the number of items to 5
              trendingItems = trendingData
                  .take(10) // Take only the first 5 items
                  .map((data) => TrendingItem.fromJson(data))
                  .toList();
            });
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
  }

  Future<void> fetchDatacategories() async {
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
print(responseData);
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
          print('Failed to fetch categories. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching categories: $e');
    }
  }//fetch categpris data

  Future<void> fetchCollectionsData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}collections'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            final List<dynamic> collectionsList = responseData['data']['collections'];

            setState(() {
              collectionsData = List<Map<String, dynamic>>.from(collectionsList);
              print(collectionsData);
            });
          } else {
            // Handle cases where 'status' is false
            print('API response status is false.');
          }
        } else {
          // Handle unsuccessful API response
          print('Failed to fetch collections. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching collections: $e');
    }
  }//fetch collections data

  void addToWishlist(TrendingItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}wishlist'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'item_id': '${item.id}',
          }),
        );

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
    print('Adding item ${item.id} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add item to wishlist

  void removeFromWishlist(TrendingItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}wishlist'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'item_id': '${item.id}',
            '_method': 'DELETE',
          }),
        );

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
    print('Adding item ${item.id} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to remove item from wishlist

  void addToCart(TrendingItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'item_id': '${item.id}',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          _fetchcartcount();
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
    print('Adding item ${item.id} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add item to cart

  void updateToCart(TrendingItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'item_id': '${item.id}',
            'quantity': '${item.cartQuantity}',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          _fetchcartcount();
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
    print('Adding item ${item.id} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add item to cart

  void deleteCartItem(String itemId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.delete(
          Uri.parse('${MyRoutes.baseurl}cart/$itemId'), // Concatenate item ID in the URI
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          _fetchcartcount();
          print(responseData);
          if (responseData['status'] == true) {
            // Handle success response here
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to delete cart item. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  Widget _buildImageSection(TrendingItem item) {
    return Container(

      height:phoneortablet == 1 ? DynamicSize.scale(context,150) : DynamicSize.scale(context, 100),


      margin: EdgeInsets.only(top: 20),
      child: Center(
        child: ClipRRect(
          child: Image.network(
            item.image,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/error-image.png', fit: BoxFit.fill);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:  phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 8),
              // fontSize:  DynamicSize.scale(context, 11),
              fontWeight: FontWeight.w500,
              color: ColorCode.containerlblcolor,
            ),
          ),
          SizedBox(height: DynamicSize.scale(context, 5),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gwt: ${item.grossWeight ?? ''}',
                style: TextStyle(
                  fontSize:  phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 8),
                  // fontSize: DynamicSize.scale(context, 11),
                  fontWeight: FontWeight.w400,
                  color: ColorCode.containerlblcolorlight,
                ),
              ),
              Text(
                'Nwt: ${item.netWeight ?? ''}',
                style: TextStyle(
                  fontSize:  phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 8),
                  // fontSize: DynamicSize.scale(context, 11),
                  fontWeight: FontWeight.w400,
                  color: ColorCode.containerlblcolorlight,
                ),
              ),
            ],
          ),
          SizedBox(height: DynamicSize.scale(context, 1),),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.only(right: DynamicSize.scale(context, 8),left: DynamicSize.scale(context, 8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.cartQuantity > 0
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal :DynamicSize.scale(context, 0),vertical: DynamicSize.scale(context, 8)),
            child: Container(

              height: phoneortablet == 1 ? DynamicSize.scale(context,46) : DynamicSize.scale(context, 25),
              // height:  DynamicSize.scale(context, 25),
              decoration: BoxDecoration(
                color: Colors.transparent, // If you want the button background to be transparent
                border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  _buildCartQuantityControls(item),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        deleteCartItem(item.cartId.toString());
                        showCustomSnackBar(context, 'Product Removed From Cart',Colors.red,2000);
                        // showToastMessage(context,'Product Removed From Cart',backColor: Colors.red);
                        // Toestmessage('Product Removed From Cart');
                        item.cartQuantity = 0;
                      });
                    },
                    child: Padding(
                      padding:  EdgeInsets.only(right: phoneortablet == 1 ? DynamicSize.scale(context,8) : DynamicSize.scale(context, 2)),
                      // padding:  EdgeInsets.only(right: DynamicSize.scale(context, 8)),
                      child: SvgPicture.asset(
                        'assets/icon/remove.svg', // Make sure the path is correct
                        width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                        height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                        // width: DynamicSize.scale(context, 25), // Adjust the width and height as needed
                        // height: DynamicSize.scale(context, 25),
                        // color: ColorCode.appcolorback, // Optional: Set the color if you want to colorize the SVG
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal :DynamicSize.scale(context, 0),vertical: DynamicSize.scale(context, 8)),
            child:GestureDetector(
              onTap: () {
                setState(() {
                  addToCart(item);
                  // Toestmessage('Product Added To Cart');
                  showCustomSnackBar(context, 'Product Added To Cart',ColorCode.appcolorback,2000);
                  // showToastMessage(context,'Product Added To Cart',backColor: ColorCode.appcolorback);
                  item.cartQuantity++;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent, // If you want the button background to be transparent
                  border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding as needed
                child: Center(
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      color: ColorCode.btncolor,
                      fontSize:  phoneortablet == 1 ? DynamicSize.scale(context,13) : DynamicSize.scale(context, 8),
                      // fontSize: DynamicSize.scale(context, 13),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),

            // child: ElevatedButton(
            //
            //           onPressed: () {
            // setState(() {
            //   addToCart(item);
            //   Toestmessage('Product Added To Cart');
            //   item.cartQuantity++;
            // });
            //           },
            //           style: ElevatedButton.styleFrom(
            // side: BorderSide(color: ColorCode.addtocartbtnbackcolor),
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //           ),
            //           child: Center(
            // child: Text(
            //   'Add to Cart',
            //   style: TextStyle(
            //     color: ColorCode.btncolor,
            //     fontSize: DynamicSize.scale(context, 10),
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            //           ),
            //         ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartQuantityControls(TrendingItem item) {
    return Container(

      decoration: BoxDecoration(
        // border: Border.all(color: ColorCode.appcolorback, width: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            // padding: EdgeInsets.all(0), // Removes padding around the icon
            onPressed: () {
              setState(() {
                item.cartQuantity--;
                if (item.cartQuantity > 0) {
                  updateToCart(item);
                  showCustomSnackBar(context, 'Product Updated',ColorCode.appcolorback,2000);
                  // showToastMessage(context,'Product Added To Cart',backColor: ColorCode.appcolorback);
                } else {
                  deleteCartItem(item.cartId.toString());
                  showCustomSnackBar(context, 'Product Removed From Cart',Colors.red,2000);

                  // showToastMessage(context,'Product Removed From Cart',backColor: Colors.red);

                  // Toestmessage('Product Removed From Cart');
                }
              });
            },
            icon: Container(

              // padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
              decoration: BoxDecoration(
                // border: Border.all(color: ColorCode.appcolorback, width: 0.1),
                borderRadius: BorderRadius.circular(4.0),
                color: ColorCode.lightcontainerbackcolor,
              ),
              child: SvgPicture.asset(
                'assets/icon/minusicon.svg', // Replace this with your SVG asset path
                width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                // width: DynamicSize.scale(context, 25),
                // height: DynamicSize.scale(context, 25),
                color: Color.fromRGBO(90, 45, 71, 1), // Apply color styling
              ),
              // child: Icon(
              //   Icons.remove,
              //   color: ColorCode.appcolorback,
              //   size: DynamicSize.scale(context, 20),
              // ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 3)),
            child: Text(
              '${item.cartQuantity}',
              style: TextStyle(
                fontSize: phoneortablet == 1 ? DynamicSize.scale(context,13) : DynamicSize.scale(context, 5),
                // fontSize: DynamicSize.scale(context, 13),
                fontWeight: FontWeight.w500,
                color: ColorCode.appcolor,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            constraints: BoxConstraints(), // Removes default constraints
            onPressed: () {
              setState(() {
                item.cartQuantity++;
                updateToCart(item);
                showCustomSnackBar(context, 'Product Updated',ColorCode.appcolorback,2000);
                // showToastMessage(context,'Cart Updated',backColor: ColorCode.appcolorback);
              });
            },
            icon: SvgPicture.asset(
              'assets/icon/plusicon.svg', // Replace this with your SVG asset path
              width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
              height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
              // width: DynamicSize.scale(context, 25), // Adjust the width and height as needed
              // height: DynamicSize.scale(context, 25),
              color: Color.fromRGBO(90, 45, 71, 1), // Apply color styling
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.only(top: DynamicSize.scale(context, 10)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 20,),
          Positioned(
            height:  DynamicSize.scale(context, 30),
            right:  DynamicSize.scale(context, 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (item.isWishlist) {
                    removeFromWishlist(item);
                    // showToastMessage(context,'Remove From Wishlist',backColor: Colors.red);
                    showCustomSnackBar(context, 'Remove To Wishlist',Colors.red,2000);
                    // Toestmessage('Remove From Wishlist');
                  } else {
                    addToWishlist(item);
                    // showToastMessage(context,'Add From Wishlist',backColor: Colors.purple);
                    showCustomSnackBar(context, 'Added To Wishlist',Colors.purple,2000);
                    // Toestmessage('Add To Wishlist');
                  }
                  item.isWishlist = !item.isWishlist;
                });
                print(item.id);
              },
              child: SvgPicture.asset(
                item.isWishlist ? 'assets/icon/heartfilled.svg' : 'assets/icon/heart.svg',
                // width: 24.0,
                // height: 24.0,
              ),
            ),
          ),
          // Positioned(
          //   left:  DynamicSize.scale(context, 10),
          //   // left: 30,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(4.0),
          //       color: ColorCode.lightcontainerbackcolor,
          //     ),
          //     child: Padding(
          //       padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
          //       child: Text(
          //         item.available ? 'AVAILABLE' : 'UNAVAILABLE',
          //         style: TextStyle(
          //           color: item.available ? ColorCode.containerlblcolor : ColorCode.containerlblcolor,
          //           fontSize: DynamicSize.scale(context, 8),
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            left: DynamicSize.scale(context, 10),
            child: item.available
                ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: ColorCode.lightcontainerbackcolor,
              ),
              child: Padding(
                padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                child: Text(
                  'AVAILABLE',
                  style: TextStyle(
                    color: ColorCode.containerlblcolor,
                    fontSize: DynamicSize.scale(context, 8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
                : SizedBox.shrink(), // This will create an empty space when item.available is false
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return isLoading
        ? Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    )
        : Container();
  }


  @override
  void initState() {
    super.initState();
    _fetchcartcount();//call cart qty count
    fetchDatacategories();//call categpris data
    fetchCollectionsData();//call collections data
    fetchTrendingItems();//call trending  data
    //heighwidth();
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


    double defaultFontSizeall = 16.0;
    double defaultFontSizeheading = 40.0;
    double containerwidth = 100.0;

    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder;



    defaultFontSizeheading = isTablet(context) ? 30.0 : 20.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 14.0;

    containerwidth = isTablet(context) ? 26.0 : 10.0;
    double categorycontainerheight = isTablet(context) ? 135.0 : DynamicSize.scale(context, 50);
    double categorycontainerwidth = isTablet(context) ? 145.0 : DynamicSize.scale(context, 40);
    double toolbarheight = isTablet(context) ? 80.0 : 50.0;



    double trendingheight = isTablet(context) ? 450.0 : DynamicSize.scale(context, 290);
    double trendingsizeboxheight = isTablet(context) ? 440.0 : DynamicSize.scale(context, 310);
    double trendingsizeboxwidth = isTablet(context) ? 230.0 : DynamicSize.scale(context, 200);
    double plussminusicon = isTablet(context) ? 40.0 : DynamicSize.scale(context, 30);




    return WillPopScope(
      onWillPop: () async {
        // Return false to disable the back button
        return false;

      },
      child: WillPopScope(
        onWillPop: () async {
          // Check if on the home screen
          if (Navigator.of(context).canPop()) {
            // Navigate back if not on the home screen
            Navigator.of(context).pop(true);
            return false; // Prevent default behavior
          } else {
            // If on the home screen, open previous page on right swipe
            return false; // Allow default behavior
          }
        },


        child:Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,


          appBar: AppBar(

            backgroundColor: Colors.white,
            centerTitle: false,
            automaticallyImplyLeading: false,
            toolbarHeight: 56.0, // Example toolbar height
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );
              },
              icon: Icon(Icons.menu, color: Colors.black),
            ),
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, MyRoutes.wishlist);
                    },
                    child: SvgPicture.asset(
                      'assets/icon/heartfilled.svg',
                      width: 28.0,
                      height: 28.0,
                      color: Color.fromRGBO(90, 45, 71, 1),
                    ),
                  ),

                  SizedBox(width: 10),
                  PopupMenuButton<int>(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 55.0, // Adjust the width as needed
                            height: 28.0, // Adjust the height as needed
                            child: SvgPicture.asset(
                              'assets/icon/shoppingcart.svg', // Replace this with your SVG asset path
                              width: 24.0, // Adjust the width as needed
                              height: 24.0, // Adjust the height as needed
                              color: Color.fromRGBO(90, 45, 71, 1), // Apply color styling
                            ),
                          ),
                          if (cartQuantity > 0)
                            Positioned(
                              left: 30,
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 204, 195, 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 15,
                                  minHeight: 15,
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.only(left: 1,right: 1,top: 1,bottom: 2),
                                  child: Text(
                                    '$cartQuantity',
                                    style: TextStyle(
                                      color: ColorCode.appcolorback,
                                      fontWeight: FontWeight.w800,
                                      fontSize:phoneortablet == 1 ? DynamicSize.scale(context,7) : DynamicSize.scale(context, 4),
                                      // fontSize: DynamicSize.scale(context, 7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    itemBuilder: (context) => [

                      PopupMenuItem<int>(
                        value: 1,
                        child: Container(
                          height: 100,
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(context, MyRoutes.cart);
                                },
                                child: Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Check Out: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '$cartQuantity',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Text(
                                      //   'Gross Wt: $cartgrosswt',
                                      //   style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),
                                      // ),
                                    ),
                                    SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icon/cart.svg',
                                      width: 28.0,
                                      height: 28.0,
                                      color: Color.fromRGBO(90, 45, 71, 1),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(context, MyRoutes.cart);
                                },
                                child: Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'T.Gross Wt: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '$cartgrosswt',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Text(
                                      //   'Gross Wt: $cartgrosswt',
                                      //   style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),
                                      // ),
                                    ),
                                    SizedBox(width: 8),
                                    // SvgPicture.asset(
                                    //   'assets/icon/scale.svg',
                                    //   // 'assets/icon/balance-scale.svg',
                                    //   width: 28.0,
                                    //   height: 28.0,
                                    //   color: Color.fromRGBO(90, 45, 71, 1),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        ),
                      ),
                    ]),

                ],
              ),
            ],
          ),

          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              // padding: EdgeInsets.all(DynamicSize.scale(context, 8)),
              padding: EdgeInsets.all(10),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 2)),
                    child: GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorCode.textboxanddropdownbackcolor,
                        ),
                        padding: EdgeInsets.all(DynamicSize.scale(context, 8)),
                        child: Row(
                          children: [
                            Icon(Icons.search,color: ColorCode.homepagefontcolorfont,),
                            SizedBox(width: DynamicSize.scale(context, 2)),
                            Text(
                              'Search By Category, products & more...',
                              style: TextStyle(
                                // fontSize: DynamicSize.scale(context, 10),
                                fontSize: phoneortablet == 1 ? DynamicSize.scale(context,10) : DynamicSize.scale(context, 5),
                                color: ColorCode.homepagefontcolorfont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),//serchpage
                  SizedBox(height: DynamicSize.scale(context, 8)),
                  // Container for the text
                  Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Category cards
                          ...categories.map((category) {
                            return GestureDetector(
                              child: Padding(
                                padding:  EdgeInsets.only(right:DynamicSize.scale(context, 10)),
                                child: GestureDetector(
                                  onTap: () async {
                                    print('Category ID: ${category.id}');
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemListScreen(categoryId: category.id,title: category.name,suncategoryid: category.subCategories.first.id,),
                                      ),
                                    );
                                    await _fetchcartcount();

                                    // Add any other actions you want to perform on tap
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Image
                                      Container(
                                        // height:DynamicSize.scale(context, 55),
                                        // width:DynamicSize.scale(context, 55),
                                        height:phoneortablet == 1 ? DynamicSize.scale(context,55) : DynamicSize.scale(context, 55),
                                        width:phoneortablet == 1 ? DynamicSize.scale(context,55) : DynamicSize.scale(context, 55),
                                        // width: categorycontainerwidth,
                                        // height: categorycontainerheight,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100.0),
                                          image: DecorationImage(

                                            image: NetworkImage(category.image,),
                                            fit: BoxFit.fill,

                                          ),
                                        ),
                                      ),
                                      SizedBox(height: DynamicSize.scale(context, 5)),

                                      SizedBox(

                                        height:phoneortablet == 1 ? DynamicSize.scale(context,55) : DynamicSize.scale(context, 20),
                                        width:DynamicSize.scale(context, 55),
                                        // height: categorycontainerwidth,
                                        // width: categorycontainerwidth, // Set the width to match the image width
                                        child: Text(
                                          category.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2, // Limit to 2 lines
                                          overflow: TextOverflow.ellipsis, // Handle overflow
                                          style: TextStyle(
                                            // color: ColorCode.black,
                                            color: ColorCode.containerlblcolor,
                                            fontWeight: FontWeight.w400,
                                              // fontSize: DynamicSize.scale(context, 10),
                                            fontSize: phoneortablet == 1 ? DynamicSize.scale(context,10) : DynamicSize.scale(context, 5),
                                            // fontSize: defaultFontSizeall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          // Static "View All" card
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, MyRoutes.categories);
                            },
                            child: Column(
                              children: [
                                Container(

                                  height:DynamicSize.scale(context, 55),
                                  width:DynamicSize.scale(context, 55),
                                  // width: categorycontainerwidth,
                                  // height: categorycontainerheight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: ColorCode.containerlblcolor, // Placeholder color
                                  ),
                                  child: Icon(Icons.view_list, color: ColorCode.white),
                                ),
                                SizedBox(height: DynamicSize.scale(context, 5)),
                                SizedBox(
                                  height:phoneortablet == 1 ? DynamicSize.scale(context,55) : DynamicSize.scale(context, 20),
                                  width:DynamicSize.scale(context, 55),
                                  // height: categorycontainerwidth,
                                  // width: categorycontainerwidth, // Set the width to match the image width
                                  child: Text(
                                    'View All',
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Limit to 2 lines
                                    overflow: TextOverflow.ellipsis, // Handle overflow
                                    style: TextStyle(
                                      color: ColorCode.containerlblcolor,
                                      fontSize: phoneortablet == 1 ? DynamicSize.scale(context,10) : DynamicSize.scale(context, 5),
                                      // fontSize: DynamicSize.scale(context, 10),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: DynamicSize.scale(context, 8)), // Add spacing between "View All" and categories
                        ],
                      ),
                    ),
                  ),//category
                  SizedBox(height: DynamicSize.scale(context, 1)),

                  BannerSlider(), //slider banners data display from model ma BannerSlider // ued bannerslider file in model
                  Padding(
                    padding:  EdgeInsets.only(top: DynamicSize.scale(context, 25)),
                    child: Text(
                      'All Iconic Collection',
                      style: TextStyle(
                          fontSize: DynamicSize.scale(context, 15),
                          // fontSize: defaultFontSizeheading,
                          fontWeight: FontWeight.w600,
                          color: ColorCode.homepagecolorfontsome,
                      ),
                      textAlign: TextAlign.start, // Aligns the text to start from the left
                    ),
                  ),


                  Container(
                    // color: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 10)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: collectionsData.map((collection) {
                            return Padding(
                              padding: EdgeInsets.only(right: DynamicSize.scale(context, 6)),
                              child: ImageAndNameWidgetSquare(
                                image: collection['image'] ?? '',
                                name: collection['name'] ?? '',
                                id: collection['id'] ?? 0,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),//list of collections data //ued ImageAndNameWidgetSquare file in model ma Categories
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    // color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Center horizontally
                      children: [
                        Text(
                          'Featured',
                          style: TextStyle(
                              fontSize: DynamicSize.scale(context, 15),
                              // fontSize: defaultFontSizeheading, // Font size
                              fontWeight: FontWeight.w600, color: ColorCode.black

                          ),
                        ),
                      ],
                    ),
                  ),//Featured caitainer
                  Container(
                    margin: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 10)),
                    // color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Aligns children to the start
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, MyRoutes.CustomOrders);
                            },
                            child: ImageAndNameInsidePhotoCustomFeatured(
                              image: 'icon/custemizedorder.svg',
                              name: 'Customized Orders',
                              gradientColors: [
                                const Color.fromRGBO(240, 172, 161, 0.05),
                                const Color.fromRGBO(240, 172, 161, 0.8),
                              ],
                            ),
                          ),
                          SizedBox(width: DynamicSize.scale(context, 5)),
                          GestureDetector(
                            onTap: () async{
                              print('hrer');
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemListScreen(title: 'Latest',),
                                ),
                              );
                              await _fetchcartcount();
                            },
                            child: ImageAndNameInsidePhotoCustomFeatured(
                              image: 'icon/newarrive.svg',
                              name: 'New Arrivals',
                              gradientColors: [
                                const Color.fromRGBO(255, 172, 253, 0.1),
                                const Color.fromRGBO(142, 97, 141, 0.5),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),//custom order and top products

                  // SizedBox(height: DynamicSize.scale(context, 10)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Trending Now',
                          style: TextStyle(
                            fontSize: DynamicSize.scale(context, 15),
                              // fontSize: defaultFontSizeall+5, // Font size
                              fontWeight: FontWeight.w600, color: ColorCode.homepagecolorfontsome,

                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemListScreen(title: 'trending',),
                              ),
                            );
                          },
                          child: Container(


                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: ColorCode.appcolorback,
                            ),
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 8),vertical: DynamicSize.scale(context, 4)),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                    fontSize: DynamicSize.scale(context, 12),
                                    // fontSize: defaultFontSizeall+5, // Font size
                                    fontWeight: FontWeight.w600,
                                    color: ColorCode.btntextcolor

                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ), //trending now Container

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          // SizedBox(height: DynamicSize.scale(context, 10)),
                          SizedBox(
                            // height: DynamicSize.scale(context, 310),  // Adjust height to match your item height
                            height: phoneortablet == 1 ? DynamicSize.scale(context, 310) : DynamicSize.scale(context, 201) ,  // Adjust height to match your item height
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,  // Change to horizontal scrolling
                              shrinkWrap: false,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,  // One row with multiple columns
                                crossAxisSpacing: DynamicSize.scale(context, 20),  // Adjust spacing between columns
                                mainAxisSpacing: DynamicSize.scale(context, 10),  // Adjust spacing between rows
                                mainAxisExtent: phoneortablet == 1 ? 200 : 300,  // Adjust item width
                                childAspectRatio: 16 / 7,  // Adjust aspect ratio if needed
                              ),
                              itemCount: trendingItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == trendingItems.length) {
                                  return _buildLoader();
                                } else {
                                  TrendingItem item = trendingItems[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      print('item ID: ${item.id}');
                                      print('item ID: ${item}');
                                      // Navigate to product details page
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4, right: 2, bottom: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Color.fromRGBO(0, 0, 0, 0.1),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildTopSection(item),
                                            GestureDetector(
                                              child: _buildImageSection(item),
                                              onTap: () async {
                                                print('item ID: ${item.id}');
                                                print(item.cartQuantity);
                                                // Pass the category ID to the next screen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProductDetails(
                                                      itemid: item.id,
                                                      title: item.name,
                                                      gwt: item.grossWeight,
                                                      nwt: item.netWeight,
                                                      image: item.image,
                                                      qty: item.cartQuantity,
                                                      cartid: item.cartId,
                                                    ),
                                                  ),
                                                ).then((_) {
                                                  // This code block executes after returning from ProductDetails
                                                  setState(() {
                                                    fetchTrendingItems(); // Refresh the page by fetching trending items
                                                  });
                                                });
                                              },
                                            ),
                                            _buildDetailsSection(item),
                                            _buildQuantitySection(item),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),//tranding products api



//                   Container(
//                     height: trendingheight,
//                     child: trendingItems.isEmpty
//                         ? Center(child: CircularProgressIndicator())
//                         : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: trendingItems.map((item) {
//                           return Padding(
//                             padding: EdgeInsets.all(1),
//                             child: SizedBox(
//                               height: trendingsizeboxheight, // Adjust height based on screen width
//                               width: trendingsizeboxwidth, // Adjust width based on screen width
//                               child:Card(
// // color: Colors.green,
//                                 elevation: 1,
//                                 // shadowColor: Colors.blueGrey,
//                                 // color: ColorCode.white10,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(20.0),
//                                       color: ColorCode.white
//                                   ),
//
//                                   // color: ColorCode.white,
//
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Stack(
//                                         alignment: Alignment.center,
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () async {
//                                               print('item ID: ${item.id}');
//                                               // Pass the category ID to the next screen
//                                               // Inside CartPage, call fetchTrendingItems() after returning from ProductDetails
//                                               // Navigator.push(
//                                               //   context,
//                                               //   MaterialPageRoute(
//                                               //     builder: (context) => ProductDetails(
//                                               //       itemid: item.id,
//                                               //       title: item.name,
//                                               //       gwt: item.grossWeight,
//                                               //       nwt: item.netWeight,
//                                               //       image: item.image,
//                                               //     ),
//                                               //   ),
//                                               // ).then((_) {
//                                               //   // This code block executes after returning from ProductDetails
//                                               //   setState(() {
//                                               //     fetchTrendingItems(); // Refresh the page by fetching trending items
//                                               //   });
//                                               // });
//                                             },
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(4.0),
//                                                 color: ColorCode.backgroundColor,
//                                               ),
//                                               child: Image.network(
//                                                 item.image,
//                                                 height: isTablet(context) ? 300.0 : 200.0,
//                                                 width: isTablet(context) ? 300.0 : 200.0,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error, stackTrace) {
//                                                   return Image.asset(
//                                                     'assets/images/error-image.png',
//                                                     fit: BoxFit.cover,
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             top: 5,
//                                             right: 10,
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   setState(() {
//                                                     if (item.isWishlist) {
//                                                       removeFromWishlist(item); // Call method to remove from wishlist
//                                                     } else {
//                                                       addToWishlist(item); // Call method to add to wishlist
//                                                     }
//                                                     item.isWishlist = !item.isWishlist; // Toggle wishlist status
//                                                   });
//                                                   print(item.id);
//                                                 });
//                                               },
//                                               child: Icon(
//                                                 item.isWishlist ? Icons.favorite : Icons.favorite_border,
//                                                 color: item.isWishlist ? Colors.red : null,size: defaultFontSizeheading+10,
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             top: 10,
//                                             right: 100,
//                                             child: Visibility(
//                                               visible: item.available,
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.circular(4.0),
//                                                   color: ColorCode.appcolorback,
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.all(5),
//                                                   child: Text(
//                                                     'AVAILABLE',
//                                                     style: TextStyle(
//                                                       color: ColorCode.white,
//                                                       fontSize: defaultFontSizeall-2,
//                                                       fontWeight: FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Padding(
//                                         padding:  EdgeInsets.symmetric(horizontal: 8.0),
//                                         child: Container(
//                                           child: Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   item.name ?? '',
//                                                   maxLines: 1,
//                                                   overflow: TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                       fontSize: defaultFontSizeall,
//                                                       fontWeight: FontWeight.w500,
//                                                       color: Colors.black
//                                                   ),
//                                                 ),
//                                               ]
//                                           ),
//                                         ),//item name
//                                       ),
//                                       SizedBox(height: 5,),
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(horizontal: 8.0),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Gwt: ${item.grossWeight ?? ''}',
//                                               style: TextStyle(
//                                                   fontSize: defaultFontSizeall,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.black
//                                               ),
//                                             ),
//                                             Text(
//                                               'Nwt: ${item.netWeight ?? ''}',
//                                               style:  TextStyle(
//                                                   fontSize: defaultFontSizeall,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.black
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),//grosswt and netwt
//                                       SizedBox(height: 5,),
//                                       Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           item.cartQuantity > 0
//                                               ? Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
//                                             children: [
//                                               IconButton(
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     item.cartQuantity--;
//                                                     print('Cart Quantity Decreased: ${item.cartQuantity}');
//                                                     if (item.cartQuantity > 0) {
//                                                       updateToCart(item);
//                                                       // Decrease cart quantity
//                                                     }
//                                                     if (item.cartQuantity == 0){
//                                                       deleteCartItem(item.cartId.toString());
//                                                     }
//                                                   });
//                                                 },
//                                                 icon: Container(
//                                                   decoration: BoxDecoration(
//                                                       borderRadius: BorderRadius.circular(8.0),
//                                                       color: ColorCode.appcolorback
//                                                   ),
//                                                   child: Icon(Icons.remove,color:ColorCode.white, size: plussminusicon),
//                                                 ),
//                                                 // color: ColorCode.white,
//                                               ),
//                                               Text(
//                                                 '${item.cartQuantity}',
//                                                 style: TextStyle(
//                                                   fontSize: defaultFontSizeall+5,
//                                                   fontWeight: FontWeight.w400,
//                                                 ),
//                                               ),
//                                               IconButton(
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     updateToCart(item);
//                                                     // Increase cart quantity
//                                                     item.cartQuantity++;
//                                                     print('Cart Quantity Increased: ${item.cartQuantity}');
//                                                   });
//                                                 },
//                                                 icon: Container(
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(8.0),
//                                                     color: ColorCode.appcolorback,
//                                                   ),
//                                                   child: Icon(Icons.add,color: ColorCode.white, size: plussminusicon),
//                                                 ),
//                                                 color: ColorCode.white,
//                                               ),
//                                               IconButton(
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     deleteCartItem(item.cartId.toString());
//                                                     // Remove item from cart
//                                                     item.cartQuantity = 0;
//                                                     print('Item removed from cart');
//                                                   });
//                                                 },
//                                                 icon: Container(
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(6.0),
//                                                     color: ColorCode.appcolorback,
//                                                   ),
//                                                   child: Icon(Icons.delete_rounded, size: plussminusicon,),
//                                                 ),
//                                                 color: ColorCode.white,
//                                               ),
//                                             ],
//                                           )
//                                               : Padding(
//                                             padding: EdgeInsets.only(left: 10,right: 10,bottom:0,top: 0,),
//                                             child: ElevatedButton(
//                                               onPressed: () {
//                                                 setState(() {
//                                                   addToCart(item); // Call method to remove from wishlist
//                                                   // Add item to cart
//                                                   item.cartQuantity++;
//                                                   print('Cart Quantity: ${item.cartQuantity}');
//                                                 });
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                 // minimumSize: Size(screenWidth / 4, 0), // Set a minimum width
//                                                 backgroundColor: ColorCode.appcolorback,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius: BorderRadius.circular(10),
//                                                 ),
//                                               ),
//                                               child: Container(
//                                                 child: Center(
//                                                   child: Text(
//                                                     'Add to Cart',
//                                                     style: TextStyle(
//                                                       color: ColorCode.white,
//                                                       fontSize: defaultFontSizeall+2,
//                                                       fontWeight: FontWeight.w900,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),//qty button
//                                       // SizedBox(height: 4.0),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               // child: CardsWidget(trendingItems: trendingItems), // Add your CardsWidget here,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),//tranding products api
                ],
              )
          ),


        ),
    ));



  }
}
