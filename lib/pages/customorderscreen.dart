import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';
import '../utilis/routes.dart';

class OrderHistory {
  final int? id;
  final String? customizeOrderNo;
  final String? dueDate;
  final String? subname;
  final String? remark;
  final int? categoryId;
  final int? purityId;
  final String? referenceName;
  final int? quantity;
  final int? pcs;
  final String? approxWeight;
  final OrderStatus? orderStatus;
  final String? description;
  final User? createdBy;
  final User? updatedBy;
  final User? customer;
  final Category? category;
  final Purity? purity;


  OrderHistory({
    required this.id,
    required this.customizeOrderNo,
    required this.dueDate,
    required this.subname,
    required this.remark,
    required this.categoryId,
    required this.purityId,
    required this.referenceName,
    required this.quantity,
    required this.pcs,
    required this.approxWeight,
    required this.orderStatus,
    required this.description,
    required this.createdBy,
    required this.updatedBy,
    required this.customer,
    required this.category,
    required this.purity,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'],
      customizeOrderNo: json['customize_order_no'],
      dueDate: json['due_date'],
      subname: json['subname'],
      remark: json['remark'],
      categoryId: json['category_id'],
      purityId: json['purity_id'],
      referenceName: json['reference_name'],
      quantity: json['quantity'],
      pcs: json['pcs'],
      approxWeight: json['approx_weight'],
      orderStatus: OrderStatus.fromJson(json['order_status']),
      description: json['description'],
      createdBy: User.fromJson(json['created_by']),
      updatedBy: User.fromJson(json['updated_by']),
      customer: User.fromJson(json['customer']),
      category: Category.fromJson(json['category']),
      purity: Purity.fromJson(json['purity']),
    );
  }
}

class OrderStatus {
  final int id;
  final String name;

  OrderStatus({
    required this.id,
    required this.name,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'],
      name: json['name'],
    );
  }
}

class User {
  final int id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Purity {
  final int id;
  final String name;

  Purity({
    required this.id,
    required this.name,
  });

  factory Purity.fromJson(Map<String, dynamic> json) {
    return Purity(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CustomOrders extends StatefulWidget {
  @override
  State<CustomOrders> createState() => _CustomOrdersState();
}

class _CustomOrdersState extends State<CustomOrders> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderHistory> _orderHistory = [];
  bool _isLoading = false;
  String? pdflink = '';
  double defaultFontSizeall = 16.0;
  double defaultFontSizeheading = 16.0;

  bool isDropdownSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _downloadOrder(String orderid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}customize-orders/$orderid/print'),
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

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${MyRoutes.baseurl}customize-orders'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);



          List<dynamic> orderData = responseData['data'];

          if (_searchController.text.isNotEmpty) {
            orderData = orderData.where((item) =>
                item['subname'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
          }


          final List<OrderHistory> orderHistory = orderData.map((data) => OrderHistory.fromJson(data)).toList();

          setState(() {
            _orderHistory = orderHistory;
            _isLoading = false;
          });
        } else {
          print('Failed to fetch order history. Status code: ${response.statusCode}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Access token is null.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching order history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Custom Orders',
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: ColorCode.textboxanddropdownbackcolor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric( horizontal:  DynamicSize.scale(context, 8)),
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
                    hintText: 'Search by Sub Name',
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
              child: _buildBody(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Center(
          child: GestureDetector(



            onTap: () {
              Navigator.pushNamed(context, MyRoutes.addCustomOrders);
            },
            child: Container(
              width: 1000,
              height: 50,
              decoration: BoxDecoration(
                color: ColorCode.appcolorback,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Add Custom Order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorCode.btntextcolor,
                    fontSize: DynamicSize.scale(context, 14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_orderHistory.isEmpty) {
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
            // GestureDetector(
            //   onTap: (){
            //     Navigator.pushNamed(context, MyRoutes.dashboard);
            //   },
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 40),vertical: DynamicSize.scale(context, 12)),
            //     child: Container(
            //
            //       decoration: BoxDecoration(
            //         color: ColorCode.appcolorback,
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: Center(
            //         child: Padding(
            //           padding:  EdgeInsets.symmetric(vertical: DynamicSize.scale(context, 12)),
            //           child: Text(
            //             'Order Now',
            //             style: TextStyle(
            //               color: ColorCode.btntextcolor,
            //               fontSize: DynamicSize.scale(context, 14),
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _orderHistory.length,
              itemBuilder: (context, index) {
                return _buildCard(_orderHistory[index]);
              },
            ),
          ),
        ],
      );
    }
  }

  // Widget _buildBody() {
  //   if (_orderHistory.isEmpty && _isLoading) {
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   } else {
  //     return ListView.builder(
  //       itemCount: _orderHistory.length,
  //       itemBuilder: (context, index) {
  //         return _buildCard(_orderHistory[index]);
  //       },
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
                          cardData.customizeOrderNo!,
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
                          'Due Date:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.dueDate!,
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
                          'Sub Name:',
                          style: TextStyle(
                            color: ColorCode.appcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: DynamicSize.scale(context, 10),
                          ),
                        ),
                        Text(
                          cardData.subname!,
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
                      await _downloadOrder(cardData.id.toString());
                      print(pdflink);
                      await launch(pdflink!);
                    },
                  ),
                ),
              ],
            ),
          ), // First row
          // Remove SizedBox and padding to minimize space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Reduced padding
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
                        cardData.quantity.toString(),
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
                        'Category:',
                        style: TextStyle(
                          color: ColorCode.appcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: DynamicSize.scale(context, 10),
                        ),
                      ),
                      Text(
                        cardData.category!.name,
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
                        'Remarks:',
                        style: TextStyle(
                          color: ColorCode.appcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: DynamicSize.scale(context, 10),
                        ),
                      ),
                      Text(
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
                flex: 1,
                child: Container(),
              ),
            ],
          ), // Second row
          // Remove SizedBox and padding to minimize space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pcs:',
                        style: TextStyle(
                          color: ColorCode.appcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: DynamicSize.scale(context, 10),
                        ),
                      ),
                      Text(
                        cardData.pcs.toString(),
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
                        'Purity:',
                        style: TextStyle(
                          color: ColorCode.appcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: DynamicSize.scale(context, 10),
                        ),
                      ),
                      Text(
                        cardData.purity!.name,
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
                child: Container(),
              ),
            ],
          ), // Third row
          // Remove SizedBox and padding to minimize space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: ColorCode.appcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: DynamicSize.scale(context, 10),
                        ),
                      ),
                      Text(
                        cardData.description != null ? cardData.description.toString() : '',
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
            ],
          ), // Fourth row
          // Remove SizedBox(height: DynamicSize.scale(context, 1)),
        ],
      ),
    );
  }



// Widget _buildCard(OrderHistory cardData) {
  //   return Card(
  //     elevation: 2,
  //     child: Column(
  //       children: [
  //         // First Row
  //         Padding(
  //           padding:  EdgeInsets.all(DynamicSize.scale(context, 5)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 flex: 2,
  //                 child: Container(
  //                   // padding: const EdgeInsets.all(8.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Order No:',
  //                         style: TextStyle(
  //                           color: ColorCode.appcolor,
  //                           fontWeight: FontWeight.w400,
  //                           fontSize: DynamicSize.scale(context, 10),
  //                         ),
  //                       ),
  //                       Text(
  //                         cardData.customizeOrderNo!,
  //                         style: TextStyle(
  //                           color: ColorCode.containerlblcolor,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: DynamicSize.scale(context, 12),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Container(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Due Date:',
  //                         style: TextStyle(
  //                           color: ColorCode.appcolor,
  //                           fontWeight: FontWeight.w400,
  //                           fontSize: DynamicSize.scale(context, 10),
  //                         ),
  //                       ),
  //                       Text(
  //                         cardData.dueDate!,
  //                         style: TextStyle(
  //                           color: ColorCode.containerlblcolor,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: DynamicSize.scale(context, 12),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Container(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Sub Name:',
  //                         style: TextStyle(
  //                           color: ColorCode.appcolor,
  //                           fontWeight: FontWeight.w400,
  //                           fontSize: DynamicSize.scale(context, 10),
  //                         ),
  //                       ),
  //                       Text(
  //                         cardData.subname!,
  //                         style: TextStyle(
  //                           color: ColorCode.containerlblcolor,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: DynamicSize.scale(context, 12),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 1,
  //                 child:  IconButton(
  //                   icon: Icon(Icons.download_for_offline, color: ColorCode.appcolorback),
  //                   iconSize: DynamicSize.scale(context, 40),
  //                   onPressed: () async {
  //                     print(pdflink);
  //                     await _downloadOrder(cardData.customizeOrderNo.toString());
  //                     print(pdflink);
  //                     await launch(pdflink!);
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ), // First row
  //         SizedBox(height: DynamicSize.scale(context, 1)),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Quantity:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.quantity.toString(),
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Category:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.category!.name,
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Remarks:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.remark!,
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 1,
  //               child: Container(
  //
  //
  //               ),
  //             ),
  //           ],
  //         ), // Second row
  //         SizedBox(height: DynamicSize.scale(context, 1)),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Pcs:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.pcs.toString(),
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Purity:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.purity!.name,
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 2,
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Status:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: cardData.orderStatus?.name == 'Pending' ? Colors.yellow : Colors.green,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(
  //                           cardData.orderStatus!.name,
  //                           style: TextStyle(
  //                             color: ColorCode.containerlblcolor,
  //                             fontWeight: FontWeight.w500,
  //                             fontSize: DynamicSize.scale(context, 12),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 1,
  //               child: Container(
  //
  //
  //               ),
  //             ),
  //           ],
  //         ), // Third row
  //         SizedBox(height: DynamicSize.scale(context, 1)),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Remarks:',
  //                       style: TextStyle(
  //                         color: ColorCode.appcolor,
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: DynamicSize.scale(context, 10),
  //                       ),
  //                     ),
  //                     Text(
  //                       cardData.remark.toString(),
  //                       style: TextStyle(
  //                         color: ColorCode.containerlblcolor,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: DynamicSize.scale(context, 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //
  //           ],
  //         ), // forth row
  //         SizedBox(height: DynamicSize.scale(context, 1)),
  //       ],
  //     ),
  //   );
  // }

}