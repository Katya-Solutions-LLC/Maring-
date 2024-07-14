import 'package:maring/pages/allcontent.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/pages/playlistcontent.dart';
import 'package:maring/provider/playlistprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class MyPlayList extends StatefulWidget {
  const MyPlayList({super.key});

  @override
  State<MyPlayList> createState() => _MyPlayListState();
}

class _MyPlayListState extends State<MyPlayList> {
  late PlaylistProvider playlistProvider;
  final playlistTitleController = TextEditingController();
  late ScrollController _scrollController;
  bool isPublic = false;
  bool isPrivate = false;

  @override
  void initState() {
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchData(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (playlistProvider.currentPage ?? 0) <
            (playlistProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      await playlistProvider.setLoadMore(true);
      _fetchData(playlistProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${playlistProvider.isMorePage}");
    debugPrint("totalPage   ======> ${playlistProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await playlistProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    playlistProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils().otherPageAppBar(context, "myplaylist", true),
            body: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 35),
              child: Column(
                children: [buildPlaylist(), createPlayListButton()],
              ),
            ),
          ),
        ),
         Utils.showBannerAd(context),
      ],
    );
  }

  Widget buildPlaylist() {
    return Consumer<PlaylistProvider>(
        builder: (context, playlistprovider, child) {
      if (playlistprovider.loading && !playlistprovider.loadMore) {
        return playListShimmer();
      } else {
        return Column(
          children: [
            playList(),
            if (playlistProvider.loadMore)
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

  Widget playList() {
    return Consumer<PlaylistProvider>(
        builder: (context, playlistprovider, child) {
      if (playlistprovider.getContentbyChannelModel.status == 200 &&
          playlistprovider.playListData != null) {
        if ((playlistprovider.playListData?.length ?? 0) > 0) {
          return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                  minItemWidth: 120,
                  minItemsPerRow: 2,
                  maxItemsPerRow: 2,
                  horizontalGridSpacing: 35,
                  verticalGridSpacing: 35,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: List.generate(
                    playlistProvider.playListData?.length ?? 0,
                    (index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PlaylistContent(
                                  playlistId: playlistProvider
                                          .playListData?[index].id
                                          .toString() ??
                                      "",
                                  title: playlistProvider
                                          .playListData?[index].title
                                          .toString() ??
                                      "",
                                );
                              },
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                              color: colorPrimaryDark,
                              alignment: Alignment.center,
                              child: ((playlistprovider.playListData?[index]
                                              .playlistImage?.length ??
                                          0) >
                                      0)
                                  ? playlistImage(playlistprovider
                                      .playListData?[index].playlistImage)
                                  : MyImage(
                                      width: 35,
                                      height: 35,
                                      imagePath: "ic_music.png"),
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyText(
                                      color: white,
                                      text: playlistProvider
                                              .playListData?[index].title
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsize: Dimens.textTitle,
                                      multilanguage: false,
                                      inter: false,
                                      maxline: 2,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
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
                                              playlistDilog(
                                                isEditPlaylist: true,
                                                playlistId: playlistProvider
                                                        .playListData?[index].id
                                                        .toString() ??
                                                    "",
                                              );
                                              playlistTitleController.text =
                                                  playlistProvider
                                                          .playListData?[index]
                                                          .title
                                                          .toString() ??
                                                      "";

                                              playlistProvider.selectPrivacy(
                                                  type: int.parse(
                                                      playlistProvider
                                                              .playListData?[
                                                                  index]
                                                              .playlistType
                                                              .toString() ??
                                                          ""));
                                            }
                                          },
                                          child: MyImage(
                                              width: 18,
                                              height: 18,
                                              imagePath: "ic_edit.png")),
                                      const SizedBox(width: 10),
                                      Consumer<PlaylistProvider>(builder:
                                          (context, deleteplaylistprovider,
                                              child) {
                                        if (deleteplaylistprovider.position ==
                                                index &&
                                            deleteplaylistprovider
                                                .deletePlaylistloading) {
                                          return const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: colorAccent,
                                              strokeWidth: 1,
                                            ),
                                          );
                                        } else {
                                          return InkWell(
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
                                                  await playlistProvider
                                                      .getDeletePlayList(
                                                          index,
                                                          playlistProvider
                                                                  .playListData?[
                                                                      index]
                                                                  .id
                                                                  .toString() ??
                                                              "");
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: MyImage(
                                                    width: 18,
                                                    height: 18,
                                                    imagePath: "ic_delete.png"),
                                              ));
                                        }
                                      }),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return AllContent(
                                                  playlistId: playlistProvider
                                                          .playListData?[index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 3, 10, 3),
                                          decoration: BoxDecoration(
                                              color: colorAccent,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: MyText(
                                              color: white,
                                              text: "Add",
                                              textalign: TextAlign.left,
                                              fontsize: Dimens.textDesc,
                                              multilanguage: false,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                        ),
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
                  )));
        } else {
          return const NoData(
              title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
        }
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    });
  }

  Widget playListShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 0,
        verticalGridSpacing: 25,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          10,
          (index) {
            return const Row(
              children: [
                CustomWidget.rectangular(
                  width: 160,
                  height: 100,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 8,
                      ),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 8,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomWidget.circular(
                            width: 15,
                            height: 15,
                          ),
                          SizedBox(width: 10),
                          CustomWidget.circular(
                            width: 15,
                            height: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget createPlayListButton() {
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
          playlistDilog(isEditPlaylist: false);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
        margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
            color: white,
            text: "Create PlayList",
            textalign: TextAlign.left,
            fontsize: Dimens.textBig,
            multilanguage: false,
            inter: false,
            maxline: 2,
            fontwaight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  playlistDilog({required bool isEditPlaylist, playlistId}) {
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
            child: Consumer<PlaylistProvider>(
                builder: (context, playlistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: isEditPlaylist == true
                          ? "editplaylist"
                          : "newplaylist",
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
                      hintText: isEditPlaylist == true
                          ? "Change your playlist a title"
                          : "Give your playlist a title",
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
                          playlistprovider.selectPrivacy(type: 1);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: playlistprovider.isType == 1
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: playlistprovider.isType == 1
                                    ? colorAccent
                                    : white),
                          ),
                          child: playlistprovider.isType == 1
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
                          multilanguage: false,
                          text: "Public",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          playlistprovider.selectPrivacy(type: 2);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: playlistprovider.isType == 2
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: playlistprovider.isType == 2
                                    ? colorAccent
                                    : white),
                          ),
                          child: playlistprovider.isType == 2
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
                          multilanguage: false,
                          text: "Private",
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
                          playlistProvider.isType = 0;
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
                          } else if (playlistprovider.isType == 0) {
                            Utils.showSnackbar(
                                context, "pleaseselectplaylisttype");
                          } else {
                            if (isEditPlaylist == true) {
                              await playlistprovider.getEditPlayList(
                                  playlistId,
                                  playlistTitleController.text,
                                  playlistProvider.isType.toString());

                              if (!playlistprovider.loading) {
                                if (playlistprovider.editPlaylistModel.status ==
                                    200) {
                                  if (!mounted) return;
                                  Utils.showSnackbar(
                                      context, "playlisteditsuccsessfully");
                                } else {
                                  if (!mounted) return;
                                  Utils.showSnackbar(context,
                                      "${playlistprovider.editPlaylistModel.message}");
                                }
                              }
                            } else {
                              await playlistprovider.getcreatePlayList(
                                Constant.channelID,
                                playlistTitleController.text,
                                playlistProvider.isType.toString(),
                              );
                              if (!playlistprovider.loading) {
                                if (playlistprovider.successModel.status ==
                                    200) {
                                  if (!mounted) return;
                                  Utils.showSnackbar(
                                      context, "playlistcreatesuccsessfully");
                                } else {
                                  if (!mounted) return;
                                  Utils.showSnackbar(context,
                                      "${playlistprovider.successModel.message}");
                                }
                              }
                            }
                            if (!mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            playlistProvider.isType = 0;
                            _fetchData(0);
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
                              text: isEditPlaylist == true ? "edit" : "create",
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

  Widget playlistImage(playlistImage) {
    return MyNetworkImage(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
      imagePath: playlistImage[0],
    );
  }
}
