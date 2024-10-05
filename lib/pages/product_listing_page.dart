
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:motion_toast/motion_toast.dart';
// import 'package:motion_toast/motion_toast.dart';
import 'package:newuijewelsync/pages/product_details_page.dart';
import 'package:newuijewelsync/utilis/colorcode.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Categories.dart';
import '../utilis/AnimatedSnackBar.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/routes.dart';
import 'dashboard.dart';
import 'filterpage.dart';

class ItemListScreen extends StatefulWidget {

  final int? categoryId;
  final int? suncategoryid;
  final String? selectedGendersStr;
  final String? selectedBrandsStr;
  final String? selectedCollectionsStr;
  final String? grosswtStr;
  final String? netwtStr;
  final String? title;
  final String? serch;


  ItemListScreen({this.categoryId,this.selectedGendersStr,this.selectedBrandsStr,this.selectedCollectionsStr,this.grosswtStr,this.netwtStr,this.title,this.serch,this.suncategoryid}); // Constructor to receive categoryId (optional)

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final FocusNode focusNode = FocusNode();

  int? cartId;
  int cartQuantity = 0;
  double cartgrosswt = 0.00;

  int phoneortablet = 1;
  String? totitems = '0';
  int _crossaxixcount = 2;
  double rasio = 0.62;
  int? _selectedTabIndex = 0;
  int? _categoryId  = 0; //
  String preselected  ='Genders'; //
  int sub_categoryId = 0; // Initialize with a default value of 1
  List<TrendingItem> trendingItems = [];
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();
  int? _selectedSortOption = 1; // Define and initialize _selectedSortOption
  // Sample list of tabs (replace it with your own data)
  List<Map<String, dynamic>> tabs = [];
  Future<List<Map<String, dynamic>>> fetchTabList(int categoryId) async {
    // Replace the URL with your API endpoint to fetch tab list data
    final String apiUrl = '${MyRoutes.baseurl}sub-categories';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'category_id': _categoryId,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('data')) {
            final List<
                dynamic> subcategories = responseData['data']['subcategories'];
            return subcategories.cast<Map<String, dynamic>>();
          } else {
            throw Exception('Data key not found in the API response');
          }
        } else {
          throw Exception('Failed to load tab list data. Status code: ${response
              .statusCode}');
        }
      } else {
        throw Exception('Access token is null');
      }
    } catch (e) {
      throw Exception('Error fetching tab list data: $e');
    }
  }
  void _selectTab(int index) async {
    setState(() {
      sub_categoryId = tabs[index]["id"];

      _selectedTabIndex = tabs[index]["id"]; // Update selected tab index
      print('sub' + sub_categoryId.toString());
      trendingItems.clear();
      _pageNumber = 1;
    });
    // await fetchTrendingItems();

    // Add your logic to fetch data based on the selected tab here
  }

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
  int totalItems=0;
  int lastpage=0;
  int currntpage=0;
  int _pageNumber = 0;
  String orderby = 'id';
  String in_order = 'DESC';

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
    print('Adding item ${item.id} to wishlist');
    // You can call an API here or perform any other necessary action
  } // Method to add item to wishlist

  Future<void> fetchTrendingItems() async {
    Stopwatch stopwatch = Stopwatch()..start(); // Start the stopwatch
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        _pageNumber++;
        // Reset _pageNumber to 1 before making the API call

        print('sub category id issssss: $_selectedTabIndex');

        print(currntpage);
        print(lastpage);

        print(in_order);
        if(currntpage != 1){
          if(currntpage == lastpage){
            _pageNumber--;
            currntpage=lastpage;
          }
        }
// if(currntpage == lastpage){
//   _pageNumber--;
//   currntpage=lastpage;
// }
        final response = await http.post(
          Uri.parse('${MyRoutes.baseurl}items'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'order_by': orderby,
            'in_order': in_order,
            'category_id': widget.categoryId,
            'subcategory_id': _selectedTabIndex,
            'brand_id': widget.selectedBrandsStr,
            'collection_id': widget.selectedCollectionsStr,
            'gender_id': widget.selectedGendersStr,
            'gross_weight': widget.grosswtStr,
            'net_weight': widget.netwtStr,
            'page': _pageNumber,
            'search': widget.serch,
          }),
        );
        print('krn' + _pageNumber.toString());
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          totalItems = responseData['data']['items']['total'];
          currntpage = responseData['data']['items']['current_page'];
          lastpage = responseData['data']['items']['last_page'];
          print('Total items: $totalItems');
          totitems = totalItems.toString(); // Save total items to variable if needed
          print('Total itemswwwww: $totitems');
          // showToast("total Page is $lastpage currnt page is $currntpage", context: context);
          print(responseData);
          if (responseData['status'] == true) {
            final List<dynamic> trendingData = responseData['data']['items']['data'];
            final Set<int> existingItemIds = trendingItems.map((item) => item.id).toSet();
            setState(() {
              trendingData.forEach((data) {
                final item = TrendingItem.fromJson(data);
                if (!existingItemIds.contains(item.id)) {
                  existingItemIds.add(item.id);
                  trendingItems.add(item);
                }
              });
              // _pageNumber++; // Increment the page number for the next fetch
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
      print('fetchTrendingItems took: ${stopwatch.elapsedMilliseconds} milliseconds');
    } catch (e) {
      print('Error fetching trending items: $e');
    } finally {
      stopwatch.stop();
    }
  }

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
        print(response.statusCode);
        if (response.statusCode == 200) {
          _fetchcartcount();
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          if (responseData['status'] == true) {
            setState(() {
              print(responseData['cart_id']);
              cartId = responseData['cart_id'];
              item.cartId = cartId;
              cartId = responseData['cart_id'];
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
            print('k');
            print(responseData['cart_id']);
            print(responseData);
            // cartIdlocal =  responseData['cart_id'];
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
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          print(responseData);
          _fetchcartcount();

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



  @override
  void initState() {
    super.initState();


    _pageNumber = 1;
    focusNode.addListener(_onFocusChange);
    orderby = widget.title == 'trending' ? 'trending' : 'id';
    in_order = widget.title == 'latest' ? 'ASC' : 'DESC';
    _fetchcartcount();

    if (widget.categoryId != null) {
      _categoryId = widget.categoryId!; // Assign provided categoryId if not null
    }
    print('Category ID: $_categoryId'); // Print categoryId
    // if (widget.suncategoryid != null) {
    //   _selectedTabIndex = widget.suncategoryid!; // Assign provided categoryId if not null
    // }

    print('SubCategory ID: $_selectedTabIndex'); // Print categoryId
    fetchTrendingItems(); // Pass categoryId to fetchTrendingItems
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User has scrolled to the bottom, load more data
        if (!isLoading) {
          setState(() {
            isLoading = true;
          });
          fetchTrendingItems().then((_) {
            setState(() {
              isLoading = false;
            });
          });
        }
      }
    });
    tabs.add({"id": 0, "name": "  All  "});
    fetchTabList(_categoryId!).then((tabData) {
      setState(() {
        tabs.addAll(tabData); // Add fetched tabs to the existing tabs list
      });
    }).catchError((error) {
      print('Error fetching tab list data: $error');
    });
  }

  var deviceWidth = 0.0;
  var screenWidth = 0.0;
  double screenHeight = 0;
  double defaultFontSize = 16.0;
  @override
  Widget build(BuildContext context) {



    double defaultFontSizeall = 13.0;
    double defaultFontSizeheading = 14.0;
    double containerheight = 100.0;
    double defaultFontSizeallbottombar = 1.0;


    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder;
    double aspectRatio = screenWidth > 600 ? 1.7 : 1.3;

    isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;
      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }

    // isTablet(context) ? _crossaxixcount = 4 : _crossaxixcount = 2;
    isTablet(context) ? phoneortablet = 2 : phoneortablet = 1;//phone hoy to 1 ane tablet hoy to 2

    isTablet(context) ? defaultFontSizeallbottombar = 30 : defaultFontSizeallbottombar = 20;

    deviceWidth = MediaQuery.of(context).size.width;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;


    return WillPopScope(
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
      child: Scaffold(
        backgroundColor:Color.fromRGBO(250, 250, 250,1),

        appBar: AppBar(
          title: Text(widget.title?.toString() ?? 'Listing',style: TextStyle(color: ColorCode.appcolorback),),
          centerTitle: true,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, MyRoutes.serch);
                  },
                  child: SvgPicture.asset(
                    'assets/icon/searchicon.svg', // Ensure the SVG file is in your assets folder
                    height: 24,
                    width: 24,
                    color: ColorCode.appcolorback,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: fetchTrendingItems,
                  child: PopupMenuButton<int>(
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
                ),
                SizedBox(width: 10),

              ],
            ),
          ],
        ),

        body:

        WillPopScope(
          onWillPop: () async {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));
            if (Navigator.of(context).canPop()) {

              // Navigator.of(context).popAndPushNamed(MyRoutes.dashboard);
              return true; // Prevent default behavior
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard(initialIndex: 0,)));

              return true; // Allow default behavior
            }
          },
          child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Container(
                      height:DynamicSize.scale(context, 40),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectTab(
                                  index); // Call method to handle tab selection
                              print(tabs[index]["name"]);
                              print(tabs[index]["id"]);
                              sub_categoryId = tabs[index]["id"];
                              // _pageNumber == 0;
                              _pageNumber--;

                              fetchTrendingItems();
                              // Handle tab selection
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal:  DynamicSize.scale(context, 4),vertical:  DynamicSize.scale(context, 4)),
                              child: Container(

                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedTabIndex == tabs[index]["id"] ? Colors
                                        .transparent : Colors.transparent,
                                  ),

                                  color: _selectedTabIndex == tabs[index]["id"] ? ColorCode
                                      .appcolorback : ColorCode.lightcontainerbackcolor,
                                  // Change color to red for selected tab
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      tabs[index]["name"],
                                      style: TextStyle(
                                          color: _selectedTabIndex == tabs[index]["id"]
                                              ? ColorCode.white
                                              : ColorCode.appcolor,
                                          fontSize: DynamicSize.scale(context, 12)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ), //sub cetogory
                    SizedBox(height: DynamicSize.scale(context, 10)),
                    Padding(
                      padding: EdgeInsets.only(right:  phoneortablet == 1 ? DynamicSize.scale(context,20) : DynamicSize.scale(context, 20),left:  phoneortablet == 1 ? DynamicSize.scale(context,20) : DynamicSize.scale(context, 10)), // Add padding for better touch area

                      // padding:  EdgeInsets.only(right: DynamicSize.scale(context, 20),left: DynamicSize.scale(context, 20),),
                      child: Container(
                        // height:phoneortablet == 1 ? DynamicSize.scale(context,20) : DynamicSize.scale(context, 8),
                        // height:DynamicSize.scale(context, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(totitems.toString() + ' Products',style: TextStyle(color: ColorCode.appcolor),),
                            Text('Page: $currntpage / $lastpage',style: TextStyle(color: ColorCode.appcolor),),
                          ],
                        ),
                      ),
                    ), //product displaying name
                    SizedBox(height: DynamicSize.scale(context, 10)),
                    if(phoneortablet == 1)...[
                      if (_crossaxixcount == 4) ...[
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: false,
                            controller: _scrollController,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: DynamicSize.scale(context, 10),
                              mainAxisSpacing: DynamicSize.scale(context, 10),
                              mainAxisExtent: DynamicSize.scale(context, 450),
                              childAspectRatio: 16/4,
                            ),
                            itemCount: trendingItems.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == trendingItems.length) {
                                return _buildLoader();
                              } else {
                                TrendingItem item = trendingItems[index];
                                return GestureDetector(
                                  onTap: () async {
                                    print('item ID: ${item.id}');
                                  },
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 4,right: 4),
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
                                          // _buildImageSectionline(item),
                                          _buildTopSection(item),
                                          GestureDetector(child: _buildImageSectionline(item),onTap: () async {
                                            print('item ID: ${item.id}');
                                            print('lk');
                                            print(item.cartQuantity);
                                            // Pass the category ID to the next screen
                                            // Inside CartPage, call fetchTrendingItems() after returning from ProductDetails
                                            final result = await Navigator.push(
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
                                            );
                                            await _fetchcartcount();
                                            _pageNumber--;
                                            await fetchTrendingItems();
                                            print('k');
                                            print(item.cartQuantity);
                                            print(item.cartId);
                                            if (result != null && result is Map) {
                                              setState(() {
                                                item.cartQuantity = result['cartQuantity'] ?? item.cartQuantity;
                                                item.cartId = result['cart_id'] ?? item.cartQuantity;

                                                cartId = result['cart_id'] ?? item.cartQuantity;
                                                // _pageNumber = 1; // Reset to the first page or adjust as needed
                                              });
                                              print('k');
                                              print(item.cartQuantity);
                                              print(item.cartId);
                                            }
                                          },
                                          ),
                                          // _buildImageSection(item),
                                          _buildDetailsSectionineline(item),

                                          _buildQuantitySectionline(item),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ] //single view
                      else
                        if (_crossaxixcount == 2) ...[
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: false,
                              controller: _scrollController,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: DynamicSize.scale(context, 0),
                                mainAxisSpacing: DynamicSize.scale(context, 0),
                                mainAxisExtent: DynamicSize.scale(context, 320),
                                childAspectRatio: 16/7,
                              ),
                              itemCount: trendingItems.length + 1,
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
                                      padding:  EdgeInsets.only(left: 4,right: 2,bottom: 6),
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

                                            // GestureDetector(child: _buildImageSection(item),onTap: () async {
                                            //   print('item ID: ${item.id}');
                                            //   print(';l;ll');
                                            //   print(item.cartQuantity);
                                            //   // Pass the category ID to the next screen
                                            //   // Inside CartPage, call fetchTrendingItems() after returning from ProductDetails
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           ProductDetails(
                                            //             itemid: item.id,
                                            //             title: item.name,
                                            //             gwt: item.grossWeight,
                                            //             nwt: item.netWeight,
                                            //             image: item.image,
                                            //             qty: item.cartQuantity,
                                            //            cartid: item.cartId,
                                            //           ),
                                            //     ),
                                            //   ).then((_) {
                                            //     // This code block executes after returning from ProductDetails
                                            //     setState(() {
                                            //       _pageNumber--;
                                            //       fetchTrendingItems(); // Refresh the page by fetching trending items
                                            //     });
                                            //
                                            //     // _pageNumber= 1;
                                            //     // fetchTrendingItems(); // Refresh the page by fetching trending items
                                            //   });
                                            // },),



                                            GestureDetector(
                                              child: _buildImageSection(item),
                                              onTap: () async {
                                                print('item ID: ${item.id}');
                                                print(';l;ll');
                                                print(item.cartQuantity);
                                                print(item.cartId);

                                                final result = await Navigator.push(
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
                                                );
                                                await _fetchcartcount();
                                                _pageNumber--;
                                                await fetchTrendingItems();
                                                print('k');
                                                print(item.cartQuantity);
                                                print(item.cartId);
                                                if (result != null && result is Map) {
                                                  setState(() {
                                                    item.cartQuantity = result['cartQuantity'] ?? item.cartQuantity;
                                                    item.cartId = result['cart_id'] ?? item.cartQuantity;

                                                    cartId = result['cart_id'] ?? item.cartQuantity;
                                                    // _pageNumber = 1; // Reset to the first page or adjust as needed
                                                  });
                                                  print('k');
                                                  print(item.cartQuantity);
                                                  print(item.cartId);
                                                }
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
                        ] //two view
                        else
                          ...[
                          ]
                    ], //phone hoy to
                    if(phoneortablet == 2)...[
                      if (_crossaxixcount == 4) ...[
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: false,
                            controller: _scrollController,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: DynamicSize.scale(context, 10),
                              mainAxisSpacing: DynamicSize.scale(context, 10),
                              mainAxisExtent: DynamicSize.scale(context, 295),
                              childAspectRatio: 16/4,
                            ),
                            itemCount: trendingItems.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == trendingItems.length) {
                                return _buildLoader();
                              } else {
                                TrendingItem item = trendingItems[index];
                                return GestureDetector(
                                  onTap: () async {
                                    print('item ID: ${item.id}');
                                  },
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 4,right: 4),
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
                                          // _buildImageSectionline(item),
                                          _buildTopSection(item),
                                          GestureDetector(child: _buildImageSectionline(item),onTap: () async {
                                            print('item ID: ${item.id}');
                                            print('lk');
                                            print(item.cartQuantity);
                                            // Pass the category ID to the next screen
                                            // Inside CartPage, call fetchTrendingItems() after returning from ProductDetails
                                            final result = await Navigator.push(
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
                                            );
                                            await _fetchcartcount();
                                            _pageNumber--;
                                            await fetchTrendingItems();
                                            print('k');
                                            print(item.cartQuantity);
                                            print(item.cartId);
                                            if (result != null && result is Map) {
                                              setState(() {
                                                item.cartQuantity = result['cartQuantity'] ?? item.cartQuantity;
                                                item.cartId = result['cart_id'] ?? item.cartQuantity;

                                                cartId = result['cart_id'] ?? item.cartQuantity;
                                                // _pageNumber = 1; // Reset to the first page or adjust as needed
                                              });
                                              print('k');
                                              print(item.cartQuantity);
                                              print(item.cartId);
                                            }
                                          },
                                          ),
                                          // _buildImageSection(item),
                                          _buildDetailsSectionineline(item),

                                          _buildQuantitySectionline(item),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ] //single view
                      else
                        if (_crossaxixcount == 2) ...[
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: false,
                              controller: _scrollController,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: DynamicSize.scale(context, 0),
                                mainAxisSpacing: DynamicSize.scale(context, 0),
                                mainAxisExtent: DynamicSize.scale(context, 195),
                                childAspectRatio: 16/7,
                              ),
                              itemCount: trendingItems.length + 1,
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
                                      padding:  EdgeInsets.only(left: 4,right: 2,bottom: 6),
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
                                            GestureDetector(child: _buildImageSection(item),onTap: () async {
                                              print('item ID: ${item.id}');
                                              print(';l;ll');
                                              print(item.cartQuantity);
                                              // Pass the category ID to the next screen
                                              // Inside CartPage, call fetchTrendingItems() after returning from ProductDetails
                                              final result = await Navigator.push(
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
                                              );
                                              await _fetchcartcount();
                                              _pageNumber--;
                                              await fetchTrendingItems();
                                              print('k');
                                              print(item.cartQuantity);
                                              print(item.cartId);
                                              if (result != null && result is Map) {
                                                setState(() {
                                                  item.cartQuantity = result['cartQuantity'] ?? item.cartQuantity;
                                                  item.cartId = result['cart_id'] ?? item.cartQuantity;
                                                  cartId = result['cart_id'] ?? item.cartQuantity;
                                                  // _pageNumber = 1; // Reset to the first page or adjust as needed
                                                });
                                                print('k');
                                                print(item.cartQuantity);
                                                print(item.cartId);
                                              }
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
                        ] //two view
                        else
                          ...[
                          ]
                    ], //tablet hoy to hoy to
                  ],

                );
              }),
        ),
        bottomNavigationBar: Container(

          height: phoneortablet == 1 ? DynamicSize.scale(context,40) : DynamicSize.scale(context, 20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: ColorCode.addtocartbtnbackcolor, width: 1.0),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ColorCode.addtocartbtnbackcolor,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (_crossaxixcount == 4) {
                        _crossaxixcount = 2;
                      } else
                        _crossaxixcount = 4;

                      print(_crossaxixcount);
                      print(phoneortablet);

                      if (context.mounted) setState(() {});
                    },
                    icon: SvgPicture.asset(
                      'assets/icon/view.svg', // Path to your SVG file
                      color: ColorCode.btncolor, // Custom color for the SVG
                      height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                      width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                      // width: DynamicSize.scale(context, 20), // Set the width as needed
                      // height: DynamicSize.scale(context, 20), // Set the height as needed
                    ),
                    label: Text(
                      'View',
                      style: TextStyle(
                          color: ColorCode.btncolor,
                          // fontSize: DynamicSize.scale(context, 14),
                          fontSize: phoneortablet == 1 ? DynamicSize.scale(context,14) : DynamicSize.scale(context, 8),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: ColorCode.btncolor,
                    endIndent: 6,
                    indent: 6,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showSortOptions(context);
                    },
                    icon: SvgPicture.asset(
                      'assets/icon/sort.svg', // Path to your SVG file
                      color: ColorCode.btncolor, // Custom color for the SVG
                      height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                      width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                      // width: DynamicSize.scale(context, 20), // Set the width as needed
                      // height: DynamicSize.scale(context, 20), // Set the height as needed
                    ),
                    label: Text(
                      'Sort',
                      style: TextStyle(
                          color: ColorCode.btncolor,
                          fontSize: phoneortablet == 1 ? DynamicSize.scale(context,14) : DynamicSize.scale(context, 8),
                          // fontSize: DynamicSize.scale(context, 14),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: ColorCode.btncolor,
                    endIndent: 6,
                    indent: 6,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterPage(
                            categoryId: _categoryId,
                            selectedGendersStr: widget.selectedGendersStr,
                            selectedBrandsStr: widget.selectedBrandsStr,
                            selectedCollectionsStr: widget.selectedCollectionsStr,
                            grosswtStr: widget.grosswtStr,
                            netwtStr: widget.netwtStr,
                            preSelectedCategory: 'genders',
                          ),
                        ),
                      );
                      await fetchTrendingItems();
                      // SelectionPage
                    },
                    icon: SvgPicture.asset(
                      'assets/icon/filter.svg', // Path to your SVG file
                      color: ColorCode.btncolor, // Custom color for the SVG
                      height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                      width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),

                      // width: DynamicSize.scale(context, 20), // Set the width as needed
                      // height: DynamicSize.scale(context, 20), // Set the height as needed
                    ),
                    label: Text(
                      'Filter',
                      style: TextStyle(
                          color: ColorCode.btncolor,
                          fontSize: phoneortablet == 1 ? DynamicSize.scale(context,14) : DynamicSize.scale(context, 8),
                          // fontSize: DynamicSize.scale(context, 14),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFocusChange() {
    print("Home screen is ${focusNode.hasFocus ? "focused" : "unfocused"}");
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 1), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }
  void _showSortOptions(BuildContext context) {

    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }
    double  defaultFontSizeheading = isTablet(context) ? 20.0 : 20.0;
    double  defaultFontSizeall = isTablet(context) ? 16.0 : 16.0;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Sort By:',style: TextStyle(fontSize: defaultFontSizeheading,fontWeight: FontWeight.w500),),
                  dense: true,
                ),
                RadioListTile(
                  title: Text('Name A-Z',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 3,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async {
                    setState(() {
                      _selectedSortOption = value;
                      orderby = 'name';
                      in_order = 'ASC';
                      trendingItems.clear();
                      _pageNumber = 0;
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//name a to z
                RadioListTile(
                  title: Text('Name Z-A',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 2,
                  groupValue: _selectedSortOption,
                  onChanged: (value)  async{
                    setState(() {
                      _selectedSortOption = value;
                      orderby = 'name';
                      in_order = 'DESC';
                      trendingItems.clear();
                      _pageNumber = 0;
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//name z to a
                RadioListTile(
                  title: Text('Latest',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 1,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async {
                    setState(() {
                      _selectedSortOption = value;
                      orderby = 'id';
                      in_order = 'DESC';
                      _pageNumber = 0;
                      trendingItems.clear();
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//leset
                RadioListTile(
                  title: Text('Oldest',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 4,
                  groupValue: _selectedSortOption,
                  onChanged: (value)  async{
                    setState(() {
                      _selectedSortOption = value;
                      orderby = 'id';
                      in_order = 'ASC';
                      _pageNumber = 0;
                      trendingItems.clear();
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//oldest
                RadioListTile(
                  title: Text('Most Trending',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 5,
                  groupValue: _selectedSortOption,

                  // onChanged: (value)  async{
                  //   setState(() {
                  //     _selectedSortOption = value;
                  //     orderby = 'trending';
                  //     in_order = 'DESC';
                  //     _pageNumber = 0;
                  //     trendingItems.clear();
                  //     print(_selectedSortOption);
                  //   });
                  //   Navigator.pop(context);
                  //   await fetchTrendingItems();
                  //   scrollToTop();
                  // },

                  onChanged: (value) async{
                    setState(() {
                      _selectedSortOption = value;
                      orderby = 'trending';
                      in_order = 'DESC';
                      _pageNumber = 0;
                      print(_selectedSortOption);
                      trendingItems.clear();
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//most trending
                RadioListTile(
                  title: Text('Gross Wt Low To High',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 6,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async{
                    setState(() {
                      orderby = 'gross_weight';
                      in_order = 'ASC';
                      _pageNumber = 0;
                      trendingItems.clear();
                      _selectedSortOption = value;
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//grosswtlowtohigh
                RadioListTile(
                  title: Text('Gross Wt High To Low',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 7,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async{
                    setState(() {
                      orderby = 'gross_weight';
                      in_order = 'DESC';
                      _pageNumber = 0;
                      trendingItems.clear();
                      _selectedSortOption = value;
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//grosswthightolow
                RadioListTile(
                  title: Text('Net Wt Low To High',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 8,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async{
                    setState(() {
                      orderby = 'net_weight';
                      in_order = 'ASC';
                      _pageNumber = 0;
                      trendingItems.clear();
                      _selectedSortOption = value;
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//netwtlowtohigh
                RadioListTile(
                  title: Text('Net Wt High To Low',style: TextStyle(fontSize: defaultFontSizeall),),
                  value: 9,
                  groupValue: _selectedSortOption,
                  onChanged: (value) async{
                    setState(() {
                      orderby = 'net_weight';
                      in_order = 'DESC';
                      _pageNumber = 0;
                      _selectedSortOption = value;
                      trendingItems.clear();
                      print(_selectedSortOption);
                    });
                    Navigator.pop(context);
                    await fetchTrendingItems();
                    scrollToTop();
                  },
                ),//netwthightolow
              ],
            ),
          ),
        );
      },
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
                    showCustomSnackBar(context, 'Remove From Wishlist',Colors.red,2000);
                    // showToastMessage(context,'Remove From Wishlist',backColor: Colors.red);
                    // Toestmessage('Remove From Wishlist');
                  } else {
                    addToWishlist(item);
                    showCustomSnackBar(context, 'Added To Wishlist',Colors.purple,2000);
                    // showToastMessage(context,'Add To Wishlist',backColor: Colors.purple);
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

  Widget _buildImageSection(TrendingItem item) {
    return Container(
      height: phoneortablet == 1 ? DynamicSize.scale(context,150) : DynamicSize.scale(context, 100),
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
  Widget _buildImageSectionline(TrendingItem item) {
    return Container(
      height: phoneortablet == 1 ? DynamicSize.scale(context,300) : DynamicSize.scale(context, 200),
      margin: EdgeInsets.only(top: 20),
      child: Center(
        child: ClipRRect(
          child: Image.network(
            item.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/error-image.png', fit: BoxFit.contain);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
              // fontSize: DynamicSize.scale(context, 11),
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
                  fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
                  // fontSize: DynamicSize.scale(context, 11),
                  fontWeight: FontWeight.w400,
                  color: ColorCode.containerlblcolorlight,
                ),
              ),
              Text(
                'Nwt: ${item.netWeight ?? ''}',
                style: TextStyle(
                  fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
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
  Widget _buildDetailsSectionineline(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          SizedBox(height: DynamicSize.scale(context, 5),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
                  // fontSize: DynamicSize.scale(context, 11),
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
                      fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
                      // fontSize: DynamicSize.scale(context, 11),
                      fontWeight: FontWeight.w400,
                      color: ColorCode.containerlblcolorlight,
                    ),
                  ),
                  SizedBox(width: DynamicSize.scale(context, 10),),
                  Text(
                    'Nwt: ${item.netWeight ?? ''}',
                    style: TextStyle(
                      fontSize: phoneortablet == 1 ? DynamicSize.scale(context,11) : DynamicSize.scale(context, 5),
                      // fontSize: DynamicSize.scale(context, 11),
                      fontWeight: FontWeight.w400,
                      color: ColorCode.containerlblcolorlight,
                    ),
                  ),
                ],
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
              onTap: () async {
                setState(() {
                  addToCart(item);

                  item.cartId = cartId;
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
  Widget _buildQuantitySectionline(TrendingItem item) {
    return Padding(
      padding: EdgeInsets.only(right: DynamicSize.scale(context, 0),left: DynamicSize.scale(context, 8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          item.cartQuantity > 0
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal :DynamicSize.scale(context, 0),vertical: DynamicSize.scale(context, 8)),
            child: Container(
              height: phoneortablet == 1 ? DynamicSize.scale(context,46) : DynamicSize.scale(context, 25),
              decoration: BoxDecoration(
                color: Colors.transparent, // If you want the button background to be transparent
                border: Border.all(color: ColorCode.addtocartbtnbackcolor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  _buildCartQuantityControls(item),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        deleteCartItem(item.cartId.toString());
                        // Toestmessage('Product Removed From Cart');
                        showCustomSnackBar(context, 'Product Removed From Cart',Colors.red,2000);
                        // showToastMessage(context,'Product Removed From Cart',backColor: Colors.red);
                        item.cartQuantity = 0;
                      });
                    },
                    child: Padding(
                      padding:  EdgeInsets.only(right: DynamicSize.scale(context, 8)),
                      child: SvgPicture.asset(
                        'assets/icon/remove.svg', // Make sure the path is correct
                        width: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                        height: phoneortablet == 1 ? DynamicSize.scale(context,25) : DynamicSize.scale(context, 15),
                        // width: DynamicSize.scale(context, 25),
                        // height: DynamicSize.scale(context, 25),
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
              : Padding(
            padding: EdgeInsets.symmetric(horizontal :DynamicSize.scale(context, 0),vertical: DynamicSize.scale(context, 8)),
            child:GestureDetector(
              onTap: () {
                setState(() {
                  addToCart(item);
                  // showToastMessage(context,'Product Added To Cart',backColor: ColorCode.appcolorback);
                  showCustomSnackBar(context, 'Product Added To Cart',ColorCode.appcolorback,2000);
                  // Toestmessage('Product Added To Cart');
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
}

void main() {
  runApp(MaterialApp(
    home: ItemListScreen(),
  ));
}