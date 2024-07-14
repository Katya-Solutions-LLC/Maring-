import 'dart:developer';
import 'dart:io';

import 'package:maring/pages/login.dart';
import 'package:maring/provider/getmusicbycategoryprovider.dart';
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

class GetMusicByCategory extends StatefulWidget {
  final String categoryId, title;
  const GetMusicByCategory({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<GetMusicByCategory> createState() => _GetMusicByCategoryState();
}

class _GetMusicByCategoryState extends State<GetMusicByCategory> {
  final MusicManager musicManager = MusicManager();
  late GetMusicByCategoryProvider getMusicByCategoryProvider;
  late ScrollController _scrollController;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();

  @override
  void initState() {
    getMusicByCategoryProvider =
        Provider.of<GetMusicByCategoryProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
  }

  /* Category All Music Pagination */
  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (getMusicByCategoryProvider.currentPage ?? 0) <
            (getMusicByCategoryProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      getMusicByCategoryProvider.setLoadMore(true);
      _fetchData(getMusicByCategoryProvider.currentPage ?? 0);
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (getMusicByCategoryProvider.playlistcurrentPage ?? 0) <
            (getMusicByCategoryProvider.playlisttotalPage ?? 0)) {
      await getMusicByCategoryProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(getMusicByCategoryProvider.playlistcurrentPage ?? 0);
    }
  }

  /* Get All Category Music Api */
  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${getMusicByCategoryProvider.isMorePage}");
    debugPrint("currentPage ======> ${getMusicByCategoryProvider.currentPage}");
    debugPrint("totalPage   ======> ${getMusicByCategoryProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await getMusicByCategoryProvider.getMusicbyCategory(
        widget.categoryId, (nextPage ?? 0) + 1);
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    debugPrint(
        "playlistmorePage  =======> ${getMusicByCategoryProvider.playlistmorePage}");
    debugPrint(
        "playlistcurrentPage =======> ${getMusicByCategoryProvider.playlistcurrentPage}");
    debugPrint(
        "playlisttotalPage   =======> ${getMusicByCategoryProvider.playlisttotalPage}");
    debugPrint("nextPage   ========> $nextPage");
    await getMusicByCategoryProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    debugPrint(
        "fetchPlaylist length ==> ${getMusicByCategoryProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    getMusicByCategoryProvider.clearProvider();
    super.dispose();
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
              child: buildPage(),
            ),
          ),
        ),
        Utils.buildMusicPanel(context),
      ],
    );
  }

  Widget buildPage() {
    return Consumer<GetMusicByCategoryProvider>(
        builder: (context, getmusicbycategoryprovider, child) {
      if (getmusicbycategoryprovider.loading &&
          !getmusicbycategoryprovider.loadMore) {
        return musicListShimmer();
      } else {
        return Column(
          children: [
            musicList(),
            if (getMusicByCategoryProvider.loadMore)
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

  Widget musicList() {
    return Consumer<GetMusicByCategoryProvider>(
        builder: (context, getmusicbycategoryprovider, child) {
      if (getmusicbycategoryprovider.getMusicByCategoryModel.status == 200 &&
          getmusicbycategoryprovider.musicList != null) {
        if ((getmusicbycategoryprovider.musicList?.length ?? 0) > 0) {
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 25,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    getmusicbycategoryprovider.musicList?.length ?? 0, (index) {
                  return InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () {
                        playAudio(
                            getmusicbycategoryprovider
                                    .musicList?[index].contentType
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            index,
                            getmusicbycategoryprovider.musicList,
                            getmusicbycategoryprovider.musicList?[index].title
                                    .toString() ??
                                "",
                            getmusicbycategoryprovider.musicList?[index].isBuy
                                    .toString() ??
                                "");
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: 55,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                                imagePath: getmusicbycategoryprovider
                                        .musicList?[index].portraitImg
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
                                    text: getmusicbycategoryprovider
                                            .musicList?[index].title
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
                                    text: getmusicbycategoryprovider
                                            .musicList?[index].description
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
                                moreBottomSheet(
                                  getmusicbycategoryprovider
                                          .musicList?[index].userId
                                          .toString() ??
                                      "",
                                  getmusicbycategoryprovider
                                          .musicList?[index].id
                                          .toString() ??
                                      "",
                                  index,
                                  getmusicbycategoryprovider
                                          .musicList?[index].title
                                          .toString() ??
                                      "",
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
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
                }),
              ),
            ),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget musicListShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 55,
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
          }),
        ),
      ),
    );
  }

  moreBottomSheet(reportUserid, contentid, position, contentName) {
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
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  moreFunctionItem("ic_watchlater.png", "savetowatchlater",
                      () async {
                    await getMusicByCategoryProvider.addremoveWatchLater(
                        "2", contentid, "0", "1");
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Utils.showSnackbar(context, "savetowatchlater");
                  }),
                  moreFunctionItem("ic_playlisttitle.png", "savetoplaylist",
                      () async {
                    Navigator.pop(context);
                    selectPlaylistBottomSheet(position, contentid);
                    await getMusicByCategoryProvider.getcontentbyChannel(
                        Constant.userID, Constant.channelID, "5", "1");
                  }),
                  moreFunctionItem("ic_share.png", "share", () {
                    Navigator.pop(context);
                    Utils.shareApp(Platform.isIOS
                        ? "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                        : "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MyText(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsize: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
        inter: true,
      ),
      leading: MyImage(
        width: 20,
        height: 20,
        imagePath: icon,
        color: white,
      ),
      onTap: onTap,
    );
  }

  /* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(position, contentid) {
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
                              playlistId:
                                  getMusicByCategoryProvider.playlistId);
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
                Consumer<GetMusicByCategoryProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (getMusicByCategoryProvider
                                .getContentbyChannelModel.status ==
                            200 &&
                        getMusicByCategoryProvider.playlistData != null) {
                      if ((getMusicByCategoryProvider.playlistData?.length ??
                              0) >
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
                                if (getMusicByCategoryProvider
                                        .playlistId.isEmpty ||
                                    getMusicByCategoryProvider.playlistId ==
                                        "") {
                                  Utils.showSnackbar(
                                      context, "pleaseelectyourplaylist");
                                } else {
                                  await getMusicByCategoryProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          getMusicByCategoryProvider.playlistId,
                                          "3",
                                          contentid,
                                          "0",
                                          "1");

                                  if (!getMusicByCategoryProvider.loading) {
                                    if (getMusicByCategoryProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      debugPrint("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${getMusicByCategoryProvider.addremoveContentToPlaylistModel.message}");
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
    return Consumer<GetMusicByCategoryProvider>(
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
    log("Playlist Lenght==>${getMusicByCategoryProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${getMusicByCategoryProvider.playlistPosition}");
    log("Playlist Id==>${getMusicByCategoryProvider.playlistId}");
    if (getMusicByCategoryProvider.getContentbyChannelModel.status == 200 &&
        getMusicByCategoryProvider.playlistData != null) {
      if ((getMusicByCategoryProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: getMusicByCategoryProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                getMusicByCategoryProvider.selectPlaylist(
                    index,
                    getMusicByCategoryProvider.playlistData?[index].id
                            .toString() ??
                        "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: getMusicByCategoryProvider.playlistPosition == index &&
                        getMusicByCategoryProvider.isSelectPlaylist == true
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
                          text: getMusicByCategoryProvider
                                  .playlistData?[index].title
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
                    getMusicByCategoryProvider.playlistPosition == index &&
                            getMusicByCategoryProvider.isSelectPlaylist == true
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
            child: Consumer<GetMusicByCategoryProvider>(
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
                          fontsize: Dimens.textBig,
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
                          fontsize: Dimens.textDesc,
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
                          getMusicByCategoryProvider.isType = 0;
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
                            await createplaylistprovider.getcreatePlayList(
                              Constant.channelID,
                              playlistTitleController.text,
                              getMusicByCategoryProvider.isType.toString(),
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
                            if (!mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            getMusicByCategoryProvider.isType = 0;
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

  Future<void> playAudio(
    String playingType,
    String episodeid,
    String contentid,
    int position,
    dynamic contentList,
    String contentName,
    String? isBuy,
  ) async {
    /* Play Music */
    musicManager.setInitialMusic(position, playingType, contentList, contentid,
        addView(playingType, contentid), false, 0, isBuy ?? "");
    /* Play Podcast */
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
