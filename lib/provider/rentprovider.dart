import 'package:maring/model/rentsectionmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class RentProvider extends ChangeNotifier {
  RentSectionModel rentSectionModel = RentSectionModel();
  bool loading = false;

  List<Result>? rentsectionList = [];
  bool rentloading = false, rentLoadMore = false;
  int? renttotalRows, renttotalPage, rentcurrentPage;
  bool? rentisMorePage;

/* SectionList Api */
  Future<void> getRentSeactionList(pageNo) async {
    rentloading = true;
    rentSectionModel = await ApiService().rentSection(pageNo);
    if (rentSectionModel.status == 200) {
      setRentSectionPaginationData(
          rentSectionModel.totalRows,
          rentSectionModel.totalPage,
          rentSectionModel.currentPage,
          rentSectionModel.morePage);
      if (rentSectionModel.result != null &&
          (rentSectionModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(rentSectionModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $rentcurrentPage');
        if (rentSectionModel.result != null &&
            (rentSectionModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(rentSectionModel.result?.length ?? 0)}");
          for (var i = 0; i < (rentSectionModel.result?.length ?? 0); i++) {
            rentsectionList?.add(rentSectionModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          rentsectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          rentsectionList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(rentsectionList?.length ?? 0)}");
          setRentSectionLoadMore(false);
        }
      }
    }
    rentloading = false;
    notifyListeners();
  }

  setRentSectionPaginationData(int? renttotalRows, int? renttotalPage,
      int? rentcurrentPage, bool? rentisMorePage) {
    this.rentcurrentPage = rentcurrentPage;
    this.renttotalRows = renttotalRows;
    this.renttotalPage = renttotalPage;
    rentisMorePage = rentisMorePage;
    notifyListeners();
  }

  setRentSectionLoadMore(rentLoadMore) {
    this.rentLoadMore = rentLoadMore;
    notifyListeners();
  }

  clearProvider() {
    rentSectionModel = RentSectionModel();
    loading = false;
    rentsectionList = [];
    rentloading = false;
    rentLoadMore = false;
    renttotalRows;
    renttotalPage;
    rentcurrentPage;
    rentisMorePage;
  }
}
