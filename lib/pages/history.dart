import 'package:maring/pages/detail.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/provider/historyprovider.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/musicmanager.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final MusicManager musicManager = MusicManager();
  late HistoryProvider historyProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    _fetchData("1", 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (historyProvider.currentPage ?? 0) < (historyProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      _fetchData("1", historyProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    debugPrint("isMorePage  ======> ${historyProvider.isMorePage}");
    debugPrint("currentPage ======> ${historyProvider.currentPage}");
    debugPrint("totalPage   ======> ${historyProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await historyProvider.getHistory(contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    historyProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils().otherPageAppBar(context, "history", true),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tabButton(),
                  buildPage(),
                ],
              ),
            ),
          ),
        ),
        Utils.buildMusicPanel(context),
      ],
    );
  }

/* Tab  */
  tabButton() {
    return Consumer<HistoryProvider>(
        builder: (context, historyprovider, child) {
      return SizedBox(
        height: 35,
        child: ListView.builder(
            itemCount: Constant.historyTabList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: colorPrimaryDark,
                highlightColor: colorPrimaryDark,
                hoverColor: colorPrimaryDark,
                splashColor: colorPrimaryDark,
                onTap: () async {
                  await historyprovider.chageTab(index);
                  await historyprovider.clearTab();
                  if (index == 0) {
                    _fetchData("1", 0);
                  } else if (index == 1) {
                    _fetchData("2", 0);
                  } else if (index == 2) {
                    _fetchData("4", 0);
                  } else if (index == 3) {
                    _fetchData("6", 0);
                  } else {
                    if (!mounted) return;
                    Utils.showSnackbar(context, "Something Went Wronge !!!");
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: historyprovider.tabindex == index
                          ? colorAccent
                          : colorPrimary,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: colorAccent)),
                  child: MyText(
                      color: white,
                      multilanguage: true,
                      text: Constant.historyTabList[index],
                      textalign: TextAlign.center,
                      fontsize: Dimens.textMedium,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
              );
            }),
      );
    });
  }

/* Tab Item According to Type */
  Widget buildPage() {
    return Consumer<HistoryProvider>(
        builder: (context, historyprovider, child) {
      if (historyprovider.loading && !historyprovider.loadMore) {
        return shimmer();
      } else {
        return Column(
          children: [
            buildLayout(),
            if (historyProvider.loadMore)
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

  buildLayout() {
    return Consumer<HistoryProvider>(
        builder: (context, historyprovider, child) {
      if (historyprovider.tabindex == 0) {
        return buildHistoryVideo();
      } else if (historyprovider.tabindex == 1) {
        return buildHistoryMusic();
      } else if (historyprovider.tabindex == 2) {
        return buildHistoryPodcast();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildHistoryVideo() {
    if (historyProvider.historyModel.status == 200 &&
        historyProvider.historyList != null) {
      if ((historyProvider.historyList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: historyProvider.historyList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                hoverColor: colorAccent,
                highlightColor: colorAccent,
                autofocus: true,
                onTap: () {
                  AdHelper.showFullscreenAd(context, Constant.interstialAdType,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Detail(
                            stoptime: historyProvider
                                    .historyList?[index].stopTime
                                    .toString() ??
                                "",
                            iscontinueWatching: true,
                            videoid: historyProvider.historyList?[index].id
                                    .toString() ??
                                "",
                          );
                        },
                      ),
                    );
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                  width: 130,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  imagePath: historyProvider
                                          .historyList?[index].portraitImg
                                          .toString() ??
                                      ""),
                            ),
                            // (historyProvider.historyList?[index].contentType
                            //                 .toString() ??
                            //             "") ==
                            //         "3"
                            //     ? const SizedBox.shrink()
                            //     : Positioned.fill(
                            //         child: Align(
                            //           alignment: Alignment.bottomCenter,
                            //           child: Container(
                            //             width: 140,
                            //             alignment: Alignment.bottomCenter,
                            //             constraints:
                            //                 const BoxConstraints(minWidth: 0),
                            //             padding: const EdgeInsets.all(3),
                            //             child: LinearPercentIndicator(
                            //               padding: const EdgeInsets.all(0),
                            //               barRadius: const Radius.circular(2),
                            //               lineHeight: 4,
                            //               percent: Utils.getPercentage(
                            //                   historyProvider
                            //                           .historyList?[index]
                            //                           .contentDuration ??
                            //                       0,
                            //                   historyProvider
                            //                           .historyList?[index]
                            //                           .stopTime ??
                            //                       0),
                            //               backgroundColor: black,
                            //               progressColor: colorAccent,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: white,
                                  text: historyProvider
                                          .historyList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textMedium,
                                  multilanguage: false,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              MyText(
                                  color: gray,
                                  text: contentString(index),
                                  multilanguage: false,
                                  textalign: TextAlign.left,
                                  fontsize: 12,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              MyText(
                                  color: gray,
                                  text: Utils.timeAgoCustom(
                                    DateTime.parse(
                                      historyProvider
                                              .historyList?[index].createdAt ??
                                          "",
                                    ),
                                  ),
                                  textalign: TextAlign.left,
                                  fontsize: 12,
                                  multilanguage: false,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget buildHistoryMusic() {
    if (historyProvider.historyModel.status == 200 &&
        historyProvider.historyList != null) {
      if ((historyProvider.historyList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: historyProvider.historyList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () {
                  AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
                    playAudio(
                        playingType: historyProvider
                                .historyList?[index].contentType
                                .toString() ??
                            "",
                        episodeid:
                            historyProvider.historyList?[index].id.toString() ??
                                "",
                        contentid:
                            historyProvider.historyList?[index].id.toString() ??
                                "",
                        position: index,
                        contentList: historyProvider.historyList,
                        contentName: historyProvider.historyList?[index].title
                                .toString() ??
                            "",
                        stoptime: historyProvider.historyList?[index].stopTime
                                .toString() ??
                            "",
                        isBuy: historyProvider.historyList?[index].isBuy
                                .toString() ??
                            "");
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 55,
                  margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: 55,
                            height: 55,
                            imagePath: historyProvider
                                    .historyList?[index].portraitImg
                                    .toString() ??
                                ""),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                                color: colorAccent,
                                multilanguage: false,
                                text: historyProvider.historyList?[index].title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsize: Dimens.textDesc,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 5),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: Utils.timeAgoCustom(
                                  DateTime.parse(
                                    historyProvider
                                            .historyList?[index].createdAt ??
                                        "",
                                  ),
                                ),
                                textalign: TextAlign.left,
                                fontsize: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget buildHistoryPodcast() {
    if (historyProvider.historyModel.status == 200 &&
        historyProvider.historyList != null) {
      if ((historyProvider.historyList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: historyProvider.historyList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () {
                  AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
                    playAudio(
                      playingType: historyProvider
                              .historyList?[index].contentType
                              .toString() ??
                          "",
                      episodeid: historyProvider
                              .historyList?[index].episode?[0].id
                              .toString() ??
                          "",
                      contentid:
                          historyProvider.historyList?[index].id.toString() ??
                              "",
                      position: index,
                      contentName: historyProvider
                              .historyList?[index].episode?[0].name
                              .toString() ??
                          "",
                      isBuy: historyProvider.historyList?[index].isBuy
                              .toString() ??
                          "",
                      contentList: historyProvider.historyList ?? [],
                      stoptime: historyProvider.historyList?[index].stopTime
                              .toString() ??
                          "",
                    );
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 55,
                  margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: 55,
                            height: 55,
                            imagePath: historyProvider
                                    .historyList?[index].episode?[0].portraitImg
                                    .toString() ??
                                ""),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                                color: colorAccent,
                                multilanguage: false,
                                text: historyProvider
                                        .historyList?[index].episode?[0].name
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsize: Dimens.textDesc,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 5),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: Utils.timeAgoCustom(
                                  DateTime.parse(
                                    historyProvider.historyList?[index]
                                            .episode?[0].createdAt
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                textalign: TextAlign.left,
                                fontsize: Dimens.textSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  contentString(index) {
    if (historyProvider.historyList?[index].contentType == 1) {
      return "Video";
    } else if (historyProvider.historyList?[index].contentType == 2) {
      return "Music";
    } else if (historyProvider.historyList?[index].contentType == 3) {
      return "Short";
    } else if (historyProvider.historyList?[index].contentType == 4) {
      return "Podcast";
    } else if (historyProvider.historyList?[index].contentType == 5) {
      return "Paylist";
    } else if (historyProvider.historyList?[index].contentType == 6) {
      return "Radio";
    } else {
      return "";
    }
  }

  Widget shimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 10,
        itemBuilder: (BuildContext ctx, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(
                    width: 140,
                    height: 80,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 200,
                          height: 7,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 150,
                          height: 7,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          width: 100,
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    required int position,
    dynamic contentList,
    required String contentName,
    dynamic stoptime,
    required String? isBuy,
  }) async {
    int finalStopTime = int.parse(stoptime);
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
      if (playingType == "2") {
        /* Only Music Direct Play*/
        musicManager.setInitialMusic(
            position,
            playingType,
            contentList,
            contentid,
            addView(playingType, contentid),
            true,
            finalStopTime,
            isBuy ?? "");
      } else if (playingType == "4") {
        musicManager.setInitialHistory(
            context,
            episodeid,
            position,
            playingType,
            contentList,
            contentid,
            addView(playingType, contentid),
            true,
            finalStopTime,
            isBuy ?? "",
            "episode");
      }
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
