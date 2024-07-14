import 'package:maring/pages/contentdetail.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/pages/musicdetails.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/provider/seeallprovider.dart';
import 'package:maring/subscription/allpayment.dart';
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
import '../model/sectiondetailmodel.dart';

class SeeAll extends StatefulWidget {
  final String? title, contentType, sectionId;
  final bool isRent;
  const SeeAll({
    super.key,
    required this.title,
    required this.isRent,
    this.contentType,
    required this.sectionId,
  });

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  final MusicManager musicManager = MusicManager();
  late SeeAllProvider seeAllProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    seeAllProvider = Provider.of<SeeAllProvider>(context, listen: false);
    if (widget.isRent == false) {
      _sectionDetailMusic(0);
    } else {
      _rentDetailVideo(0);
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      await seeAllProvider.setSeeAllLoadMore(true);
      if (widget.isRent == false) {
        if ((seeAllProvider.sectiondatacurrentPage ?? 0) <
            (seeAllProvider.sectiondatatotalPage ?? 0)) {
          debugPrint("load more Music====>");
          _sectionDetailMusic(seeAllProvider.sectiondatacurrentPage ?? 0);
        }
      } else {
        if ((seeAllProvider.rentcurrentPage ?? 0) <
            (seeAllProvider.renttotalPage ?? 0)) {
          debugPrint("load more Rent Video====>");
          _rentDetailVideo(seeAllProvider.sectiondatacurrentPage ?? 0);
        }
      }
    }
  }

  Future<void> _sectionDetailMusic(int? nextPage) async {
    debugPrint("isMorePage  ======> ${seeAllProvider.sectiondataisMorePage}");
    debugPrint("currentPage ======> ${seeAllProvider.sectiondatacurrentPage}");
    debugPrint("totalPage   ======> ${seeAllProvider.sectiondatatotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await seeAllProvider.getSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);
  }

  Future<void> _rentDetailVideo(int? nextPage) async {
    debugPrint("isMorePage  ======> ${seeAllProvider.rentisMorePage}");
    debugPrint("currentPage ======> ${seeAllProvider.rentcurrentPage}");
    debugPrint("totalPage   ======> ${seeAllProvider.renttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await seeAllProvider.getRentSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    seeAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils()
                .otherPageAppBar(context, widget.title.toString(), false),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: widget.isRent == false ? buildItem() : buildRentItem(),
            ),
          ),
        ),
        Utils.buildMusicPanel(context),
      ],
    );
  }

  Widget buildItem() {
    debugPrint("contenttype===>${widget.contentType}");
    return Consumer<SeeAllProvider>(
        builder: (context, sectiondataprovider, child) {
      if (sectiondataprovider.loading && !sectiondataprovider.seeallLoadMore) {
        return buildShimmer();
      } else {
        if (sectiondataprovider.sectionListModel.status == 200 &&
            sectiondataprovider.sectionDataList != null) {
          if ((sectiondataprovider.sectionDataList?.length ?? 0) > 0) {
            return Column(
              children: [
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: ResponsiveGridList(
                      minItemWidth: 120,
                      minItemsPerRow: setListCount(),
                      maxItemsPerRow: setListCount(),
                      horizontalGridSpacing: 10,
                      verticalGridSpacing: 25,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                      children: List.generate(
                          sectiondataprovider.sectionDataList?.length ?? 0,
                          (index) {
                        return setLayout(
                            index, sectiondataprovider.sectionDataList);
                      }),
                    ),
                  ),
                ),
                if (seeAllProvider.seeallLoadMore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        } else {
          return const NoData(title: "", subTitle: "");
        }
      }
    });
  }

/* ContentType = 1 = Music */
/* ContentType = 2 = Podcast */
/* ContentType = 3 = Radio */
/* ContentType = 4 = Playlist */

  Widget setLayout(index, sectionDataList) {
    if (widget.contentType == "1") {
      return buildMusic(index, sectionDataList);
    } else if (widget.contentType == "2") {
      return buildPodcast(index, sectionDataList);
    } else if (widget.contentType == "3") {
      return buildRadio(index, sectionDataList);
    } else if (widget.contentType == "4") {
      return buildPlaylist(index, sectionDataList);
    } else {
      /* Rent Video SeeAll  */
      return const SizedBox.shrink();
    }
  }

  int setListCount() {
    if (widget.contentType == "1") {
      return 1;
    } else if (widget.contentType == "2") {
      return 2;
    } else if (widget.contentType == "3") {
      return 3;
    } else if (widget.contentType == "4") {
      return 2;
    } else {
      return 0;
    }
  }

/* Music Layout */
  Widget buildMusic(int index, List<Result>? sectionDataList) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType: sectionDataList?[index].contentType.toString() ?? "",
          episodeid: sectionDataList?[index].id.toString() ?? "",
          contentid: sectionDataList?[index].id.toString() ?? "",
          position: index,
          sectionBannerList: sectionDataList ?? [],
          contentName: sectionDataList?[index].title.toString() ?? "",
          isBuy: sectionDataList?[index].isBuy.toString() ?? "",
        );
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
                  imagePath:
                      sectionDataList?[index].portraitImg.toString() ?? ""),
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
                      text: sectionDataList?[index].title.toString() ?? "",
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
                      text:
                          sectionDataList?[index].description.toString() ?? "",
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
  }

/* Radio Layout */
  Widget buildRadio(int index, List<Result>? sectionDataList) {
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
          playAudio(
            playingType: sectionDataList?[index].contentType.toString() ?? "",
            podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
            episodeid: sectionDataList?[index].id.toString() ?? "",
            contentid: sectionDataList?[index].id.toString() ?? "",
            position: index,
            contentUserid: sectionDataList?[index].userId.toString() ?? "",
            sectionBannerList: sectionDataList ?? [],
            contentName: sectionDataList?[index].title.toString() ?? "",
            playlistImages: [],
            isBuy: sectionDataList?[index].isBuy.toString() ?? "",
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: MyNetworkImage(
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                imagePath: sectionDataList?[index].portraitImg.toString() ?? "",
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 100,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsize: Dimens.textSmall,
                  inter: false,
                  multilanguage: false,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }

/* Podcast Layout */
  Widget buildPodcast(int index, List<Result>? sectionDataList) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType: sectionDataList?[index].contentType.toString() ?? "",
          podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
          episodeid: sectionDataList?[index].id.toString() ?? "",
          contentid: sectionDataList?[index].id.toString() ?? "",
          position: index,
          contentUserid: sectionDataList?[index].userId.toString() ?? "",
          sectionBannerList: sectionDataList ?? [],
          contentName: sectionDataList?[index].title.toString() ?? "",
          playlistImages: [],
          isBuy: sectionDataList?[index].isBuy.toString() ?? "",
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: 100,
                fit: BoxFit.cover,
                imagePath: sectionDataList?[index].portraitImg ?? "",
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title ?? "",
                  textalign: TextAlign.center,
                  fontsize: Dimens.textSmall,
                  inter: false,
                  multilanguage: false,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }

/* Playlist Layout */
  Widget buildPlaylist(int index, List<Result>? sectionDataList) {
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
          playAudio(
            playingType: sectionDataList?[index].contentType.toString() ?? "",
            podcastimage: sectionDataList?[index].portraitImg.toString() ?? "",
            episodeid: sectionDataList?[index].id.toString() ?? "",
            contentid: sectionDataList?[index].id.toString() ?? "",
            position: index,
            contentUserid: sectionDataList?[index].userId.toString() ?? "",
            sectionBannerList: sectionDataList ?? [],
            contentName: sectionDataList?[index].title.toString() ?? "",
            playlistImages: sectionDataList?[index].playlistImage ?? [],
            isBuy: sectionDataList?[index].isBuy.toString() ?? "",
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            playlistImages(index, sectionDataList),
            const SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: MyText(
                  color: white,
                  text: sectionDataList?[index].title.toString() ?? "",
                  textalign: TextAlign.left,
                  fontsize: Dimens.textMedium,
                  inter: false,
                  multilanguage: false,
                  maxline: 1,
                  fontwaight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                      color: gray,
                      text: Utils.kmbGenerator(int.parse(
                          sectionDataList?[index].totalView.toString() ?? "")),
                      textalign: TextAlign.left,
                      fontsize: Dimens.textMedium,
                      inter: false,
                      multilanguage: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(width: 5),
                  MyText(
                      color: gray,
                      text: "views",
                      textalign: TextAlign.left,
                      fontsize: Dimens.textMedium,
                      inter: false,
                      multilanguage: true,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playlistImages(index, List<Result>? sectionDataList) {
    if ((sectionDataList?[index].playlistImage?.length ?? 0) == 4) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
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
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[2]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[3]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 3) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  imagePath:
                      sectionDataList?[index].playlistImage?[2].toString() ??
                          "",
                ),
              ),
            ],
          ));
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 2) {
      return SizedBox(
          width: 160,
          height: 150,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[0]
                                .toString() ??
                            "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: sectionDataList?[index]
                                .playlistImage?[1]
                                .toString() ??
                            "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionDataList?[index].playlistImage?.length ?? 0) == 1) {
      return SizedBox(
          width: 160,
          height: 150,
          child: MyNetworkImage(
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            imagePath:
                sectionDataList?[index].playlistImage?[0].toString() ?? "",
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

/* Rent Video Layout */
  Widget buildRentItem() {
    return Consumer<SeeAllProvider>(
        builder: (context, sectiondataprovider, child) {
      if (sectiondataprovider.loading && !sectiondataprovider.seeallLoadMore) {
        return buildRentItemShimmer();
      } else {
        if (sectiondataprovider.rentSectionDetailModel.status == 200 &&
            sectiondataprovider.rentVideoList != null) {
          if ((sectiondataprovider.rentVideoList?.length ?? 0) > 0) {
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: ResponsiveGridList(
                  minItemWidth: 120,
                  minItemsPerRow: 2,
                  maxItemsPerRow: 2,
                  horizontalGridSpacing: 10,
                  verticalGridSpacing: 25,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                  ),
                  children: List.generate(
                    sectiondataprovider.rentVideoList?.length ?? 0,
                    (index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(4),
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
                          } else if (sectiondataprovider
                                  .rentVideoList?[index].isRentBuy ==
                              0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AllPayment(
                                    currency: Constant.currencySymbol,
                                    itemId: sectiondataprovider
                                            .rentVideoList?[index].id
                                            .toString() ??
                                        "",
                                    itemTitle: sectiondataprovider
                                            .rentVideoList?[index].title
                                            .toString() ??
                                        "",
                                    payType: "",
                                    price: sectiondataprovider
                                            .rentVideoList?[index].rentPrice
                                            .toString() ??
                                        "",
                                    productPackage: "",
                                    typeId: "",
                                    videoType: "",
                                  );
                                },
                              ),
                            );
                            /* Payment Option Page Ridirect */
                          } else {
                            audioPlayer.pause();
                            Utils.openPlayer(
                              iscontinueWatching: false,
                              stoptime: "",
                              context: context,
                              videoId: sectiondataprovider
                                      .rentVideoList?[index].id
                                      .toString() ??
                                  "",
                              videoUrl: sectiondataprovider
                                      .rentVideoList?[index].content
                                      .toString() ??
                                  "",
                              vUploadType: sectiondataprovider
                                      .rentVideoList?[index].contentUploadType
                                      .toString() ??
                                  "",
                              videoThumb: sectiondataprovider
                                      .rentVideoList?[index].landscapeImg
                                      .toString() ??
                                  "",
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 170,
                                height: 105,
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: MyNetworkImage(
                                        imagePath: sectiondataprovider
                                                .rentVideoList?[index]
                                                .portraitImg
                                                .toString() ??
                                            "",
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 4, 10, 4),
                                        decoration: BoxDecoration(
                                          color: colorAccent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: MyText(
                                            color: white,
                                            text:
                                                "${Constant.currencySymbol} ${sectiondataprovider.rentVideoList?[index].rentPrice.toString() ?? ""}",
                                            textalign: TextAlign.left,
                                            fontsize: Dimens.textMedium,
                                            multilanguage: false,
                                            inter: false,
                                            maxline: 2,
                                            fontwaight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 160,
                                child: MyText(
                                    color: white,
                                    text: sectiondataprovider
                                            .rentVideoList?[index].title
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
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        } else {
          return const NoData(title: "", subTitle: "");
        }
      }
    });
  }

  Widget buildRentItemShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(
            10,
            (index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      width: 170,
                      height: 105,
                    ),
                    CustomWidget.roundrectborder(
                      width: 170,
                      height: 5,
                    ),
                    CustomWidget.roundrectborder(
                      width: 170,
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

/* All Shimmer */
  Widget buildShimmer() {
    return Column(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: setListCount(),
              maxItemsPerRow: setListCount(),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(10, (index) {
                return setShimmer();
              }),
            ),
          ),
        ),
        if (seeAllProvider.seeallLoadMore)
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

  setShimmer() {
    if (widget.contentType == "1") {
      return buildMusicShimmer();
    } else if (widget.contentType == "2") {
      return buildPodcastShimmer();
    } else if (widget.contentType == "3") {
      return buildRadioShimmer();
    } else if (widget.contentType == "4") {
      return buildPlaylistShimmer();
    } else {
      return Utils.pageLoader(context);
    }
  }

  Widget buildMusicShimmer() {
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
                  width: 200,
                  height: 8,
                ),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioShimmer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomWidget.circular(
            width: 90,
            height: 90,
          ),
          SizedBox(height: 10),
          CustomWidget.roundrectborder(
            width: 80,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPodcastShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomWidget.roundrectborder(
            width: MediaQuery.of(context).size.width,
            height: 100,
          ),
          const SizedBox(height: 10),
          const CustomWidget.roundrectborder(
            width: 100,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPlaylistShimmer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomWidget.rectangular(height: 150, width: 160),
          SizedBox(height: 10),
          CustomWidget.roundrectborder(height: 8, width: 140),
        ],
      ),
    );
  }

/* Open Pages */
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
      if (widget.contentType == "1") {
        musicManager.setInitialMusic(position, playingType, sectionBannerList,
            contentid, addView(playingType, contentid), false, 0, isBuy ?? "");
      } else if (widget.contentType == "2") {
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
      } else if (widget.contentType == "3") {
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
      } else if (widget.contentType == "4") {
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
