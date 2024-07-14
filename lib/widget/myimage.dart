import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyImage extends StatelessWidget {
  double height;
  double width;
  String imagePath;
  Color? color;
  // ignore: prefer_typing_uninitialized_variables
  var fit;
  // var alignment;

  MyImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.imagePath,
      this.color,
      this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/$imagePath",
      height: height,
      color: color,
      width: width,
      fit: fit,
      // errorBuilder: (context, url, error) {
      //   return Image.asset(
      //     "assets/images/no_image_port.png",
      //     width: width,
      //     height: height,
      //     fit: BoxFit.cover,
      //   );
      // },
    );
  }
}
