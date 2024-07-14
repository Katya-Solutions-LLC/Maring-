import 'package:maring/pages/login.dart';
import 'package:maring/pages/profile.dart';
import 'package:maring/pages/search.dart';
import 'package:maring/provider/homeprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String contentType;
  const CustomAppBar({super.key, required this.contentType});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  SharedPre sharedPre = SharedPre();
  String? userImage;
  @override
  void initState() {
    super.initState();
    getApi();
  }

  getApi() async {
    if (Constant.userID != null) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.getprofile(Constant.userID);
      userImage = await sharedPre.read("image");
      debugPrint("_getData userProfile ===> $userImage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyImage(width: 55, height: 55, imagePath: "ic_appicon.png"),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Search(
                                  contentType: widget.contentType,
                                );
                              },
                            ),
                          );
                        });
                      },
                      child: MyImage(
                          width: 20, height: 20, imagePath: "ic_search.png")),
                  const SizedBox(width: 15),
                  InkWell(
                      onTap: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Login();
                                },
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Profile(
                                    isProfile: true,
                                    channelUserid: "",
                                    channelid: "",
                                  );
                                },
                              ),
                            );
                          }
                        });
                      },
                      child: Constant.userID == null
                          ? MyImage(
                              width: 30, height: 30, imagePath: "ic_user.png")
                          : Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  border: Border.all(color: white, width: 1),
                                  shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                    imagePath: userImage ?? ""),
                              ),
                            )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
