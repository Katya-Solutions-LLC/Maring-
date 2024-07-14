import 'package:maring/model/rentsectiondetailmodel.dart' as rent;
import 'package:maring/model/rentsectiondetailmodel.dart';
import 'package:maring/model/sectiondetailmodel.dart' as section;
import 'package:maring/model/sectiondetailmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class SeeAllProvider extends ChangeNotifier {
  SectionDetailModel sectionListModel = SectionDetailModel();
  RentSectionDetailModel rentSectionDetailModel = RentSectionDetailModel();
  bool loading = false;
  bool seeallLoadMore = false;

  List<section.Result>? sectionDataList = [];
  int? sectiondatatotalRows, sectiondatatotalPage, sectiondatacurrentPage;
  bool? sectiondataisMorePage;

  List<rent.Result>? rentVideoList = [];
  int? renttotalRows, renttotalPage, rentcurrentPage;
  bool? rentisMorePage;

/* SectionList Api */
  Future<void> getSeactionDetail(sectionId, pageNo) async {
    loading = true;
    sectionListModel = await ApiService().sectionDetail(sectionId, pageNo);
    if (sectionListModel.status == 200) {
      setSectionDataPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $sectiondatacurrentPage');
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionDataList
                ?.add(sectionListModel.result?[i] ?? section.Result());
          }
          final Map<int, section.Result> postMap = {};
          sectionDataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionDataList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(sectionDataList?.length ?? 0)}");
          setSeeAllLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setSectionDataPaginationData(
      int? sectiondatatotalRows,
      int? sectiondatatotalPage,
      int? sectiondatacurrentPage,
      bool? sectionisMorePage) {
    this.sectiondatacurrentPage = sectiondatacurrentPage;
    this.sectiondatatotalRows = sectiondatatotalRows;
    this.sectiondatatotalPage = sectiondatatotalPage;
    sectionisMorePage = sectionisMorePage;
    notifyListeners();
  }

  /* Rent Video SeeAll Data Api */
  Future<void> getRentSeactionDetail(sectionId, pageNo) async {
    loading = true;
    rentSectionDetailModel =
        await ApiService().rentSectionDetail(sectionId, pageNo);
    if (rentSectionDetailModel.status == 200) {
      setRentPaginationData(
          rentSectionDetailModel.totalRows,
          rentSectionDetailModel.totalPage,
          rentSectionDetailModel.currentPage,
          rentSectionDetailModel.morePage);
      if (rentSectionDetailModel.result != null &&
          (rentSectionDetailModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(rentSectionDetailModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $sectiondatacurrentPage');
        if (rentSectionDetailModel.result != null &&
            (rentSectionDetailModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(rentSectionDetailModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (rentSectionDetailModel.result?.length ?? 0);
              i++) {
            rentVideoList
                ?.add(rentSectionDetailModel.result?[i] ?? rent.Result());
          }
          final Map<int, rent.Result> postMap = {};
          rentVideoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          rentVideoList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(rentVideoList?.length ?? 0)}");
          setSeeAllLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRentPaginationData(int? renttotalRows, int? renttotalPage,
      int? rentcurrentPage, bool? rentisMorePage) {
    this.rentcurrentPage = rentcurrentPage;
    this.renttotalRows = renttotalRows;
    this.renttotalPage = renttotalPage;
    rentisMorePage = rentisMorePage;
    notifyListeners();
  }

  setSeeAllLoadMore(seeallLoadMore) {
    this.seeallLoadMore = seeallLoadMore;
    notifyListeners();
  }

  clearProvider() {
    sectionListModel = SectionDetailModel();
    rentSectionDetailModel = RentSectionDetailModel();
    loading = false;
    seeallLoadMore = false;
    sectionDataList = [];
    sectionDataList?.clear();
    sectiondatatotalRows;
    sectiondatatotalPage;
    sectiondatacurrentPage;
    sectiondataisMorePage;
    rentVideoList = [];
    rentVideoList?.clear();
    renttotalRows;
    renttotalPage;
    rentcurrentPage;
    rentisMorePage;
  }
}
