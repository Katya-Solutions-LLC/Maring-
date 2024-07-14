import 'package:maring/model/gethistorymodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class HistoryProvider extends ChangeNotifier {
  GetHistoryModel historyModel = GetHistoryModel();
  int tabindex = 0;

  List<Result>? historyList = [];
  bool loadMore = false, loading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getHistory(contentType, pageNo) async {
    loading = true;
    historyModel = await ApiService().historyList(contentType, pageNo);
    if (historyModel.status == 200) {
      setPaginationData(historyModel.totalRows, historyModel.totalPage,
          historyModel.currentPage, historyModel.morePage);
      if (historyModel.result != null &&
          (historyModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(historyModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (historyModel.result != null &&
            (historyModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(historyModel.result?.length ?? 0)}");
          for (var i = 0; i < (historyModel.result?.length ?? 0); i++) {
            historyList?.add(historyModel.result?[i] ?? Result());
          }
          if (contentType != "4") {
            final Map<int, Result> postMap = {};
            historyList?.forEach((item) {
              postMap[item.id ?? 0] = item;
            });
            historyList = postMap.values.toList();
          }
          debugPrint(
              "followFollowingList length :==> ${(historyList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  clearTab() {
    historyList = [];
    historyList?.clear();
    historyModel = GetHistoryModel();
  }

  clearProvider() {
    historyModel = GetHistoryModel();
    loading = false;
    tabindex = 0;
    historyList = [];
    historyList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
