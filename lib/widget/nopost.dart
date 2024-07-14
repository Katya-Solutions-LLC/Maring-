import 'package:maring/utils/color.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:flutter/material.dart';

class NoPost extends StatelessWidget {
  final String? title, subTitle;
  const NoPost({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      decoration: BoxDecoration(
        color: transparent,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5, minWidth: 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyImage(
              height: 130,
              fit: BoxFit.contain,
              imagePath: "ic_no_post.png",
              width: 130,
            ),
            const SizedBox(height: 20),
            (title ?? "") != ""
                ? MyText(
                    color: white,
                    text: title ?? "",
                    fontsize: 16,
                    maxline: 2,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            (subTitle ?? "") != ""
                ? MyText(
                    color: white,
                    text: subTitle ?? "",
                    fontsize: 14,
                    maxline: 5,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
