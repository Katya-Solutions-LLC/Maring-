// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:maring/widget/mytext.dart';

// ignore: must_be_immutable
class MyBtn extends StatelessWidget {
  double? width, height, fontsize;
  var textcolor, text, btncolor;

  MyBtn({
    super.key,
    this.width,
    this.height,
    this.text,
    this.textcolor,
    this.btncolor,
    this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: btncolor,
      ),
      alignment: Alignment.center,
      child: MyText(
          color: textcolor,
          text: text,
          fontsize: fontsize,
          fontwaight: FontWeight.w600,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal),
    );
  }
}
