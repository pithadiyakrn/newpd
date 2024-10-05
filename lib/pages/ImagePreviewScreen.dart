

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../utilis/colorcode.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  ImagePreviewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set scaffold background to white
      appBar: AppBar(
        backgroundColor: ColorCode.appcolorback, // Set app bar background to white
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black), // Set close icon color to black for contrast
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
          ),
          imageProvider: NetworkImage(imageUrl),
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/error-image.png',
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
