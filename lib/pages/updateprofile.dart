// ignore_for_file: deprecated_member_use
import 'dart:developer';
import 'dart:io';
import 'package:maring/utils/sharedpre.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:maring/provider/updateprofileprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final String channelid;
  const UpdateProfile({super.key, required this.channelid});

  @override
  State<UpdateProfile> createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  final ImagePicker picker = ImagePicker();
  SharedPre sharedPre = SharedPre();
  String userid = "", name = "";
  String gendarvalue = 'Male';
  String? countrycode = WidgetsBinding.instance.window.locale.countryCode ?? "";
  XFile? _image;
  XFile? _coverImage;
  bool iseditimg = false;
  bool iseditcoverImg = false;
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  String mobilenumber = "";
  String? countryCode;
  @override
  void initState() {
    super.initState();
    getApi();
  }

  getApi() async {
    final updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);

    await updateprofileProvider.getprofile(Constant.userID);

    nameController.text =
        updateprofileProvider.profileModel.result?[0].fullName.toString() ?? "";
    emailController.text =
        updateprofileProvider.profileModel.result?[0].email.toString() ?? "";
    numberController.text =
        updateprofileProvider.profileModel.result?[0].mobileNumber.toString() ??
            "";
    channelNameController.text =
        updateprofileProvider.profileModel.result?[0].channelName.toString() ??
            "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Consumer<UpdateprofileProvider>(
            builder: (context, updateprofileProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.40,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary.withOpacity(0.9),
                          colorPrimary.withOpacity(0.1),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.1, 0.9],
                      ),
                      color: white,
                    ),
                    child: _coverImage == null
                        ? MyNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            imagePath: updateprofileProvider
                                    .profileModel.result?[0].coverImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            File(_coverImage?.path ?? ""),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary.withOpacity(0.6),
                          colorPrimary.withOpacity(1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.5],
                      ),
                      color: colorAccent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        space(0.07),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_roundback.png"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  MyText(
                                      color: white,
                                      text: "editprofile",
                                      multilanguage: true,
                                      textalign: TextAlign.center,
                                      fontsize: 16,
                                      maxline: 6,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                try {
                                  var coverImage = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 100);
                                  setState(() {
                                    _coverImage = coverImage;
                                    iseditcoverImg = true;
                                  });
                                } catch (e) {
                                  debugPrint("Error ==>${e.toString()}");
                                }
                              },
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "ic_camera.png"),
                            ),
                          ],
                        ),
                        space(0.04),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: _image == null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: MyNetworkImage(
                                          imagePath: updateprofileProvider
                                                  .profileModel.result?[0].image
                                                  .toString() ??
                                              "",
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.file(
                                          height: 151,
                                          width: 151,
                                          File(_image?.path ?? ""),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () async {
                                      try {
                                        var image = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 100);
                                        setState(() {
                                          _image = image;
                                          iseditimg = true;
                                        });
                                      } catch (e) {
                                        debugPrint("Error ==>${e.toString()}");
                                      }
                                    },
                                    child: MyImage(
                                        width: 30,
                                        height: 30,
                                        imagePath: "ic_camera.png"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        space(0.04),
                        myTextField(nameController, TextInputAction.next,
                            TextInputType.text, Constant.fullname, false),
                        space(0.03),
                        myTextField(channelNameController, TextInputAction.next,
                            TextInputType.text, Constant.channelname, false),
                        space(0.03),
                        myTextField(emailController, TextInputAction.next,
                            TextInputType.text, Constant.email, false),
                        space(0.03),
                        myTextField(
                            numberController,
                            Platform.isIOS
                                ? TextInputAction.next
                                : TextInputAction.done,
                            TextInputType.number,
                            Constant.mobile,
                            true),
                        space(0.02),
                        space(0.03),
                        InkWell(
                          onTap: () async {
                            dynamic image;
                            dynamic coverImage;
                            String fullname = nameController.text.toString();
                            String channelName =
                                channelNameController.text.toString();
                            String email = emailController.text.toString();

                            if (iseditimg) {
                              image = File(_image?.path ?? "");
                            } else {
                              image = File("");
                            }

                            if (iseditcoverImg) {
                              coverImage = File(_coverImage?.path ?? "");
                            } else {
                              coverImage = File("");
                            }

                            final updateprofileProvider =
                                Provider.of<UpdateprofileProvider>(context,
                                    listen: false);
                            Utils.showProgress(context);
                            await sharedPre.save(
                                "username", nameController.text.toString());
                            await sharedPre.save("useremail", email);
                            await sharedPre.save('usermobile', mobilenumber);
                            await updateprofileProvider.getupdateprofile(
                                Constant.userID.toString(),
                                fullname,
                                channelName,
                                email,
                                mobilenumber,
                                image,
                                coverImage);

                            if (updateprofileProvider.loading) {
                              if (!mounted) return;
                              Utils.showProgress(context);
                            } else {
                              if (updateprofileProvider
                                      .updateprofileModel.status ==
                                  200) {
                                Utils().showToast(updateprofileProvider
                                    .updateprofileModel.message
                                    .toString());
                                if (!mounted) return;
                                Utils().hideProgress(context);
                                setState(() {});
                                getApi();
                              } else {
                                Utils().showToast(updateprofileProvider
                                    .updateprofileModel.message
                                    .toString());
                                if (!mounted) return;
                                Utils().hideProgress(context);
                              }
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7)),
                              gradient: LinearGradient(
                                colors: [
                                  colorAccent.withOpacity(0.6),
                                  colorAccent.withOpacity(1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: MyText(
                                color: white,
                                text: "submit",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsize: 16,
                                maxline: 6,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget gender() {
    return Theme(
      data: Theme.of(context).copyWith(
          unselectedWidgetColor: gray,
          disabledColor: white,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: colorAccent)),
      child: Row(
        children: [
          Radio<String>(
              activeColor: colorAccent,
              value: "Male",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Male" ? colorAccent : white,
              text: "Male",
              fontsize: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
          Radio<String>(
              activeColor: colorAccent,
              value: "Female",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Female" ? colorAccent : white,
              text: "Female",
              fontsize: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
          Radio<String>(
              activeColor: colorAccent,
              value: "Other",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Other" ? colorAccent : white,
              text: "Other",
              fontsize: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget myTextField(
      controller, textInputAction, keyboardType, labletext, isMobile) {
    return SizedBox(
      height: 55,
      child: isMobile == false
          ? TextFormField(
              textAlign: TextAlign.left,
              obscureText: false,
              keyboardType: keyboardType,
              controller: controller,
              textInputAction: textInputAction,
              cursorColor: white,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: labletext,
                labelStyle: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    color: colorAccent,
                    fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
              ),
            )
          : IntlPhoneField(
              disableLengthCheck: true,
              textAlignVertical: TextAlignVertical.center,
              autovalidateMode: AutovalidateMode.disabled,
              controller: controller,
              style: Utils.googleFontStyle(
                  4, 16, FontStyle.normal, white, FontWeight.w500),
              showCountryFlag: false,
              showDropdownIcon: false,
              initialValue: "In",
              initialCountryCode: "IN",
              dropdownTextStyle: Utils.googleFontStyle(
                  4, 16, FontStyle.normal, white, FontWeight.w500),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              decoration: InputDecoration(
                labelText: labletext,
                filled: true,
                border: InputBorder.none,
                labelStyle: Utils.googleFontStyle(
                    4, 14, FontStyle.normal, white, FontWeight.w500),
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
                controller.updateCountryCode();
                countrycode = "+${country.dialCode.toString()}";
                log('countrycode===> $countrycode');
              },
            ),
    );
  }

  Widget space(double space) {
    return SizedBox(height: MediaQuery.of(context).size.height * space);
  }
}
