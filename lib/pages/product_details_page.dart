
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:newuijewelsync/models/Categories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/CustomTextbox.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/customdropdown.dart';
import '../utilis/routes.dart';
import 'ImagePreviewScreen.dart';

class ProductDetails extends StatefulWidget {
  final int? itemid; // Make categoryId optional
  final String? title;
  String? gwt;
  String? nwt;
  final String? image;
  final int? qty;
  late final int? cartid;

  ProductDetails({this.itemid,this.title,this.gwt,this.nwt,this.image,this.qty,this.cartid});
  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}
class _ProductDetailsState extends State<ProductDetails> {


  int? cartIdlocal;
  dynamic stoneDetails;
  double defaultFontSizeall = 16.0;
  double defaultFontSizeheading = 20.0;
  double iconsize = 0;

  List<TrendingItem> trendingItems = [];

  late List<String> purityValues;
  List<Size> sizeList = [];
  int cartQuantity = 0;
  bool isWishlist = false;
  Purity? _selectedPurity;
  StoneQualities? _selectedStoneQualities;
  Option? _selectedSize;
  // Option? _selectedSize;
  String? stonewt = '0';
  String? cartid = '0';
  String? otherwt = '0';
  String? netwt = '0';
  String? stoneamt = '0';
  String? otheramt = '0';
  String? descriptions = '';
  final List<String> imageUrls = [
    'https://www.candere.com/media/catalog/product/G/R/GR00103__1.jpeg',
    'https://www.candere.com/media/catalog/product/G/R/GR00103__1.jpeg',
    'https://www.candere.com/media/catalog/product/G/R/GR00103__1.jpeg',
    // Add more image URLs as needed
  ];
  String? imageurl = '';
  var deviceWidth = 0.0;
  var screenWidth = 0.0;
  double screenHeight = 0;
  double defaultFontSize = 16.0;
  int? autoselectpurityid;
  int? autoselectsizeid;


  @override
  void initState() {
    fetchItemsdetails();
    print('ins');
    print(widget.qty);
    cartQuantity = widget.qty!;
    cartIdlocal = widget.cartid;
    print('cart id is');
    print(cartIdlocal);
    super.initState();
  }

  late int selectedsizeidid = 1;
  String? selectedsizeName;

  int phoneortablet = 1;

  void puritychabge() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}items/calculate-purity'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'item_id': '${widget.itemid.toString()}',
            'purity_id': '${_selectedPurity?.id}',
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          if (responseData['status'] == true) {

            setState(() {
              widget.gwt = responseData['data']['gross_weight'].toString();
              widget.nwt = responseData['data']['net_weight'].toString();

            });
            print('k');


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
    print('Adding item ${widget.itemid} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add purity change

  void addToCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');


      if (token != null) {
        Map<String, dynamic> requestBody = {
          'item_id': '${widget.itemid}',
          'quantity': '${cartQuantity}',
        };


        if (_selectedPurity != null && _selectedPurity!.id != 0) {
          requestBody['purity_id'] = '${_selectedPurity!.id}';
        }


        if (_selectedSize != null && _selectedSize!.id != 0) {
          requestBody['size_id'] = '${_selectedSize!.id}';

        }
        if (remarks != null ) {
          requestBody['remark'] = '${remarks.text}';
        }

        if (_selectedStoneQualities != null && _selectedStoneQualities!.id != 0) {
          requestBody['stone_quality_id'] = '${_selectedStoneQualities!.id}';
        }

        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );
        print(response.statusCode);
        if (response.statusCode == 200) {

          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          if (responseData['status'] == true) {
            setState(() {
              print('k');
              print(responseData['cart_id']);
              cartIdlocal =  responseData['cart_id'];

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
    // Add your logic to add the item to the wishlist
    print('Adding item ${widget.cartid} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to add item to cart



  Future<void> updateToCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        Map<String, dynamic> requestBody = {
          'item_id': '${widget.itemid}',
          'quantity': '$cartQuantity',
        };

        if (_selectedPurity != null && _selectedPurity!.id != 0) {
          requestBody['purity_id'] = '${_selectedPurity!.id}';
        }

        if (_selectedSize != null && _selectedSize!.id != 0) {
          requestBody['size_id'] = '${_selectedSize!.id}';
        }

        if (remarks != null) {
          requestBody['remark'] = '${remarks.text}';
        }

        if (_selectedStoneQualities != null && _selectedStoneQualities!.id != 0) {
          requestBody['stone_quality_id'] = '${_selectedStoneQualities!.id}';
        }

        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            print('Item updated in cart.');
            setState(() {
              print('k');
              print(responseData['cart_id']);
              cartIdlocal = responseData['cart_id'];
            });
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to update cart. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error updating cart: $e');
    }
  }


  void deleteCartItem(String itemId) async {
    print(itemId);
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
        print(itemId);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);


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
  void addToWishlist() async {
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
            'item_id': '${widget.itemid}',
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
          print('Failed to fetch trending items. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching trending items: $e');
    }

    // Add your logic to add the item to the wishlist
    print('Adding item ${widget.itemid} to wishlist');
    // You can call an API here or perform any other necessary action
  } // Method to add item to wishlist
  void removeFromWishlist() async {
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
            'item_id': '${widget.itemid}',
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
    print('Adding item ${widget.itemid} to wishlist');
    // You can call an API here or perform any other necessary action
  }// Method to remove item from wishlist


  Future<void> fetchItemsdetails() async {
    print('Fetching item details...');
    print('Quantity: ${widget.qty}');
    Stopwatch stopwatch = Stopwatch()..start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}items/${widget.itemid}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print('Item ID: ${widget.itemid}');

        if (response.statusCode == 200) {
          print('Response received successfully.');

          final Map<String, dynamic> responseData = jsonDecode(response.body);

          Purity? selectedPurity;
          Size? selectedSize;
          StoneQualities? selectedStoneQuality;

          int? autoselectpurityid = responseData['data']['item']['purity_id'];
          int? autoselectsizeid = responseData['data']['item']['size_id'];
          int? autostonequalityid = responseData['data']['item']['stone_quality_id'];

          List<dynamic> puritiesData = responseData['data']['purities'];
          List<Purity> puritiesList = puritiesData.map((purity) {
            return Purity(
              id: purity['id'] ?? 0,
              name: purity['name'] ?? '',
            );
          }).toList();

          List<dynamic>? stoneQualitiesData = responseData['data']['stoneQualities'];
          if (stoneQualitiesData != null) {
            stoneQualitiesList = stoneQualitiesData.map((stoneQualities) {
              return StoneQualities(
                id: stoneQualities['id'] ?? 0,
                name: stoneQualities['name'] ?? '',
              );
            }).toList();
          } else {
            stoneQualitiesList = null!;
          }

          List<dynamic> sizesData = responseData['data']['sizes'];
          List<Size> sizesList = sizesData.map((size) {
            return Size(
              id: size['id'] ?? 0,
              name: size['name'] ?? '',
            );
          }).toList();

          // Convert Size list to Option list for country dropdown
          List<Option> countryList = sizesList.map((size) {
            return Option(size.id, size.name);
          }).toList();

          if (responseData['data']['cart'] != null) {
            cartQuantity = responseData['data']['cart']['quantity'] ?? 0;
            cartid = responseData['data']['cart']['id'].toString() ?? '';
          } else {
            cartQuantity = 0;
          }

          if (autoselectpurityid != null) {
            if (puritiesList.isNotEmpty) {
              selectedPurity = puritiesList.firstWhere((purity) => purity.id == autoselectpurityid);
            }
          }

          if (autoselectsizeid != null) {
            if (sizesList.isNotEmpty) {
              selectedSize = sizesList.firstWhere((size) => size.id == autoselectsizeid);
            }
          }

          if (autostonequalityid != null) {
            if (stoneQualitiesList != null && stoneQualitiesList!.isNotEmpty) {
              selectedStoneQuality = stoneQualitiesList!.firstWhere((stoneQualities) => stoneQualities.id == autostonequalityid);
            }
          }

          setState(() {
            stonewt = responseData['data']['item']['stone_weight'];
            otherwt = responseData['data']['item']['other_weight'];
            netwt = responseData['data']['item']['net_weight'];
            stoneamt = responseData['data']['item']['stone_amount'];
            otheramt = responseData['data']['item']['other_amount'];
            descriptions = responseData['data']['item']['remark'];
            int? wishlistValue = responseData['data']['item']['is_wishlist'];
            isWishlist = wishlistValue == 1;

            _selectedPurity = selectedPurity;

            if (selectedSize != null) {
              _selectedSize = Option(selectedSize.id, selectedSize.name);
            } else {
              _selectedSize = null;
            }

            if (selectedStoneQuality != null) {
              _selectedStoneQualities = selectedStoneQuality;
            }

            purityList = puritiesList;
            sizeList = sizesList;
            _listsize = countryList;
            imageurl = responseData['data']['item']['image'].toString();
          });

          // Print stoneQualitiesList
          if (stoneQualitiesList != null) {
            for (var stoneQuality in stoneQualitiesList!) {
              print('Stone Quality - ID: ${stoneQuality.id}, Name: ${stoneQuality.name}');
            }
          } else {
            print('Stone Qualities: null');
          }

          print('Net Weight: $netwt');
          print('Descriptions: $descriptions');
          if (responseData['data']['showStoneDetails'] == true) {
            stoneDetails = responseData['data']['stoneDetails'];
            print('Stone Details: $stoneDetails');
          }
        } else {
          print('Failed to fetch items. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
      print('fetchItemsdetails took: ${stopwatch.elapsedMilliseconds} milliseconds');
    } catch (e) {
      print('Error fetching item details: $e');
    } finally {
      stopwatch.stop();
    }
  }



  TextEditingController remarks = TextEditingController();

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
    print(phoneortablet);

    defaultFontSizeheading = phoneortablet == 1 ? DynamicSize.scale(context, 20) : DynamicSize.scale(context, 8);
    defaultFontSizeall = phoneortablet == 1 ? DynamicSize.scale(context, 10) : DynamicSize.scale(context, 5);
    iconsize = isTablet(context) ? DynamicSize.scale(context, 40) :DynamicSize.scale(context, 20);

    double imagecontainerheight = phoneortablet == 1 ? DynamicSize.scale(context, 400) : DynamicSize.scale(context, 250);

    return Scaffold(
      // backgroundColor: Color.fromRGBO(222, 213, 218, 1),
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title?.toString() ?? 'Product',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorCode.appcolorback
          ),
        ),
        backgroundColor: ColorCode.btntextcolor.withOpacity(0.8),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.wishlist);
                },
                child: SvgPicture.asset(
                  'assets/icon/heartfilled.svg', // Ensure the SVG file is in your assets folder
                  height: 24,
                  width: 24,
                  color: ColorCode.appcolorback,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.cart);
                },
                child: SvgPicture.asset(
                  'assets/icon/shoppingcart.svg', // Replace this with your SVG asset path
                  height: 24,
                  width: 24,
                  color: ColorCode.appcolorback,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),


            ],
          ),
        ],
      ),
      body:

      WillPopScope(
        onWillPop: () async {
          print(cartQuantity.toString());
          Navigator.of(context).pop({
            'cartQuantity': cartQuantity,
            // 'cart_id': cartid,
            'cart_id': cartIdlocal,
          });
          if (Navigator.of(context).canPop()) {
            return true; // Prevent default behavior
          } else {
            return true; // Allow default behavior
          }
        },
        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imageUrl: imageurl!),
                    ),
                  );
                },
                child: Container(
                  // height:  isTablet(context) ? DynamicSize.scale(context, 200) : DynamicSize.scale(context, 550),
                  height: imagecontainerheight,
                  width: double.infinity,
                  color: Colors.white,
                  // width: double.infinity,
                  child: Image.network(
                    imageurl.toString(),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container();

                    },
                  ),
                ),
              ),//image
              Padding(
                padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 10), horizontal: DynamicSize.scale(context, 15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Row: Headings
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gross wt:',
                            style: TextStyle(
                              color: ColorCode.appcolor,
                              fontSize: DynamicSize.scale(context, 10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Net wt:',
                            style: TextStyle(
                              color: ColorCode.appcolor,
                              fontSize: DynamicSize.scale(context, 10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (descriptions != null) ...[
                            Text(
                              'Description:',
                              style: TextStyle(
                                color: ColorCode.appcolor,
                                fontSize: DynamicSize.scale(context, 10),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ]
                    ),
                    SizedBox(height: 5), // Optional: Add some spacing between the rows
                    // Second Row: Values
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (widget.gwt) ?? '',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontSize: DynamicSize.scale(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          (widget.nwt) ?? '',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontSize: DynamicSize.scale(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),


                        if (descriptions != null) ...[
                          Text(
                            descriptions.toString(),
                            style: TextStyle(
                              color: ColorCode.appcolor,
                              fontSize: DynamicSize.scale(context, 10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ), // gwt and nwt

              Padding(
                padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 0), horizontal: DynamicSize.scale(context, 15)),
                child: Container(
                  height: DynamicSize.scale(context, 55),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft, // Ensure the container aligns its child to the right
                        child: Text(
                          'Purity :',
                          style: TextStyle(
                              color: ColorCode.appcolor,
                              fontSize: DynamicSize.scale(context, 10),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      Expanded(
                        child:  Padding(
                          padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 5),vertical: DynamicSize.scale(context, 5)),
                          child: Container(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: purityList.length,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPurity = purityList[index];
                                    // Print the selected ID and name
                                    print("Selected ID: ${_selectedPurity?.id}, Name: ${_selectedPurity?.name}");
                                    puritychabge();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric( horizontal:  DynamicSize.scale(context, 5),vertical: DynamicSize.scale(context, 5)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10), // Add border radius
                                    border: Border.all(
                                      color: _selectedPurity?.id == purityList[index].id ? Colors.transparent : Colors.black,
                                      width: _selectedPurity?.id == purityList[index].id ? 2 : 1,
                                    ),
                                    color: _selectedPurity?.id == purityList[index].id
                                        ? ColorCode.appcolorback
                                        : ColorCode.textboxanddropdownbackcolor,
                                  ),
                                  child: Text(
                                    purityList[index].name,
                                    style: TextStyle(
                                      color: _selectedPurity?.id == purityList[index].id
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize:  DynamicSize.scale(context, 12),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),// purity label
              // if(stoneQualitiesList !=null)
              //   Padding(
              //     padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 0), horizontal: DynamicSize.scale(context, 15)),
              //     child: Container(
              //       height: DynamicSize.scale(context, 55),
              //       child: Column(
              //         children: [
              //           Container(
              //             alignment: Alignment.centerLeft, // Ensure the container aligns its child to the right
              //             child: Text(
              //               'Stone Qualities :',
              //               style: TextStyle(
              //                   color: ColorCode.appcolor,
              //                   fontSize: DynamicSize.scale(context, 10),
              //                   fontWeight: FontWeight.bold
              //               ),
              //             ),
              //           ),
              //
              //           Expanded(
              //             child:  Padding(
              //               padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 5),vertical: DynamicSize.scale(context, 5)),
              //               child: Container(
              //                 child: ListView.separated(
              //                   scrollDirection: Axis.horizontal,
              //                   itemCount: stoneQualitiesList.length,
              //                   itemBuilder: (context, index) => GestureDetector(
              //                     onTap: () {
              //                       setState(() {
              //                         _selectedStoneQualities = stoneQualitiesList[index];
              //                         // Print the selected ID and name
              //                         print("Selected ID: ${_selectedStoneQualities?.id}, Name: ${_selectedStoneQualities?.name}");
              //
              //                       });
              //                     },
              //                     child: Container(
              //                       padding: EdgeInsets.symmetric( horizontal:  DynamicSize.scale(context, 5),vertical: DynamicSize.scale(context, 5)),
              //                       decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(10), // Add border radius
              //                         border: Border.all(
              //                           color: _selectedStoneQualities?.id == stoneQualitiesList[index].id ? Colors.transparent : Colors.black,
              //                           width: _selectedStoneQualities?.id == stoneQualitiesList[index].id ? 2 : 1,
              //                         ),
              //                         color: _selectedStoneQualities?.id == stoneQualitiesList[index].id
              //                             ? ColorCode.appcolorback
              //                             : ColorCode.textboxanddropdownbackcolor,
              //                       ),
              //                       child: Text(
              //                         stoneQualitiesList[index].name,
              //                         style: TextStyle(
              //                           color: _selectedStoneQualities?.id == stoneQualitiesList[index].id
              //                               ? Colors.white
              //                               : Colors.black,
              //                           fontSize:  DynamicSize.scale(context, 12),
              //                           fontWeight: FontWeight.w600,
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   separatorBuilder: (context, index) => const SizedBox(width: 10),
              //                 ),
              //               ),
              //             ),
              //           ),
              //
              //
              //         ],
              //       ),
              //     ),
              //   ),// stoneQualities label

              stoneQualitiesList.isNotEmpty
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 0), horizontal: DynamicSize.scale(context, 15)),
                child: Container(
                  height: DynamicSize.scale(context, 55),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft, // Ensure the container aligns its child to the right
                        child: GestureDetector(
                          onTap: (){
                            print(stoneQualitiesList);
                          },
                          child: Text(
                            'Stone Qualities :',
                            style: TextStyle(
                                color: ColorCode.appcolor,
                                fontSize: DynamicSize.scale(context, 10),
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 5), vertical: DynamicSize.scale(context, 5)),
                          child: Container(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: stoneQualitiesList.length,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedStoneQualities = stoneQualitiesList[index];
                                    // Print the selected ID and name
                                    print("Selected ID: ${_selectedStoneQualities?.id}, Name: ${_selectedStoneQualities?.name}");
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 5), vertical: DynamicSize.scale(context, 5)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10), // Add border radius
                                    border: Border.all(
                                      color: _selectedStoneQualities?.id == stoneQualitiesList[index].id ? Colors.transparent : Colors.black,
                                      width: _selectedStoneQualities?.id == stoneQualitiesList[index].id ? 2 : 1,
                                    ),
                                    color: _selectedStoneQualities?.id == stoneQualitiesList[index].id
                                        ? ColorCode.appcolorback
                                        : ColorCode.textboxanddropdownbackcolor,
                                  ),
                                  child: Text(
                                    stoneQualitiesList[index].name,
                                    style: TextStyle(
                                      color: _selectedStoneQualities?.id == stoneQualitiesList[index].id
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: DynamicSize.scale(context, 12),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Container(), // If stoneQualitiesList is empty, show an empty container


              Container(

                padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Size Dropdown using CustomTypeAheadFormField
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              _showOptions(context, _listsize, _seectedsizelist, (Option? option) {
                                if (option != null) {
                                  setState(() {
                                    _selectedSize = option;
                                    // selectedsizeName = option.name;
                                    print("Selected ID: ${option.id}, Name: ${option.name}");
                                    // _seectedsizelist = option;
                                    // selectedsizeName = option.name;
                                    // _selectedSize = option.id;
                                    // print("Selected ID: ${option.id}, Name: ${option.name}");
                                  });
                                }
                              });
                            },
                            child: Container(
                              width: DynamicSize.screenWidth(context) / 2.5,
                              padding: EdgeInsets.only(left: DynamicSize.scale(context, 10)),

                              decoration: BoxDecoration(

                                color: ColorCode.textboxanddropdownbackcolor,
                                borderRadius: BorderRadius.circular(10),

                              ),
                              child: Padding(
                                padding:  EdgeInsets.all(DynamicSize.scale(context, 10)),
                                child: Text(

                                  // selectedsizeName ?? (_seectedsizelist != null ? _seectedsizelist?.name : 'Select Size')!,
                                  _selectedSize?.name ?? (_selectedSize != null ? _selectedSize?.name : 'Select Size')!,

                                  style: TextStyle(

                                    color: ColorCode.appcolor,


                                    // fontSize: phoneortablet == 1
                                    //     ? DynamicSize.scale(context, 20)
                                    //     : DynamicSize.scale(context, 8),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),


                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: Colors.transparent, // Set the border color if needed
                            width: 0.0, // Set the border width if needed
                          ),
                          color: ColorCode.textboxanddropdownbackcolor, // Set the background color
                        ),
                        child: Row(
                          children: [

                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: DynamicSize.scale(context, 10)),
                                child: TextField(
                                  cursorColor: ColorCode.appcolorback, // Set the cursor color
                                  controller: remarks,
                                  style: TextStyle(color: ColorCode.appcolor),

                                  textCapitalization: TextCapitalization.characters,

                                  decoration: InputDecoration(
                                    isDense: true, // Make the TextField dense to reduce height
                                    hintStyle: TextStyle(color: ColorCode.appcolor, height: DynamicSize.scale(context, 1.5)),
                                    hintText: 'Remarks',
                                    border: InputBorder.none,

                                  ),
                                  onChanged: (value) {
                                    // Handle the quantity value here
                                    remarks.text = value;
                                    print('code: $value');
                                  },

                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),


              Container(
                // padding: EdgeInsets.all(16),
                // child:    const Column(
                //   mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       'Description',
                //       style: TextStyle(
                //           color: Colors.black,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w700
                //       ),
                //     ),
                //     ReadMoreText(
                //       'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //       style: TextStyle(
                //         fontSize: 13,
                //         color: Colors.black,
                //         fontWeight: FontWeight.w300,
                //       ),
                //       trimExpandedText: 'Less',
                //       trimCollapsedText: 'Read more',
                //       trimLength: 100,
                //       moreStyle: TextStyle(
                //         fontSize: 13,
                //         color: Colors.black,
                //         fontWeight: FontWeight.w500,
                //       ),
                //       lessStyle: TextStyle(
                //         fontSize: 13,
                //         color: Colors.black,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ],
                // ),
              ),// Descriptions details
              Container(
                padding: EdgeInsets.only(left: DynamicSize.scale(context, 10),right: DynamicSize.scale(context, 10),),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DynamicSize.scale(context, 8),),
                    // Stone weight detail rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stone wt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                        Text('$stonewt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                      ],
                    ),//stonewt
                    Divider(thickness: 0.5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Other wt',style: TextStyle(fontSize: DynamicSize.scale(context, 10),),),
                        Text('$otherwt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                      ],
                    ),//otherwt
                    Divider(thickness: 0.5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Net wt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                        Text('$netwt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                      ],
                    ),//netwt
                    Divider(thickness: 0.5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stone Amt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                        Text('$stoneamt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                      ],
                    ),//stoneamt
                    Divider(thickness: 0.5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Other Amt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                        Text('$otheramt',style: TextStyle(fontSize: DynamicSize.scale(context, 10)),),
                      ],
                    ),//otheramt
                    Divider(thickness: 0.5,),
                  ],
                ),
              ),

              if (stoneDetails != null)
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: stoneDetails!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            for (var item in stoneDetails![index])
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      item.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: DynamicSize.scale(context, 8),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),



            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal:phoneortablet == 1 ? DynamicSize.scale(context, 10) : DynamicSize.scale(context, 0),vertical: phoneortablet == 1 ? DynamicSize.scale(context, 20) : DynamicSize.scale(context, 0)),
        // padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10),vertical: DynamicSize.scale(context, 5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(

              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isWishlist) {
                      removeFromWishlist(); // Call method to remove from wishlist
                      showCustomSnackBar(context, 'Remove From Wishlist',Colors.red,2000);
                    } else {
                      addToWishlist(); // Call method to add to wishlist
                      showCustomSnackBar(context, 'Added To Wishlist',Colors.purple,2000);
                    }
                    isWishlist = !isWishlist; // Toggle wishlist status
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 12),horizontal: DynamicSize.scale(context, 12)), // Add padding for better touch area
                  decoration: BoxDecoration(
                    color: isWishlist ? ColorCode.appcolorback : Colors.transparent, // Change color based on wishlist status
                    border: Border.all(
                      color: ColorCode.addtocartbtnbackcolor, // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(
                      //   isWishlist ? Icons.favorite : Icons.favorite_border,
                      //   color: isWishlist ? Colors.white : ColorCode.appcolorback,
                      // ),
                      SizedBox(width: 8), // Add some space between the icon and text
                      Text(
                        isWishlist ?  'Remove Wishlist': 'Add To Wishlist',
                        style: TextStyle(
                          color: isWishlist ? Colors.white : ColorCode.appcolorback,
                          fontSize: DynamicSize.scale(context, 12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: DynamicSize.scale(context, 8),),
            Expanded(child: _buildQuantitySection()),
          ],
        ),

      ),


    );

  }
  Widget _buildQuantitySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cartQuantity <= 0
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  cartQuantity++;
                });
                addToCart();
                showCustomSnackBar(context, 'Product Added To Cart', ColorCode.appcolorback, 2000);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent, // If you want the button background to be transparent
                  border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14), // Adjust padding as needed
                child: Center(
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      color: ColorCode.btncolor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.transparent, // If you want the button background to be transparent
                border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCartQuantityControls(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showCustomSnackBar(context, 'Product Removed From Cart', Colors.red, 2000);
                        cartQuantity = 0;
                        deleteCartItem(widget.cartid.toString());
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SvgPicture.asset(
                        'assets/icon/remove.svg', // Make sure the path is correct
                        width: 25, // Adjust the width and height as needed
                        height: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (cartQuantity > 0) {
                  cartQuantity--;
                  if (cartQuantity > 0) {
                    updateToCart();
                    showCustomSnackBar(context, 'Product Updated', ColorCode.appcolorback, 2000);
                  } else {
                    showCustomSnackBar(context, 'Product Removed From Cart', Colors.red, 2000);
                    deleteCartItem(widget.cartid.toString());
                  }
                }
              });
            },
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: ColorCode.lightcontainerbackcolor,
              ),
              child: Icon(
                Icons.remove,
                color: ColorCode.appcolorback,
                size: 20,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: Text(
              '$cartQuantity',
              style: TextStyle(
                fontSize: 13,
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
                cartQuantity++;
                updateToCart();
                showCustomSnackBar(context, 'Product Updated', ColorCode.appcolorback, 2000);
              });
            },
            icon: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: ColorCode.lightcontainerbackcolor,
              ),
              child: Icon(
                Icons.add,
                color: ColorCode.appcolorback,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



void main() {
  runApp(MaterialApp(
    home: ProductDetails(),
  ));
}

class Size {
  final int id;
  final String name;

  Size({required this.id, required this.name});
}
List<Size> sizeList = [];
class Purity {
  final int id;
  final String name;

  Purity({required this.id, required this.name});
}
List<Purity> purityList = [];

class StoneQualities {
  final int id;
  final String name;

  StoneQualities({required this.id, required this.name});
}
List<StoneQualities> stoneQualitiesList = [];



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
                Text('Select Size',style: TextStyle(color: ColorCode.appcolorback),),
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

class Option {
  int id;
  String name;
  Option(this.id, this.name);
}

List<Option> _listsize = [


];//country list
Option? _seectedsizelist;//selected list