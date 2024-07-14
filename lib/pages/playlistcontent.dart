import 'package:maring/pages/contentdetail.dart';
import 'package:maring/pages/detail.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/provider/playlistcontentprovider.dart';
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

class PlaylistContent extends StatefulWidget {
  final String playlistId, title;
  const PlaylistContent(
      {super.key, required this.playlistId, required this.title});

  @override
  State<PlaylistContent> createState() => PlaylistContentState();
}

class PlaylistContentState extends State<PlaylistContent> {
  final MusicManager musicManager = MusicManager();
  late ScrollController _scrollController;
  late PlaylistContentProvider playlistContentProvider;

  @override
  void initState() {
    playlistContentProvider =
        Provider.of<PlaylistContentProvider>(context, listen: false);
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
        (playlistContentProvider.currentPage ?? 0) <
            (playlistContentProvider.totalPage ?? 0)) {
      await playlistContentProvider.setLoadMore(true);
      if (playlistContentProvider.tabindex == 0) {
        _fetchData("1", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 1) {
        _fetchData("2", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 2) {
        _fetchData("4", playlistContentProvider.currentPage ?? 0);
      } else if (playlistContentProvider.tabindex == 3) {
        _fetchData("6", playlistContentProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils.showSnackbar(context, "Something Went Wronge !!!");
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    debugPrint("isMorePage  ======> ${playlistContentProvider.isMorePage}");
    debugPrint("currentPage ======> ${playlistContentProvider.currentPage}");
    debugPrint("totalPage   ======> ${playlistContentProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await playlistContentProvider.getPlaylistContent(
        widget.playlistId, contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    playlistContentProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils().otherPageAppBar(context, widget.title, false),
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
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      return SizedBox(
        height: 35,
        child: ListView.builder(
            itemCount: Constant.selectContentTabList.length,
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
                  await playlistcontentprovider.chageTab(index);
                  await playlistcontentprovider.clearTab();
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
                      color: playlistcontentprovider.tabindex == index
                          ? colorAccent
                          : colorPrimary,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: colorAccent)),
                  child: MyText(
                      color: white,
                      multilanguage: true,
                      text: Constant.selectContentTabList[index],
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
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      if (playlistcontentprovider.loading &&
          !playlistcontentprovider.loadMore) {
        return buildShimmer();
      } else {
        return Column(
          children: [
            buildLayout(),
            if (playlistcontentprovider.loadMore)
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
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      if (playlistcontentprovider.tabindex == 0) {
        return buildVideo();
      } else if (playlistcontentprovider.tabindex == 1) {
        return buildMusic();
      } else if (playlistcontentprovider.tabindex == 2) {
        return buildPodcast();
      } else if (playlistcontentprovider.tabindex == 3) {
        return buildRadio();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  buildShimmer() {
    return Consumer<PlaylistContentProvider>(
        builder: (context, playlistcontentprovider, child) {
      if (playlistcontentprovider.tabindex == 0) {
        return buildVideoShimmer();
      } else if (playlistcontentprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (playlistcontentprovider.tabindex == 2) {
        return buildPodcastShimmer();
      } else if (playlistcontentprovider.tabindex == 3) {
        return buildRadioShimmer();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

/* Select Video Item */
  Widget buildVideo() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
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
                  return Detail(
                    stoptime: "",
                    iscontinueWatching: false,
                    videoid: playlistContentProvider.contantList?[index].id
                            .toString() ??
                        "",
                  );
                },
              ),
            );
          }
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
                    imagePath: playlistContentProvider
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
                        text: playlistContentProvider.contantList?[index].title
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
                        text: playlistContentProvider
                                .contantList?[index].channelName
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
                            playlistContentProvider
                                    .contantList?[index].createdAt
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
              if (playlistContentProvider.position == index &&
                  playlistContentProvider.deletecontentPlaylistLoading)
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
                    await playlistContentProvider.addremoveContentToPlaylist(
                        index,
                        Constant.channelID,
                        widget.playlistId,
                        playlistContentProvider.contantList?[index].contentType
                                .toString() ??
                            "",
                        playlistContentProvider.contantList?[index].id
                                .toString() ??
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
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
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
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
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
                  imagePath: playlistContentProvider
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
                      color: colorAccent,
                      multilanguage: false,
                      text: playlistContentProvider.contantList?[index].title
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
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
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
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
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
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
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
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
                    "",
            podcastimage: playlistContentProvider
                    .contantList?[index].portraitImg
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
                  imagePath: playlistContentProvider
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
                      color: colorAccent,
                      multilanguage: false,
                      text: playlistContentProvider.contantList?[index].title
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
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
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
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
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

/* Select Podcast Item */
  Widget buildRadio() {
    if (playlistContentProvider.getPlaylistContentModel.status == 200 &&
        playlistContentProvider.contantList != null) {
      if ((playlistContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: playlistContentProvider.contantList?.length ?? 0,
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
            playingType: playlistContentProvider.contantList?[index].contentType
                    .toString() ??
                "",
            contentList: playlistContentProvider.contantList,
            contentUserid:
                playlistContentProvider.contantList?[index].userId.toString() ??
                    "",
            episodeid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            contentid:
                playlistContentProvider.contantList?[index].id.toString() ?? "",
            position: index,
            contentName:
                playlistContentProvider.contantList?[index].title.toString() ??
                    "",
            podcastimage: playlistContentProvider
                    .contantList?[index].portraitImg
                    .toString() ??
                "",
            playlistImages: [],
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
                  imagePath: playlistContentProvider
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
                      color: colorAccent,
                      multilanguage: false,
                      text: playlistContentProvider.contantList?[index].title
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
                          playlistContentProvider
                                  .contantList?[index].createdAt ??
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
            if (playlistContentProvider.position == index &&
                playlistContentProvider.deletecontentPlaylistLoading)
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
                  await playlistContentProvider.addremoveContentToPlaylist(
                      index,
                      Constant.channelID,
                      widget.playlistId,
                      playlistContentProvider.contantList?[index].contentType
                              .toString() ??
                          "",
                      playlistContentProvider.contantList?[index].id
                              .toString() ??
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
              ),
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

  /* Open Pages */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic contentList,
    dynamic playlistImages,
    required String contentName,
    String? isBuy,
  }) async {
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
      debugPrint("Enter===>");
      /* Play Music */
      if (playingType == "2") {
        musicManager.setInitialMusic(position, playingType, contentList,
            contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      } else if (playingType == "4") {
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
          isBuy ?? "",
          "podcast",
        );
      } else if (playingType == "6") {
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
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
