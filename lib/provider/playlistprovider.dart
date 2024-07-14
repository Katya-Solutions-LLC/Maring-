import 'package:maring/model/deleteplaylistmodel.dart';
import 'package:maring/model/editplaylistmodel.dart';
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class PlaylistProvider extends ChangeNotifier {
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();

  DeletePlaylistModel deletePlaylistModel = DeletePlaylistModel();
  EditPlaylistModel editPlaylistModel = EditPlaylistModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  int position = 0;
  bool deletePlaylistloading = false;
  int isType = 0;

  List<Result>? playListData = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    loading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    if (getContentbyChannelModel.status == 200) {
      setPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getContentbyChannelModel.result != null &&
            (getContentbyChannelModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getContentbyChannelModel.result?.length ?? 0);
              i++) {
            playListData?.add(getContentbyChannelModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          playListData?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          playListData = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(playListData?.length ?? 0)}");
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

  getEditPlayList(playlistId, title, playlistType) async {
    loading = true;
    editPlaylistModel =
        await ApiService().editPlaylist(playlistId, title, playlistType);
    loading = false;
    getcontentbyChannel(Constant.userID, Constant.channelID, "5", "1");
    notifyListeners();
  }

  getDeletePlayList(index, playlistId) async {
    position = index;
    setDeletePlaylistLoading(true);
    deletePlaylistModel = await ApiService().deletePlaylist(playlistId);
    setDeletePlaylistLoading(false);
    playListData?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deletePlaylistloading = isSending;
    notifyListeners();
  }

  /* isType == 1 ==>  Public Playlist */
  /* isType == 2 ==>  Private Playlist */
  selectPrivacy({required int type}) {
    isType = type;
    notifyListeners();
  }

  getcreatePlayList(chennelId, title, playlistType) async {
    loading = true;
    successModel =
        await ApiService().createPlayList(chennelId, title, playlistType);
    loading = false;
  }

  clearProvider() {
    getContentbyChannelModel = GetContentbyChannelModel();
    deletePlaylistModel = DeletePlaylistModel();
    editPlaylistModel = EditPlaylistModel();
    loading = false;
    playListData = [];
    playListData?.clear();
    loadMore = false;
    position = 0;
    deletePlaylistloading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
