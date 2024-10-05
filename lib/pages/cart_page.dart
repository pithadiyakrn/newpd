
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:newuijewelsync/pages/product_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';
import 'dashboard.dart';

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

  final int? itemid;
  late final int? cardid;
  final String? imageUrl;
  final String? name;
  String? grossWeight;
  String? stoneWeight;
  String? nwtwt;
  final List<Size> sizes;
  final List<Purity> purities;
  int? purityid;
  int? sizeid;
  int qty;
  bool loading;

  final String? unittype;
  late  String? remark;
  String? stonequalities;




  YourCardData({

    required this.itemid,
    required this.cardid,
    required this.imageUrl,
    required this.name,
    required this.grossWeight,
    required this.stoneWeight,
    required this.nwtwt,
    required this.sizes,
    required this.purities,
    required this.purityid,
    required this.sizeid,
    required this.qty,
    required this.unittype,
    required this.remark,
    required this.stonequalities,
    this.loading = false,
  });
}
class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  final TextEditingController _searchController = TextEditingController();
  double defaultFontSizeall = 12.0;
  double defaultFontSizeheading = 12.0;

  int totqty = 0;
  String? totgrossWt;
  String? tototnetWt;
  List<YourCardData> cardsData = [];
  bool _isLoading = false;


  int phoneortablet = 1;

  double cardspaddingbottom = 5.0;
  double cardspaddingleft =  10.0;
  double cardspaddingright = 10.0;



  @override
  void initState() {
    super.initState();
    _fetchItemsDetails();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _fetchItemsDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          List<dynamic> items = responseData['data']['items'];
          setState(() {
            cardsData.clear();
            _isLoading = true;
            for (var item in items) {
              cardsData.add(YourCardData(
                cardid: item['cart_id'],
                imageUrl: item['image'],
                name: item['name'],
                grossWeight: item['gross_weight'],
                nwtwt: item['net_weight'],
                stoneWeight: item['stone_weight'],
                sizes: List<Size>.from(item['sizes'].map((size) => Size(id: size['id'], name: size['name']))),
                purities: List<Purity>.from(responseData['data']['purities'].map((purity) => Purity(id: purity['id'], name: purity['name']))),
                purityid: item['purity_id'] ?? null,
                sizeid: item['size_id'] ?? null,
                qty: item['quantity'],
                remark: item['remark'],
                unittype: item['item']['sub_category']['unit']['name'],
                itemid: item['item']['id'],
                stonequalities: item['stone_quality'],
              ));
            }
            totqty = responseData['data']['total_quantity'];
            totgrossWt = responseData['data']['total_gross_weight'].toStringAsFixed(3);
            tototnetWt = responseData['data']['total_net_weight'].toStringAsFixed(3);
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

  // Future _fetchItemsDetails() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('access_token');
  //     if (token != null) {
  //       final response = await http.get(
  //         Uri.parse('${MyRoutes.baseurl}cart'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $token',
  //         },
  //       );
  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> responseData = jsonDecode(response.body);
  //         List<dynamic> items = responseData['data']['items'];
  //         if (_searchController.text.isNotEmpty) {
  //           items = items.where((item) =>
  //               item['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  //         }
  //         setState(() {
  //
  //           cardsData.clear();
  //           _isLoading = true;
  //           for (var item in items) {
  //             cardsData.add(YourCardData(
  //               cardid: item['cart_id'],
  //               imageUrl: item['image'],
  //               name: item['name'],
  //               grossWeight: item['gross_weight'],
  //               nwtwt: item['net_weight'],
  //               stoneWeight: item['stone_weight'],
  //               sizes: List<Size>.from(item['sizes'].map((size) =>
  //                   Size(id: size['id'], name: size['name']))),
  //               purities: List<Purity>.from(
  //                   responseData['data']['purities'].map((purity) =>
  //                       Purity(id: purity['id'], name: purity['name']))),
  //               purityid: item['purity_id'] ?? null,
  //               sizeid: item['size_id'] ?? null,
  //               qty: item['quantity'],
  //               remark: item['remark'],
  //               unittype: item['item']['sub_category']['unit']['name'],
  //               itemid: item['item']['id'],
  //               stonequalities: item['stone_quality'],
  //             ));
  //           }
  //           totqty = responseData['data']['total_quantity'];
  //           totgrossWt = responseData['data']['total_gross_weight'].toStringAsFixed(3);
  //           tototnetWt = responseData['data']['total_net_weight'].toStringAsFixed(3);
  //
  //         });
  //       } else {
  //         print('Failed to fetch items. Status code: ${response.statusCode}');
  //       }
  //     } else {
  //       print('Access token is null.');
  //     }
  //   } catch (e) {
  //     print('Error fetching items: $e');
  //   }
  // }
  deleteCartItem(String itemId) async {
    print(itemId);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.delete(
          Uri.parse('${MyRoutes.baseurl}cart/$itemId'),
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


  Future<void> updateToCart(String itemId, {String? quantity, String? purityId, String? sizeId, String? remarks}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final uri = Uri.parse('${MyRoutes.baseurl}cart/$itemId');
        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

        final Map<String, dynamic> body = {};

        if (quantity != null) {
          body['quantity'] = quantity;
        }
        if (purityId != null) {
          body['purity_id'] = purityId;
        }
        if (sizeId != null) {
          body['size_id'] = sizeId;
        }
        // if (remarks != null) {
        //   body['remark'] = remarks;
        // }
        body['remark'] = remarks;

        final response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {


            print('Cart updated successfully.');
          } else {
            print('API response status is false.');
          }
        } else {
          print('Failed to update cart item. Status code: ${response.statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }

  Future<Map<String, String>> puritychange(String itemid, String purityid) async {
    Map<String, String> result = {
      'gwt': '0',
      'nwt': '0',
    };

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
            'item_id': itemid,
            'purity_id': purityid,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          // Fluttertoast.showToast(
          //   msg: 'Purity change',
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.transparent,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
          print(responseData);
          if (responseData['status'] == true) {
            print(responseData);
            result['gwt'] = responseData['data']['gross_weight'].toString();
            result['nwt'] = responseData['data']['net_weight'].toString();
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
    print('Adding item $itemid to wishlist');
    // You can call an API here or perform any other necessary action

    return result;
  }

  @override
  Widget build(BuildContext context) {

    double defaultFontSizeall = DynamicSize.scale(context, 10);
    double defaultFontSizeheading = 40.0;
    double containerheight = 100.0;

    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder;


    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }

    defaultFontSizeheading = isTablet(context) ? 30.0 : DynamicSize.scale(context, 10);
    defaultFontSizeall = isTablet(context) ? 16.0 : DynamicSize.scale(context, 10);



    cardspaddingbottom = isTablet(context) ? 5.0 : 5.0;
    cardspaddingleft = isTablet(context) ? 50.0 : 10.0;
    cardspaddingright = isTablet(context) ? 50.0 : 10.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cart',
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: ColorCode.appcolorback
          ),
        ),
      ),

      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));
          if (Navigator.of(context).canPop()) {

            // Navigator.of(context).popAndPushNamed(MyRoutes.dashboard);
            return true; // Prevent default behavior
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));

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
            SizedBox(height: DynamicSize.scale(context, 10)), // Space between label and value
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: cardsData.isEmpty == false ? Container(
        padding: EdgeInsets.all(DynamicSize.scale(context, 10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                    Text('$totqty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Gross Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                    Text('$totgrossWt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Net Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                    Text('$tototnetWt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultFontSizeall)),
                  ],
                ),
              ],
            ),
            SizedBox(height: DynamicSize.scale(context, 10)),
            Container(
              decoration: BoxDecoration(
                color: ColorCode.appcolorback,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () {
                  if (totqty != 0) {
                    Navigator.pushNamed(context, MyRoutes.orderinstructions);
                  } else {
                    print('totqty is 0');
                  }
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(DynamicSize.scale(context, 12)),
                    child: Text(
                      'Continue to Place Order',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorCode.white,
                        fontSize: DynamicSize.scale(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : null,


    );
  }

  Widget _buildBody() {
    if (_isLoading == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (cardsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/emptycart.svg', // Path to your SVG file
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
              'Add Items to get started.',
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
                        'Shop Now',
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



  Widget _buildCard(YourCardData cardData) {

    bool isTablet(BuildContext context) {

      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }
    defaultFontSizeheading = isTablet(context) ? 20.0 : 16.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 12.0;



    TextEditingController remarksController = TextEditingController();
    if (cardData.remark != null) {
      remarksController.text = cardData.remark.toString();
    }

    // remarksController.text = cardData.remark.toString();
    void _showRemarkBottomSheet() {
      final FocusNode _focusNode = FocusNode();

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          // Request focus when the bottom sheet is built
          WidgetsBinding.instance!.addPostFrameCallback((_) => _focusNode.requestFocus());
          return SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: ColorCode.textboxanddropdownbackcolor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SizedBox(height: 10.0),
                    // SizedBox(height: 10.0),
                    Padding(
                      padding:  EdgeInsets.all(DynamicSize.scale(context, 8)),
                      child: Text(
                        'Enter Remarks',
                        style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
                      ),
                    ),

                    // Use FocusNode to keep TextFormField always focused
                    TextFormField(
                      cursorColor: ColorCode.appcolor,
                      controller: remarksController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter remarks...',
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: DynamicSize.scale(context, 12)),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close the bottom sheet
                        cardData.remark = remarksController.text;
                        await updateToCart(cardData.cardid.toString(),quantity: cardData.qty.toString(),remarks: cardData.remark);
                        await _fetchItemsDetails();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorCode.appcolorback,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Padding(
                            padding:  EdgeInsets.all(DynamicSize.scale(context, 12)),
                            child: Text(
                              'Update',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorCode.btntextcolor,
                                fontSize: DynamicSize.scale(context, 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),

                  ],
                ),
              ),
            ),
          );
        },
      );
    }

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
                        // First Row: Name and details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                // Remove padding to minimize space
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

                                    // Text(
                                    //   'Gwt: ' + cardData.grossWeight! + ' Nwt: ' + cardData.nwtwt! + ' Unit: ' + cardData.unittype.toString() + 'stone qualities' + cardData.stonequalities!,
                                    //   style: TextStyle(
                                    //     color: ColorCode.containerlblcolorlight,
                                    //     fontWeight: FontWeight.w500,
                                    //     fontSize: DynamicSize.scale(context, 12),
                                    //   ),
                                    // ),
                                    Text(
                                      'Gwt: ${cardData.grossWeight!} Nwt: ${cardData.nwtwt!} Unit: ${cardData.unittype.toString()}'
                                          '${cardData.stonequalities != null ? ' stone qualities: ${cardData.stonequalities!}' : ''}',
                                      style: TextStyle(
                                        color: ColorCode.containerlblcolorlight,
                                        fontWeight: FontWeight.w500,
                                        fontSize: DynamicSize.scale(context, 12),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox for spacing
                        SizedBox(height: DynamicSize.scale(context, 10)),
                        // Row for Image and Second Container
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container for Image
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: ()async {

                                  print('photoclick');
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetails(
                                        itemid: cardData.itemid,
                                        title: cardData.name,
                                        gwt: cardData.grossWeight,
                                        nwt: cardData.nwtwt,
                                        image: cardData.imageUrl,
                                        qty: cardData.qty,
                                        cartid: cardData.cardid,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                                  child: CachedNetworkImage(
                                    imageUrl: cardData.imageUrl!,
                                    height: DynamicSize.scale(context, 150),
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
                            ),
                            // Second Container with different background color
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
                                decoration: BoxDecoration(

                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            // Remove padding to minimize space
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Size',
                                                  style: TextStyle(
                                                    color: ColorCode.containerlblcolorlight,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: DynamicSize.scale(context, 12),
                                                  ),
                                                ),
                                                Container(
                                                  child: DropdownButton<int?>(
                                                    value: cardData.sizes.any((size) => size.id == cardData.sizeid) ? cardData.sizeid : (cardData.sizes.isNotEmpty ? cardData.sizes.first.id : null),
                                                    onChanged: (int? newValue) {
                                                      setState(() {
                                                        cardData.sizeid = newValue;
                                                        if (newValue != null) {
                                                          final selectedSize = cardData.sizes.firstWhere((size) => size.id == newValue, orElse: () => null!);
                                                          if (selectedSize != null) {
                                                            print('Selected ID: ${selectedSize.id}');
                                                            print('Selected Name: ${selectedSize.name}');
                                                            updateToCart(
                                                              cardData.cardid.toString(),
                                                              quantity: cardData.qty.toString(),
                                                              sizeId: selectedSize.id.toString(),
                                                            );
                                                          }
                                                        }
                                                      });
                                                    },
                                                    items: <DropdownMenuItem<int?>>[
                                                      if (cardData.sizeid == null)
                                                        DropdownMenuItem<int?>(
                                                          value: null,
                                                          child: Text(
                                                            'Size',
                                                            style: TextStyle(
                                                              fontSize: DynamicSize.scale(context, 12),
                                                            ),
                                                          ),
                                                        ),
                                                      for (var size in cardData.sizes)
                                                        DropdownMenuItem<int?>(
                                                          value: size.id,
                                                          child: Text(
                                                            size.name ?? 'No Size',
                                                            style: TextStyle(
                                                              fontSize: DynamicSize.scale(context, 14),
                                                              color: ColorCode.appcolorback,
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
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            // Remove padding to minimize space
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Purity',
                                                  style: TextStyle(
                                                    color: ColorCode.containerlblcolorlight,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: DynamicSize.scale(context, 12),
                                                  ),
                                                ),
                                                Container(
                                                  child: DropdownButton<int?>(
                                                    value: cardData.purityid!,
                                                    onChanged: (int? newValue) {
                                                      setState(() async {
                                                        cardData.purityid = newValue;
                                                        cardData.purityid = newValue;
                                                        if (newValue != null) {
                                                          final selectedPurity = cardData.purities.firstWhere((size) => size.id == newValue);
                                                          if (selectedPurity != null) {
                                                            print('Selected ID: ${selectedPurity.id}');
                                                            print('Selected Name: ${selectedPurity.name}');



                                                            // Call the puritychange function

                                                            Map<String, String> result = await puritychange(cardData.itemid.toString(), cardData.purityid.toString());

                                                            // Access the returned values
                                                            String gwt = result['gwt'] ?? '0';
                                                            String nwt = result['nwt'] ?? '0';

                                                            // Display the values
                                                            print('Gross Weight: $gwt');
                                                            print('Net Weight: $nwt');

                                                            // puritychange(cardData.itemid.toString(), cardData.purityid.toString());

                                                            setState(() {
                                                              cardData.grossWeight = gwt.toString();
                                                              cardData.stoneWeight = nwt.toString();
                                                            });
                                                            updateToCart(cardData.cardid.toString(), quantity: cardData.qty.toString(), purityId: selectedPurity.id.toString());
                                                          }
                                                        }
                                                      });
                                                    },
                                                    items: <DropdownMenuItem<int?>>[
                                                      if (cardData.purityid == null)
                                                        DropdownMenuItem<int?>(
                                                          value: null,
                                                          child: Text(
                                                            'Select Size',
                                                            style: TextStyle(
                                                              fontSize: DynamicSize.scale(context, 14),
                                                            ),
                                                          ),
                                                        ), // Placeholder text
                                                      for (var purity in cardData.purities!)
                                                        DropdownMenuItem<int?>(
                                                          value: purity.id, // Use size.id as the value
                                                          child: Text(
                                                            purity.name ?? 'Unknown purity',
                                                            style: TextStyle(
                                                              fontSize: DynamicSize.scale(context, 14),
                                                              color: ColorCode.appcolorback,
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
                                    Row(
                                      children: [
                                        Expanded(

                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10)),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              color: ColorCode.textboxanddropdownbackcolor,
                                            ),
                                            child: TextField(
                                              onTap: () async {
                                                _showRemarkBottomSheet(); // Call _showRemarkBottomSheet when tapped
                                              },
                                              readOnly: true,
                                              controller: TextEditingController(text: cardData.remark != null && cardData.remark != 'null' ? cardData.remark : ''),
                                              style: TextStyle(fontSize: DynamicSize.scale(context, 12)),
                                              decoration: InputDecoration(
                                                hintStyle: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                                                hintText: 'Remarks',
                                                border: InputBorder.none,


                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal :DynamicSize.scale(context, 0),vertical: DynamicSize.scale(context, 8)),
                                      child: Container(
                                        height:  DynamicSize.scale(context, 42),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent, // If you want the button background to be transparent
                                          border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [

                                            _buildCartQuantityControls(cardData),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  deleteCartItem(cardData.cardid.toString());
                                                  showCustomSnackBar(context, 'Remove From The Cart',Colors.red,2000);

                                                  // showToastMessage(context,'Cart Updated',backColor: Colors.red);
                                                  // Toestmessage('Product Removed From Cart');
                                                  // item.cartQuantity = 0;
                                                }
                                                );
                                                await _fetchItemsDetails();


                                              },
                                              child: Padding(
                                                padding:  EdgeInsets.only(right: DynamicSize.scale(context, 8)),
                                                child: SvgPicture.asset(
                                                  'assets/icon/remove.svg', // Make sure the path is correct
                                                  width: DynamicSize.scale(context, 25), // Adjust the width and height as needed
                                                  height: DynamicSize.scale(context, 25),

                                                  // color: ColorCode.appcolorback, // Optional: Set the color if you want to colorize the SVG
                                                ),
                                              ),
                                            ),
                                            //   child: Text(
                                            //     'Remove',
                                            //     style: TextStyle(
                                            //       color: ColorCode.appcolorback,
                                            //       fontSize: DynamicSize.scale(context, 10),
                                            //       fontWeight: FontWeight.bold,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    )
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
  Widget _buildCartQuantityControls(YourCardData item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: item.loading
                ? null
                : () async {
              setState(() {
                item.loading = true;
              });
              if (item.qty > 1) {
                setState(() {
                  item.qty--;
                });
                await updateToCart(item.cardid.toString(), quantity: item.qty.toString(),remarks: item.remark);
                showCustomSnackBar(context, 'Cart Updated', ColorCode.appcolorback, 2000);
              } else {
                await deleteCartItem(item.cardid.toString());
                showCustomSnackBar(context, 'Product Removed From Cart', Colors.red, 2000);
              }
              await _fetchItemsDetails();
              setState(() {
                item.loading = false;
              });
            },
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: item.loading ? Colors.white : ColorCode.lightcontainerbackcolor,
              ),
              child: Icon(
                Icons.remove,
                color: ColorCode.appcolorback,
                size: DynamicSize.scale(context, 20),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 3)),
            child: Text(
              '${item.qty}',
              style: TextStyle(
                fontSize: DynamicSize.scale(context, 13),
                fontWeight: FontWeight.w500,
                color: ColorCode.appcolor,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            constraints: BoxConstraints(),
            onPressed: item.loading
                ? null
                : () async {
              setState(() {
                item.loading = true;
              });
              setState(() {
                item.qty++;
              });
              await updateToCart(item.cardid.toString(), quantity: item.qty.toString(),remarks: item.remark);
              showCustomSnackBar(context, 'Cart Updated', ColorCode.appcolorback, 2000);
              await _fetchItemsDetails();
              setState(() {
                item.loading = false;
              });
            },
            icon: Container(
              padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: item.loading ? Colors.white : ColorCode.lightcontainerbackcolor,
              ),
              child: Icon(
                Icons.add,
                color: ColorCode.appcolorback,
                size: DynamicSize.scale(context, 13),
              ),
            ),
          ),
        ],
      ),
    );
  }



}