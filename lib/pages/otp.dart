import 'dart:developer';
import 'dart:io';
import 'package:maring/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';

class Otp extends StatefulWidget {
  final String number;
  const Otp({
    super.key,
    required this.number,
  });

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPre = SharedPre();
  final pinPutController = TextEditingController();
  String? strDeviceType, strDeviceToken;
  bool codeResended = false;
  int? forceResendingToken;
  String? verificationId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeSend(false);
    });
    _getDeviceToken();
    super.initState();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = OneSignal.User.pushSubscription.id.toString();
      }
    } catch (e) {
      debugPrint("_getDeviceToken Exception ===> $e");
    }
    debugPrint("===>strDeviceToken $strDeviceToken");
    debugPrint("===>strDeviceType $strDeviceType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    alignment: Alignment.bottomCenter,
                    child: MyImage(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.height * 0.25,
                        imagePath: "ic_appicon.png"),
                  ),
                  Positioned.fill(
                    top: 35,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "ic_roundback.png"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
                        text: "pleaseenteryourotp",
                        textalign: TextAlign.center,
                        fontsize: Dimens.textBig,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 10),
                    MyText(
                        color: white,
                        text: "we have sent an otp to your number",
                        textalign: TextAlign.center,
                        multilanguage: true,
                        fontsize: Dimens.textDesc,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 10),
                    MyText(
                        color: colorAccent,
                        text: widget.number.toString(),
                        textalign: TextAlign.center,
                        fontsize: 14,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 55,
                      child: Pinput(
                        length: 6,
                        keyboardType: TextInputType.number,
                        controller: pinPutController,
                        textInputAction: TextInputAction.done,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        defaultPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(color: colorAccent, width: 0.5),
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: GoogleFonts.roboto(
                            color: white,
                            fontSize: Dimens.textBig,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        codeSend(true);
                      },
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 70),
                        padding: const EdgeInsets.all(5),
                        child: MyText(
                          color: white,
                          text: "resend",
                          multilanguage: true,
                          fontsize: Dimens.textTitle,
                          fontwaight: FontWeight.w700,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    InkWell(
                      onTap: () {
                        if (pinPutController.text.toString().isEmpty) {
                          Utils.showSnackbar(context, "pleaseenterotp");
                        } else {
                          if (verificationId == null || verificationId == "") {
                            Utils.showSnackbar(context, "otp_not_working");
                            return;
                          }
                          Utils.showProgress(context);
                          _checkOTPAndLogin();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.06,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MyText(
                            color: white,
                            text: "login",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsize: 16,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  codeSend(bool isResend) async {
    Utils.showProgress(context);
    log("================>>Code send Successfully<<<============");
    await phoneSignIn(phoneNumber: widget.number);
    if (!mounted) return;
    Utils().hideProgress(context);
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    log("================>>Verify Your Mobile Number <<<============");
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    log("verification completed ======> ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    log("user phoneNumber =====> ${user?.phoneNumber}");
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      log("The phone number entered is invalid!");
      Utils.showSnackbar(context, "invalidphonenumberotp");
      Utils().hideProgress(context);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    log("verificationId =======> $verificationId");
    log("resendingToken =======> ${forceResendingToken.toString()}");
    log("code sent");
    Utils.showSnackbar(context, "coderesendsuccessfully");
    Utils().hideProgress(context);
    _checkOTPAndLogin();
  }

  _onCodeTimeout(String verificationId) {
    log("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    Utils().hideProgress(context);
    return null;
  }

  _checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    debugPrint("_checkOTPAndLogin verificationId =====> $verificationId");
    debugPrint("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    debugPrint(
        "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}");
    debugPrint(
        "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
    try {
      userCredential = await auth.signInWithCredential(phoneAuthCredential);
      debugPrint(
          "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
    } on FirebaseAuthException catch (e) {
      Utils().hideProgress(context);
      log("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpinvalid");
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpsessionexpired");
        return;
      } else {
        error = true;
      }
    }
    debugPrint(
        "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
    if (!error && userCredential != null) {
      _login(
          widget.number.toString(), userCredential.user?.uid.toString() ?? "");
    } else {
      if (!mounted) return;
      Utils().hideProgress(context);
    }
  }

  _login(String mobile, String firebaseId) async {
    debugPrint("click on Submit mobile =====> $mobile");
    debugPrint("click on Submit firebaseId => $firebaseId");
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    Utils.showProgress(context);
    await generalProvider.login(
        "1", "", mobile, strDeviceType ?? "", strDeviceToken ?? "");
    debugPrint('test');
    if (!generalProvider.loading) {
      if (!mounted) return;
      log('Loading');
      Utils().hideProgress(context);
      debugPrint('test');
      if (generalProvider.loginModel.status == 200) {
        debugPrint(
            'loginRegisterModel ==>> ${generalProvider.loginModel.toString()}');
        debugPrint('Login Successfull!');
        /* Save Users Credentials */
        await sharedPre.save(
            "userid", generalProvider.loginModel.result?[0].id.toString());
        await sharedPre.save("channelid",
            generalProvider.loginModel.result?[0].channelId.toString());
        await sharedPre.save("channelname",
            generalProvider.loginModel.result?[0].channelName.toString());
        await sharedPre.save("fullname",
            generalProvider.loginModel.result?[0].fullName.toString());
        await sharedPre.save(
            "email", generalProvider.loginModel.result?[0].email.toString());
        await sharedPre.save("mobilenumber",
            generalProvider.loginModel.result?[0].mobileNumber.toString());
        await sharedPre.save(
            "image", generalProvider.loginModel.result?[0].image.toString());
        await sharedPre.save("coverimage",
            generalProvider.loginModel.result?[0].coverImg.toString());
        await sharedPre.save(
            "type", generalProvider.loginModel.result?[0].type.toString());
        await sharedPre.save("desciption",
            generalProvider.loginModel.result?[0].description.toString());
        await sharedPre.save("devicetype",
            generalProvider.loginModel.result?[0].deviceType.toString());
        await sharedPre.save("address",
            generalProvider.loginModel.result?[0].address.toString());
        await sharedPre.save("website",
            generalProvider.loginModel.result?[0].website.toString());
        await sharedPre.save("instagramUrl",
            generalProvider.loginModel.result?[0].instagramUrl.toString());
        await sharedPre.save("facebookUrl",
            generalProvider.loginModel.result?[0].facebookUrl.toString());
        await sharedPre.save("twitterUrl",
            generalProvider.loginModel.result?[0].twitterUrl.toString());
        await sharedPre.save("devicetoken",
            generalProvider.loginModel.result?[0].deviceToken.toString());
        await sharedPre.save(
            "status", generalProvider.loginModel.result?[0].status.toString());
        await sharedPre.save("createat",
            generalProvider.loginModel.result?[0].createdAt.toString());
        await sharedPre.save("updateat",
            generalProvider.loginModel.result?[0].updatedAt.toString());
        await sharedPre.save("userIsBuy",
            generalProvider.loginModel.result?[0].isBuy.toString());
        // Set UserID With Chennal ID for Next
        Constant.userID = generalProvider.loginModel.result?[0].id.toString();
        Constant.isBuy = generalProvider.loginModel.result?[0].isBuy.toString();
        Utils.updatePremium(
            generalProvider.loginModel.result?[0].isBuy.toString() ?? "");
        Constant.channelID =
            generalProvider.loginModel.result?[0].channelId.toString() ?? "";

        debugPrint('Constant userID ==>> ${Constant.userID}');
        debugPrint('Constant ChannelId ==>> ${Constant.channelID}');

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        log('error');
        Utils().hideProgress(context);
        Utils.showSnackbar(context, "Error");
      }
    }
  }
}
