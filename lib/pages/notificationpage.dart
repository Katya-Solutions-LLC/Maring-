import 'package:maring/provider/notificationprovider.dart';
import 'package:maring/utils/customwidget.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/mytext.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late NotificationProvider notificationProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
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
        (notificationProvider.currentPage ?? 0) <
            (notificationProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      _fetchData(notificationProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${notificationProvider.isMorePage}");
    debugPrint("currentPage ======> ${notificationProvider.currentPage}");
    debugPrint("totalPage   ======> ${notificationProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await notificationProvider.getNotification((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    notificationProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "notification", true),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        physics: const BouncingScrollPhysics(),
        child: buildNotification(),
      ),
    );
  }

  Widget buildNotification() {
    return Consumer<NotificationProvider>(
        builder: (context, notificationprovider, child) {
      if (notificationprovider.loading && !notificationprovider.loadMore) {
        return notificationShimmer();
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            notificationList(),
            if (notificationProvider.loadMore)
              SizedBox(
                height: 50,
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  Widget notificationList() {
    if (notificationProvider.getNotificationModel.status == 200 &&
        notificationProvider.notificationList != null) {
      if ((notificationProvider.notificationList?.length ?? 0) > 0) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: notificationProvider.notificationList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: colorAccent),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child:
                        notificationProvider.notificationList?[index].type == 1
                            ? MyImage(
                                width: 55, height: 55, imagePath: "ic_user.png")
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    width: 55,
                                    height: 55,
                                    imagePath: notificationProvider
                                            .notificationList?[index].userImage
                                            .toString() ??
                                        "",
                                    fit: BoxFit.cover),
                              ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        notificationProvider.notificationList?[index].type == 1
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: notificationProvider
                                              .notificationList?[index].title
                                              ?.toString() ??
                                          "",
                                      fontsize: Dimens.textDesc,
                                      multilanguage: false,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                      fontwaight: FontWeight.w500),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    alignment: Alignment.centerLeft,
                                    child: ExpandableText(
                                      notificationProvider
                                              .notificationList?[index].message
                                              .toString() ??
                                          "",
                                      expandText: "Read More",
                                      collapseText: "Read less",
                                      maxLines: 2,
                                      expandOnTextTap: true,
                                      collapseOnTextTap: true,
                                      linkStyle: TextStyle(
                                        fontSize: Dimens.textDesc,
                                        fontStyle: FontStyle.normal,
                                        color: colorAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      style: TextStyle(
                                        fontSize: Dimens.textSmall,
                                        fontStyle: FontStyle.normal,
                                        color: gray,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : MyText(
                                color: colorAccent,
                                text: notificationProvider
                                        .notificationList?[index].title
                                        ?.toString() ??
                                    "",
                                fontsize: Dimens.textDesc,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                                fontwaight: FontWeight.w500),
                        const SizedBox(height: 13),
                        Consumer<NotificationProvider>(
                            builder: (context, notificationprovider, child) {
                          if (notificationprovider.position == index &&
                              notificationprovider.readnotificationloading) {
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
                                await notificationProvider.getReadNotification(
                                    index,
                                    notificationProvider
                                            .notificationList?[index].id
                                            ?.toString() ??
                                        "",
                                    true);
                              },
                              child: MyImage(
                                  width: 16,
                                  height: 16,
                                  imagePath: "ic_delete.png"),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child:
                        notificationProvider.notificationList?[index].type == 1
                            ? const SizedBox.shrink()
                            : MyNetworkImage(
                                width: 70,
                                height: 50,
                                imagePath: notificationProvider
                                        .notificationList?[index].contentImage
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget notificationShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.circular(
                width: 55,
                height: 55,
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(
                    width: 250,
                    height: 8,
                  ),
                  SizedBox(height: 5),
                  CustomWidget.roundrectborder(
                    width: 250,
                    height: 8,
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
