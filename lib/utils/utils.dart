// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/pages/musicdetails.dart';
import 'package:maring/players/player_video.dart';
import 'package:maring/players/player_vimeo.dart';
import 'package:maring/players/player_youtube.dart';
import 'package:maring/provider/profileprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/dimens.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as number;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class Utils {
  static ProgressDialog? prDialog;

  static TextStyle googleFontStyle(int inter, double fontsize,
      FontStyle fontstyle, Color color, FontWeight fontwaight) {
    if (inter == 1) {
      return GoogleFonts.poppins(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.lobster(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 4) {
      return GoogleFonts.roboto(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }

  // Widget Page Loader
  static Widget pageLoader(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorAccent,
      ),
    );
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        webShowClose: true,
        backgroundColor: white,
        textColor: black,
        fontSize: 14);
  }

  static BoxDecoration setGradTTBBGWithBorder(Color colorStart, Color colorEnd,
      Color borderColor, double radius, double border) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  // Global SnakBar
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorAccent,
        content: MyText(
          text: message,
          multilanguage: true,
          fontsize: 14,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
          fontwaight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  // Global Progress Dilog
  static void showProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

    prDialog!.style(
      message: "Please Wait",
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog!.show();
  }

  void hideProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    if (prDialog!.isShowing()) {
      prDialog!.hide();
    }
  }

  otherPageAppBar(BuildContext context, String title, bool multilanguage) {
    return AppBar(
      backgroundColor: colorPrimary,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: colorPrimary,
      ),
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context).pop(false);
          debugPrint("Back Click");
        },
        child: Align(
            alignment: Alignment.center,
            child:
                MyImage(width: 30, height: 30, imagePath: "ic_roundback.png")),
      ),
      title: MyText(
          color: white,
          multilanguage: multilanguage,
          text: title,
          textalign: TextAlign.center,
          fontsize: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal),
    );
  }

  divider(BuildContext context, EdgeInsets padding) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      padding: padding,
      color: gray,
    );
  }

  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(path.join(documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png'));
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      debugPrint("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("fullname");
      await sharedPref.remove("email");
      await sharedPref.remove("mobilenumber");
      await sharedPref.remove("image");
      await sharedPref.remove("coverimage");
      await sharedPref.remove("type");
      await sharedPref.remove("desciption");
      await sharedPref.remove("channelid");
      await sharedPref.remove("channelname");
      await sharedPref.remove("userIsBuy");
    }
    Constant.userID = await sharedPref.read("userid");
    debugPrint('setUserId userID ==> ${Constant.userID}');
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != null) {
      return true;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const Login();
        },
      ),
    );
    return false;
  }

  // KMB Text Generator Method
  static String kmbGenerator(int num) {
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(0)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1)} B";
    } else {
      return num.toString();
    }
  }

  static String timeAgoCustom(DateTime d) {
    // <-- Custom method Time Show  (Display Example  ==> 'Today 7:00 PM')     // WhatsApp Time Show Status Shimila
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return DateFormat.E().add_jm().format(d);
    }
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static String formatTime(double time) {
    Duration duration = Duration(milliseconds: time.round());
    duration.inHours;
    if (duration.inHours == 00) {
      return [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    } else {
      return [duration.inHours, duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    }
  }

  convertMillisecondsToSeconds(double milliseconds) {
    return milliseconds / 1000;
  }

  static openPlayer({
    required BuildContext context,
    required String videoId,
    required String videoUrl,
    required String vUploadType,
    required String videoThumb,
    required String stoptime,
    required bool iscontinueWatching,
  }) {
    if (kIsWeb) {
      /* Normal, Vimeo & Youtube Player */
      if (!context.mounted) return;
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      }
    } else {
      /* Better, Youtube & Vimeo Players */
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      } else if (vUploadType == "vimeo") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVimeo(videoId, videoUrl, vUploadType, videoThumb);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      }
    }
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: MyImage(
        height: 17,
        width: 17,
        imagePath: "ic_roundback.png",
        color: white,
      ),
    );
  }

  static Widget buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return MusicDetails(
            ishomepage: false,
            contentid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.album)
                    .toString(),
            episodeid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.id)
                    .toString(),
            stoptime: audioPlayer.position.toString(),
            contenttype:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre)
                    .toString(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static void getCurrencySymbol() async {
    SharedPre sharedPref = SharedPre();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    debugPrint('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    debugPrint('Constant currency ==> ${Constant.currency}');
  }

  static Widget buildGradLine() {
    return Container(
      height: 0.5,
      decoration: Utils.setGradTTBBGWithBorder(
          colorPrimaryDark.withOpacity(0.4),
          colorAccent.withOpacity(0.4),
          transparent,
          0,
          0),
    );
  }

  static double getPercentage(int totalValue, int usedValue) {
    double percentage = 0.0;
    try {
      if (totalValue != 0) {
        percentage = ((usedValue / totalValue).clamp(0.0, 1.0) * 100);
      } else {
        percentage = 0.0;
      }
    } catch (e) {
      debugPrint("getPercentage Exception ==> $e");
      percentage = 0.0;
    }
    percentage = (percentage.round() / 100);
    return percentage;
  }

  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    debugPrint("fixFourDigit =>>> ${Constant.fixFourDigit}");
    debugPrint("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    debugPrint("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    debugPrint("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    debugPrint("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    debugPrint("finalOID =>>> $finalOID");

    return finalOID;
  }

  static AppBar myAppBarWithBack(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: colorPrimaryDark,
      centerTitle: true,
      leading: IconButton(
        autofocus: true,
        focusColor: white.withOpacity(0.5),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: MyImage(
          imagePath: "back.png",
          fit: BoxFit.contain,
          height: 17,
          width: 17,
          color: white,
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsize: Dimens.textBig,
        fontstyle: FontStyle.normal,
        fontwaight: FontWeight.bold,
        textalign: TextAlign.center,
        color: colorPrimary,
      ),
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Future<void> shareApp(shareMessage) async {
    try {
      await FlutterShare.share(
        title: Constant.appName,
        linkUrl: shareMessage,
      );
    } catch (e) {
      debugPrint("shareFile Exception ===> $e");
      return;
    }
  }

  static Future<File?> saveAudioInStorage(audioUrl, audioTitle) async {
    try {
      var response = await http.get(Uri.parse(audioUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(join(documentDirectory?.path ?? "",
          '${audioTitle.toString().replaceAll(" ", "").toLowerCase()}.aac'));
      file.writeAsBytesSync(response.bodyBytes);
      debugPrint("saveAudioInStorage file ===> ${file.path}");
      Fluttertoast.showToast(
        msg: "Download Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: white,
        textColor: black,
        fontSize: 14,
      );
      return file;
    } catch (e) {
      debugPrint("saveAudioInStorage Exception ===> $e");
      return null;
    }
  }

  Future<void> showAlertSimple(
      BuildContext context, String msg, String positive) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(15),
          content: MyText(
            multilanguage: true,
            color: black,
            text: msg,
            fontsize: 16,
            fontwaight: FontWeight.w500,
            maxline: 5,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                foregroundColor: white,
                backgroundColor: colorPrimary, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: positive,
                fontsize: 15,
                fontwaight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () {
                debugPrint("Clicked on positive!");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        color: colorPrimaryDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: white,
                    text: "updateprofile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsize: Dimens.textTitle,
                    fontwaight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: white,
                    text: "editpersonaldetail",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsize: Dimens.textSmall,
                    fontwaight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                controller: nameController,
                hintText: "full_name",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider =
                          Provider.of<ProfileProvider>(context, listen: false);
                      if (!profileEditProvider.loadingUpdate) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: white,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: white,
                        text: "cancel",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsize: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      if (profileEditProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(context),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          SharedPre sharedPref = SharedPre();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          debugPrint(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          debugPrint(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          debugPrint(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showSnackbar(context, "enter_fullname");
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils.showSnackbar(context, "enter_email");
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showSnackbar(context, "enter_mobile_number");
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showSnackbar(
                              context,
                              "enter_valid_email",
                            );
                          } else {
                            final profileEditProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                                fullName, emailAddress, mobileNumber);
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (profileEditProvider.successModel.status ==
                                  200) {
                                if (isNameReq) {
                                  await sharedPref.save('username', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPref.save(
                                      'useremail', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPref.save(
                                      'usermobile', mobileNumber);
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: white,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textTitle,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          isDense: false,
          fillColor: transparent,
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: colorAccent)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: colorAccent)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: colorAccent)),
          disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: colorAccent)),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: colorAccent)),
          label: MyText(
            multilanguage: true,
            color: white,
            text: hintText,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            fontsize: Dimens.textMedium,
            fontwaight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  static Widget miniPlayerSpace() {
    return Container(
      height: 60,
    );
  }

  static void updatePremium(String isPremiumBuy) async {
    debugPrint('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPre sharedPre = SharedPre();
    await sharedPre.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPre.read("userpremium");
    debugPrint('updatePremium ===============> $isPremium');
  }

  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    bool? isPremiumBuy = await Utils.checkPremiumUser();
    debugPrint("loadAds isPremiumBuy :==> $isPremiumBuy");
    if (context.mounted) {
      AdHelper.getAds(context);
    }
    if (!kIsWeb && !isPremiumBuy) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  static Future<bool> checkPremiumUser() async {
    SharedPre sharedPre = SharedPre();
    String? isPremiumBuy = await sharedPre.read("userIsBuy");
    debugPrint('checkPremiumUser isPremiumBuy ==> $isPremiumBuy');
    if (isPremiumBuy != null && isPremiumBuy == "1") {
      return true;
    } else {
      return false;
    }
  }
}
