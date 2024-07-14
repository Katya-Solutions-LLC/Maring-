import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maring/pages/contentdetail.dart';
import 'package:maring/pages/detail.dart';
import 'package:maring/pages/musicdetails.dart';
import 'package:maring/pages/short.dart';
import 'package:maring/pages/updateprofile.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/nodata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:maring/provider/profileprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/getcontentbychannelmodel.dart';

class Profile extends StatefulWidget {
  final bool isProfile;
  final String channelUserid;
  final String channelid;
  const Profile(
      {super.key,
      required this.isProfile,
      required this.channelUserid,
      required this.channelid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    log("channelUserid===>${widget.channelUserid}");
    log("loginUserid===>${Constant.userID}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    if (widget.isProfile == true) {
      _fetchData(0, "1", Constant.userID, Constant.channelID);
    } else {
      _fetchData(0, "1", widget.channelUserid, widget.channelid);
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    await profileProvider.getprofile(context,
        widget.isProfile == true ? Constant.userID : widget.channelUserid);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (profileProvider.currentPage ?? 0) < (profileProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      profileProvider.setLoadMore(true);
      if (profileProvider.position == 0) {
        getTabData(profileProvider.currentPage ?? 0, "1");
      } else if (profileProvider.position == 1) {
        getTabData(profileProvider.currentPage ?? 0, "4");
      } else if (profileProvider.position == 2) {
        getTabData(profileProvider.currentPage ?? 0, "5");
      } else if (profileProvider.position == 3) {
        getTabData(profileProvider.currentPage ?? 0, "3");
      } else {
        debugPrint("Something Went Wronge!!!");
      }
    }
  }

  getTabData(pageNo, contenttype) {
    if (widget.isProfile == true) {
      _fetchData(pageNo, contenttype, Constant.userID, Constant.channelID);
    } else {
      _fetchData(pageNo, contenttype, widget.channelUserid, widget.channelid);
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    debugPrint("isMorePage  ======> ${profileProvider.isMorePage}");
    debugPrint("currentPage ======> ${profileProvider.currentPage}");
    debugPrint("totalPage   ======> ${profileProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
  }

  Future<void> _fetchRentData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${profileProvider.rentisMorePage}");
    debugPrint("currentPage ======> ${profileProvider.rentcurrentPage}");
    debugPrint("totalPage   ======> ${profileProvider.renttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getUserbyRentContent(
        widget.isProfile == true ? Constant.userID : widget.channelUserid,
        (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    profileProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            body: NestedScrollView(
                controller: _scrollController,
                floatHeaderSlivers: true,
                physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
                scrollDirection: Axis.vertical,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    /* UserProfile Section */
                    SliverAppBar(
                      floating: true,
                      forceElevated: true,
                      snap: true,
                      elevation: 0,
                      expandedHeight: MediaQuery.of(context).size.height * 0.35,
                      automaticallyImplyLeading: false,
                      backgroundColor: colorPrimaryDark,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Consumer<ProfileProvider>(
                            builder: (context, settingProvider, child) {
                          if (settingProvider.profileloading) {
                            return Utils.pageLoader(context);
                          } else {
                            if (settingProvider.profileModel.status == 200 &&
                                settingProvider
                                    .profileModel.result!.isNotEmpty) {
                              return Stack(
                                children: [
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: CachedNetworkImage(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      imageUrl: (settingProvider
                                              .profileModel.result?[0].coverImg
                                              .toString() ??
                                          ""),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 25),
                                    height: MediaQuery.of(context).size.width,
                                    width: MediaQuery.of(context).size.width,
                                    child: SafeArea(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: MyImage(
                                                          width: 25,
                                                          height: 25,
                                                          imagePath:
                                                              "ic_roundback.png"),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    MyText(
                                                        color: white,
                                                        text: "myprofile",
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsize:
                                                            Dimens.textBig,
                                                        multilanguage: true,
                                                        inter: false,
                                                        maxline: 1,
                                                        fontwaight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ],
                                                ),
                                              ),
                                              widget.isProfile == false &&
                                                      widget.channelUserid !=
                                                          Constant.userID
                                                  ? InkWell(
                                                      onTap: () {
                                                        if (widget.isProfile ==
                                                                false &&
                                                            widget.channelUserid !=
                                                                Constant
                                                                    .userID) {
                                                          showMenu(
                                                            context: context,
                                                            position:
                                                                const RelativeRect
                                                                        .fromLTRB(
                                                                    100,
                                                                    100,
                                                                    0,
                                                                    0),
                                                            items: <PopupMenuEntry>[
                                                              PopupMenuItem(
                                                                onTap:
                                                                    () async {
                                                                  await profileProvider.addremoveBlockChannel(
                                                                      "1",
                                                                      settingProvider
                                                                              .profileModel
                                                                              .result?[0]
                                                                              .channelId
                                                                              .toString() ??
                                                                          "");
                                                                },
                                                                value: 'item1',
                                                                child: settingProvider.profileModel.result?[0].isBlock == 0
                                                                    ? MyText(
                                                                        color:
                                                                            colorPrimaryDark,
                                                                        text:
                                                                            "blockuser",
                                                                        textalign:
                                                                            TextAlign
                                                                                .center,
                                                                        fontsize:
                                                                            Dimens
                                                                                .textTitle,
                                                                        multilanguage:
                                                                            true,
                                                                        inter:
                                                                            false,
                                                                        maxline:
                                                                            1,
                                                                        fontwaight:
                                                                            FontWeight
                                                                                .w500,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        fontstyle:
                                                                            FontStyle
                                                                                .normal)
                                                                    : MyText(
                                                                        color:
                                                                            colorPrimaryDark,
                                                                        text:
                                                                            "removeblockuser",
                                                                        textalign:
                                                                            TextAlign
                                                                                .center,
                                                                        fontsize:
                                                                            Dimens
                                                                                .textTitle,
                                                                        multilanguage:
                                                                            true,
                                                                        inter:
                                                                            false,
                                                                        maxline:
                                                                            1,
                                                                        fontwaight:
                                                                            FontWeight
                                                                                .w500,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        fontstyle:
                                                                            FontStyle.normal),
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: MyImage(
                                                            width: 15,
                                                            height: 15,
                                                            imagePath:
                                                                "ic_more.png"),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: colorAccent),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60)),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                      child: MyNetworkImage(
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.fill,
                                                          imagePath: (settingProvider
                                                                          .profileModel
                                                                          .status ==
                                                                      200 &&
                                                                  settingProvider
                                                                          .profileModel
                                                                          .result !=
                                                                      null)
                                                              ? (settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .image
                                                                      .toString() ??
                                                                  "")
                                                              : ""),
                                                    ),
                                                  ),
                                                  widget.isProfile == true
                                                      ? Positioned.fill(
                                                          bottom: 3,
                                                          right: 3,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              UpdateProfile(channelid: Constant.channelID ?? "")),
                                                                    )
                                                                    .then((val) => val
                                                                        ? getApi()
                                                                        : null);
                                                              },
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color:
                                                                        colorAccent),
                                                                child:
                                                                    const Icon(
                                                                  Icons.edit,
                                                                  size: 20,
                                                                  color: white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              settingProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .fullName !=
                                                          null ||
                                                      settingProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .fullName !=
                                                          ""
                                                  ? MyText(
                                                      color: colorAccent,
                                                      text: settingProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .fullName
                                                              .toString() ??
                                                          "",
                                                      multilanguage: false,
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 16,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w500,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal)
                                                  : MyText(
                                                      color: colorAccent,
                                                      text: settingProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .channelName
                                                              .toString() ??
                                                          "",
                                                      multilanguage: false,
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 16,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w500,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                              const SizedBox(height: 5),
                                              MyText(
                                                  color: white,
                                                  text: settingProvider
                                                          .profileModel
                                                          .result?[0]
                                                          .email
                                                          .toString() ??
                                                      "",
                                                  textalign: TextAlign.center,
                                                  fontsize: 14,
                                                  multilanguage: false,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w400,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyText(
                                                      color: white,
                                                      text: Utils.kmbGenerator(
                                                          (settingProvider
                                                                      .profileModel
                                                                      .result?[
                                                                          0]
                                                                      .totalSubscriber ??
                                                                  0)
                                                              .round()),
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 12,
                                                      multilanguage: false,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w400,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                  const SizedBox(width: 5),
                                                  MyText(
                                                      color: white,
                                                      text: "subscriber",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 12,
                                                      multilanguage: true,
                                                      inter: false,
                                                      maxline: 1,
                                                      fontwaight:
                                                          FontWeight.w400,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                  const SizedBox(width: 5),
                                                  MyText(
                                                      color: white,
                                                      text: settingProvider
                                                              .profileModel
                                                              .result?[0]
                                                              .totalContent
                                                              .toString() ??
                                                          "",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 12,
                                                      inter: false,
                                                      maxline: 1,
                                                      multilanguage: false,
                                                      fontwaight:
                                                          FontWeight.w400,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                  const SizedBox(width: 5),
                                                  MyText(
                                                      color: white,
                                                      text: "content",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsize: 12,
                                                      inter: false,
                                                      maxline: 1,
                                                      multilanguage: true,
                                                      fontwaight:
                                                          FontWeight.w400,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return profileNoData();
                            }
                          }
                        }),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      buildTab(),
                      buildTabItem(),
                    ],
                  ),
                )),
          ),
        ),
        Utils.showBannerAd(context),
      ],
    );
  }

  Widget buildTab() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: Constant.profileTabList.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  // physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      autofocus: false,
                      focusColor: black,
                      highlightColor: black,
                      hoverColor: black,
                      splashColor: black,
                      onTap: () async {
                        profileprovider.changeTab(index);
                        /* Video */
                        if (profileprovider.position == 0) {
                          getTabData(0, "1");
                          profileprovider.clearListData();
                          /* Podcast */
                        } else if (profileprovider.position == 1) {
                          getTabData(0, "4");
                          profileprovider.clearListData();
                          /* Playlist */
                        } else if (profileprovider.position == 2) {
                          getTabData(0, "5");
                          profileprovider.clearListData();
                          /* Short */
                        } else if (profileprovider.position == 3) {
                          getTabData(0, "3");
                          profileprovider.clearListData();
                          /* Other Page  */
                        } else if (profileprovider.position == 4) {
                          _fetchRentData(0);
                          profileprovider.clearListData();
                          /* Other Page  */
                        } else {
                          profileprovider.clearListData();
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                                color: profileprovider.position == index
                                    ? colorAccent
                                    : white,
                                text: Constant.profileTabList[index],
                                textalign: TextAlign.center,
                                fontsize: Dimens.textTitle,
                                inter: false,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 20),
                            Container(
                              color: profileprovider.position == index
                                  ? colorAccent
                                  : black,
                              height: 2,
                              width: 100,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              color: colorPrimaryDark,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 2,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      );
    });
  }

  Widget buildTabItem() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.position == 0) {
        return buildVideo();
      } else if (profileprovider.position == 1) {
        return buildPadcast();
      } else if (profileprovider.position == 2) {
        return buildPlaylist();
      } else if (profileprovider.position == 3) {
        return buildReels();
      } else if (profileprovider.position == 4) {
        return buildRentVideo();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return videoShimmer();
      } else {
        return Column(
          children: [
            video(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget video() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Detail(
                              stoptime: "",
                              iscontinueWatching: false,
                              videoid: profileProvider
                                      .channelContentList?[index].id
                                      .toString() ??
                                  "",
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MyNetworkImage(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                  imagePath: profileProvider
                                          .channelContentList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                              if (profileProvider.deleteItemIndex == index &&
                                  profileProvider.deletecontentLoading)
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
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
                                  child: InkWell(
                                    onTap: () async {
                                      if (widget.channelUserid ==
                                          Constant.userID) {
                                        await profileProvider.getDeleteContent(
                                            index,
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "0");
                                      }
                                    },
                                    child: widget.channelUserid ==
                                            Constant.userID
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 8, 5, 8),
                                            child: MyImage(
                                                width: 20,
                                                height: 20,
                                                color: white,
                                                imagePath: "ic_delete.png"),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 80,
                          child: MyText(
                              color: white,
                              text: profileProvider
                                      .channelContentList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.center,
                              fontsize: Dimens.textSmall,
                              inter: false,
                              multilanguage: false,
                              maxline: 2,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
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
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget videoShimmer() {
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
          children: List.generate(10, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomWidget.roundrectborder(
                    width: 90,
                    height: 90,
                  ),
                  SizedBox(height: 8),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildPadcast() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        return Column(
          children: [
            padcast(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget padcast() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: profileProvider
                                    .channelContentList?[index].contentType
                                    .toString() ??
                                "",
                            contentImage: profileProvider
                                    .channelContentList?[index].portraitImg
                                    .toString() ??
                                "",
                            contentName: profileProvider
                                    .channelContentList?[index].title
                                    .toString() ??
                                "",
                            /* Temporary Null ContentUserid */
                            contentUserid: "",
                            contentId: profileProvider
                                    .channelContentList?[index].id
                                    .toString() ??
                                "",
                            playlistImage: profileProvider
                                .channelContentList?[index].playlistImage,
                            isBuy: profileProvider
                                    .channelContentList?[index].isBuy
                                    .toString() ??
                                "",
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: profileProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                            if (profileProvider.deleteItemIndex == index &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
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
                                child: InkWell(
                                  onTap: () async {
                                    if (widget.channelUserid ==
                                        Constant.userID) {
                                      await profileProvider.getDeleteContent(
                                          index,
                                          profileProvider
                                                  .channelContentList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          profileProvider
                                                  .channelContentList?[index].id
                                                  .toString() ??
                                              "",
                                          "0");
                                    }
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: MyImage(
                                              width: 20,
                                              height: 20,
                                              color: white,
                                              imagePath: "ic_delete.png"),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider.channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
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
              }),
            ),
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

  Widget padcastShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
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
                  height: 100,
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

  Widget buildPlaylist() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return playlistShimmer();
      } else {
        return Column(
          children: [
            playlist(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget playlist() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: profileProvider
                                    .channelContentList?[index].contentType
                                    .toString() ??
                                "",
                            contentImage: profileProvider
                                    .channelContentList?[index].portraitImg
                                    .toString() ??
                                "",
                            contentName: profileProvider
                                    .channelContentList?[index].title
                                    .toString() ??
                                "",
                            /* Temporary Null ContentUserid */
                            contentUserid: "",
                            contentId: profileProvider
                                    .channelContentList?[index].id
                                    .toString() ??
                                "",
                            playlistImage: profileProvider
                                .channelContentList?[index].playlistImage,
                            isBuy: profileProvider
                                    .channelContentList?[index].isBuy
                                    .toString() ??
                                "",
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 150,
                          child: Stack(
                            children: [
                              playlistImages(index,
                                  profileProvider.channelContentList ?? []),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                              if (profileProvider.deleteItemIndex == index &&
                                  profileProvider.deletecontentLoading)
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
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
                                  child: InkWell(
                                    onTap: () async {
                                      if (widget.channelUserid ==
                                          Constant.userID) {
                                        await profileProvider.getDeleteContent(
                                            index,
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "0");
                                      }
                                    },
                                    child: widget.channelUserid ==
                                            Constant.userID
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 8, 5, 8),
                                            child: MyImage(
                                                width: 20,
                                                height: 20,
                                                color: white,
                                                imagePath: "ic_delete.png"),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 150,
                          child: MyText(
                              color: white,
                              text: profileProvider
                                      .channelContentList?[index].title
                                      .toString() ??
                                  "",
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
                                      profileProvider.channelContentList?[index]
                                              .totalView
                                              .toString() ??
                                          "")),
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
              }),
            ),
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

  Widget playlistShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(6, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.rectangular(height: 150, width: 160),
                  SizedBox(height: 10),
                  CustomWidget.rectangular(height: 5, width: 160),
                  SizedBox(height: 5),
                  CustomWidget.rectangular(height: 5, width: 160),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildReels() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            reels(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget reels() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
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
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Short(
                            initialIndex: index,
                            shortType: "profile",
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
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: profileProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                            if (profileProvider.deleteItemIndex == index &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
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
                                child: InkWell(
                                  onTap: () async {
                                    if (widget.channelUserid ==
                                        Constant.userID) {
                                      await profileProvider.getDeleteContent(
                                          index,
                                          profileProvider
                                                  .channelContentList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          profileProvider
                                                  .channelContentList?[index].id
                                                  .toString() ??
                                              "",
                                          "0");
                                    }
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: MyImage(
                                              width: 20,
                                              height: 20,
                                              color: white,
                                              imagePath: "ic_delete.png"),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider.channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
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
              }),
            ),
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

  Widget reelsShimmer() {
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

  Widget buildRentVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return rentVideoShimmer();
      } else {
        return Column(
          children: [
            rentVideo(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget rentVideo() {
    if (profileProvider.getUserRentContentModel.status == 200 &&
        profileProvider.rentContentList != null) {
      if ((profileProvider.rentContentList?.length ?? 0) > 0) {
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
              children: List.generate(
                  profileProvider.rentContentList?.length ?? 0, (index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    audioPlayer.pause();
                    Utils.openPlayer(
                      iscontinueWatching: false,
                      stoptime: "0",
                      context: context,
                      videoId: profileProvider.rentContentList?[index].id
                              .toString() ??
                          "",
                      videoUrl: profileProvider.rentContentList?[index].content
                              .toString() ??
                          "",
                      vUploadType: profileProvider
                              .rentContentList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: profileProvider
                              .rentContentList?[index].landscapeImg
                              .toString() ??
                          "",
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 135,
                          height: 155,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: MyNetworkImage(
                                  imagePath: profileProvider
                                          .rentContentList?[index].portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: MyText(
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol} ${profileProvider.rentContentList?[index].rentPrice.toString() ?? ""}",
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
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 130,
                          child: MyText(
                              color: white,
                              text: profileProvider
                                      .rentContentList?[index].title
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
              }),
            ),
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

  Widget rentVideoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
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
                      width: 135,
                      height: 150,
                    ),
                    SizedBox(height: 10),
                    CustomWidget.roundrectborder(
                      width: 130,
                      height: 5,
                    ),
                    SizedBox(height: 7),
                    CustomWidget.roundrectborder(
                      width: 130,
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

  Widget playlistImages(index, List<Result>? sectionList) {
    if ((sectionList?[index].playlistImage?.length ?? 0) == 4) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[2].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[3].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 3) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
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
                      sectionList?[index].playlistImage?[2].toString() ?? "",
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 2) {
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
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
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
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 1) {
      return SizedBox(
          width: 160,
          height: 150,
          child: MyNetworkImage(
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            imagePath: sectionList?[index].playlistImage?[0].toString() ?? "",
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

  Widget profileNoData() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: colorPrimaryDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: MyImage(
                                width: 25,
                                height: 25,
                                imagePath: "ic_roundback.png"),
                          ),
                          const SizedBox(width: 15),
                          MyText(
                              color: white,
                              text: "myprofile",
                              textalign: TextAlign.center,
                              fontsize: Dimens.textBig,
                              multilanguage: true,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                    widget.isProfile == false
                        ? InkWell(
                            onTap: () {
                              // showMenu(
                              //   context: context,
                              //   position:
                              //       const RelativeRect.fromLTRB(100, 100, 0, 0),
                              //   items: <PopupMenuEntry>[
                              //     PopupMenuItem(
                              //       onTap: () async {},
                              //       value: 'item1',
                              //       child: settingProvider.profileModel
                              //                   .result?[0].isBlock ==
                              //               0
                              //           ? MyText(
                              //               color: colorPrimaryDark,
                              //               text: "blockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal)
                              //           : MyText(
                              //               color: colorPrimaryDark,
                              //               text: "removeblockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal),
                              //     ),
                              //   ],
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyImage(
                                  width: 15,
                                  height: 15,
                                  imagePath: "ic_more.png"),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                              borderRadius: BorderRadius.circular(60)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: MyImage(
                              width: 90,
                              height: 90,
                              fit: BoxFit.fill,
                              imagePath: "ic_user.png",
                            ),
                          ),
                        ),
                        widget.isProfile == true
                            ? Positioned.fill(
                                bottom: 3,
                                right: 3,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () {
                                      if (Utils.checkLoginUser(context)) {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                  builder: (_) => UpdateProfile(
                                                      channelid:
                                                          Constant.channelID ??
                                                              "")),
                                            )
                                            .then(
                                                (val) => val ? getApi() : null);
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorAccent),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyText(
                        color: colorAccent,
                        text: "Guest User",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsize: 16,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsize: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "subscriber",
                            textalign: TextAlign.center,
                            fontsize: 12,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsize: 12,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "content",
                            textalign: TextAlign.center,
                            fontsize: 12,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
