import 'package:flutter/material.dart';

import 'DynamicSize.dart';

class AnimatedSnackBar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;

  const AnimatedSnackBar({
    Key? key,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _AnimatedSnackBarState createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),  // Start from left
      end: Offset(0.0, 0.0)  // End at its natural position
    ).animate(CurvedAnimation(
      parent: _controller,
      // curve: Curves.elasticOut,
      curve: Curves.slowMiddle,
      // curve: Curves.easeOutQuint,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      Future.delayed(widget.duration, () {
        _controller.reverse().then((value) {
          if (mounted) {
            setState(() {
              // Hide the snackbar after the animation completes
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // top: DynamicSize.scale(context, 50), // Adjust the position from the bottom
      bottom: DynamicSize.scale(context, 50), // Adjust the position from the bottom
      left: DynamicSize.scale(context, 50),
      right: DynamicSize.scale(context, 50),
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
         // height: DynamicSize.scale(context, 50),
          // margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(horizontal: DynamicSize.scale(context, 16), vertical: DynamicSize.scale(context, 8)),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DynamicSize.scale(context, 10),
                    decoration: TextDecoration.none, // Disable underline
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String message, Color color, int durationInMillis) {
  final overlay = Overlay.of(context);
  if (overlay != null) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => AnimatedSnackBar(
        message: message,
        icon: Icons.shopping_cart,
        backgroundColor: color,
        duration: Duration(milliseconds: durationInMillis),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: durationInMillis), () {
      overlayEntry.remove();
    });
  }
}

void showCustomSnackBarusericon(BuildContext context, String message, Color color, int durationInMillis) {
  final overlay = Overlay.of(context);
  if (overlay != null) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => AnimatedSnackBar(
        message: message,
        icon: Icons.login,
        backgroundColor: color,
        duration: Duration(milliseconds: durationInMillis),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(milliseconds: durationInMillis), () {
      overlayEntry.remove();
    });
  }
}
