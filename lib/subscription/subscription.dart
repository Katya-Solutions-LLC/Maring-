import 'dart:async';
import 'dart:io';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/provider/subscriptionprovider.dart';
import 'package:maring/subscription/allpayment.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/packagemodel.dart';

class Subscription extends StatefulWidget {
  const Subscription({
    Key? key,
  }) : super(key: key);

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  SharedPre sharedPre = SharedPre();
  String? userName, userEmail, userMobileNo;

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    Utils.getCurrencySymbol();
    await subscriptionProvider.getPackage();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      for (var i = 0; i < (packageList?.length ?? 0); i++) {
        if (packageList?[i].isBuy == 1) {
          debugPrint("<============= Purchaged =============>");
          Utils.showSnackbar(context, "already_purchased");
          return;
        }
      }
      if (packageList?[index].isBuy == 0) {
        /* Update Required data for payment */
        if ((userName ?? "").isEmpty ||
            (userEmail ?? "").isEmpty ||
            (userMobileNo ?? "").isEmpty) {
          updateDataDialog(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        }
        /* Update Required data for payment */
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AllPayment(
                payType: 'Package',
                itemId: packageList?[index].id.toString() ?? '',
                price: packageList?[index].price.toString() ?? '',
                itemTitle: packageList?[index].name.toString() ?? '',
                typeId: '',
                videoType: '',
                productPackage: (!kIsWeb)
                    ? (Platform.isIOS
                        ? (packageList?[index].iosProductPackage.toString() ??
                            '')
                        : (packageList?[index]
                                .androidProductPackage
                                .toString() ??
                            ''))
                    : '',
                currency: '',
              );
            },
          ),
        );
      }
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        ),
      );
    }
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: colorPrimary,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "subscription", true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildSubscription(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      return SizedBox(
        height: 100,
        child: Utils.pageLoader(context),
      );
    } else {
      if (subscriptionProvider.packageModel.status == 200) {
        return Column(
          children: [
            const SizedBox(height: 12),
            MyImage(
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
                imagePath: "ic_primium.png"),
            const SizedBox(height: 18),
            /* Remaining Data */
            _buildItems(subscriptionProvider.packageModel.result),
            const SizedBox(height: 20),
          ],
        );
      } else {
        return const NoData(title: '', subTitle: '');
      }
    }
  }

  Widget _buildItems(List<Result>? packageList) {
    return buildMobileItem(packageList);
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return CarouselSlider.builder(
        itemCount: packageList.length,
        carouselController: pageController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: packageList.length > 1 ? true : false,
          enlargeFactor: 0.18,
          autoPlay: false,
          autoPlayCurve: Curves.easeInOutQuart,
          enableInfiniteScroll: packageList.length > 1 ? true : false,
          viewportFraction: packageList.length > 1 ? 0.8 : 0.9,
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 3,
                color: (packageList[index].isBuy == 1
                    ? colorAccent
                    : colorPrimaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyText(
                              color: (packageList[index].isBuy == 1
                                  ? white
                                  : colorAccent),
                              text: packageList[index].name ?? "",
                              textalign: TextAlign.start,
                              fontsize: Dimens.textTitle,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          MyText(
                            color: white,
                            text:
                                "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textTitle,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: colorAccent,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                      constraints: const BoxConstraints(minHeight: 0),
                      child: SingleChildScrollView(
                        child: _buildBenefits(packageList, index),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* Choose Plan */
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () async {
                          _checkAndPay(packageList, index);
                        },
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: BoxDecoration(
                            color: (packageList[index].isBuy == 1
                                ? white
                                : colorAccent),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Consumer<SubscriptionProvider>(
                            builder: (context, subscriptionProvider, child) {
                              return MyText(
                                color: black,
                                text: (packageList[index].isBuy == 1)
                                    ? "current"
                                    : "chooseplan",
                                textalign: TextAlign.center,
                                fontsize: Dimens.textTitle,
                                fontwaight: FontWeight.w700,
                                multilanguage: true,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
        child: ResponsiveGridList(
          minItemWidth: 130,
          verticalGridSpacing: 8,
          horizontalGridSpacing: 6,
          minItemsPerRow: 1,
          maxItemsPerRow: 3,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (packageList.length),
            (index) {
              return Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 3,
                color: (packageList[index].isBuy == 1 ? colorPrimary : black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyText(
                              color: (packageList[index].isBuy == 1
                                  ? black
                                  : colorPrimary),
                              text: packageList[index].name ?? "",
                              textalign: TextAlign.start,
                              fontsize: Dimens.textBig,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          MyText(
                            color: (packageList[index].isBuy == 1
                                ? black
                                : colorPrimary),
                            text:
                                "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textTitle,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: colorAccent,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                      height: 300,
                      child: SingleChildScrollView(
                        child: _buildBenefits(packageList, index),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* Choose Plan */
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () async {
                            _checkAndPay(packageList, index);
                          },
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            decoration: BoxDecoration(
                              color: (packageList[index].isBuy == 1
                                  ? white
                                  : colorAccent),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            child: Consumer<SubscriptionProvider>(
                              builder: (context, subscriptionProvider, child) {
                                return MyText(
                                  color: white,
                                  text: (packageList[index].isBuy == 1)
                                      ? "current"
                                      : "chooseplan",
                                  textalign: TextAlign.center,
                                  fontsize: Dimens.textTitle,
                                  fontwaight: FontWeight.w700,
                                  multilanguage: true,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBenefits(List<Result>? packageList, int? index) {
    if (packageList?[index ?? 0].data != null &&
        (packageList?[index ?? 0].data?.length ?? 0) > 0) {
      return AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 25,
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
        itemCount: (packageList?[index ?? 0].data?.length ?? 0),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int position) {
          return Container(
            constraints: const BoxConstraints(minHeight: 15),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    color: (packageList?[index ?? 0].isBuy == 1
                        ? black
                        : colorAccent),
                    text: packageList?[index ?? 0].data?[position].packageKey ??
                        "",
                    textalign: TextAlign.start,
                    multilanguage: false,
                    fontsize: Dimens.textDesc,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                ((packageList?[index ?? 0].data?[position].packageValue ??
                                "") ==
                            "1" ||
                        (packageList?[index ?? 0]
                                    .data?[position]
                                    .packageValue ??
                                "") ==
                            "0")
                    ? MyImage(
                        width: 23,
                        height: 23,
                        // color: colorAccent,
                        // (packageList?[index ?? 0]
                        //                 .data?[position]
                        //                 .packageValue ??
                        //             "") ==
                        //         "1"
                        //     ? (packageList?[index ?? 0].isBuy == 1
                        //         ? black
                        //         : colorPrimary)
                        //     : colorAccent,
                        imagePath: (packageList?[index ?? 0]
                                        .data?[position]
                                        .packageValue ??
                                    "") ==
                                "1"
                            ? "true.png"
                            : "cross_mark.png",
                      )
                    : MyText(
                        color: white,
                        text: packageList?[index ?? 0]
                                .data?[position]
                                .packageValue ??
                            "",
                        textalign: TextAlign.center,
                        fontsize: Dimens.textTitle,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.bold,
                        fontstyle: FontStyle.normal,
                      ),
              ],
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
