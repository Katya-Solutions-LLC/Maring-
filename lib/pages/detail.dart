import 'dart:io';
import 'package:maring/pages/login.dart';
import 'package:maring/pages/musicdetails.dart';
import 'package:maring/pages/profile.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:maring/provider/detailsprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Detail extends StatefulWidget {
  final String videoid, stoptime;
  final bool iscontinueWatching;
  const Detail(
      {super.key,
      required this.videoid,
      required this.iscontinueWatching,
      required this.stoptime});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final commentController = TextEditingController();
  late DetailsProvider detailsProvider;
  late ScrollController _scrollController;
  late ScrollController replaycommentController;
  String? userImage;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    debugPrint("Stop Time===> ${widget.stoptime}");
    detailsProvider = Provider.of<DetailsProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    replaycommentController = ScrollController();
    replaycommentController.addListener(_scrollListenerReplayComment);
    super.initState();
    getApi();
    _fetchCommentData(0);
  }

  getApi() async {
    await detailsProvider.getvideodetails(widget.videoid.toString(), "1");
    userImage = await sharedPre.read("image");
    debugPrint("_getData userProfile ===> $userImage");
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (detailsProvider.currentPageComment ?? 0) <
            (detailsProvider.totalPageComment ?? 0)) {
      debugPrint("load more====>");
      detailsProvider.setCommentLoadMore(true);
      _fetchCommentData(detailsProvider.currentPageComment ?? 0);
    }
  }

  Future<void> _fetchCommentData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${detailsProvider.morePageComment}");
    debugPrint("currentPage ======> ${detailsProvider.currentPageComment}");
    debugPrint("totalPage   ======> ${detailsProvider.totalPageComment}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getComment("1", widget.videoid, (nextPage ?? 0) + 1);
    await detailsProvider.setCommentLoading(false);
  }

  _scrollListenerReplayComment() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (detailsProvider.currentPageReplayComment ?? 0) <
            (detailsProvider.totalPageReplayComment ?? 0)) {
      await detailsProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(detailsProvider.commentId,
          detailsProvider.currentPageReplayComment ?? 0);
    }
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    debugPrint("isMorePage  ======> ${detailsProvider.morePageReplayComment}");
    debugPrint(
        "currentPage ======> ${detailsProvider.currentPageReplayComment}");
    debugPrint("totalPage   ======> ${detailsProvider.totalPageReplayComment}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await detailsProvider.setReplayCommentLoadMore(false);
  }

  @override
  void dispose() {
    detailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Column(
        children: [
          /* Video Image */
          buildImage(),
          /* Video Title With Discription With Comments */
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildDiscription(),
                  const SizedBox(height: 15),
                  channelItem(),
                  const SizedBox(height: 25),
                  functionList(),
                  const SizedBox(height: 20),
                  addComment(),
                  const SizedBox(height: 15),
                  buildComment(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Video Image
  Widget buildImage() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return buildImageShimmer();
      } else {
        return Stack(
          children: [
            MyNetworkImage(
              width: MediaQuery.of(context).size.width,
              height: 300,
              fit: BoxFit.fill,
              imagePath: detailsprovider.detailsModel.result?[0].portraitImg
                      .toString() ??
                  "",
            ),
            /* Back Button */
            Positioned.fill(
              top: 35,
              left: 15,
              child: Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyImage(
                        width: 30, height: 30, imagePath: "ic_roundback.png"),
                  ),
                ),
              ),
            ),
            /* Play Button */
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
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
                        debugPrint("StopTime====>${widget.stoptime}");
                        /* StopTime Converted Milisecond To Second */
                        String stopTime = "0";
                        if (widget.stoptime.isEmpty || widget.stoptime == "") {
                          stopTime = "0";
                        } else {
                          double convertTime =
                              int.parse(widget.stoptime) / 1000;
                          stopTime = convertTime.toString();
                        }
                        debugPrint("StopTime====>${widget.stoptime}");

                        audioPlayer.pause();
                        Utils.openPlayer(
                          iscontinueWatching: widget.iscontinueWatching,
                          stoptime: stopTime,
                          context: context,
                          videoId: detailsprovider.detailsModel.result?[0].id
                                  .toString() ??
                              "",
                          videoUrl: detailsprovider
                                  .detailsModel.result?[0].content
                                  .toString() ??
                              "",
                          vUploadType: detailsprovider
                                  .detailsModel.result?[0].contentUploadType
                                  .toString() ??
                              "",
                          videoThumb: detailsprovider
                                  .detailsModel.result?[0].landscapeImg
                                  .toString() ??
                              "",
                        );
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:
                        MyImage(width: 50, height: 50, imagePath: "pause.png"),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    });
  }

  Widget buildImageShimmer() {
    return CustomWidget.rectangular(
      width: MediaQuery.of(context).size.width,
      height: 300,
    );
  }

// build Title Discription With view Count

  Widget buildDiscription() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return buildDiscriptionShimmer();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyText(
                color: white,
                text:
                    detailsprovider.detailsModel.result?[0].title.toString() ??
                        "",
                multilanguage: false,
                textalign: TextAlign.left,
                fontsize: Dimens.textBig,
                inter: true,
                maxline: 5,
                fontwaight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(minHeight: 0),
              alignment: Alignment.centerLeft,
              child: ExpandableText(
                detailsprovider.detailsModel.result?[0].description
                        .toString() ??
                    "",
                expandText: "Read More",
                collapseText: "Read less",
                maxLines: 2,
                expandOnTextTap: true,
                collapseOnTextTap: true,
                linkStyle: TextStyle(
                  fontSize: Dimens.textDesc,
                  fontStyle: FontStyle.normal,
                  color: colorAccent,
                  fontWeight: FontWeight.w600,
                ),
                style: TextStyle(
                  fontSize: Dimens.textMedium,
                  fontStyle: FontStyle.normal,
                  color: gray,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                MyText(
                    color: gray,
                    text: Utils.kmbGenerator(int.parse(detailsprovider
                            .detailsModel.result?[0].totalView
                            .toString() ??
                        "")),
                    textalign: TextAlign.left,
                    fontsize: Dimens.textSmall,
                    inter: false,
                    multilanguage: false,
                    maxline: 2,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 5),
                MyText(
                    color: gray,
                    text: "views",
                    textalign: TextAlign.left,
                    fontsize: Dimens.textSmall,
                    inter: false,
                    multilanguage: true,
                    maxline: 2,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal),
                const SizedBox(width: 15),
                MyText(
                    color: gray,
                    text: Utils.timeAgoCustom(DateTime.parse(detailsprovider
                            .detailsModel.result?[0].createdAt
                            .toString() ??
                        "")),
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
        );
      }
    });
  }

  Widget buildDiscriptionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.75,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.30,
        ),
        const SizedBox(height: 10),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width * 0.50,
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            CustomWidget.circular(
              height: 10,
              width: 10,
            ),
            SizedBox(width: 5),
            CustomWidget.roundrectborder(
              height: 5,
              width: 60,
            ),
            SizedBox(width: 15),
            CustomWidget.roundrectborder(
              height: 5,
              width: 60,
            ),
          ],
        ),
      ],
    );
  }

// Add Comment Seaction
  Widget addComment() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return addCommentShimmer();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
                color: white,
                text: "comments",
                textalign: TextAlign.left,
                fontsize: Dimens.textSmall,
                inter: false,
                maxline: 2,
                multilanguage: true,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Constant.userID == null
                    ? MyImage(width: 35, height: 35, imagePath: "ic_user.png")
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MyNetworkImage(
                          width: 35,
                          height: 35,
                          imagePath: userImage?.toString() ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextFormField(
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      controller: commentController,
                      textInputAction: TextInputAction.done,
                      cursorColor: lightgray,
                      style: Utils.googleFontStyle(
                          4, 14, FontStyle.normal, white, FontWeight.w400),
                      decoration: InputDecoration(
                        hintStyle: Utils.googleFontStyle(
                            4, 14, FontStyle.normal, white, FontWeight.w400),
                        hintText: "Add Your comment here...",
                        filled: true,
                        fillColor: colorPrimaryDark,
                        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        disabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
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
                      if (detailsProvider.detailsModel.result?[0].isComment ==
                          0) {
                        Utils.showSnackbar(
                            context, "youcannotcommentthiscontent");
                      } else if (commentController.text.isEmpty) {
                        Utils.showSnackbar(context, "pleaseenteryourcomment");
                      } else {
                        await detailsProvider.getaddcomment(
                          "1",
                          widget.videoid,
                          "0",
                          commentController.text.toString(),
                          "0",
                        );
                        commentController.clear();
                      }
                    }
                  },
                  child: Consumer<DetailsProvider>(
                      builder: (context, detailprovider, child) {
                    if (detailprovider.addcommentloading) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: colorAccent,
                          strokeWidth: 1,
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: colorAccent,
                          shape: BoxShape.circle,
                        ),
                        child: MyImage(
                            width: 20, height: 20, imagePath: "ic_send.png"),
                      );
                    }
                  }),
                ),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget addCommentShimmer() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(
          height: 5,
          width: 60,
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.circular(
              width: 35,
              height: 35,
            ),
            SizedBox(width: 10),
            Expanded(
              child: CustomWidget.roundcorner(
                height: 35,
              ),
            ),
            SizedBox(width: 10),
            CustomWidget.circular(
              width: 35,
              height: 35,
            ),
          ],
        ),
      ],
    );
  }

// Channel Section
  Widget channelItem() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return channelItemShimmer();
      } else {
        return InkWell(
          onTap: () {
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
                    return Profile(
                      isProfile: false,
                      channelUserid: detailsProvider
                              .detailsModel.result?[0].userId
                              .toString() ??
                          "",
                      channelid: detailsProvider
                              .detailsModel.result?[0].channelId
                              .toString() ??
                          "",
                    );
                  },
                ),
              );
            }
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: MyNetworkImage(
                  width: 35,
                  height: 35,
                  imagePath: detailsProvider
                          .detailsModel.result?[0].channelImage
                          .toString() ??
                      "",
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                        color: white,
                        text: detailsProvider
                                .detailsModel.result?[0].channelName
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textDesc,
                        multilanguage: false,
                        inter: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(detailsProvider
                                    .detailsModel.result?[0].totalSubscriber
                                    .toString() ??
                                "")),
                            textalign: TextAlign.left,
                            fontsize: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "subscriber",
                            textalign: TextAlign.left,
                            fontsize: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              detailsProvider.detailsModel.result?[0].userId.toString() ==
                      Constant.userID
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: () async {
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
                          await detailsProvider.addremoveSubscribe(
                              detailsProvider.detailsModel.result?[0].userId
                                      .toString() ??
                                  "",
                              "1");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: detailsProvider
                                      .detailsModel.result?[0].isSubscribe ==
                                  0
                              ? colorAccent
                              : colorPrimary,
                          border: Border.all(width: 1, color: colorAccent),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: MyText(
                            color: white,
                            text: detailsProvider
                                        .detailsModel.result?[0].isSubscribe ==
                                    0
                                ? "subscribe"
                                : "subscribed",
                            textalign: TextAlign.left,
                            fontsize: Dimens.textSmall,
                            inter: false,
                            maxline: 2,
                            multilanguage: true,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
            ],
          ),
        );
      }
    });
  }

  Widget channelItemShimmer() {
    return const Row(
      children: [
        CustomWidget.circular(
          width: 35,
          height: 35,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(height: 8),
              SizedBox(height: 5),
              CustomWidget.roundrectborder(
                height: 8,
                width: 100,
              ),
            ],
          ),
        ),
        SizedBox(width: 15),
        CustomWidget.roundcorner(
          height: 18,
          width: 65,
        ),
      ],
    );
  }

// Like Dislike Button
  Widget functionList() {
    return Consumer<DetailsProvider>(
        builder: (context, detailsprovider, child) {
      if (detailsProvider.loading) {
        return functionListShimmer();
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              detailsProvider.detailsModel.result?[0].isLike == 1
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorPrimaryDark,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
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
                                if (detailsProvider
                                        .detailsModel.result?[0].isLike ==
                                    0) {
                                  Utils.showSnackbar(
                                      context, "youcannotlikethiscontent");
                                } else {
                                  if ((detailsProvider.detailsModel.result?[0]
                                              .isUserLikeDislike ??
                                          0) ==
                                      1) {
                                    debugPrint("Remove Api");
                                    await detailsProvider.like(
                                        "1",
                                        detailsProvider
                                                .detailsModel.result?[0].id
                                                .toString() ??
                                            "",
                                        "0",
                                        "0");
                                  } else {
                                    await detailsProvider.like(
                                        "1",
                                        detailsProvider
                                                .detailsModel.result?[0].id
                                                .toString() ??
                                            "",
                                        "1",
                                        "0");
                                  }
                                }
                              }
                            },
                            child: Row(
                              children: [
                                (detailsProvider.detailsModel.result?[0]
                                                .isUserLikeDislike ??
                                            0) ==
                                        1
                                    ? MyImage(
                                        width: 25,
                                        height: 25,
                                        imagePath: "ic_likefill.png",
                                      )
                                    : MyImage(
                                        width: 25,
                                        height: 25,
                                        imagePath: "ic_like.png",
                                      ),
                                const SizedBox(width: 8),
                                MyText(
                                    color: white,
                                    text: Utils.kmbGenerator(int.parse(
                                        detailsProvider.detailsModel.result?[0]
                                                .totalLike
                                                .toString() ??
                                            "")),
                                    multilanguage: false,
                                    textalign: TextAlign.center,
                                    fontsize: Dimens.textTitle,
                                    inter: false,
                                    maxline: 6,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 20,
                            color: white,
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
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
                                // Dislike APi Call
                                if (detailsProvider
                                        .detailsModel.result?[0].isLike ==
                                    0) {
                                  Utils.showSnackbar(
                                      context, "youcannotlikethiscontent");
                                } else {
                                  if ((detailsProvider.detailsModel.result?[0]
                                              .isUserLikeDislike ??
                                          2) ==
                                      0) {
                                    debugPrint("Remove Api");
                                    await detailsProvider.dislike(
                                        "1",
                                        detailsProvider
                                                .detailsModel.result?[0].id
                                                .toString() ??
                                            "",
                                        "0",
                                        "0");
                                  } else {
                                    await detailsProvider.dislike(
                                        "1",
                                        detailsProvider
                                                .detailsModel.result?[0].id
                                                .toString() ??
                                            "",
                                        "2",
                                        "0");
                                  }
                                }
                              }
                            },
                            child: (detailsProvider.detailsModel.result?[0]
                                            .isUserLikeDislike ??
                                        0) ==
                                    2
                                ? MyImage(
                                    width: 25,
                                    height: 25,
                                    imagePath: "ic_dislikefill.png",
                                  )
                                : MyImage(
                                    width: 25,
                                    height: 25,
                                    imagePath: "ic_dislike.png",
                                  ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 8),
              detailsProvider.detailsModel.result?[0].isDownload == 1
                  ? InkWell(
                      onTap: () async {
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
                          // Dislike APi Call
                          if (detailsProvider
                                  .detailsModel.result?[0].isDownload ==
                              0) {
                            Utils.showSnackbar(
                                context, "youcannotdownloadthiscontent");
                          } else {}
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorPrimaryDark,
                        ),
                        child: Row(
                          children: [
                            MyImage(
                              width: 12,
                              height: 12,
                              imagePath: "ic_download.png",
                              color: white,
                            ),
                            const SizedBox(width: 8),
                            MyText(
                                color: white,
                                text: "save",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsize: Dimens.textMedium,
                                inter: false,
                                maxline: 6,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Utils.shareApp(Platform.isIOS
                      ? "Hey! I'm Listening ${detailsProvider.detailsModel.result?[0].id.toString()}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                      : "Hey! I'm Listening ${detailsProvider.detailsModel.result?[0].id.toString()}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorPrimaryDark,
                  ),
                  child: Row(
                    children: [
                      MyImage(
                        width: 10,
                        height: 10,
                        imagePath: "ic_share.png",
                        color: white,
                      ),
                      const SizedBox(width: 5),
                      MyText(
                          color: white,
                          text: "share",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          inter: false,
                          maxline: 6,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget functionListShimmer() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
        SizedBox(width: 10),
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
        SizedBox(width: 10),
        CustomWidget.roundcorner(
          height: 25,
          width: 90,
        ),
      ],
    );
  }

// Comments
  Widget buildComment() {
    return Consumer<DetailsProvider>(builder: (context, detailprovider, child) {
      if (detailprovider.commentloading && !detailprovider.commentloadmore) {
        return commentShimmer();
      } else {
        return Column(
          children: [
            commentList(),
            if (detailsProvider.commentloadmore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  Widget commentList() {
    if (detailsProvider.getcommentModel.status == 200 &&
        detailsProvider.commentList != null) {
      if ((detailsProvider.commentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: detailsProvider.commentList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        imagePath: detailsProvider.commentList?[index].image
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: white,
                              text: detailsProvider
                                      .commentList?[index].channelName
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textTitle,
                              fontwaight: FontWeight.w500,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              inter: false,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 5),
                          MyText(
                              color: gray,
                              text: detailsProvider.commentList?[index].comment
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              fontwaight: FontWeight.w400,
                              multilanguage: false,
                              inter: false,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  detailsProvider.storeReplayCommentId(
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "");
                                  _fetchReplayCommentData(
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "",
                                      0);
                                  replayCommentBottomSheet(
                                      index,
                                      detailsProvider.detailsModel.result?[0].id
                                              .toString() ??
                                          "",
                                      detailsProvider.commentList?[index].id
                                              .toString() ??
                                          "",
                                      detailsProvider.commentList?[index].image
                                              .toString() ??
                                          "",
                                      detailsProvider
                                              .commentList?[index].channelName
                                              .toString() ??
                                          "",
                                      detailsProvider
                                              .commentList?[index].comment
                                              .toString() ??
                                          "");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: colorPrimaryDark,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: MyImage(
                                      width: 12,
                                      height: 12,
                                      imagePath: "ic_comment.png"),
                                ),
                              ),
                              const SizedBox(width: 15),
                              if (detailsProvider.commentList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                if (detailsProvider.deletecommentLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorAccent,
                                      strokeWidth: 1,
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () async {
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
                                        await detailsProvider.getDeleteComment(
                                            detailsProvider
                                                    .commentList?[index].id
                                                    .toString() ??
                                                "",
                                            true,
                                            index);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: colorPrimaryDark,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: MyImage(
                                          width: 12,
                                          height: 12,
                                          imagePath: "ic_delete.png"),
                                    ),
                                  )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        return const NoData(title: "datanotfound", subTitle: "commentisempty");
      }
    } else {
      return const NoData(title: "datanotfound", subTitle: "commentisempty");
    }
  }

  Widget commentShimmer() {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (BuildContext ctx, index) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.circular(
                  width: 35,
                  height: 35,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 5,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 5,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          CustomWidget.circular(
                            width: 10,
                            height: 10,
                          ),
                          SizedBox(width: 15),
                          CustomWidget.circular(
                            width: 10,
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// Replay Comment
  replayCommentBottomSheet(int index, videoid, commentid, commentUserImage,
      commentUsername, comment) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildReplayComment(index, videoid, commentid, commentUserImage,
                commentUsername, comment),
          ],
        );
      },
    ).whenComplete(() {
      debugPrint(
          "comment count ====>>> ${detailsProvider.getcommentModel.result?.length}");
    });
  }

  Widget buildReplayComment(
      index, videoid, commentId, commentUserImage, commentUsername, comment) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                          color: white,
                          text: "replay",
                          fontsize: Dimens.textTitle,
                          fontwaight: FontWeight.w500,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        commentController.clear();
                        detailsProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1, color: white)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                          imagePath: commentUserImage,
                          fit: BoxFit.fill,
                          width: 26,
                          height: 26),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          color: white,
                          text: commentUsername,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 5),
                      MyText(
                          color: white,
                          text: comment,
                          fontsize: Dimens.textSmall,
                          fontwaight: FontWeight.w400,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: buildreplayCommentList()),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Replay Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          debugPrint("videoid==> $videoid");
                          debugPrint("comment==> ${commentController.text}");
                          debugPrint("comment==> $commentId");
                          await detailsProvider.getaddReplayComment(
                            "1",
                            videoid,
                            "0",
                            commentController.text,
                            commentId,
                          );
                          commentController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<DetailsProvider>(
                              builder: (context, detailprovider, child) {
                            if (detailprovider.addreplaycommentloading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorAccent,
                                  strokeWidth: 1,
                                ),
                              );
                            } else {
                              return MyImage(
                                  width: 20,
                                  height: 20,
                                  imagePath: "ic_send.png");
                            }
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildreplayCommentList() {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child:
          Consumer<DetailsProvider>(builder: (context, detailprovider, child) {
        if (detailprovider.replaycommentloding &&
            !detailprovider.replayCommentloadmore) {
          return Utils.pageLoader(context);
        } else {
          return Column(
            children: [
              replayCommentList(),
              if (detailprovider.replayCommentloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        }
      }),
    );
  }

  Widget replayCommentList() {
    if (detailsProvider.replayCommentModel.status == 200 &&
        detailsProvider.replaycommentList != null) {
      if ((detailsProvider.replaycommentList?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: detailsProvider.replaycommentList?.length ?? 0,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      // color: gray,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(width: 1, color: white)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                  imagePath: detailsProvider
                                          .replaycommentList?[index].image
                                          .toString() ??
                                      "",
                                  fit: BoxFit.fill,
                                  width: 20,
                                  height: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                detailsProvider.replaycommentList?[index]
                                            .fullName ==
                                        ""
                                    ? MyText(
                                        color: white,
                                        text: detailsProvider
                                                .replaycommentList?[index]
                                                .fullName
                                                .toString() ??
                                            "",
                                        fontsize: Dimens.textDesc,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal)
                                    : MyText(
                                        color: white,
                                        text: detailsProvider
                                                .replaycommentList?[index]
                                                .channelName
                                                .toString() ??
                                            "",
                                        fontsize: Dimens.textMedium,
                                        fontwaight: FontWeight.w500,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: MyText(
                                      color: white,
                                      text: detailsProvider
                                              .replaycommentList?[index].comment
                                              .toString() ??
                                          "",
                                      fontsize: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 3,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (detailsProvider.replaycommentList?[index].userId
                                  .toString() ==
                              Constant.userID)
                            if (detailsProvider.deletecommentLoading &&
                                detailsProvider.deleteItemIndex == index)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorAccent,
                                  strokeWidth: 1,
                                ),
                              )
                            else
                              InkWell(
                                onTap: () async {
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
                                    await detailsProvider.getDeleteComment(
                                      detailsProvider
                                              .replaycommentList?[index].id
                                              .toString() ??
                                          "",
                                      false,
                                      index,
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyImage(
                                      width: 16,
                                      height: 16,
                                      color: colorAccent,
                                      imagePath: "ic_delete.png"),
                                ),
                              )
                        ],
                      ),
                    );
                  }),
            ),
            if (detailsProvider.commentloading)
              const CircularProgressIndicator(
                color: colorAccent,
              )
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }
}
