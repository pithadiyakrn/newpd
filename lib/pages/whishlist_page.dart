import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';
import 'dashboard.dart';
import 'product_details_page.dart';

class Size {
  final int? id;
  final String? name;

  Size({required this.id, required this.name});
}

class Purity {
  final int? id;
  final String? name;

  Purity({required this.id, required this.name});
}

class YourCardData {
  final int? cardid;
  final String? imageUrl;
  final String? name;
  final String? grossWeight;
  final String? netweight;
  final String? sizeName; // Store size name instead of list
  final String? purityName; // Store purity name instead of list
  final int? purityid;
  final int? sizeid;


  YourCardData({
    required this.cardid,
    required this.imageUrl,
    required this.name,
    required this.grossWeight,
    required this.netweight,
    required this.sizeName,
    required this.purityName,
    required this.purityid,
    required this.sizeid,

  });
}
class WishlistPage extends StatefulWidget {
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {

  final TextEditingController _searchController = TextEditingController();
  double defaultFontSizeall = 16.0;
  double defaultFontSizeheading = 16.0;
  double imghightwidth =0.00;

  List<YourCardData> cardsData = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchItemsDetails();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future _fetchItemsDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}wishlist'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          print(response);

          final Map<String, dynamic> responseData = jsonDecode(response.body);
          List<dynamic> items = responseData['data']['items'];
          if (_searchController.text.isNotEmpty) {
            items = items.where((item) =>
                item['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
          }
          setState(() {
            _isLoading = true;
            cardsData = items.map((item) {
              return YourCardData(
                cardid: item['id'],
                imageUrl: item['image'],
                name: item['name'],
                grossWeight: item['gross_weight'],
                netweight: item['net_weight'],
                sizeName: item['size'] != null ? item['size']['name'] : null,
                purityName: item['purity'] != null ? item['purity']['name'] : null,
                purityid: item['purity_id'],
                sizeid: item['size_id'],

              );
            }).toList();
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
  deletefromwhishlist(String itemId) async {
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
            'item_id' : itemId,
            '_method': 'DELETE',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          if (responseData['status'] == true) {
// Handle success response
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to update cart item. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }
  deleteCartItem(String itemId) async {
    print(itemId);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}wishlist/$itemId'),
          // Concatenate item ID in the URI
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
       
        );
        print(itemId);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);


          print(responseData);
          if (responseData['status'] == true) {
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to delete cart item. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }
  void addToCart(String itemId) async {
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
            'item_id': '$itemId',
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
    print('Adding item ${itemId} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add item to cart
  @override
  Widget build(BuildContext context) {
    // var  deviceWidth = MediaQuery.of(context).size.width;
    // var screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    // double defaultFontSize = 16.0;
    // defaultFontSizeheading = defaultFontSize * screenWidth / 400;
    // defaultFontSizeall = defaultFontSize * screenWidth / 500;

    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }

    defaultFontSizeheading = isTablet(context) ? 30.0 : 20.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 16.0;

    imghightwidth = isTablet(context) ? 200.0 : 120.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
           'Wishlist',
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: ColorCode.appcolorback
          ),
        ),
      ),
      body:

      WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));
          if (Navigator.of(context).canPop()) {

            // Navigator.of(context).popAndPushNamed(MyRoutes.dashboard);
            return true; // Prevent default behavior
          } else {


            return true; // Allow default behavior
          }
        },
        child: Column(
          children: [
            // Add text fields for filtering data
            Padding(
              padding:  EdgeInsets.symmetric( horizontal: DynamicSize.scale(context, 10)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: ColorCode.textboxanddropdownbackcolor,
                ),
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal:  DynamicSize.scale(context, 8)),
                  child: TextFormField(
                    cursorColor: ColorCode.appcolorback, // Set the cursor color
                    style: TextStyle(
                      color: ColorCode.appcolorback, // Set the text color
                      fontWeight: FontWeight.w400,
                      fontSize: DynamicSize.scale(context, 14),
                    ),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: ColorCode.appcolorback,
                      ),
                      hintText: 'Serch By Item Name',
                      border: InputBorder.none, // Remove the default underline
                    ),
                    onChanged: (value) {
                      _fetchItemsDetails();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: DynamicSize.scale(context, 10)),
            Expanded(
              child: Padding(
                padding:  EdgeInsets.only(right: isTablet(context) ? 50 : DynamicSize.scale(context, 10), left: isTablet(context) ? 50 : DynamicSize.scale(context, 10), bottom: isTablet(context) ? 5 : DynamicSize.scale(context, 5)),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),

    );
  }


  Widget _buildBody() {
    if (_isLoading== false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (cardsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/whishlistempty.svg', // Path to your SVG file
              height: 200, // Adjust size as needed
            ),
            SizedBox(height: 20),
            Text(
              'Nothing in Here',
              style: TextStyle(
                color: ColorCode.appcolorback,
                fontSize: DynamicSize.scale(context, 20),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Go to Shopping add items.',
              style: TextStyle(
                color: ColorCode.appcolor,
                fontSize: DynamicSize.scale(context, 12),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, MyRoutes.dashboard);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 40),vertical: DynamicSize.scale(context, 12)),
                child: Container(

                  decoration: BoxDecoration(
                    color: ColorCode.appcolorback,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 12)),
                      child: Text(
                        'Order Now',
                        style: TextStyle(
                          color: ColorCode.btntextcolor,
                          fontSize: DynamicSize.scale(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cardsData.length,
              itemBuilder: (context, index) {
                return _buildCard(cardsData[index]);
              },
            ),
          ),
        ],
      );
    }
  }

  // Widget _buildBody() {
  //   if (cardsData.isEmpty && _isLoading) {
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   } else {
  //     return Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: cardsData.length,
  //             itemBuilder: (context, index) {
  //               return _buildCard(cardsData[index]);
  //             },
  //           ),
  //         ),
  //         if (_isLoading)
  //           Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           ),
  //       ],
  //     );
  //   }
  // }
  Widget _buildCard(YourCardData cardData) {

    bool isTablet(BuildContext context) {

      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }
    defaultFontSizeheading = isTablet(context) ? 20.0 : 16.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 12.0;

    return Card(
        elevation: 3,
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        // Row for Image and Second Container
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                                child: CachedNetworkImage(
                                  imageUrl: cardData.imageUrl!,
                                  height: DynamicSize.scale(context, 100),
                                  width: DynamicSize.scale(context, 200),
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0), // Set border radius here
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                                decoration: BoxDecoration(

                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cardData.name!,
                                      style: TextStyle(
                                        color: ColorCode.containerlblcolor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: DynamicSize.scale(context, 14),
                                      ),
                                    ),

                                    Text(
                                      'Gwt: ' + cardData.grossWeight! + ' Nwt: ' + cardData.netweight!,
                                      style: TextStyle(
                                        color: ColorCode.containerlblcolorlight,
                                        fontWeight: FontWeight.w500,
                                        fontSize: DynamicSize.scale(context, 12),
                                      ),
                                    ),
                                    Text(
                                      'Purity: ' + cardData.purityName! + ' Size: ' + (cardData.sizeName != null && cardData.sizeName!.isNotEmpty ? cardData.sizeName! : ''),
                                      style: TextStyle(
                                        color: ColorCode.containerlblcolorlight,
                                        fontWeight: FontWeight.w500,
                                        fontSize: DynamicSize.scale(context, 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 0), vertical: DynamicSize.scale(context, 8)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: DynamicSize.scale(context, 42),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent, // If you want the button background to be transparent
                                              border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      // addToCart(cardData.cardid.toString());
                                                      // deletefromwhishlist(cardData.cardid.toString());
                                                      // showToastMessage(context,'Added To Cart',backColor: ColorCode.appcolorback);
                                                      showCustomSnackBar(context, 'Added To Cart',ColorCode.appcolorback,2000);
                                                      // _fetchItemsDetails();
                                                    });

                                                    addToCart(cardData.cardid.toString());
                                                    await deletefromwhishlist(cardData.cardid.toString());
                                                    // showToastMessage(context,'Added To Cart',backColor: ColorCode.appcolorback);
                                                    await _fetchItemsDetails();
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(DynamicSize.scale(context, 10)),
                                                    child: Text(
                                                      'Move To Cart',
                                                      style: TextStyle(
                                                        color: ColorCode.appcolorback,
                                                        fontSize: DynamicSize.scale(context, 14),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Add the label next to the container
                                          GestureDetector(
                                            onTap: ()async{
                                              setState(() {
                                                // await deletefromwhishlist(cardData.cardid.toString());
                                                // showToastMessage(context,' Remove From Whishlist ',backColor: Colors.red);
                                                // await _fetchItemsDetails();
                                              }
                                              );

                                              await deletefromwhishlist(cardData.cardid.toString());
                                              // showCustomSnackBar(context, 'Remove To Whishlist',Colors.red,2000);
                                              showCustomSnackBar(context, 'Remove To Whishlist',Colors.red,2000);

                                              // showToastMessage(context,' Remove To Whishlist ',backColor: Colors.red);
                                              await _fetchItemsDetails();
                                            },
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                color: ColorCode.appcolorback,
                                                fontSize: DynamicSize.scale(context, 10),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
            ))
    );
  }

}
