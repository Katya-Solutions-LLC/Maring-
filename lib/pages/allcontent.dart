import 'dart:developer';
import 'package:maring/provider/allcontentprovider.dart';
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

class AllContent extends StatefulWidget {
  final String playlistId;
  const AllContent({super.key, required this.playlistId});

  @override
  State<AllContent> createState() => _AllContentState();
}

class _AllContentState extends State<AllContent> {
  late ScrollController _scrollController;
  late AllContentProvider allContentProvider;

  @override
  void initState() {
    allContentProvider =
        Provider.of<AllContentProvider>(context, listen: false);
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
        (allContentProvider.currentPage ?? 0) <
            (allContentProvider.totalPage ?? 0)) {
      await allContentProvider.setLoadMore(true);
      if (allContentProvider.tabindex == 0) {
        _fetchData("1", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 1) {
        _fetchData("2", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 2) {
        _fetchData("4", allContentProvider.currentPage ?? 0);
      } else if (allContentProvider.tabindex == 3) {
        _fetchData("6", allContentProvider.currentPage ?? 0);
      } else {
        if (!mounted) return;
        Utils.showSnackbar(context, "somethingwentwronge");
      }
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    debugPrint("isMorePage  ======> ${allContentProvider.isMorePage}");
    debugPrint("currentPage ======> ${allContentProvider.currentPage}");
    debugPrint("totalPage   ======> ${allContentProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await allContentProvider.getContentByPlaylist(
        contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    allContentProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "addvideo", true),
      floatingActionButton: Consumer<AllContentProvider>(
          builder: (context, allcontentprovider, child) {
        return FloatingActionButton.extended(
          onPressed: () async {
            String contentIds = allContentProvider.storeContentId.join(",");

            log("videoIds===> $contentIds");

            if (allcontentprovider.tabindex == 0) {
              if (contentIds.isEmpty) {
                Utils.showSnackbar(context, "pleaseselectvideo");
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "1");
              }
            } else if (allcontentprovider.tabindex == 1) {
              if (contentIds.isEmpty) {
                Utils.showSnackbar(context, "pleaseselectmusic");
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "2");
              }
            } else if (allcontentprovider.tabindex == 2) {
              if (contentIds.isEmpty) {
                Utils.showSnackbar(context, "pleaseselectpodcast");
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "4");
              }
            } else if (allcontentprovider.tabindex == 3) {
              if (contentIds.isEmpty) {
                Utils.showSnackbar(context, "pleaseselectradio");
              } else {
                addMultipleItemToPlaylist(
                    allContentId: contentIds, contentType: "6");
              }
            } else {
              Utils.showSnackbar(context, "somethingwentwronge");
            }
          },
          focusColor: colorAccent,
          backgroundColor: colorAccent,
          elevation: 1,
          label: Row(
            children: [
              const Icon(Icons.add),
              MyText(
                  color: white,
                  text:
                      flotingButtonTitle(tabindex: allcontentprovider.tabindex),
                  textalign: TextAlign.left,
                  fontsize: Dimens.textTitle,
                  multilanguage: false,
                  inter: false,
                  maxline: 2,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
        );
      }),
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
    );
  }

/* Tab  */

  tabButton() {
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
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
                  await allcontentprovider.chageTab(index);
                  await allcontentprovider.clearTab();
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
                      color: allcontentprovider.tabindex == index
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
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      if (allcontentprovider.loading && !allcontentprovider.loadMore) {
        return buildShimmer();
      } else {
        return Column(
          children: [
            buildLayout(),
            if (allcontentprovider.loadMore)
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
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      if (allcontentprovider.tabindex == 0) {
        return buildVideo();
      } else if (allcontentprovider.tabindex == 1) {
        return buildMusic();
      } else if (allcontentprovider.tabindex == 2) {
        return buildPodcast();
      } else if (allcontentprovider.tabindex == 3) {
        return buildRadio();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  buildShimmer() {
    return Consumer<AllContentProvider>(
        builder: (context, allcontentprovider, child) {
      if (allcontentprovider.tabindex == 0) {
        return buildVideoShimmer();
      } else if (allcontentprovider.tabindex == 1) {
        return buildMusicShimmer();
      } else if (allcontentprovider.tabindex == 2) {
        return buildPodcastShimmer();
      } else if (allcontentprovider.tabindex == 3) {
        return buildRadioShimmer();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

/* Select Video Item */
  Widget buildVideo() {
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
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
                    imagePath: allContentProvider
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
                        text: allContentProvider.contantList?[index].title
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
                        text: allContentProvider.contantList?[index].channelName
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
                            allContentProvider.contantList?[index].createdAt
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
              const SizedBox(width: 18),
              if (allContentProvider.selectContentItemIndex.contains(index))
                MyImage(width: 20, height: 20, imagePath: "true.png")
              else
                const SizedBox.shrink(),
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
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
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
                  imagePath: allContentProvider.contantList?[index].portraitImg
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
                      text: allContentProvider.contantList?[index].title
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
                          allContentProvider.contantList?[index].createdAt ??
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
            const SizedBox(width: 18),
            if (allContentProvider.selectContentItemIndex.contains(index))
              MyImage(width: 20, height: 20, imagePath: "true.png")
            else
              const SizedBox.shrink(),
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
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
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
                  imagePath: allContentProvider.contantList?[index].portraitImg
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
                      text: allContentProvider.contantList?[index].title
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
                          allContentProvider.contantList?[index].createdAt ??
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
            const SizedBox(width: 18),
            if (allContentProvider.selectContentItemIndex.contains(index))
              MyImage(width: 20, height: 20, imagePath: "true.png")
            else
              const SizedBox.shrink(),
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
    if (allContentProvider.getContentByPlaylistModel.status == 200 &&
        allContentProvider.contantList != null) {
      if ((allContentProvider.contantList?.length ?? 0) > 0) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            itemCount: allContentProvider.contantList?.length ?? 0,
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
        if (allContentProvider.selectContentItemIndex.contains(index)) {
          allContentProvider.removeItemContent(
              index,
              allContentProvider.contantList?[index].id.toString() ?? "",
              false);
        } else {
          allContentProvider.addItemContent(index,
              allContentProvider.contantList?[index].id.toString() ?? "", true);
        }
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
                  imagePath: allContentProvider.contantList?[index].portraitImg
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
                      text: allContentProvider.contantList?[index].title
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
                          allContentProvider.contantList?[index].createdAt ??
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
            const SizedBox(width: 18),
            if (allContentProvider.selectContentItemIndex.contains(index))
              MyImage(width: 20, height: 20, imagePath: "true.png")
            else
              const SizedBox.shrink(),
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

  String flotingButtonTitle({required tabindex}) {
    if (tabindex == 0) {
      return "Add Video";
    } else if (tabindex == 1) {
      return "Add Music";
    } else if (tabindex == 2) {
      return "Add Podcast";
    } else if (tabindex == 3) {
      return "Add Radio";
    } else {
      return "Add";
    }
  }

  addMultipleItemToPlaylist(
      {required contentType, required allContentId}) async {
    await allContentProvider.addMultipleContentToPlaylist(
        widget.playlistId, contentType, allContentId);

    if (!allContentProvider.loading) {
      if (allContentProvider.addMultipleContentModel.status == 200) {
        if (!mounted) return;
        Utils.showSnackbar(context, "contentaddsuccsessfully");
        allContentProvider.clearAllSelectedContent();
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
            context, "${allContentProvider.addMultipleContentModel.message}");
      }
    }
  }
}
