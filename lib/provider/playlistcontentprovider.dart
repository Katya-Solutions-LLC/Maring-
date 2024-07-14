import 'package:maring/model/addremovecontenttoplaylistmodel.dart';
import 'package:maring/model/getplaylistcontentmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class PlaylistContentProvider extends ChangeNotifier {
  GetPlaylistContentModel getPlaylistContentModel = GetPlaylistContentModel();
  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  bool loading = false, deletecontentPlaylistLoading = false;

  int tabindex = 0;
  int position = 0;

  /* Pagination With Api Calling */
  List<Result>? contantList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getPlaylistContent(playlistId, contentType, pageNo) async {
    loading = true;
    getPlaylistContentModel =
        await ApiService().getPlaylistContent(playlistId, contentType, pageNo);
    if (getPlaylistContentModel.status == 200) {
      setPaginationData(
          getPlaylistContentModel.totalRows,
          getPlaylistContentModel.totalPage,
          getPlaylistContentModel.currentPage,
          getPlaylistContentModel.morePage);
      if (getPlaylistContentModel.result != null &&
          (getPlaylistContentModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getPlaylistContentModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getPlaylistContentModel.result != null &&
            (getPlaylistContentModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getPlaylistContentModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getPlaylistContentModel.result?.length ?? 0);
              i++) {
            contantList?.add(getPlaylistContentModel.result?[i] ?? Result());
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

  /* Add Remove Content Playlist  */

  /* Type = 1 = Add */
  /* Type = 2 = Remove */
  addremoveContentToPlaylist(index, chennelId, playlistId, contenttype,
      contentid, episodeid, type) async {
    position = index;
    setDeletePlaylistLoading(true);
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    setDeletePlaylistLoading(false);
    contantList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecontentPlaylistLoading = isSending;
    notifyListeners();
  }

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  clearTab() {
    contantList = [];
    contantList?.clear();
    getPlaylistContentModel = GetPlaylistContentModel();
  }

  clearProvider() {
    getPlaylistContentModel = GetPlaylistContentModel();
    loading = false;
    tabindex = 0;
    /* Pagination With Api Calling */
    contantList = [];
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
