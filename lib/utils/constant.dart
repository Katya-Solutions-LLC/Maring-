class Constant {
  final String baseurl = "https://adminmarina.ru";
  static String appName = "Maring ® 🤳";
  static String appPackageName = "com.marina.sharing";
  static String appleAppId = "";
  /* OneSignal App ID keyId*/
  static String? oneSignalAppId;
  static const String oneSignalAppIdKey = "onesignal_apid";
  static bool isTV = false;
  /* Share */
  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";
  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=$appPackageName";
  static String iosAppUrl = "https://apps.apple.com/us/app/id$appleAppId";

// Intro Screen Image
  List introImage = [
    "ic_intro1.png",
    "ic_intro2.png",
    "ic_intro3.png",
  ];

// Intro Screen Text
  List introText = [
    "Watch interesting videos from around the world! 🐱‍💻",
    "Watch interesting videos easily from your device .. 🤞",
    "Let's explore videos around the world with Maring ® 🤳 Now!",
  ];

// TabList Music Page
  static List tabList = [
    "home",
    "music",
    "radio",
    "podcast",
  ];

  static String musicType = "1";
  static String podcastType = "2";
  static String radioType = "3";

// Profile Tab List
  static List profileTabList = [
    "video",
    "podcast",
    "playlist",
    "short",
    "rent"
  ];

  // Profile Tab List
  static List historyTabList = [
    "video",
    "music",
    "podcast",
  ];

  // Profile Tab List
  static List selectContentTabList = [
    "video",
    "music",
    "podcast",
    "radio",
  ];

  static List watchlaterTabList = [
    "video",
    "Music",
    "Short",
    "Podcast",
    "Radio",
  ];
  static String? selectedAudioPath = "";
  static int recordDuration = 30;
  static int maxRecordDuration = 30;
  static int minRecordDuration = 5;

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static String? userID;
  static String? channelID;
  static String? isBuy;
  static String? userPanelStatus;
  static String? channelName;
  static String? channelImage;
  static String currencySymbol = "";
  static String currency = "";

  static String fullname = "FullName";
  static String channelname = "Channel Name";
  static String email = "Email";
  static String password = "Password";

// HomePage
  static String search = "Search";

// update Profile
  static String bio = "Bio";
  static String mobile = "Mobile";

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";
}
