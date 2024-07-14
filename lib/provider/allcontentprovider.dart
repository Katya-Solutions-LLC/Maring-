import 'package:maring/model/getcontentbyplaylistmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class AllContentProvider extends ChangeNotifier {
  GetContentByPlaylistModel getContentByPlaylistModel =
      GetContentByPlaylistModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel addMultipleContentModel = SuccessModel();

  bool loading = false;
  int tabindex = 0;

  /* Pagination With Api Calling */
  List<Result>? contantList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* Select Multiple Video Item Array */
  final List<int> selectContentItemIndex = [];
  List storeContentId = [];
  bool isContentVisible = false;

  Future<void> getContentByPlaylist(contentType, pageNo) async {
    loading = true;
    getContentByPlaylistModel =
        await ApiService().contentByPlaylist(contentType, pageNo);
    if (getContentByPlaylistModel.status == 200) {
      setPaginationData(
          getContentByPlaylistModel.totalRows,
          getContentByPlaylistModel.totalPage,
          getContentByPlaylistModel.currentPage,
          getContentByPlaylistModel.morePage);
      if (getContentByPlaylistModel.result != null &&
          (getContentByPlaylistModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getContentByPlaylistModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getContentByPlaylistModel.result != null &&
            (getContentByPlaylistModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getContentByPlaylistModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getContentByPlaylistModel.result?.length ?? 0);
              i++) {
            contantList?.add(getContentByPlaylistModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          contantList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          contantList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(contantList?.length ?? 0)}");
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

/* Multiple Video Add And Remove */
  addItemContent(index, contentId, isVisible) {
    isContentVisible = isVisible;
    selectContentItemIndex.add(index);
    storeContentId.add(contentId);
    notifyListeners();
  }

  removeItemContent(index, contentId, isVisible) {
    selectContentItemIndex.removeWhere((val) => val == index);
    storeContentId.removeWhere((val) => val == contentId);
    if (selectContentItemIndex.isEmpty) {
      isContentVisible = isVisible;
    }
    notifyListeners();
  }

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  addMultipleContentToPlaylist(playlistId, contentType, contentIds) async {
    loading = true;
    addMultipleContentModel = await ApiService()
        .addMultipleContentToPlaylist(playlistId, contentType, contentIds);
    loading = false;
    notifyListeners();
  }

  clearTab() {
    contantList = [];
    contantList?.clear();
    getContentByPlaylistModel = GetContentByPlaylistModel();
  }

  clearAllSelectedContent() {
    debugPrint("Clear Selected Data");
    /* Select Multiple Video Item Array */
    selectContentItemIndex.clear();
    storeContentId = [];
    storeContentId.clear();
    isContentVisible = false;
  }

  clearProvider() {
    getContentByPlaylistModel = GetContentByPlaylistModel();
    loading = false;
    tabindex = 0;
    /* Select Multiple Video Item Array */
    selectContentItemIndex.clear();
    storeContentId = [];
    storeContentId.clear();
    isContentVisible = false;
    /* Pagination With Api Field */
    contantList = [];
    contantList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
