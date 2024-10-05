// // // import 'package:flutter/material.dart';
// // //
// // // class CustomTextbox extends StatefulWidget {
// // //   final String labelText;
// // //   final Function(String) onChanged;
// // //   final Icon? prefixIcon;
// // //   final Icon? suffixIcon;
// // //   final VoidCallback? onPrefixPressed;
// // //   final VoidCallback? onSuffixPressed;
// // //   final double? borderWidth;
// // //   final TextEditingController? controller;
// // //
// // //   CustomTextbox({
// // //     required this.labelText,
// // //     required this.onChanged,
// // //     this.prefixIcon,
// // //     this.suffixIcon,
// // //     this.onPrefixPressed,
// // //     this.onSuffixPressed,
// // //     this.borderWidth,
// // //     this.controller,
// // //   });
// // //
// // //   @override
// // //   State<CustomTextbox> createState() => _CustomTextboxState();
// // // }
// // //
// // // class _CustomTextboxState extends State<CustomTextbox> {
// // //   bool obscureText = false; // Track password visibility
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     Brightness brightness = Theme.of(context).brightness;
// // //     Color borderColor = brightness == Brightness.light ? Colors.grey : Colors.red;
// // //
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         borderRadius: BorderRadius.all(Radius.circular(10)),
// // //         border: Border.all(
// // //           color: borderColor,
// // //           width: widget.borderWidth ?? 0.0,
// // //         ),
// // //       ),
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
// // //         child: Row(
// // //           children: [
// // //             if (widget.prefixIcon != null)
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   if (widget.onPrefixPressed != null) {
// // //                     widget.onPrefixPressed!();
// // //                   }
// // //                   setState(() {
// // //                     obscureText = !obscureText;
// // //                   });
// // //                 },
// // //                 child: widget.prefixIcon!,
// // //               ),
// // //             Expanded(
// // //               child: TextField(
// // //                 controller: widget.controller,
// // //                 style: TextStyle(color: Colors.black),
// // //                 obscureText: obscureText,
// // //                 decoration: InputDecoration(
// // //                   hintText: widget.labelText,
// // //                   border: InputBorder.none,
// // //                 ),
// // //                 onChanged: widget.onChanged,
// // //               ),
// // //             ),
// // //             if (widget.suffixIcon != null)
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   if (widget.onSuffixPressed != null) {
// // //                     widget.onSuffixPressed!();
// // //                   }
// // //                   setState(() {
// // //                     obscureText = !obscureText;
// // //                   });
// // //                 },
// // //                 child: widget.suffixIcon!,
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// //
// //
// // import 'package:flutter/material.dart';
// //
// // class CustomTextbox extends StatefulWidget {
// //   final String labelText;
// //   final Function(String) onChanged;
// //   final Icon? prefixIcon;
// //   final Icon? suffixIcon;
// //   final VoidCallback? onPrefixPressed;
// //   final VoidCallback? onSuffixPressed;
// //   final double? borderWidth;
// //   final TextEditingController? controller;
// //   final Color? borderColor; // New parameter for border color
// //
// //   CustomTextbox({
// //     required this.labelText,
// //     required this.onChanged,
// //     this.prefixIcon,
// //     this.suffixIcon,
// //     this.onPrefixPressed,
// //     this.onSuffixPressed,
// //     this.borderWidth,
// //     this.controller,
// //     this.borderColor, // Provide a default value or let it be null
// //   });
// //
// //   @override
// //   State<CustomTextbox> createState() => _CustomTextboxState();
// // }
// //
// // class _CustomTextboxState extends State<CustomTextbox> {
// //   bool obscureText = false; // Track password visibility
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     Brightness brightness = Theme.of(context).brightness;
// //     Color borderColor = widget.borderColor ?? (brightness == Brightness.light ? Colors.grey : Colors.red);
// //
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.all(Radius.circular(10)),
// //         border: Border.all(
// //           color: borderColor,
// //           width: widget.borderWidth ?? 0.0,
// //         ),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //         child: Row(
// //           children: [
// //             if (widget.prefixIcon != null)
// //               GestureDetector(
// //                 onTap: () {
// //                   if (widget.onPrefixPressed != null) {
// //                     widget.onPrefixPressed!();
// //                   }
// //                   setState(() {
// //                     obscureText = !obscureText;
// //                   });
// //                 },
// //                 child: widget.prefixIcon!,
// //               ),
// //             Expanded(
// //               child: TextField(
// //                 controller: widget.controller,
// //                 style: TextStyle(color: Colors.black),
// //                 obscureText: obscureText,
// //                 decoration: InputDecoration(
// //                   hintText: widget.labelText,
// //                   border: InputBorder.none,
// //                 ),
// //                 onChanged: widget.onChanged,
// //               ),
// //             ),
// //             if (widget.suffixIcon != null)
// //               GestureDetector(
// //                 onTap: () {
// //                   if (widget.onSuffixPressed != null) {
// //                     widget.onSuffixPressed!();
// //                   }
// //                   setState(() {
// //                     obscureText = !obscureText;
// //                   });
// //                 },
// //                 child: widget.suffixIcon!,
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../utilis/colorcode.dart';
import 'DynamicSize.dart';

class CustomTextbox extends StatefulWidget {
  final String labelText;
  final Function(String) onChanged;
  final Icon? prefixIcon;
  final Widget? suffixIcon; // Change type to Widget?
  final bool obscureText; // Add obscureText parameter
  final VoidCallback? onPrefixPressed;
  final VoidCallback? onSuffixPressed;
  final double? borderWidth;
  final TextEditingController? controller;
  final Color? borderColor; // New parameter for border color
  final bool useNumericKeyboard; // New parameter to determine whether to use numeric keyboard
  final String? errorMessage;
  final TextCapitalization textCapitalization; // New parameter for text capitalization
  final bool enabled; // New parameter for enabling/disabling the TextField
  final double? fontSize; // Optional font size parameter
  final FormFieldValidator<String>? validator; // Add validator parameter
  final bool required;
  final Color? backgroundColor; // New parameter for background color

  CustomTextbox({
    required this.labelText,
    required this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onPrefixPressed,
    this.onSuffixPressed,
    this.borderWidth,
    this.controller,
    this.obscureText = false, // Provide a default value
    this.borderColor, // Provide a default value or let it be null
    this.useNumericKeyboard = false, // Provide a default value or let it be false
    this.errorMessage,
    this.textCapitalization = TextCapitalization.none, // Provide a default valueh
    this.enabled = true, // Provide a default value for enabling the TextField
    this.fontSize, // Accept optional font size parameter
    this.validator, // Accept validator parameter
    this.required = false,
    this.backgroundColor, // Accept background color parameter
  });

  @override
  State<CustomTextbox> createState() => _CustomTextboxState();
}

class _CustomTextboxState extends State<CustomTextbox> {
  String? _validateInput(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  }

  // bool obscureText = widget.obscureText as bool; // Track password visibility


  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // double defaultFontSize = widget.fontSize ?? 14; // Assign 0 if fontSize parameter is not provided




    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = widget.borderColor ?? (brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder);
    borderColor = Colors.transparent;

    Color backgroundColor = widget.backgroundColor ?? ColorCode.textboxanddropdownbackcolor; // Use passed background color or default

    bool obscureText = widget.obscureText; // Track password visibility

    return Container(
      // height: 40,
        // width: 398,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: borderColor,
          width: widget.borderWidth ?? 0.0,
        ),

        color: backgroundColor, // Set the background color
        // color: Color.fromRGBO(202, 118, 134, 0.08),
      ),
      child: Padding(
        padding:  EdgeInsets.all(DynamicSize.scale(context, 0)),
        child: Row(
          children: [
            if (widget.prefixIcon != null)
              GestureDetector(
                onTap: () {
                  if (widget.onPrefixPressed != null) {
                    widget.onPrefixPressed!();
                  }
                  setState(() {
                    obscureText = true;
                    obscureText = !obscureText;
                  });
                },
                child: widget.prefixIcon!,
              ),
            Expanded(

              child: Padding(
                padding:  EdgeInsets.only(left: DynamicSize.scale(context, 10)),
                child: TextField(

                  cursorColor: ColorCode.appcolorback, // Set the cursor color
                  controller: widget.controller,
                  style: TextStyle(color: ColorCode.appcolor,),
                  obscureText: obscureText,
                  textCapitalization: widget.useNumericKeyboard ? TextCapitalization.characters : widget.textCapitalization,
                  keyboardType: widget.useNumericKeyboard ? TextInputType.number : null, // Set numeric keyboard if needed
                  inputFormatters: widget.useNumericKeyboard ? [FilteringTextInputFormatter.digitsOnly] : null,
                  decoration: InputDecoration(
                    isDense: true, // Make the TextField dense to reduce height
                    // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Remove top and bottom padding
                    hintStyle: TextStyle(color: ColorCode.appcolor, height:  DynamicSize.scale(context, 0),),
                    hintText: widget.labelText,
                    border: InputBorder.none,
                    errorText: widget.errorMessage, // Set error message here
                  ),
                  onChanged: widget.onChanged,
                enabled: widget.enabled,
                ),
              ),
            ),

            if (widget.suffixIcon != null)
              GestureDetector(
                onTap: () {
                  if (widget.onSuffixPressed != null) {
                    widget.onSuffixPressed!();
                  }
                  setState(() {
                    obscureText = true;
                    obscureText = !obscureText;
                  });
                },
                child: widget.suffixIcon!,
              ),
          ],
        ),
      ),
    );
  }
}


class CustomTextbox2 extends StatefulWidget {
  final String labelText;
  final Function(String) onChanged;
  final Icon? prefixIcon;
  final Widget? suffixIcon; // Change type to Widget?
  final bool obscureText; // Add obscureText parameter
  final VoidCallback? onPrefixPressed;
  final VoidCallback? onSuffixPressed;
  final double? borderWidth;
  final TextEditingController? controller;
  final Color? borderColor; // New parameter for border color
  final bool useNumericKeyboard; // New parameter to determine whether to use numeric keyboard
  final String? errorMessage;
  final TextCapitalization textCapitalization; // New parameter for text capitalization
  final bool enabled; // New parameter for enabling/disabling the TextField
  final double? fontSize; // Optional font size parameter
  final FormFieldValidator<String>? validator; // Add validator parameter
  final bool required;
  final Color? backgroundColor; // New parameter for background color

  CustomTextbox2({
    required this.labelText,
    required this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onPrefixPressed,
    this.onSuffixPressed,
    this.borderWidth,
    this.controller,
    this.obscureText = false, // Provide a default value
    this.borderColor, // Provide a default value or let it be null
    this.useNumericKeyboard = false, // Provide a default value or let it be false
    this.errorMessage,
    this.textCapitalization = TextCapitalization.none, // Provide a default valueh
    this.enabled = true, // Provide a default value for enabling the TextField
    this.fontSize, // Accept optional font size parameter
    this.validator, // Accept validator parameter
    this.required = false,
    this.backgroundColor, // Accept background color parameter
  });

  @override
  State<CustomTextbox2> createState() => _CustomTextboxState2();
}

class _CustomTextboxState2 extends State<CustomTextbox2> {
  String? _validateInput(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  }

  bool obscureText = false; // Track password visibility


  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // double defaultFontSize = widget.fontSize ?? 14; // Assign 0 if fontSize parameter is not provided




    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = widget.borderColor ?? (brightness == Brightness.light ? ColorCode.lightborder : ColorCode.darkborder);
    borderColor = Colors.transparent;

    Color backgroundColor = widget.backgroundColor ?? ColorCode.textboxanddropdownbackcolor; // Use passed background color or default


    return Container(

      // height: 56,
      //   width: 398,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: borderColor,
          width: widget.borderWidth ?? 0.0,
        ),

        color: backgroundColor, // Set the background color
        // color: Color.fromRGBO(202, 118, 134, 0.08),
      ),
      child: Padding(
        padding:  EdgeInsets.all(DynamicSize.scale(context, 0)),
        child: Row(
          children: [
            if (widget.prefixIcon != null)
              GestureDetector(
                onTap: () {
                  if (widget.onPrefixPressed != null) {
                    widget.onPrefixPressed!();
                  }
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                child: widget.prefixIcon!,
              ),
            Expanded(
              child: Padding(
                padding:  EdgeInsets.only(left: DynamicSize.scale(context, 2)),
                child: TextField(
                  cursorColor: ColorCode.appcolorback, // Set the cursor color
                  controller: widget.controller,
                  style: TextStyle(color: ColorCode.appcolor,),
                  obscureText: obscureText,
                  textCapitalization: widget.useNumericKeyboard ? TextCapitalization.characters : widget.textCapitalization,
                  keyboardType: widget.useNumericKeyboard ? TextInputType.number : null, // Set numeric keyboard if needed
                  inputFormatters: widget.useNumericKeyboard ? [FilteringTextInputFormatter.digitsOnly] : null,
                  decoration: InputDecoration(
                    isDense: true, // Make the TextField dense to reduce height
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Remove top and bottom padding
                    hintStyle: TextStyle(color: ColorCode.appcolor,),
                    // hintStyle: TextStyle(color: ColorCode.appcolor, height: 16.94 / DynamicSize.scale(context, 12),),
                    hintText: widget.labelText,
                    border: InputBorder.none,
                    errorText: widget.errorMessage, // Set error message here
                  ),
                  onChanged: widget.onChanged,
                  enabled: widget.enabled,
                ),
              ),
            ),

            if (widget.suffixIcon != null)
              GestureDetector(
                onTap: () {
                  if (widget.onSuffixPressed != null) {
                    widget.onSuffixPressed!();
                  }
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                child: widget.suffixIcon!,
              ),
          ],
        ),
      ),
    );
  }
}
