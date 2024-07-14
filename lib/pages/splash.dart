import 'dart:developer';
import 'package:maring/provider/homeprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/pages/intro.dart';
import 'package:maring/provider/generalprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/widget/myimage.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  SharedPre sharedpre = SharedPre();

  @override
  void initState() {
    final splashdata = Provider.of<GeneralProvider>(context, listen: false);
    splashdata.getGeneralsetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ischeckFirstTime();
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: MyImage(
            width: MediaQuery.of(context).size.width,
            height: 300,
            imagePath: "ic_appicon.png"),
      ),
    );
  }

  Future ischeckFirstTime() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final splashdata = Provider.of<GeneralProvider>(context);
    Constant.userID = await sharedpre.read('userid');
    Constant.channelID = await sharedpre.read('channelid');
    Constant.channelName = await sharedpre.read('channelname');
    Constant.channelImage = await sharedpre.read('image');
    Utils.getCurrencySymbol();
    debugPrint("Userid===>${Constant.userID}");
    debugPrint("Channalid===>${Constant.channelID}");
    debugPrint("Channalid===>${Constant.channelName}");
    debugPrint("Channalid===>${Constant.channelImage}");
    if (!splashdata.loading) {
      for (var i = 0; i < splashdata.generalsettingModel.result!.length; i++) {
        sharedpre.save(
          splashdata.generalsettingModel.result?[i].key.toString() ?? "",
          splashdata.generalsettingModel.result?[i].value.toString() ?? "",
        );
      }
      String? seen = await sharedpre.read("seen") ?? "";
      log("seen:---$seen");
      /* Get Ads Init */
      if (context.mounted && !kIsWeb) {
        AdHelper.getAds(context);
      }

      if (seen == "1") {
        debugPrint("Boolian statement if Condition : $seen");
        debugPrint("UserID NotEmpty");
        await homeProvider.setLoading(true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        debugPrint("Boolian statement Else Condition : $seen");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Intro();
            },
          ),
        );
      }
    }
  }
}
