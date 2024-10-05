import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../utilis/DynamicSize.dart';
import '../utilis/colorcode.dart';

class HtmlDisplay extends StatelessWidget {
  final String htmlContent;

  HtmlDisplay({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Condition', style: TextStyle(
            fontWeight: FontWeight.w400,
            color: ColorCode.appcolorback
        ),),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: HtmlWidget(
            htmlContent,
            textStyle: TextStyle(fontSize: 24), // Optional: Custom style for the text
          ),
        ),
      ),
    );
  }
}
