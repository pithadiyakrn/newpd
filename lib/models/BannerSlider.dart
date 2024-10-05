import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/routes.dart';

class BannerData {
  final String name;
  final String image;

  BannerData({
    required this.name,
    required this.image,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      name: json['name'],
      image: json['image'],
    );
  }
}

class BannerSlider extends StatefulWidget {
  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<BannerData> banners = [];
  late String? token;

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }


  Future<void> fetchBanners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');


    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
        Uri.parse('${MyRoutes.baseurl}banners'), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> bannerList = responseData['data']['banners'];
      setState(() {
        banners = bannerList.map((item) => BannerData.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load banners');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        // height: MediaQuery
        //     .of(context)
        //     .size
        //     .width > 600 ? 450.0 : 230.0,
        height: MediaQuery
            .of(context)
            .size
            .width > 600 ? DynamicSize.scale(context, 200) : DynamicSize.scale(context, 200),
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayCurve: Curves.easeInCirc,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 1.0,
      ),
      items: banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
            borderRadius: BorderRadius.circular(20),
              child: Image.network(
                banner.image,
                fit: BoxFit.contain,
                height: MediaQuery
                    .of(context)
                    .size
                    .width > 600 ? DynamicSize.scale(context, 200) : DynamicSize.scale(context, 200),
                // height: MediaQuery
                //     .of(context)
                //     .size
                //     .width > 600 ? 600.0 : 398.0,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}