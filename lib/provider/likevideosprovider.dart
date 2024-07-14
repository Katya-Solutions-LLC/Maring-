import 'package:maring/model/addremovelikedislikemodel.dart';
import 'package:maring/model/likevideosmodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class LikeVideosProvider extends ChangeNotifier {
  LikeContentModel likeContentModel = LikeContentModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  bool loading = false;

  List<Result>? likevideoList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getlikeVideos(contentType, pageNo) async {
    loading = true;
    likeContentModel = await ApiService().likeVideos(contentType, pageNo);
    if (likeContentModel.status == 200) {
      setPaginationData(likeContentModel.totalRows, likeContentModel.totalPage,
          likeContentModel.currentPage, likeContentModel.morePage);
      if (likeContentModel.result != null &&
          (likeContentModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(likeContentModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (likeContentModel.result != null &&
            (likeContentModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(likeContentModel.result?.length ?? 0)}");
          for (var i = 0; i < (likeContentModel.result?.length ?? 0); i++) {
            likevideoList?.add(likeContentModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          likevideoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          likevideoList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(likevideoList?.length ?? 0)}");
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

  Future<void> addLikeDislike(
      index, contenttype, contentid, status, episodeId) async {
    addRemoveLikeDislikeModel = await ApiService()
        .addRemoveLikeDislike(contenttype, contentid, status, episodeId);
    likevideoList?.removeAt(index);
    notifyListeners();
  }

  clearProvider() {
    likeContentModel = LikeContentModel();
    loading = false;
    likevideoList = [];
    likevideoList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
