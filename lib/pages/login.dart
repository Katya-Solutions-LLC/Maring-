// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:maring/pages/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/provider/generalprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final numberController = TextEditingController();
  String mobilenumber = "", countrycode = "";
  File? mProfileImg;
  bool isagreeCondition = false;
  String? strDeviceType, strDeviceToken;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: colorPrimary,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                        color: white,
                        text: "hello",
                        textalign: TextAlign.center,
                        fontsize: 20,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    MyText(
                        color: white,
                        text: "loginyouraccount",
                        textalign: TextAlign.center,
                        fontsize: 16,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    /* Send OTP Continue Button Text  */
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: IntlPhoneField(
                        disableLengthCheck: true,
                        textAlignVertical: TextAlignVertical.center,
                        autovalidateMode: AutovalidateMode.disabled,
                        controller: numberController,
                        style: Utils.googleFontStyle(
                            4, 16, FontStyle.normal, white, FontWeight.w500),
                        showCountryFlag: false,
                        showDropdownIcon: false,
                        initialCountryCode: "IN",
                        dropdownTextStyle: Utils.googleFontStyle(
                            4, 16, FontStyle.normal, white, FontWeight.w500),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorPrimaryDark,
                          border: InputBorder.none,
                          hintStyle: Utils.googleFontStyle(
                              4, 14, FontStyle.normal, white, FontWeight.w500),
                          hintText: "Mobile Number",
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: white, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: white, width: 1),
                          ),
                        ),
                        onChanged: (phone) {
                          mobilenumber = phone.completeNumber;
                          log('mobile number===>mobileNumber $mobilenumber');
                        },
                        onCountryChanged: (country) {
                          countrycode = "+${country.dialCode.toString()}";
                          log('countrycode===> $countrycode');
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    /* Send OTP Continue Button Text  */
                    InkWell(
                      onTap: () {
                        if (numberController.text.toString().isEmpty) {
                          Utils.showSnackbar(
                              context, "pleaseenteryourmobilenumber");
                        } else if (isagreeCondition != true) {
                          Utils.showSnackbar(
                              context, "pleaseaccepttermsandcondition");
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Otp(number: mobilenumber),
                            ),
                          );
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
                            text: "continue",
                            textalign: TextAlign.center,
                            fontsize: 16,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    /* Accept Terms & Consition */
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: white,
                          ),
                          child: Checkbox(
                            value: isagreeCondition,
                            activeColor: colorAccent,
                            checkColor: white,
                            onChanged: (bool? isagreeCondition) {
                              setState(() {
                                this.isagreeCondition = isagreeCondition!;
                              });
                              log("value== $isagreeCondition");
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MyText(
                                    color: white,
                                    text: "termconditionfirst",
                                    textalign: TextAlign.center,
                                    fontsize: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                MyText(
                                    color: colorAccent,
                                    text: "terms",
                                    textalign: TextAlign.center,
                                    fontsize: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                MyText(
                                    color: colorAccent,
                                    text: "condition",
                                    textalign: TextAlign.center,
                                    fontsize: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            MyText(
                                color: colorAccent,
                                text: "privacy_policy",
                                textalign: TextAlign.left,
                                fontsize: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    /* OR Text  */
                    Align(
                      alignment: Alignment.center,
                      child: MyText(
                          color: white,
                          text: "or",
                          textalign: TextAlign.center,
                          fontsize: 16,
                          inter: false,
                          multilanguage: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* Google Signin Button */
                        InkWell(
                          onTap: () {
                            if (isagreeCondition == true) {
                              gmailLogin();
                              log("Gmail login ======>>>>>");
                            } else {
                              Utils.showSnackbar(
                                  context, "pleaseaccepttermsandcondition");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: black),
                            child: MyImage(
                                width: 27,
                                height: 27,
                                imagePath: "ic_google.png"),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05),
                        /* Apple Signin Button */
                        Platform.isIOS
                            ? InkWell(
                                onTap: () {
                                  if (isagreeCondition == true) {
                                    signInWithApple();
                                  } else {
                                    Utils.showSnackbar(context,
                                        "pleaseaccepttermsandcondition");
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: black),
                                  child: MyImage(
                                      width: 27,
                                      height: 27,
                                      imagePath: "ic_apple.png"),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const Spacer(),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: InkWell(
                    //     onTap: () {},
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         MyText(
                    //             color: red,
                    //             text: "donthaveanccount",
                    //             textalign: TextAlign.left,
                    //             fontsize: 12,
                    //             multilanguage: true,
                    //             inter: false,
                    //             maxline: 1,
                    //             fontwaight: FontWeight.w400,
                    //             overflow: TextOverflow.ellipsis,
                    //             fontstyle: FontStyle.normal),
                    //         SizedBox(
                    //             width:
                    //                 MediaQuery.of(context).size.width * 0.01),
                    //         MyText(
                    //             color: white,
                    //             text: "signup",
                    //             textalign: TextAlign.left,
                    //             fontsize: 12,
                    //             multilanguage: true,
                    //             inter: false,
                    //             maxline: 1,
                    //             fontwaight: FontWeight.w400,
                    //             overflow: TextOverflow.ellipsis,
                    //             fontstyle: FontStyle.normal),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Login With Google
  Future<void> gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    debugPrint('GoogleSignIn ===> id : ${user.id}');
    debugPrint('GoogleSignIn ===> email : ${user.email}');
    debugPrint('GoogleSignIn ===> displayName : ${user.displayName}');
    debugPrint('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      debugPrint("User Name: ${userCredential.user?.displayName}");
      debugPrint("User Email ${userCredential.user?.email}");
      debugPrint("User photoUrl ${userCredential.user?.photoURL}");
      debugPrint("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      debugPrint('firebasedid :===> $firebasedid');
      // Call Login Api
      if (!mounted) return;
      Utils.showProgress(context);
      checkAndNavigate(user.email, user.displayName ?? "", "", "", "2");
    } on FirebaseAuthException catch (e) {
      debugPrint('===>Exp${e.code.toString()}');
      debugPrint('===>Exp${e.message.toString()}');
      Utils().hideProgress(context);
    }
  }

  // Signin With Apple
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    debugPrint("Click Apple");
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';

      final firebaseUser = authResult.user;
      debugPrint("=================");

      final userEmail = '${firebaseUser?.email}';
      debugPrint("userEmail =====> $userEmail");
      debugPrint(firebaseUser?.email.toString());
      debugPrint(firebaseUser?.displayName.toString());
      debugPrint(firebaseUser?.photoURL.toString());
      debugPrint(firebaseUser?.uid);
      debugPrint("=================");

      final firebasedId = firebaseUser?.uid;
      debugPrint("firebasedId ===> $firebasedId");

      checkAndNavigate(userEmail, displayName.toString(), "", "", "3");
    } catch (exception) {
      debugPrint("Apple Login exception =====> $exception");
    }
    return null;
  }

  checkAndNavigate(
    String email,
    String userName,
    String profileImg,
    String password,
    String type,
  ) async {
    final loginItem = Provider.of<GeneralProvider>(context, listen: false);
    Utils.showProgress(
      context,
    );
    File? userProfileImg = await Utils.saveImageInStorage(profileImg);
    debugPrint("userProfileImg ===========> $userProfileImg");

    await loginItem.login(
        type, email, "", strDeviceType ?? "", strDeviceToken ?? "");

    debugPrint('checkAndNavigate loading ==>> ${loginItem.loading}');

    if (loginItem.loading) {
      if (!mounted) return;
      Utils.showProgress(context);
    } else {
      if (loginItem.loginModel.status == 200 &&
          loginItem.loginModel.result!.isNotEmpty) {
        await sharedPre.save(
            "userid", loginItem.loginModel.result?[0].id.toString());
        await sharedPre.save(
            "channelid", loginItem.loginModel.result?[0].channelId.toString());
        await sharedPre.save("channelname",
            loginItem.loginModel.result?[0].channelName.toString());
        await sharedPre.save(
            "fullname", loginItem.loginModel.result?[0].fullName.toString());
        await sharedPre.save(
            "email", loginItem.loginModel.result?[0].email.toString());
        await sharedPre.save("mobilenumber",
            loginItem.loginModel.result?[0].mobileNumber.toString());
        await sharedPre.save(
            "image", loginItem.loginModel.result?[0].image.toString());
        await sharedPre.save(
            "coverimage", loginItem.loginModel.result?[0].coverImg.toString());
        await sharedPre.save(
            "type", loginItem.loginModel.result?[0].type.toString());
        await sharedPre.save("desciption",
            loginItem.loginModel.result?[0].description.toString());
        await sharedPre.save("devicetype",
            loginItem.loginModel.result?[0].deviceType.toString());
        await sharedPre.save(
            "address", loginItem.loginModel.result?[0].address.toString());
        await sharedPre.save(
            "website", loginItem.loginModel.result?[0].website.toString());
        await sharedPre.save("instagramUrl",
            loginItem.loginModel.result?[0].instagramUrl.toString());
        await sharedPre.save("facebookUrl",
            loginItem.loginModel.result?[0].facebookUrl.toString());
        await sharedPre.save("twitterUrl",
            loginItem.loginModel.result?[0].twitterUrl.toString());
        await sharedPre.save("devicetoken",
            loginItem.loginModel.result?[0].deviceToken.toString());
        await sharedPre.save(
            "status", loginItem.loginModel.result?[0].status.toString());
        await sharedPre.save(
            "createat", loginItem.loginModel.result?[0].createdAt.toString());
        await sharedPre.save(
            "updateat", loginItem.loginModel.result?[0].updatedAt.toString());
        await sharedPre.save(
            "userIsBuy", loginItem.loginModel.result?[0].isBuy.toString());
        if (!mounted) return;

        // Set UserID With Chennal ID for Next
        Constant.userID = loginItem.loginModel.result?[0].id.toString() ?? "";
        Constant.isBuy = loginItem.loginModel.result?[0].isBuy.toString() ?? "";
        Utils.updatePremium(
            loginItem.loginModel.result?[0].isBuy.toString() ?? "");
        Constant.channelID =
            loginItem.loginModel.result?[0].channelId.toString() ?? "";
        debugPrint('Constant userID ===============>> ${Constant.userID}');
        debugPrint('ChannelID ===============>> ${Constant.channelID}');

        Utils().hideProgress(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false);
      } else {
        if (!mounted) return;
        Utils().hideProgress(context);
      }
    }
  }
}
