import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import '../pages/product_listing_page.dart';
import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';

class Category {
  final int id;
  final String name;
  final String image;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<dynamic> subCategoriesJson = json['sub_categories'];
    List<SubCategory> subCategories =
    subCategoriesJson.map((data) => SubCategory.fromJson(data)).toList();

    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      subCategories: subCategories,
    );
  }
}

class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String code;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.code,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

List<Category> categories = [];

class TopCategories extends StatefulWidget {
  final String image;
  final String name;
  final int categoryId;

  const TopCategories({
    required this.image,
    required this.name,
    required this.categoryId,
  });

  @override
  State<TopCategories> createState() => TopCategoriesState();
}

class TopCategoriesState extends State<TopCategories> {


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFontSize = 16.0;
    return GestureDetector(
      onTap: () {
        print('Category ID: ${widget.categoryId}');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ItemListScreen(categoryId: widget.categoryId),
        //   ),
        // );
        // Add any other actions you want to perform on tap
      },
      child: Column(
        children: [
          Container(
            width: screenWidth/5,
            height: screenWidth/5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(
                    widget.image), // Use NetworkImage for fetching from a URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            widget.name,
            textAlign: TextAlign.center,style: TextStyle(color: ColorCode.textColor, fontWeight: FontWeight.w500,fontSize: defaultFontSize * screenWidth / 550,),
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> collectionsData = [];
class Collection {
  final String image;
  final String name;

  Collection({
    required this.image,
    required this.name,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      image: json['image'],
      name: json['name'],
    );
  }
}//collections model

List<Map<String, dynamic>> trendingItems = [];
class ApiResponse {
  final bool status;
  final Data data;

  ApiResponse({required this.status, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final TrendingItems trendingItems;

  Data({required this.trendingItems});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      trendingItems: TrendingItems.fromJson(json['items']),
    );
  }
}

class TrendingItems {
  final int currentPage;
  final List<TrendingItem> data;

  TrendingItems({required this.currentPage, required this.data});

  factory TrendingItems.fromJson(Map<String, dynamic> json) {
    return TrendingItems(
      currentPage: int.parse(json['current_page'].toString()), // Parse as int
      data: List<TrendingItem>.from(json['data'].map((x) => TrendingItem.fromJson(x))),
    );
  }
}

class TrendingItem {
   int id;
  final String name;
  final String grossWeight;
  final String netWeight;
  final String image;
   int? cartId;
   int? stone_quality_id;
   int cartQuantity; // Change type to int
   bool isWishlist;
  final bool available;

  TrendingItem({
    required this.id,
    required this.name,
    required this.grossWeight,
    required this.netWeight,
    required this.image,
    required this.cartId,
    required this.stone_quality_id,
    required this.cartQuantity, // Change type to int
    required this.isWishlist,
    required this.available,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'] ?? 0,
      // Provide a default value if null
      name: json['name'] ?? '',
      grossWeight: json['gross_weight'] ?? '0.0',
      // Provide a default value if null
      netWeight: json['net_weight'] ?? '0.0',
      // Provide a default value if null
      image: json['image'] ?? '',
      cartId: json['cart_id'],
      stone_quality_id: json['stone_quality_id'],
      // Provide a default value if null
      cartQuantity: int.parse(json['cart_quantity'].toString()),
      // Provide a default value if null
      isWishlist: json['is_wishlist'] ?? false,
      // Provide a default value if null
      available: json['available'] ?? false, // Provide a default value if null
    );
  }
}
class ImageAndNameWidgetSquare extends StatelessWidget {
  final String image;
  final String name;
  final int id;

  const ImageAndNameWidgetSquare({
    required this.image,
    required this.name,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {

    double defaultFontSizeall = 16.0;
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
    // double heightcollectioncontainer =  isTablet(context) ? 200.0 : 240.0;
    // double widthcollectioncontainer = isTablet(context) ? 150.0 : 180.0;

    double heightcollectioncontainer =  isTablet(context) ?  DynamicSize.scale(context, 200) :  DynamicSize.scale(context, 190);
    double widthcollectioncontainer = isTablet(context) ? DynamicSize.scale(context, 150) : DynamicSize.scale(context, 145);


    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    // double defaultFontSize = 16.0;
    return Column(
      children: [
        SizedBox(
          height: heightcollectioncontainer,
          width: widthcollectioncontainer,
          // height: screenWidth / 1.8,
          // width: screenWidth / 2.3,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () async{
                  // Handle the onTap event here
                  print('Collection Name: $name, ID: $id');
                  print('Collection Name: selectedCollectionsStr: $id');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemListScreen(selectedCollectionsStr: '$id', title:this.name),
                    ),
                  );

                },
                child: Container(
                  height: heightcollectioncontainer,
                  width: widthcollectioncontainer,
                  // width: screenWidth / 2,
                  // height: screenWidth / 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: NetworkImage(image), // Use NetworkImage for network images
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    // color: ColorCode.primaryColor.withOpacity(0.8),
                    color: Color.fromRGBO(255, 237, 247, 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: DynamicSize.scale(context, 12),
                          // fontSize: defaultFontSizeall,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(90, 45, 71, 1)),
                          // color: ColorCode.backgroundColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class ImageAndNameInsidePhotoCustomFeatured extends StatelessWidget {
  final String image;
  final String name;
  final List<Color> gradientColors;

  const ImageAndNameInsidePhotoCustomFeatured({
    required this.image,
    required this.name,
    required this.gradientColors,
  });
  @override
  Widget build(BuildContext context) {
    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }
    double heightcollectioncontainer =  isTablet(context) ?  DynamicSize.scale(context, 120) :  DynamicSize.scale(context, 120);
    double widthcollectioncontainer = isTablet(context) ? DynamicSize.scale(context, 165) : DynamicSize.scale(context, 165);

    // double heightcollectioncontainer = isTablet(context) ? 220.0 : 139.0;
    // double widthcollectioncontainer = isTablet(context) ? 210.0 : 190.0;

    // double imageheight = isTablet(context) ? 100.0 : 50.0;
    // double imagewidth = isTablet(context) ? 100.0 : 50.0;

    double imageheightwidth = isTablet(context) ? DynamicSize.scale(context, 50) : DynamicSize.scale(context, 50);




    return SizedBox(
      height: heightcollectioncontainer,
      width: widthcollectioncontainer,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: imageheightwidth,
                height: imageheightwidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: SvgPicture.asset(
                    'assets/$image', // Ensure the SVG file is in your assets folder

                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: DynamicSize.scale(context, 10)),
              Text(
                name,
                style: TextStyle(
                  fontSize: DynamicSize.scale(context, 12),
                  color: Color.fromRGBO(119, 46, 35, 1),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class ImageAndNameInsidePhotoCustomFeatured extends StatelessWidget {
//   final String image;
//   final String name;
//   final List<Color> gradientColors;
//
//   const ImageAndNameInsidePhotoCustomFeatured({
//     required this.image,
//     required this.name,
//     required this.gradientColors,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool isTablet(BuildContext context) {
//       // Get the diagonal screen size
//       final double diagonalSize = MediaQuery.of(context).size.shortestSide;
//
//       // If the diagonal size is greater than 600, it's considered a tablet
//       return diagonalSize > 600;
//     }
//     double heightcollectioncontainer =  isTablet(context) ? 220.0 : 200.0;
//     double widthcollectioncontainer = isTablet(context) ? 210.0 : 200.0;
//
//     double imageheight = isTablet(context) ? 100.0 : 100.0;
//     double imagewidth = isTablet(context) ? 100.0 : 100.0;
//
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double defaultFontSize = isTablet(context) ? 24.0 : 16.0;
//     double defaultFontSizeheading = isTablet(context) ? 40.0 : 50.0;
//
//
//     return SizedBox(
//       height: heightcollectioncontainer,
//       width: widthcollectioncontainer,
//       child: GestureDetector(
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20.0),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: gradientColors,
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: imagewidth,
//                 height: imageheight,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20.0),
//                   child: Image.asset(
//                     height: 100,
//                     width: 100,
//                     'assets/$image',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: defaultFontSize+2,
//                   color: Color.fromRGBO(119, 46, 35, 1),
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }//featured gor use in home




// class ImageAndNameInsidePhotoCustomFeatured extends StatelessWidget {
//   final String image;
//   final String name;
//   final List<Color> gradientColors;
//
//   const ImageAndNameInsidePhotoCustomFeatured({
//     required this.image,
//     required this.name,
//     required this.gradientColors,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool isTablet(BuildContext context) {
//       // Get the diagonal screen size
//       final double diagonalSize = MediaQuery.of(context).size.shortestSide;
//
//       // If the diagonal size is greater than 600, it's considered a tablet
//       return diagonalSize > 600;
//     }
//     double heightcollectioncontainer =  isTablet(context) ? 220.0 : 150.0;
//     double widthcollectioncontainer = isTablet(context) ? 210.0 : 150.0;
//
//     double imageheight = isTablet(context) ? 100.0 : 100.0;
//     double imagewidth = isTablet(context) ? 100.0 : 100.0;
//
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double defaultFontSize = isTablet(context) ? 24.0 : 16.0;
//     double defaultFontSizeheading = isTablet(context) ? 40.0 : 50.0;
//
//
//     return SizedBox(
//       height: heightcollectioncontainer,
//       width: widthcollectioncontainer,
//       child: GestureDetector(
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20.0),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: gradientColors,
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: imagewidth,
//                 height: imageheight,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20.0),
//                   child: Image.asset(
//                     height: 100,
//                     width: 100,
//                     'assets/$image',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               // SizedBox(height: 10.0),
//               Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: defaultFontSize,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }//featured gor use in home






class ImageAndNameInsidePhotoCustomFeatured1 extends StatelessWidget {
  final String image;
  final String name;
  final List<Color> gradientColors;

  const ImageAndNameInsidePhotoCustomFeatured1({
    required this.image,
    required this.name,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet(BuildContext context) {
      // Get the diagonal screen size
      final double diagonalSize = MediaQuery.of(context).size.shortestSide;

      // If the diagonal size is greater than 600, it's considered a tablet
      return diagonalSize > 600;
    }
    double heightcollectioncontainer =  isTablet(context) ? 200.0 : 100.0;
    double widthcollectioncontainer = isTablet(context) ? 210.0 : 400.0;


    double imageheight = isTablet(context) ? 200.0 : 100.0;
    double imagewidth = isTablet(context) ? 200.0 : 100.0;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFontSize = isTablet(context) ? 24.0 : 16.0;
    double defaultFontSizeheading = isTablet(context) ? 40.0 : 50.0;


    return SizedBox(
      height: heightcollectioncontainer,
      width: widthcollectioncontainer,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: defaultFontSize+5,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(width: 20.0), // Adjust as needed for space between image and text
              Expanded(
                child: SizedBox(
                  width: imagewidth,
                  height: imageheight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'assets/$image',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }
}//featured gor use in home



class FilterData {
  List<int> selectedGenders;
  List<int> selectedBrands;
  List<int> selectedCollections;

  FilterData({
    required this.selectedGenders,
    required this.selectedBrands,
    required this.selectedCollections,
  });
}

