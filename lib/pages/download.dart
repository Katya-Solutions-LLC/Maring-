import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';

class Download extends StatefulWidget {
  const Download({super.key});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context,"download", true),
      body: videoList(),
    );
  }

  Widget videoList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerLeft,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (BuildContext ctx, index) {
                  return InkWell(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.11,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: MyImage(
                                width: MediaQuery.of(context).size.width * 0.40,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.fill,
                                imagePath: "ic_detail.png"),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    color: white,
                                    text: "Make a healthy food with me",
                                    textalign: TextAlign.left,
                                    fontsize: Dimens.textMedium,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 3,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  children: [
                                    MyText(
                                        color: white,
                                        text: "100k",
                                        multilanguage: false,
                                        textalign: TextAlign.left,
                                        fontsize: Dimens.textSmall,
                                        inter: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.01),
                                    MyText(
                                        color: white,
                                        text: "views",
                                        textalign: TextAlign.left,
                                        fontsize: Dimens.textSmall,
                                        multilanguage: false,
                                        inter: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    MyText(
                                        color: white,
                                        text: "2",
                                        textalign: TextAlign.left,
                                        fontsize: Dimens.textSmall,
                                        multilanguage: false,
                                        inter: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    MyText(
                                        color: white,
                                        text: "days ago",
                                        textalign: TextAlign.left,
                                        fontsize: Dimens.textSmall,
                                        inter: false,
                                        multilanguage: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: InkWell(
                              onTap: () {
                                morePopup();
                              },
                              child: MyImage(
                                  width: 20,
                                  height: 20,
                                  imagePath: "ic_more.png"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void morePopup() async {
    await showMenu(
      context: context,
      color: colorPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      position: const RelativeRect.fromLTRB(220, 400, 0, 50),
      items: [
        PopupMenuItem<String>(
          value: "2",
          textStyle: GoogleFonts.roboto(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          child: MyText(
              color: white,
              text: "deletefromdownload",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsize: 16,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ),
      ],
      elevation: 8.0,
    );
  }
}
