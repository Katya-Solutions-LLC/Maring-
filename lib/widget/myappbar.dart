import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maring/pages/notificationpage.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/widget/myimage.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorPrimaryDark,
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: colorPrimaryDark,
      ),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          MyImage(
              width: MediaQuery.of(context).size.width * 0.20,
              height: MediaQuery.of(context).size.width * 0.20,
              imagePath: "ic_appicon.png"),
          const Spacer(),
          InkWell(
              onTap: () {},
              child:
                  MyImage(width: 30, height: 30, imagePath: "ic_mobile.png")),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const NotificationPage();
                    },
                  ),
                );
              },
              child: MyImage(
                  width: 25, height: 25, imagePath: "ic_notification.png")),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          InkWell(
              onTap: () {},
              child:
                  MyImage(width: 20, height: 20, imagePath: "ic_search.png")),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                border: Border.all(color: white, width: 1),
                shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: MyImage(width: 30, height: 30, imagePath: "ic_test.png"),
            ),
          ),
        ],
      ),
    );
  }
}
