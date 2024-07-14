import 'dart:developer';
import 'dart:io';
import 'package:maring/provider/contentdetailprovider.dart';
import 'package:maring/provider/musicdetailprovider.dart';
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

class ContentDetail extends StatefulWidget {
  final String contentType,
      contentImage,
      contentName,
      contentId,
      contentUserid,
      isBuy;

  final dynamic playlistImage;
  const ContentDetail(
      {super.key,
      required this.contentType,
      required this.contentImage,
      required this.contentName,
      required this.contentUserid,
      required this.isBuy,
      this.playlistImage,
      required this.contentId});

  @override
  State<ContentDetail> createState() => _ContentDetailState();
}

class _ContentDetailState extends State<ContentDetail> {
  final MusicManager musicManager = MusicManager();
  late ContentDetailProvider contentDetailProvider;
  late MusicDetailProvider musicDetailProvider;
  late ScrollController _scrollController;
  late ScrollController reportReasonController;
  final playlistTitleController = TextEditingController();
  late ScrollController playlistController;

  @override
  void initState() {
    log("ContentType====>${widget.contentType}");
    contentDetailProvider =
        Provider.of<ContentDetailProvider>(context, listen: false);
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    reportReasonController = ScrollController();
    _scrollController.addListener(_scrollListener);
    reportReasonController.addListener(_scrollListenerReportReason);
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
    getApi();
  }

  getApi() async {
    if (widget.contentType == "4") {
      _fetchPodcastEpisode(0);
    } else if (widget.contentType == "5") {
      _fetchPlaylistEpisode(0);
    } else if (widget.contentType == "6") {
      _fetchRadioEpisode(0);
    }
  }

/* Content Episode Pagination After Scrolling  */
  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (widget.contentType == "4") {
        if ((contentDetailProvider.podcastcurrentPage ?? 0) <
            (contentDetailProvider.podcasttotalPage ?? 0)) {
          await contentDetailProvider.setLoadMore(true);
          _fetchPodcastEpisode(contentDetailProvider.podcastcurrentPage ?? 0);
        }
      } else if (widget.contentType == "6") {
        if ((contentDetailProvider.radiocurrentPage ?? 0) <
            (contentDetailProvider.radiototalPage ?? 0)) {
          await contentDetailProvider.setLoadMore(true);
          _fetchRadioEpisode(contentDetailProvider.radiocurrentPage ?? 0);
        }
      } else if (widget.contentType == "5") {
        if ((contentDetailProvider.playlistdatacurrentPage ?? 0) <
            (contentDetailProvider.playlistdatatotalPage ?? 0)) {
          await contentDetailProvider.setLoadMore(true);
          _fetchPlaylistEpisode(
              contentDetailProvider.playlistdatacurrentPage ?? 0);
        }
      }
    }
  }

/* Report Reason Pagination */
  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (contentDetailProvider.reportcurrentPage ?? 0) <
            (contentDetailProvider.reporttotalPage ?? 0)) {
      await contentDetailProvider.setReportReasonLoadMore(true);
      _fetchReportReason(contentDetailProvider.reportcurrentPage ?? 0);
    }
  }

/* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (contentDetailProvider.playlistcurrentPage ?? 0) <
            (contentDetailProvider.playlisttotalPage ?? 0)) {
      await contentDetailProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(contentDetailProvider.playlistcurrentPage ?? 0);
    }
  }

/* Podcast Episode Api */
  Future<void> _fetchPodcastEpisode(int? nextPage) async {
    debugPrint(
        "isMorePage  ======> ${contentDetailProvider.podcastisMorePage}");
    debugPrint(
        "currentPage ======> ${contentDetailProvider.podcastcurrentPage}");
    debugPrint("totalPage   ======> ${contentDetailProvider.podcasttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await contentDetailProvider.getEpisodeByPodcast(
        widget.contentId, (nextPage ?? 0) + 1);
  }

/* Radio Episode Api */
  Future<void> _fetchRadioEpisode(int? nextPage) async {
    debugPrint(
        "isMorePage  ======> ${contentDetailProvider.podcastisMorePage}");
    debugPrint(
        "currentPage ======> ${contentDetailProvider.podcastcurrentPage}");
    debugPrint("totalPage   ======> ${contentDetailProvider.podcasttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await contentDetailProvider.getEpisodeByRadio(
        widget.contentId, (nextPage ?? 0) + 1);
  }

/* Playlist Episode Api */
  Future<void> _fetchPlaylistEpisode(int? nextPage) async {
    debugPrint(
        "isMorePage  ======> ${contentDetailProvider.playlistdataisMorePage}");
    debugPrint(
        "currentPage ======> ${contentDetailProvider.playlistdatacurrentPage}");
    debugPrint(
        "totalPage   ======> ${contentDetailProvider.playlistdatatotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await contentDetailProvider.getEpisodeByPlaylist(
        widget.contentId, "2", (nextPage ?? 0) + 1);
  }

/* Report Reason Api */
  Future _fetchReportReason(int? nextPage) async {
    debugPrint(
        "reportmorePage  =======> ${contentDetailProvider.reportmorePage}");
    debugPrint(
        "reportcurrentPage =======> ${contentDetailProvider.reportcurrentPage}");
    debugPrint(
        "reporttotalPage   =======> ${contentDetailProvider.reporttotalPage}");
    debugPrint("nextPage   ========> $nextPage");
    await contentDetailProvider.getReportReason("2", (nextPage ?? 0) + 1);
    debugPrint(
        "fetchReportReason length ==> ${contentDetailProvider.reportReasonList?.length}");
  }

/* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    debugPrint(
        "playlistmorePage  =======> ${contentDetailProvider.playlistmorePage}");
    debugPrint(
        "playlistcurrentPage =======> ${contentDetailProvider.playlistcurrentPage}");
    debugPrint(
        "playlisttotalPage   =======> ${contentDetailProvider.playlisttotalPage}");
    debugPrint("nextPage   ========> $nextPage");
    await contentDetailProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    debugPrint(
        "fetchPlaylist length ==> ${contentDetailProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    contentDetailProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorPrimary,
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              controller: _scrollController,
              floatHeaderSlivers: false,
              physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
              scrollDirection: Axis.vertical,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: false,
                    forceElevated: false,
                    snap: false,
                    elevation: 0,
                    expandedHeight: 440,
                    automaticallyImplyLeading: true,
                    backgroundColor: colorPrimary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          podcastDiscription(),
                          const SizedBox(height: 25),
                          buildButton(),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: buildPage(),
              ),
            ),
          ),
        ),
        Utils.buildMusicPanel(context),
      ],
    );
  }

  Widget podcastDiscription() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.contentType == "5"
            ? playlistImage(widget.playlistImage)
            : ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: MyNetworkImage(
                    width: Dimens.contentDetailImagewidth,
                    height: Dimens.contentDetailImageheight,
                    imagePath: widget.contentImage,
                    fit: BoxFit.cover),
              ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.80,
          child: MyText(
              color: white,
              text: widget.contentName,
              textalign: TextAlign.center,
              fontsize: Dimens.textExtraBig,
              inter: false,
              multilanguage: false,
              maxline: 2,
              fontwaight: FontWeight.w700,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ),
      ],
    );
  }

  Widget buildButton() {
    if (widget.contentType == "4") {
      return podcastButtons();
    } else if (widget.contentType == "5") {
      return playlistButtons();
    } else if (widget.contentType == "6") {
      return radioButtons();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget podcastButtons() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* Add to Playlist Button Podcast */
          buttonItem(() async {
            selectPlaylistBottomSheet(widget.contentId, widget.contentType);
            await contentDetailProvider.getcontentbyChannel(
                Constant.userID, Constant.channelID, "5", "1");
          }, "ic_playlisttitle.png", 12, colorPrimaryDark, white),
          const SizedBox(width: 40),
          /* Play Button Podcast */
          buttonItem(() {
            AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
              if (widget.contentType == "4") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.podcastEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "6") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.radioEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "5") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.playlistEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              }
            });
          }, "ic_pausebtn.png", 25, white, black),
          const SizedBox(width: 40),
          /* More Button Podcast */
          buttonItem(() async {
            moreBottomSheetWithPodcats();
          }, "ic_more.png", 12, colorPrimaryDark, white),
        ],
      );
    });
  }

  Widget radioButtons() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* Add to Playlist Button Podcast */
          buttonItem(() async {
            selectPlaylistBottomSheet(widget.contentId, widget.contentType);
            await contentDetailProvider.getcontentbyChannel(
                Constant.userID, Constant.channelID, "5", "1");
          }, "ic_playlisttitle.png", 12, colorPrimaryDark, white),
          const SizedBox(width: 40),
          /* Play Button Podcast */
          buttonItem(() {
            AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
              if (widget.contentType == "4") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.podcastEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "6") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.radioEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "5") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.playlistEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              }
            });
          }, "ic_pausebtn.png", 25, white, black),
          /* WatchLater Button Podcast */
          const SizedBox(width: 40),
          buttonItem(() async {
            /* More Bottom Sheet open*/
            moreBottomSheetWithRadio();
          }, "ic_more.png", 12, colorPrimaryDark, white),
        ],
      );
    });
  }

  Widget playlistButtons() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* WatchLater Button Podcast */
          buttonItem(() async {
            /* More Bottom Sheet open*/
            await contentDetailProvider.addremoveWatchLater(
                widget.contentType, widget.contentId, "0", "1");
            if (!mounted) return;
            Utils.showSnackbar(context, "savetowatchlater");
          }, "ic_watchlater.png", 12, colorPrimaryDark, white),
          const SizedBox(width: 40),
          /* Play Button Podcast */
          buttonItem(() {
            AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
              if (widget.contentType == "4") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.podcastEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "6") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.radioEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              } else if (widget.contentType == "5") {
                playAudio(
                    widget.contentType,
                    true,
                    "",
                    widget.contentId,
                    0,
                    contentdetailprovider.playlistEpisodeList,
                    widget.contentName,
                    widget.isBuy);
              }
            });
          }, "ic_pausebtn.png", 25, white, black),
          const SizedBox(width: 40),
          /* More Button Podcast */
          buttonItem(() async {
            /* More Bottom Sheet open*/
            moreBottomSheet();
          }, "ic_more.png", 12, colorPrimaryDark, white),
        ],
      );
    });
  }

  // Widget buildButton() {
  //   return Consumer<ContentDetailProvider>(
  //       builder: (context, contentdetailprovider, child) {
  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         buttonItem(() {}, "ic_download.png", 12, colorPrimaryDark, white),
  //         if (widget.contentType == "4" || widget.contentType == "6")
  //           buttonItem(() async {
  //             playlistBottomSheet(contentType: widget.contentType);
  //             await contentDetailProvider.getcontentbyChannel(
  //                 Constant.userID, Constant.channelID, "5", "1");
  //           }, "ic_playlisttitle.png", 12, colorPrimaryDark, white),
  //         buttonItem(() {
  //           if (widget.contentType == "4") {
  //             playAudio(
  //               widget.contentType,
  //               true,
  //               "",
  //               widget.contentId,
  //               0,
  //               contentdetailprovider.podcastEpisodeList,
  //               widget.contentName,
  //             );
  //           } else if (widget.contentType == "6") {
  //             playAudio(
  //               widget.contentType,
  //               true,
  //               "",
  //               widget.contentId,
  //               0,
  //               contentdetailprovider.radioEpisodeList,
  //               widget.contentName,
  //             );
  //           } else if (widget.contentType == "5") {
  //             playAudio(
  //               widget.contentType,
  //               true,
  //               "",
  //               widget.contentId,
  //               0,
  //               contentdetailprovider.playlistEpisodeList,
  //               widget.contentName,
  //             );
  //           }
  //         }, "ic_pausebtn.png", 25, white, black),
  //         buttonItem(() {
  //           Utils.shareApp(Platform.isIOS
  //               ? "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
  //               : "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
  //         }, "ic_share.png", 12, colorPrimaryDark, white),
  //         buttonItem(() async {
  //           if (widget.contentType == "4") {
  //             /* Show More Bottom Sheet */
  //             await contentDetailProvider.getReportReason("2", 1);
  //             reportBottomSheet(widget.contentUserid, widget.contentId);
  //           } else {
  //             await contentDetailProvider.addremoveWatchLater(
  //                 widget.contentType, widget.contentId, "0", "1");
  //             if (!mounted) return;
  //             Utils.showSnackbar(context, "savetowatchlater");
  //           }
  //         }, widget.contentType == "4" ? "report.png" : "ic_watchlater.png", 12,
  //             colorPrimaryDark, white),
  //       ],
  //     );
  //   });
  // }

  Widget buttonItem(dynamic onTap, String imagePath, double padding,
      Color bgcolor, iconcolor) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(color: bgcolor, shape: BoxShape.circle),
        child: MyImage(
            width: 20, height: 20, imagePath: imagePath, color: iconcolor),
      ),
    );
  }

  buildPage() {
    if (widget.contentType == "4") {
      return buildPodcast();
    } else if (widget.contentType == "6") {
      return buildRadio();
    } else if (widget.contentType == "5") {
      return buildPlaylist();
    }
  }

/* Podcast Page */
  Widget buildPodcast() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      if (contentdetailprovider.loading && !contentdetailprovider.loadmore) {
        return commonShimmer();
      } else {
        return Column(
          children: [
            podcastEpisodeList(),
            if (contentdetailprovider.loadmore)
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

  Widget podcastEpisodeList() {
    if (contentDetailProvider.epidoseByPodcastModel.status == 200 &&
        contentDetailProvider.podcastEpisodeList != null) {
      if ((contentDetailProvider.podcastEpisodeList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 15,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              contentDetailProvider.podcastEpisodeList?.length ?? 0,
              (index) {
                return InkWell(
                  onTap: () {
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
                      playAudio(
                          widget.contentType,
                          false,
                          contentDetailProvider.podcastEpisodeList?[index].id
                                  .toString() ??
                              "",
                          widget.contentId,
                          index,
                          contentDetailProvider.podcastEpisodeList,
                          contentDetailProvider.podcastEpisodeList?[index].name
                                  .toString() ??
                              "",
                          contentDetailProvider.podcastEpisodeList?[index].isBuy
                                  .toString() ??
                              "");
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 55,
                              height: 55,
                              imagePath: contentDetailProvider
                                      .podcastEpisodeList?[index].portraitImg
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
                                  text: contentDetailProvider
                                          .podcastEpisodeList?[index].name
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textTitle,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: contentDetailProvider
                                          .podcastEpisodeList?[index]
                                          .description
                                          .toString() ??
                                      "",
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
                        InkWell(
                          onTap: () {
                            debugPrint(
                                "${contentDetailProvider.podcastEpisodeList?[index].id.toString()}");
                            /* More Bottom Sheet */
                            moreBottomSheet(
                                episodeId: contentDetailProvider
                                        .podcastEpisodeList?[index].id
                                        .toString() ??
                                    "");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: MyImage(
                                width: 13,
                                height: 13,
                                imagePath: "ic_more.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ));
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

/* Radio Page */
  Widget buildRadio() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      if (contentdetailprovider.loading && !contentdetailprovider.loadmore) {
        return commonShimmer();
      } else {
        return Column(
          children: [
            radioEpisodeList(),
            if (contentdetailprovider.loadmore)
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

  Widget radioEpisodeList() {
    if (contentDetailProvider.epidoseByRadioModel.status == 200 &&
        contentDetailProvider.radioEpisodeList != null) {
      if ((contentDetailProvider.radioEpisodeList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 15,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              contentDetailProvider.radioEpisodeList?.length ?? 0,
              (index) {
                return InkWell(
                  onTap: () {
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
                      playAudio(
                          widget.contentType,
                          false,
                          contentDetailProvider.radioEpisodeList?[index].id
                                  .toString() ??
                              "",
                          widget.contentId,
                          index,
                          contentDetailProvider.radioEpisodeList,
                          contentDetailProvider.radioEpisodeList?[index].title
                                  .toString() ??
                              "",
                          contentDetailProvider.radioEpisodeList?[index].isBuy
                                  .toString() ??
                              "");
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 55,
                              height: 55,
                              imagePath: contentDetailProvider
                                      .radioEpisodeList?[index].portraitImg
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
                                  text: contentDetailProvider
                                          .radioEpisodeList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textTitle,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: contentDetailProvider
                                          .radioEpisodeList?[index].description
                                          .toString() ??
                                      "",
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
              },
            ));
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

/* Playlist Page */
  Widget buildPlaylist() {
    return Consumer<ContentDetailProvider>(
        builder: (context, contentdetailprovider, child) {
      if (contentdetailprovider.loading && !contentdetailprovider.loadmore) {
        return commonShimmer();
      } else {
        return Column(
          children: [
            playlistEpisodeList(),
            if (contentdetailprovider.loadmore)
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

  Widget playlistEpisodeList() {
    if (contentDetailProvider.episodebyplaylistModel.status == 200 &&
        contentDetailProvider.playlistEpisodeList != null) {
      if ((contentDetailProvider.playlistEpisodeList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 15,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              contentDetailProvider.playlistEpisodeList?.length ?? 0,
              (index) {
                return InkWell(
                  onTap: () {
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
                      playAudio(
                          widget.contentType,
                          false,
                          contentDetailProvider.playlistEpisodeList?[index].id
                                  .toString() ??
                              "",
                          widget.contentId,
                          index,
                          contentDetailProvider.playlistEpisodeList,
                          contentDetailProvider
                                  .playlistEpisodeList?[index].title
                                  .toString() ??
                              "",
                          contentDetailProvider
                                  .playlistEpisodeList?[index].isBuy
                                  .toString() ??
                              "");
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 55,
                              height: 55,
                              imagePath: contentDetailProvider
                                      .playlistEpisodeList?[index].portraitImg
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
                                  text: contentDetailProvider
                                          .playlistEpisodeList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textTitle,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: contentDetailProvider
                                          .playlistEpisodeList?[index]
                                          .description
                                          .toString() ??
                                      "",
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
              },
            ));
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget commonShimmer() {
    return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 5,
        verticalGridSpacing: 15,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          10,
          (index) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 60,
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: const Row(
                children: [
                  CustomWidget.roundrectborder(
                    width: 55,
                    height: 55,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                        SizedBox(height: 8),
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  moreBottomSheet({episodeId, isPodcast}) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.contentType == "4")
                    moreFunctionItem("ic_watchlater.png", "savetowatchlater",
                        () async {
                      await contentDetailProvider.addremoveWatchLater(
                          "4", widget.contentId, episodeId, "1");
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      Utils.showSnackbar(context, "savetowatchlater");
                    }),
                  if (widget.contentType == "5")
                    moreFunctionItem("ic_share.png", "share", () async {
                      Navigator.of(context).pop();
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  moreBottomSheetWithPodcats({episodeId, isPodcast}) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  moreFunctionItem("report.png", "report", () async {
                    Navigator.of(context).pop();
                    _fetchReportReason(0);
                    reportBottomSheet(widget.contentUserid, widget.contentId);
                  }),
                  moreFunctionItem("ic_share.png", "share", () async {
                    Navigator.of(context).pop();
                    Utils.shareApp(Platform.isIOS
                        ? "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                        : "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  moreBottomSheetWithRadio({episodeId, isPodcast}) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  moreFunctionItem("ic_watchlater.png", "watchlater", () async {
                    await contentDetailProvider.addremoveWatchLater(
                        widget.contentType, widget.contentId, "0", "1");
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Utils.showSnackbar(context, "savetowatchlater");
                  }),
                  moreFunctionItem("ic_share.png", "share", () async {
                    Navigator.of(context).pop();
                    Utils.shareApp(Platform.isIOS
                        ? "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                        : "Hey! I'm Listening ${widget.contentName}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget moreFunctionItem(icon, title, onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyImage(
              width: 25,
              height: 25,
              imagePath: icon,
              color: white,
            ),
            const SizedBox(width: 20),
            MyText(
                color: white,
                text: title,
                textalign: TextAlign.left,
                fontsize: Dimens.textTitle,
                multilanguage: true,
                inter: false,
                maxline: 2,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        ),
      ),
    );
  }

  reportBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  alignment: Alignment.centerLeft,
                  child: MyText(
                      color: white,
                      text: "selectreportreason",
                      textalign: TextAlign.left,
                      fontsize: Dimens.textBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: buildReportReasonList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        contentDetailProvider.reportReasonList?.clear();
                        contentDetailProvider.position = 0;
                        contentDetailProvider.clearSelectReportReason();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: white),
                        ),
                        child: MyText(
                            color: white,
                            text: "cancel",
                            textalign: TextAlign.left,
                            fontsize: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () async {
                        if (contentDetailProvider.reasonId == "" ||
                            contentDetailProvider.reasonId.isEmpty) {
                          Utils.showSnackbar(
                              context, "pleaseselectyourreportreason");
                        } else {
                          await contentDetailProvider.addContentReport(
                              reportUserid,
                              contentid,
                              contentDetailProvider
                                      .reportReasonList?[contentDetailProvider
                                              .reportPosition ??
                                          0]
                                      .reason
                                      .toString() ??
                                  "",
                              "1");
                          if (!mounted) return;
                          Navigator.pop(context);
                          Utils.showSnackbar(context, "reportaddsuccsessfully");
                          contentDetailProvider.clearSelectReportReason();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5)),
                        child: MyText(
                            color: white,
                            text: "report",
                            textalign: TextAlign.left,
                            fontsize: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildReportReasonList() {
    return Consumer<ContentDetailProvider>(
        builder: (context, reportreasonprovider, child) {
      debugPrint("call List");
      if (reportreasonprovider.getcontentreportloading &&
          !reportreasonprovider.getcontentreportloadmore) {
        return Utils.pageLoader(context);
      } else {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: reportReasonController,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              buildReportReasonListItem(),
              if (reportreasonprovider.getcontentreportloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget buildReportReasonListItem() {
    log("report List Lenght==>${contentDetailProvider.reportReasonList?.length ?? 0}");
    if (contentDetailProvider.getRepostReasonModel.status == 200 &&
        contentDetailProvider.reportReasonList != null) {
      if ((contentDetailProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: contentDetailProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                contentDetailProvider.selectReportReason(
                    index,
                    true,
                    contentDetailProvider.reportReasonList?[index].id
                            .toString() ??
                        "");
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: contentDetailProvider.reportPosition == index &&
                        contentDetailProvider.isSelectReason == true
                    ? colorAccent
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
                        text: "${(index + 1).toString()}.",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: white,
                          text: contentDetailProvider
                                  .reportReasonList?[index].reason
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
                    contentDetailProvider.reportPosition == index &&
                            contentDetailProvider.isSelectReason == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        debugPrint("null Array");
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      debugPrint("null Array Last");
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget playlistImage(playlistImage) {
    if ((playlistImage.length ?? 0) == 4) {
      return SizedBox(
          width: Dimens.contentDetailImagewidth,
          height: Dimens.contentDetailImageheight,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[0],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[1],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[2],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[3],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((playlistImage.length ?? 0) == 3) {
      return SizedBox(
          width: Dimens.contentDetailImagewidth,
          height: Dimens.contentDetailImageheight,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[0],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[1],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: MyNetworkImage(
                  fit: BoxFit.cover,
                  imagePath: playlistImage[2],
                ),
              ),
            ],
          ));
    } else if ((playlistImage.length ?? 0) == 2) {
      return SizedBox(
          width: Dimens.contentDetailImagewidth,
          height: Dimens.contentDetailImageheight,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[0],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imagePath: playlistImage[1],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((playlistImage.length ?? 0) == 1) {
      return SizedBox(
          width: Dimens.contentDetailImagewidth,
          height: Dimens.contentDetailImageheight,
          child: MyNetworkImage(
            fit: BoxFit.cover,
            imagePath: playlistImage[0],
          ));
    } else {
      return Container(
        width: 160,
        height: 150,
        color: colorPrimaryDark,
        alignment: Alignment.center,
        child: MyImage(width: 35, height: 35, imagePath: "ic_music.png"),
      );
    }
  }

  Future<void> playAudio(
    String playingType,
    bool isplayBtn,
    String episodeid,
    String contentid,
    int position,
    dynamic contentList,
    String contentName,
    String isBuy,
  ) async {
    /* Play Music */
    if (playingType == "2") {
      musicManager.setInitialMusic(position, playingType, contentList,
          contentid, addView(playingType, contentid), false, 0, isBuy);
      /* Play Podcast */
    } else if (playingType == "4") {
      debugPrint("contentId ==>$contentid");
      debugPrint("episodeId ==>$episodeid");
      await musicDetailProvider.getEpisodeByPodcast(contentid, "1");
      if (!mounted) return;
      musicManager.setInitialPodcast(
          context,
          episodeid,
          position,
          playingType,
          contentList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy,
          "podcast");

      /* Play Radio */
    } else if (playingType == "5") {
      /* In This Api Get Only Music So into Api Pass ContentId == "2" */
      await musicDetailProvider.getEpisodeByPlaylist(contentid, "2", "1");
      musicManager.setInitialPlayList(position, playingType, contentList,
          contentid, addView(playingType, contentid), isBuy);
    } else if (playingType == "6") {
      await musicDetailProvider.getEpisodeByRadio(contentid, "1");
      musicManager.setInitialRadio(position, playingType, contentList,
          contentid, addView(playingType, contentid), isBuy);
    } else {
      log("Error Type");
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }

  /* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(contentid, contentType) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                          color: white,
                          text: "selectplaylist",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          multilanguage: true,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          createPlaylistDilog(
                              playlistId: contentDetailProvider.playlistId);
                        },
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: white,
                                size: 22,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                  color: white,
                                  text: "createplaylist",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textDesc,
                                  multilanguage: true,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: buildPlayList(),
                ),
                Consumer<ContentDetailProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (contentDetailProvider.getContentbyChannelModel.status ==
                            200 &&
                        contentDetailProvider.playlistData != null) {
                      if ((contentDetailProvider.playlistData?.length ?? 0) >
                          0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                playlistprovider.clearPlaylistData();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(width: 1, color: white),
                                ),
                                child: MyText(
                                    color: white,
                                    text: "cancel",
                                    textalign: TextAlign.left,
                                    fontsize: Dimens.textBig,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                if (contentDetailProvider.playlistId.isEmpty ||
                                    contentDetailProvider.playlistId == "") {
                                  Utils.showSnackbar(
                                      context, "pleaseelectyourplaylist");
                                } else {
                                  await contentDetailProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          contentDetailProvider
                                                  .getContentbyChannelModel
                                                  .result?[contentDetailProvider
                                                          .playlistPosition ??
                                                      0]
                                                  .id
                                                  .toString() ??
                                              "",
                                          contentType,
                                          contentid,
                                          "0",
                                          "1");

                                  if (!contentDetailProvider
                                      .addremovecontentplaylistloading) {
                                    if (contentDetailProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      if (!mounted) return;
                                      Utils.showSnackbar(
                                          context, "savetoplaylist");
                                    } else {
                                      if (!mounted) return;
                                      Utils.showSnackbar(context,
                                          "${contentDetailProvider.addremoveContentToPlaylistModel.message}");
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(5)),
                                child: MyText(
                                    color: white,
                                    text: "addcontent",
                                    textalign: TextAlign.left,
                                    fontsize: Dimens.textBig,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<ContentDetailProvider>(
        builder: (context, playlistprovider, child) {
      if (playlistprovider.playlistLoading &&
          !playlistprovider.playlistLoadmore) {
        return Utils.pageLoader(context);
      } else {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: playlistController,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              buildPlaylistItem(),
              if (playlistprovider.playlistLoadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget buildPlaylistItem() {
    log("Playlist Lenght==>${contentDetailProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${contentDetailProvider.playlistPosition}");
    log("Playlist Id==>${contentDetailProvider.playlistId}");
    if (contentDetailProvider.getContentbyChannelModel.status == 200 &&
        contentDetailProvider.playlistData != null) {
      if ((contentDetailProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: contentDetailProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                contentDetailProvider.selectPlaylist(
                    index,
                    contentDetailProvider.playlistData?[index].id.toString() ??
                        "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: contentDetailProvider.playlistPosition == index &&
                        contentDetailProvider.isSelectPlaylist == true
                    ? colorAccent
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
                        text: "${(index + 1).toString()}.",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: white,
                          text: contentDetailProvider.playlistData?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
                    contentDetailProvider.playlistPosition == index &&
                            contentDetailProvider.isSelectPlaylist == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const NoData(
            title: "noplaylistfound", subTitle: "createnewplaylist");
      }
    } else {
      return const NoData(
          title: "noplaylistfound", subTitle: "createnewplaylist");
    }
  }

/* Create Playlist Bottom Sheet */
  createPlaylistDilog({playlistId}) {
    debugPrint("playlistId==> $playlistId");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorAccent.withOpacity(0.10),
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<ContentDetailProvider>(
                builder: (context, createplaylistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsize: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    controller: playlistTitleController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Give your playlist a title",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "privacy",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textDesc,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 1);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 1
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 1
                                    ? colorAccent
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 1
                              ? const Icon(
                                  Icons.check,
                                  color: white,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "public",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textDesc,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 2);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 2
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 2
                                    ? colorAccent
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 2
                              ? const Icon(
                                  Icons.check,
                                  color: white,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "private",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          contentDetailProvider.isType = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textBig,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        onTap: () async {
                          if (playlistTitleController.text.isEmpty) {
                            Utils.showSnackbar(
                                context, "pleaseenterplaylistname");
                          } else if (createplaylistprovider.isType == 0) {
                            Utils.showSnackbar(
                                context, "pleaseselectplaylisttype");
                          } else {
                            Navigator.pop(context);
                            await createplaylistprovider.getcreatePlayList(
                              Constant.channelID,
                              playlistTitleController.text,
                              contentDetailProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.loading) {
                              if (createplaylistprovider
                                      .createPlaylistModel.status ==
                                  200) {
                                if (!mounted) return;
                                Utils.showSnackbar(
                                    context, "playlistcreatesuccsessfully");
                              } else {
                                if (!mounted) return;
                                Utils.showSnackbar(context,
                                    "${createplaylistprovider.createPlaylistModel.message}");
                              }
                            }

                            playlistTitleController.clear();
                            contentDetailProvider.isType = 0;
                            // _fetchPlaylist(0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textBig,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
