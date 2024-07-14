import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maring/widget/myimage.dart';

// ignore: must_be_immutable
class MyNetworkImage extends StatelessWidget {
  String imagePath;
  double? height, width;
  dynamic fit;
  bool? islandscap, isPagesIcon;
  Color? color;

  MyNetworkImage(
      {Key? key,
      required this.imagePath,
      required this.fit,
      this.islandscap,
      this.isPagesIcon,
      this.height,
      this.color,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: imageProvider,
                fit: fit,
                invertColors: isPagesIcon == true ? true : false),
          ),
        ),
        placeholder: (context, url) {
          return MyImage(
            width: width ?? 0,
            height: height ?? 0,
            imagePath: islandscap == false || islandscap == null
                ? "no_image_port.png"
                : "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
        errorWidget: (context, url, error) {
          return MyImage(
            width: width ?? 0,
            height: height ?? 0,
            imagePath: islandscap == false || islandscap == null
                ? "no_image_port.png"
                : "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
