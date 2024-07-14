import 'package:maring/pages/musicdetails.dart';
import 'package:maring/pages/seeall.dart';
import 'package:maring/provider/rentprovider.dart';
import 'package:maring/subscription/allpayment.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:provider/provider.dart';
import '../model/rentsectionmodel.dart';

class Rent extends StatefulWidget {
  const Rent({super.key});

  @override
  State<Rent> createState() => RentState();
}

class RentState extends State<Rent> {
  late RentProvider rentProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (rentProvider.rentcurrentPage ?? 0) <
            (rentProvider.renttotalPage ?? 0)) {
      _fetchData(0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${rentProvider.rentisMorePage}");
    debugPrint("currentPage ======> ${rentProvider.rentcurrentPage}");
    debugPrint("totalPage   ======> ${rentProvider.renttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await rentProvider.getRentSeactionList((nextPage ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: colorPrimary,
            appBar: Utils().otherPageAppBar(context, "Rent", true),
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPage(),
                ],
              ),
            ),
          ),
        ),
        Utils.showBannerAd(context),
      ],
    );
  }

  Widget buildPage() {
    return Consumer<RentProvider>(builder: (context, rentprovider, child) {
      if (rentprovider.rentloading && !rentprovider.rentLoadMore) {
        return rentShimmer();
      } else {
        return Column(
          children: [
            setSection(),
            if (rentprovider.rentLoadMore)
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

  Widget setSection() {
    if (rentProvider.rentSectionModel.status == 200 &&
        rentProvider.rentsectionList != null) {
      if ((rentProvider.rentsectionList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: rentProvider.rentsectionList?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (rentProvider.rentsectionList?[index].data != null &&
                (rentProvider.rentsectionList?[index].data?.length ?? 0) > 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                            color: white,
                            multilanguage: false,
                            text: rentProvider.rentsectionList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textTitle,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        rentProvider.rentsectionList?[index].viewAll == 1
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SeeAll(
                                          isRent: true,
                                          sectionId: rentProvider
                                                  .rentsectionList?[index].id
                                                  .toString() ??
                                              "",
                                          title: rentProvider
                                                  .rentsectionList?[index].title
                                                  .toString() ??
                                              "",
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: MyText(
                                    color: colorAccent,
                                    multilanguage: true,
                                    text: "seeall",
                                    textalign: TextAlign.center,
                                    fontsize: 14,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Section Data List
                  SizedBox(
                    // color: colorAccent,
                    width: MediaQuery.of(context).size.width,
                    height: 170,
                    child: setSectionData(
                        sectionindex: index,
                        sectionList: rentProvider.rentsectionList),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget setSectionData(
      {required int sectionindex, required List<Result>? sectionList}) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 3),
      itemCount: sectionList?[sectionindex].data?.length ?? 0,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            if (sectionList?[sectionindex].data?[index].isRentBuy == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AllPayment(
                      currency: Constant.currencySymbol,
                      itemId: sectionList?[sectionindex]
                              .data?[index]
                              .id
                              .toString() ??
                          "",
                      itemTitle: sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                      payType: "Rent",
                      price: sectionList?[sectionindex]
                              .data?[index]
                              .rentPrice
                              .toString() ??
                          "",
                      productPackage: "",
                      typeId: "",
                      videoType: "",
                    );
                  },
                ),
              );
            } else {
              audioPlayer.pause();
              Utils.openPlayer(
                iscontinueWatching: false,
                stoptime: "0",
                context: context,
                videoId:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                videoUrl: sectionList?[sectionindex]
                        .data?[index]
                        .content
                        .toString() ??
                    "",
                vUploadType: sectionList?[sectionindex]
                        .data?[index]
                        .contentUploadType
                        .toString() ??
                    "",
                videoThumb: sectionList?[sectionindex]
                        .data?[index]
                        .landscapeImg
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
                          imagePath: sectionList?[sectionindex]
                                  .data?[index]
                                  .portraitImg
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
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MyText(
                              color: white,
                              text:
                                  "${Constant.currencySymbol} ${sectionList?[sectionindex].data?[index].rentPrice.toString() ?? ""}",
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
                  width: 150,
                  child: MyText(
                      color: white,
                      text: sectionList?[sectionindex]
                              .data?[index]
                              .title
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
    );
  }

  Widget rentShimmer() {
    return ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomWidget.roundrectborder(height: 10, width: 200),
                    CustomWidget.roundrectborder(height: 10, width: 50),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Section Data List
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 230,
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 3),
                  itemCount: 5,
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWidget.roundrectborder(
                              width: 135,
                              height: 155,
                            ),
                            SizedBox(height: 10),
                            CustomWidget.roundrectborder(
                              width: 135,
                              height: 5,
                            ),
                            SizedBox(height: 7),
                            CustomWidget.roundrectborder(
                              width: 135,
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
