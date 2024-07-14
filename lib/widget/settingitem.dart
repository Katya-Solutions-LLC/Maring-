import 'package:flutter/widgets.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';

// ignore: must_be_immutable
class SettingItem extends StatelessWidget {
  String iconpath, text;
  SettingItem({super.key, required this.iconpath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Row(
        children: [
          MyImage(width: 20, height: 20, imagePath: iconpath),
          const SizedBox(width: 20),
          MyText(
              color: white,
              text: text,
              inter: true,
              fontsize: 14,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              fontwaight: FontWeight.w500,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }
}
