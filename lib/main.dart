import 'dart:developer';

import 'package:maring/pages/musicdetails.dart';
import 'package:maring/provider/allcontentprovider.dart';
import 'package:maring/provider/contentdetailprovider.dart';
import 'package:maring/provider/galleryvideoprovider.dart';
import 'package:maring/provider/getmusicbycategoryprovider.dart';
import 'package:maring/provider/getmusicbylanguageprovider.dart';
import 'package:maring/provider/historyprovider.dart';
import 'package:maring/provider/likevideosprovider.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/provider/notificationprovider.dart';
import 'package:maring/provider/playerprovider.dart';
import 'package:maring/provider/playlistcontentprovider.dart';
import 'package:maring/provider/playlistprovider.dart';
import 'package:maring/provider/postvideoprovider.dart';
import 'package:maring/provider/rentprovider.dart';
import 'package:maring/provider/seeallprovider.dart';
import 'package:maring/provider/settingprovider.dart';
import 'package:maring/provider/subscriptionprovider.dart';
import 'package:maring/provider/videopreviewprovider.dart';
import 'package:maring/provider/videorecordprovider.dart';
import 'package:maring/provider/videoscreenprovider.dart';
import 'package:maring/provider/watchlaterprovider.dart';
import 'package:maring/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:maring/firebase_options.dart';
import 'package:maring/pages/splash.dart';
import 'package:maring/provider/detailsprovider.dart';
import 'package:maring/provider/generalprovider.dart';
import 'package:maring/provider/homeprovider.dart';
import 'package:maring/provider/searchprovider.dart';
import 'package:maring/provider/profileprovider.dart';
import 'package:maring/provider/musicprovider.dart';
import 'package:maring/provider/updateprofileprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'provider/shortprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Just Audio Player Background Service Set
  if (Constant.isBuy != null ||
      Constant.isBuy != "0" ||
      Constant.userID != null ||
      Constant.isBuy == "1") {
    await JustAudioBackground.init(
      androidNotificationChannelId: Constant.appPackageName,
      androidNotificationChannelName: Constant.appName,
      androidNotificationOngoing: true,
    );
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Locales.init([
    'en',
    'hi',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => ShortProvider()),
        ChangeNotifierProvider(create: (_) => VideoScreenProvider()),
        ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => WatchLaterProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => LikeVideosProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ContentDetailProvider()),
        ChangeNotifierProvider(create: (_) => SeeAllProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByLanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => RentProvider()),
        ChangeNotifierProvider(create: (_) => AllContentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistContentProvider()),
        ChangeNotifierProvider(create: (_) => VideoRecordProvider()),
        ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
        ChangeNotifierProvider(create: (_) => PostVideoProvider()),
        ChangeNotifierProvider(create: (_) => GalleryVideoProvider()),
      ],
      child: const MyApp(),
    ));
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: colorPrimary,
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        log("App detached");
        audioPlayer.stop();
        audioPlayer.dispose();
        break;
      case AppLifecycleState.inactive:
        if (Constant.isBuy == null ||
            Constant.isBuy == "0" ||
            Constant.userID == null) {
          log("App inactive");
          audioPlayer.pause();
        }
        break;
      case AppLifecycleState.paused:
        if (Constant.isBuy == null ||
            Constant.isBuy == "0" ||
            Constant.userID == null) {
          log("App paused");
          audioPlayer.pause();
        }
        break;
      case AppLifecycleState.resumed:
        log("App resumed");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: colorPrimary,
          primaryColorDark: colorPrimaryDark,
          primaryColorLight: colorPrimary,
          scaffoldBackgroundColor: colorPrimaryDark,
        ),
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        home: const Splash(),
      ),
    );
  }
}
