import 'package:maring/pages/contentdetail.dart';
import 'package:maring/pages/detail.dart';
import 'package:maring/pages/short.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/provider/watchlaterprovider.dart';
import 'package:maring/utils/adhelper.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/musicmanager.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WatchLater extends StatefulWidget {
  const WatchLater({super.key});

  @override
  State<WatchLater> createState() => WatchLaterState();
}

class WatchLaterState extends State<WatchLater> {
  late ScrollController _scrollController;
  late WatchLaterProvider watchLaterProvider;
  final MusicManager musicManager = MusicManager();

  @override
  void initState() {
    watchLaterProvider =
        Provider.of<WatchLaterProvider>(context, listen: false);
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
        (watchLaterProvider.currentPage ?? 0) <
            (watchLaterProvider.totalPage ?? 0)) {
      await watchLaterProvider.setLoadMore(true);
      if (watchLaterProvider.tabindex == 0) {
        _fetchData("1", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 1) {
        _fetchData("2", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 2) {
        _fetchData("3", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 3) {
        _fetchData("4", watchLaterProvider.currentPage ?? 0);
      } else if (watchLaterProvider.tabindex == 4) {
        _fetchData("6", watchLaterProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils.showSnackbar(context, "somethingwentwronge");
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    debugPrint("isMorePage  ======> ${watchLaterProvider.isMorePage}");
    debugPrint("currentPage ======> ${watchLaterProvider.currentPage}");
    debugPrint("totalPage   ======> ${watchLaterProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await watchLaterProvider.getContentByWatchLater(
        contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    watchLaterProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils().otherPageAppBar(context, "watchlater", true),
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

/* Tab */

  tabButton() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      return SizedBox(
        height: 35,
        child: ListView.builder(
            itemCount: Constant.watchlaterTabList.length,
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
                  await watchlaterprovider.chageTab(index);
                  watchlaterprovider.clearTab();
                  if (index == 0) {
                    _fetchData("1", 0);
                  } else if (index == 1) {
                    _fetchData("2", 0);
                  } else if (index == 2) {
                    _fetchData("3", 0);
                  } else if (index == 3) {
                    _fetchData("4", 0);
                    debugPrint(
                        "length=====> ${watchLaterProvider.contantList?.length ?? 0}");
                  } else if (index == 4) {
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
                      color: watchlaterprovider.tabindex == index
                          ? colorAccent
                          : colorPrimary,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: colorAccent)),
                  child: MyText(
                      color: white,
                      multilanguage: true,
                      text: Constant.watchlaterTabList[index],
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

/* Tab Item According Perticular Type */
  Widget buildPage() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      debugPrint(
          "content lenght==>${watchlaterprovider.contantList?.length ?? 0}");
      if (watchlaterprovider.loading && !watchlaterprovider.loadMore) {
        return buildShimmer();
      } else {
        return Column(
          children: [
            buildLayout(),
            if (watchlaterprovider.loadMore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                alignment: Alignment.center,
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
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      if (watchlaterprovider.tabindex == 0) {
        return buildVideo();
      } else if (watchlaterprovider.tabindex == 1) {
        return buildMusic();
      } else if (watchlaterprovider.tabindex == 2) {
        return buildReels();
      } else if (watchlaterprovider.tabindex == 3) {
        return buildPodcast();
      } else if (watchlaterprovider.tabindex == 4) {
        return buildRadio();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  buildShimmer() {
    return Consumer<WatchLaterProvider>(
        builder: (context, watchlaterprovider, child) {
      if (watchlaterprovider.tabindex == 0) {
        return buildVideoShimmer();
      } else if (watchlaterprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (watchlaterprovider.tabindex == 2) {
        return buildReelsShimmer();
      } else if (watchlaterprovider.tabindex == 3) {
        return buildPodcastShimmer();
      } else if (watchlaterprovider.tabindex == 4) {
        return buildRadioShimmer();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

/* Select Video Item */
  Widget buildVideo() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: watchLaterProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return buildVideoItem(index: index);
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

  Widget buildVideoItem({required int index}) {
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Detail(
                  iscontinueWatching: false,
                  stoptime: "",
                  videoid:
                      watchLaterProvider.contantList?[index].id.toString() ??
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: MyNetworkImage(
                    width: 130,
                    height: 80,
                    fit: BoxFit.cover,
                    imagePath: watchLaterProvider
                            .contantList?[index].portraitImg
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
                        color: white,
                        text: watchLaterProvider.contantList?[index].title
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
                        text: watchLaterProvider.contantList?[index].channelName
                                .toString() ??
                            "",
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
                            watchLaterProvider.contantList?[index].createdAt
                                    .toString() ??
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
              const SizedBox(width: 10),
              if (watchLaterProvider.position == index &&
                  watchLaterProvider.deleteWatchlaterloading)
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
                    /* Remove Watch Later Api */
                    await watchLaterProvider.addremoveWatchLater(
                        index,
                        watchLaterProvider.contantList?[index].contentType
                                .toString() ??
                            "",
                        watchLaterProvider.contantList?[index].id.toString() ??
                            "",
                        "0",
                        "0");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyImage(
                      width: 20,
                      height: 20,
                      imagePath: "ic_delete.png",
                      color: colorAccent,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVideoShimmer() {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(
                    width: 130,
                    height: 80,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          height: 8,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          height: 8,
                        ),
                        SizedBox(height: 5),
                        CustomWidget.roundrectborder(
                          height: 8,
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

/* Select Music Item */
  Widget buildMusic() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: watchLaterProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return buildMusicItem(index: index);
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

  Widget buildMusicItem({required int index}) {
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
          playAudio(
            playingType:
                watchLaterProvider.contantList?[index].contentType.toString() ??
                    "",
            episodeid:
                watchLaterProvider.contantList?[index].id.toString() ?? "",
            contentid:
                watchLaterProvider.contantList?[index].id.toString() ?? "",
            position: index,
            sectionBannerList: watchLaterProvider.contantList ?? [],
            contentName:
                watchLaterProvider.contantList?[index].title.toString() ?? "",
            isBuy:
                watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
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
                  imagePath: watchLaterProvider.contantList?[index].portraitImg
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
                      text: watchLaterProvider.contantList?[index].title
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
                          watchLaterProvider.contantList?[index].createdAt ??
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
            const SizedBox(width: 10),
            if (watchLaterProvider.position == index &&
                watchLaterProvider.deleteWatchlaterloading)
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
                  /* Remove Watch Later Api */
                  await watchLaterProvider.addremoveWatchLater(
                      index,
                      watchLaterProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      watchLaterProvider.contantList?[index].id.toString() ??
                          "",
                      "0",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: colorAccent,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget buildMusicShimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 15,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.roundrectborder(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

/* Select Podcast Item */
  Widget buildPodcast() {
    debugPrint(
        "buildPodcast=====> ${watchLaterProvider.contantList?.length ?? 0}");
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: watchLaterProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              debugPrint(
                  "episode=====> ${watchLaterProvider.contantList?[index].episode?.length ?? 0}");
              debugPrint(
                  "content lenght=====> ${watchLaterProvider.contantList?.length ?? 0}");
              return buildPodcastItem(index: index);
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

  Widget buildPodcastItem({required int index}) {
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
          playAudio(
            playingType:
                watchLaterProvider.contantList?[index].contentType.toString() ??
                    "",
            episodeid: watchLaterProvider.contantList?[index].episode?[0].id
                    .toString() ??
                "",
            contentid:
                watchLaterProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName: watchLaterProvider.contantList?[index].episode?[0].name
                    .toString() ??
                "",
            isBuy:
                watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
            sectionBannerList: watchLaterProvider.contantList ?? [],
            podcastimage:
                watchLaterProvider.contantList?[index].portraitImg.toString() ??
                    "",
          );
        });

        // log("contentType==>${watchLaterProvider.contantList?[index].contentType.toString() ?? ""}");
        // log("episodeid==>${watchLaterProvider.contantList?[index].episode?[0].id.toString() ?? ""}");
        // log("contentid==>${watchLaterProvider.contantList?[index].id.toString() ?? ""}");
        // log("episodeid==>${watchLaterProvider.contantList?[index].episode?[0].name.toString() ?? ""}");
        // log("episodeid==>${watchLaterProvider.contantList ?? []}");
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
                  imagePath: watchLaterProvider
                          .contantList?[index].episode?[0].portraitImg ??
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
                      text: watchLaterProvider
                              .contantList?[index].episode?[0].name ??
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
                        DateTime.parse(watchLaterProvider
                                .contantList?[index].episode?[0].createdAt ??
                            ""),
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
            const SizedBox(width: 10),
            if (watchLaterProvider.position == index &&
                watchLaterProvider.deleteWatchlaterloading)
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
                  /* Remove Watch Later Api */
                  await watchLaterProvider.addremoveWatchLater(
                      index,
                      watchLaterProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      watchLaterProvider.contantList?[index].id.toString() ??
                          "",
                      watchLaterProvider.contantList?[index].episode?[0].id
                              .toString() ??
                          "",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: colorAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPodcastShimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 15,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.roundrectborder(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

/* Select Radio Item */
  Widget buildRadio() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: watchLaterProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return buildRadioItem(index: index);
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

  Widget buildRadioItem({required int index}) {
    return InkWell(
      onTap: () {
        AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
          playAudio(
            playingType:
                watchLaterProvider.contantList?[index].contentType.toString() ??
                    "",
            episodeid:
                watchLaterProvider.contantList?[index].id.toString() ?? "",
            contentid:
                watchLaterProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                watchLaterProvider.contantList?[index].title.toString() ?? "",
            isBuy:
                watchLaterProvider.contantList?[index].isBuy.toString() ?? "",
            sectionBannerList: watchLaterProvider.contantList,
            contentUserid:
                watchLaterProvider.contantList?[index].userId.toString() ?? "",
            playlistImages: [],
            podcastimage:
                watchLaterProvider.contantList?[index].portraitImg.toString() ??
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
              borderRadius: BorderRadius.circular(55),
              child: MyNetworkImage(
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                  imagePath: watchLaterProvider.contantList?[index].portraitImg
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
                      text: watchLaterProvider.contantList?[index].title
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
                          watchLaterProvider.contantList?[index].createdAt ??
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
            const SizedBox(width: 10),
            if (watchLaterProvider.position == index &&
                watchLaterProvider.deleteWatchlaterloading)
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
                  /* Remove Watch Later Api */
                  await watchLaterProvider.addremoveWatchLater(
                      index,
                      watchLaterProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      watchLaterProvider.contantList?[index].id.toString() ??
                          "",
                      "0",
                      "0");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: 20,
                    height: 20,
                    imagePath: "ic_delete.png",
                    color: colorAccent,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget buildRadioShimmer() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: 15,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
            child: const Row(
              children: [
                CustomWidget.circular(
                  width: 55,
                  height: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildReels() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 3,
            maxItemsPerRow: 3,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 25,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(watchLaterProvider.contantList?.length ?? 0,
                (index) {
              return buildReelsItem(index: index);
            }),
          ),
        );
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget buildReelsItem({required int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Short(
                initialIndex: index,
                shortType: "watchlater",
              );
            },
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath: watchLaterProvider
                            .contantList?[index].portraitImg
                            .toString() ??
                        "",
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child:
                        MyImage(width: 35, height: 35, imagePath: "pause.png")),
                if (watchLaterProvider.position == index &&
                    watchLaterProvider.deleteWatchlaterloading)
                  const Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: colorAccent,
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          /* Remove Watch Later Api */
                          await watchLaterProvider.addremoveWatchLater(
                              index,
                              watchLaterProvider.contantList?[index].contentType
                                      .toString() ??
                                  "",
                              watchLaterProvider.contantList?[index].id
                                      .toString() ??
                                  "",
                              "0",
                              "0");
                        },
                        child: MyImage(
                          width: 20,
                          height: 20,
                          imagePath: "ic_delete.png",
                          color: colorAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MyText(
              color: white,
              text:
                  watchLaterProvider.contantList?[index].title.toString() ?? "",
              textalign: TextAlign.left,
              fontsize: Dimens.textMedium,
              inter: false,
              multilanguage: false,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget buildReelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const Column(
              children: [
                CustomWidget.roundrectborder(
                  height: 150,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    /* Only Music Direct Play*/
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, sectionBannerList,
          contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      /* Otherwise Open Perticular ContaentDetail Page  */
    } else if (playingType == "4") {
      debugPrint("Enter Podvast");
      musicManager.setInitialPodcastEpisode(
          context,
          episodeid,
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy ?? "",
          "episode");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ContentDetail(
              contentType: playingType,
              contentUserid: contentUserid ?? "",
              contentImage: podcastimage ?? "",
              contentName: contentName,
              playlistImage: playlistImages ?? [],
              contentId: contentid,
              isBuy: isBuy ?? "",
            );
          },
        ),
      );
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
