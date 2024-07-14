import 'package:maring/model/addremovewatchlatermodel.dart';
import 'package:maring/model/watchlatermodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class WatchLaterProvider extends ChangeNotifier {
  GetWatchlaterModel watchlaterModel = GetWatchlaterModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  bool loading = false;
  bool deleteWatchlaterloading = false;
  int tabindex = 0;
  int position = 0;

  /* Pagination With Api Calling */
  List<Result>? contantList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getContentByWatchLater(contentType, pageNo) async {
    loading = true;
    watchlaterModel = await ApiService().watchLaterList(contentType, pageNo);
    if (watchlaterModel.status == 200) {
      setPaginationData(watchlaterModel.totalRows, watchlaterModel.totalPage,
          watchlaterModel.currentPage, watchlaterModel.morePage);
      if (watchlaterModel.result != null &&
          (watchlaterModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (watchlaterModel.result != null &&
            (watchlaterModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}");
          for (var i = 0; i < (watchlaterModel.result?.length ?? 0); i++) {
            contantList?.add(watchlaterModel.result?[i] ?? Result());
          }
          debugPrint("Array length :==> ${(contantList?.length ?? 0)}");
          if (contentType != "4") {
            final Map<int, Result> postMap = {};
            contantList?.forEach((item) {
              postMap[item.id ?? 0] = item;
            });
            contantList = postMap.values.toList();
          }
          debugPrint(
              "Podcast Episode  length :==> ${(contantList?.length ?? 0)}");
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

/* Add Remove WatchLater */
  addremoveWatchLater(index, contenttype, contentid, episodeid, type) async {
    position = index;
    setDeletePlaylistLoading(true);
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    setDeletePlaylistLoading(false);
    contantList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deleteWatchlaterloading = isSending;
    notifyListeners();
  }

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  clearTab() {
    debugPrint("clearTabData=======>");
    contantList = [];
    contantList?.clear();
    watchlaterModel = GetWatchlaterModel();
  }

  clearProvider() {
    watchlaterModel = GetWatchlaterModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    loading = false;
    deleteWatchlaterloading = false;
    tabindex = 0;
    position = 0;
    /* Pagination With Api Calling */
    contantList = [];
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
