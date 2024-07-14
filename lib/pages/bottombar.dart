import 'dart:developer';
import 'package:maring/pages/login.dart';
import 'package:maring/pages/videorecord/videorecord.dart';
import 'package:maring/provider/generalprovider.dart';
import 'package:maring/provider/profileprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maring/pages/home.dart';
import 'package:maring/pages/setting.dart';
import 'package:maring/pages/short.dart';
import 'package:maring/pages/music.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/widget/myimage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
const double playerMinHeight = 70;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  int selectedIndex = 0;
  SharedPre sharedPre = SharedPre();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    Constant.isBuy = await sharedPre.read("userIsBuy");
    pushNotification();
    if (!mounted) return;
    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      Constant.userPanelStatus = await sharedPre.save(
          "userpanelstatus",
          profileProvider.profileModel.result?[0].userPenalStatus.toString() ??
              "");
    } else {
      Utils.updatePremium("0");
      Utils.loadAds(context);
    }
    if (!mounted) return;
    await generalsetting.getGeneralsetting();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  pushNotification() async {
    Constant.oneSignalAppId = await sharedPre.read(Constant.oneSignalAppIdKey);
    log("isBUY User===>${Constant.isBuy}");
    debugPrint("OneSignal===>${Constant.oneSignalAppId}");
    /*  Push Notification Method OneSignal Start */
    if (!kIsWeb) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      debugPrint("OneSignal PushNotification===> ${Constant.oneSignalAppId}");
      OneSignal.initialize(Constant.oneSignalAppId ?? "");
      OneSignal.Notifications.requestPermission(false);
      OneSignal.Notifications.addPermissionObserver((state) {
        debugPrint("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        /// preventDefault to not display the notification
        event.preventDefault();
        // Do async work
        /// notification.display() to display after preventing default
        event.notification.display();
      });
    }
/*  Push Notification Method OneSignal End */
  }

  static List<Widget> widgetOptions = <Widget>[
    const Home(),
    const Short(),
    const VideoRecord(
      contestId: '',
      contestImg: '',
      hashtagId: '',
      hashtagName: '',
    ),
    const Music(),
    const Setting(),
  ];

  void _onItemTapped(int index) {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      switch (index) {
        case 0:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 1:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 2:
          if (Constant.userID != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const VideoRecord(
                    contestId: '',
                    contestImg: '',
                    hashtagId: '',
                    hashtagName: '',
                  );
                },
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          }
          break;

        case 3:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 4:
          setState(() {
            selectedIndex = index;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Stack(
        children: [
          Center(
            child: widgetOptions.elementAt(selectedIndex),
          ),
          selectedIndex == 1 || selectedIndex == 2
              ? const SizedBox.shrink()
              : Utils.buildMusicPanel(context),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Utils.showBannerAd(context),
          BottomNavigationBar(
            backgroundColor: colorPrimaryDark,
            selectedFontSize: Dimens.textbottomNav,
            unselectedFontSize: Dimens.textbottomNav,
            selectedIconTheme: const IconThemeData(color: colorAccent),
            unselectedIconTheme: const IconThemeData(color: gray),
            elevation: 5,
            unselectedLabelStyle:
                GoogleFonts.inter(fontSize: Dimens.textbottomNav, color: gray),
            currentIndex: selectedIndex,
            unselectedItemColor: gray,
            selectedItemColor: white,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                backgroundColor: colorPrimary,
                label: "Home",
                activeIcon: RadiantGradientMask(
                  child: MyImage(
                    imagePath: "ic_home.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                  ),
                ),
                icon: Align(
                  alignment: Alignment.center,
                  child: MyImage(
                    imagePath: "ic_home.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: gray,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: "Shorts",
                backgroundColor: colorPrimary,
                activeIcon: RadiantGradientMask(
                  child: MyImage(
                    imagePath: "ic_short.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                  ),
                ),
                icon: Align(
                  alignment: Alignment.center,
                  child: MyImage(
                    imagePath: "ic_short.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: gray,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                backgroundColor: colorPrimary,
                activeIcon: Container(
                  padding: const EdgeInsets.all(0),
                  child: MyImage(
                    imagePath: "ic_post.png",
                    width: Dimens.centerIconbottomNav,
                    height: Dimens.centerIconbottomNav,
                  ),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(0),
                  child: MyImage(
                    width: Dimens.centerIconbottomNav,
                    height: Dimens.centerIconbottomNav,
                    imagePath: "ic_post.png",
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: colorPrimary,
                label: "Music",
                activeIcon: RadiantGradientMask(
                  child: MyImage(
                    imagePath: "ic_music.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                  ),
                ),
                icon: Align(
                  alignment: Alignment.center,
                  child: MyImage(
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: gray,
                    imagePath: "ic_music.png",
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: colorPrimary,
                label: "Setting",
                activeIcon: RadiantGradientMask(
                  child: MyImage(
                    imagePath: "ic_setting.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                  ),
                ),
                icon: Align(
                  alignment: Alignment.center,
                  child: MyImage(
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: gray,
                    imagePath: "ic_setting.png",
                  ),
                ),
              ),
            ],
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}

class RadiantGradientMask extends StatelessWidget {
  final Widget? child;
  const RadiantGradientMask({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [lightpink, lightgray],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}
