import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

class OrderHistory {
  final int? orderId;
  final String? orderNo;
  final String? grossWeight;
  final String? netWeight;
  final int? quantity;
  final String? remark;
  final OrderStatus? orderStatus;

  OrderHistory({
    required this.orderId,
    required this.orderNo,
    required this.grossWeight,
    required this.netWeight,
    required this.quantity,
    required this.remark,
    required this.orderStatus,
  });
}

class OrderStatus {
  final int id;
  final String name;

  OrderStatus({
    required this.id,
    required this.name,
  });
}

class OrderPage extends StatefulWidget {
  @override
  State<OrderPage> createState() => _OrderPageState();
}


class _OrderPageState extends State<OrderPage> {

  final TextEditingController _searchController = TextEditingController();
  String? pdflink = '';
  double defaultFontSizeall = 16.0;
  double defaultFontSizeheading = 16.0;
  double iconsize = 0;
  bool _isLoading = false;
  List<OrderHistory> orderHistory = [];
  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }
  void dispose() {
    super.dispose();
  }
  Future<void> _fetchOrderHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}order/history'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          List<
              dynamic> orderData = responseData['data']['order_history']['data'];
          if (_searchController.text.isNotEmpty) {
            orderData = orderData.where((item) =>
                item['order_no'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
          }
          setState(() {
            _isLoading = true;
            orderHistory = orderData.map((order) {
              return OrderHistory(
                orderId: order['order_id'],
                orderNo: order['order_no'],
                grossWeight: order['gross_weight'],
                netWeight: order['net_weight'],
                quantity: order['quantity'],
                remark: order['remark'],
                orderStatus: OrderStatus(
                  id: order['order_status']['id'],
                  name: order['order_status']['name'],
                ),
              );
            }).toList();
          });
        } else {
          print('Failed to fetch order history. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching order history: $e');
    }
  }
  Future<void> _downloadOrder(String orderid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}order/print/$orderid'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print(responseData);
          setState(() {
            pdflink = responseData['data']['url'];
          });
        } else {
          print('Failed to fetch order history. Status code: ${response
              .statusCode}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (e) {
      print('Error fetching order history: $e');
    }
    // if (pdflink != null) {
    //   // Try to launch the PDF link in Chrome
    //   try {
    //     // Use the launch function from url_launcher to open the PDF link in Chrome
    //     await launch(
    //       pdflink!,
    //
    //       // Specify the forceSafariVC parameter to false to force opening in Chrome
    //       forceSafariVC: false,
    //       // Specify the forceWebView parameter to false to force opening in Chrome
    //       forceWebView: false,
    //       // Specify the headers parameter if needed
    //       // headers: <String, String>{'my_header_key': 'my_header_value'},
    //     );
    //   } catch (e) {
    //     // Handle any errors that occur while trying to launch the URL
    //     print('Error launching URL: $e');
    //   }
    // } else {
    //   // Handle the case where the PDF link is null or empty
    //   print('PDF link is null or empty');
    // }
  }
  Widget build(BuildContext context) {

    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }

    defaultFontSizeheading = isTablet(context) ? 30.0 : 20.0;
    defaultFontSizeall = isTablet(context) ? 16.0 : 12.0;
    iconsize = isTablet(context) ? 80.0 : 40.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Orders',
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: ColorCode.appcolorback
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(DynamicSize.scale(context, 8)),
        child: Column(
          children: [
            // Add text fields for filtering data
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: ColorCode.textboxanddropdownbackcolor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:  DynamicSize.scale(context, 8)),
                child: TextFormField(
                  controller: _searchController,
                  cursorColor: ColorCode.appcolorback, // Set the cursor color
                  style: TextStyle(
                    color: ColorCode.appcolorback, // Set the text color
                    fontWeight: FontWeight.w400,
                    fontSize: DynamicSize.scale(context, 14),
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: ColorCode.appcolorback,
                    ),
                    hintText: 'Search by Order No',
                    border: InputBorder.none, // Remove the default underline
                  ),
                  onChanged: (value) {
                    setState(() {
                      _fetchOrderHistory();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: DynamicSize.scale(context, 10)),
            Expanded(
              child: Padding(
                padding:  EdgeInsets.only(right: isTablet(context) ? DynamicSize.scale(context, 10) : DynamicSize.scale(context, 2), left: isTablet(context) ? DynamicSize.scale(context, 10) : DynamicSize.scale(context, 2), bottom: isTablet(context) ? DynamicSize.scale(context, 5) : DynamicSize.scale(context, 2)),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),

    );
  }
  Widget _buildBody() {
    if (_isLoading == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/undraw_order_delivered_re_v4ab.svg', // Path to your SVG file
              height: 200, // Adjust size as needed
            ),
            SizedBox(height: 20),
            Text(
              'No Order Here',
              style: TextStyle(
                color: ColorCode.appcolorback,
                fontSize: DynamicSize.scale(context, 20),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Order now to get started.',
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
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                return _buildCard(orderHistory[index]);
              },
            ),
          ),
        ],
      );
    }
  }
  // Widget _buildBody() {
  //   if (orderHistory.isEmpty && _isLoading) {
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   } else {
  //     return Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: orderHistory.length,
  //             itemBuilder: (context, index) {
  //               return _buildCard(orderHistory[index]);
  //             },
  //           ),
  //         ),
  //         if (_isLoading)
  //           Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: Center(
  //               child: Text('krn'),
  //               // child: CircularProgressIndicator(),
  //             ),
  //           ),
  //       ],
  //     );
  //   }
  // }


  Widget _buildCard(OrderHistory cardData) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // First Row
          Padding(
            padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
            child: Row(
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
                          'Order No:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.orderNo!,
                          style: TextStyle(
                            color: ColorCode.containerlblcolor,
                            fontWeight: FontWeight.w500,
                            fontSize: DynamicSize.scale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gross Weight',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.grossWeight!,
                          style: TextStyle(
                            color: ColorCode.containerlblcolor,
                            fontWeight: FontWeight.w500,
                            fontSize: DynamicSize.scale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Weight:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.netWeight!,
                          style: TextStyle(
                            color: ColorCode.containerlblcolor,
                            fontWeight: FontWeight.w500,
                            fontSize: DynamicSize.scale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.download_for_offline, color: ColorCode.appcolorback),
                    iconSize: DynamicSize.scale(context, 40),
                    onPressed: () async {
                      print(pdflink);
                      await _downloadOrder(cardData.orderId.toString());
                      print(pdflink);
                      await launch(pdflink!);
                    },
                  ),
                ),
              ],
            ),
          ), // First row
          Padding(
            padding: EdgeInsets.all(DynamicSize.scale(context, 5)),
            child: Row(
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
                          'Quantity:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.quantity!.toString(),
                          style: TextStyle(
                            color: ColorCode.containerlblcolor,
                            fontWeight: FontWeight.w500,
                            fontSize: DynamicSize.scale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remarks:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          // cardData.remark.toString(),
                          cardData.remark != null ? cardData.remark.toString() : '',
                          style: TextStyle(
                            color: ColorCode.containerlblcolor,
                            fontWeight: FontWeight.w500,
                            fontSize: DynamicSize.scale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: cardData.orderStatus?.name == 'WIP' ? Colors.blue.shade100 :
                            cardData.orderStatus?.name == 'Pending' ? Colors.yellow.shade100 :
                            cardData.orderStatus?.name == 'Rejected' ? Colors.red.shade100 :
                            cardData.orderStatus?.name == 'Completed' ? Colors.green.shade100 :
                            Colors.blue,
                            // color: cardData.orderStatus?.name == 'Pending' ? Colors.yellow : Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                            child: Text(
                              cardData.orderStatus!.name,
                              style: TextStyle(
                                color: ColorCode.containerlblcolor,
                                fontWeight: FontWeight.w500,
                                fontSize: DynamicSize.scale(context, 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                  ),
                ),
              ],
            ),
          ), // First row



          // Remove SizedBox and padding to minimize space

        ],
      ),
    );
  }
}
