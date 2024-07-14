import 'dart:developer';
import 'package:maring/model/addcommentmodel.dart';
import 'package:maring/model/addcontenttohistorymodel.dart';
import 'package:maring/model/addremovelikedislikemodel.dart';
import 'package:maring/model/addremovesubscribemodel.dart';
import 'package:maring/model/addviewmodel.dart';
import 'package:maring/model/commentmodel.dart';
import 'package:maring/model/deletecommentmodel.dart';
import 'package:maring/model/profilemodel.dart';
import 'package:maring/model/removecontenttohistorymodel.dart';
import 'package:maring/model/replaycommentmodel.dart' as replaycomment;
import 'package:maring/model/replaycommentmodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/model/commentmodel.dart' as comment;
import 'package:maring/model/successmodel.dart';
import 'package:maring/model/detailmodel.dart';
import 'package:maring/webservice/apiservice.dart';

class DetailsProvider extends ChangeNotifier {
  DetailsModel detailsModel = DetailsModel();
  ProfileModel profileModel = ProfileModel();
  AddCommentModel addCommentModel = AddCommentModel();
  SuccessModel likedislikemodel = SuccessModel();
  CommentModel getcommentModel = CommentModel();
  ReplayCommentModel replayCommentModel = ReplayCommentModel();
  AddViewModel addViewModel = AddViewModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();
  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();

  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  bool loading = false;
  String commentId = "";
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;

  // Comment List Field Pagination
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloadmore = false, commentloading = false;

  // Add Comment & Add Replay Comment
  bool addcommentloading = false, addreplaycommentloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  List<replaycomment.Result>? replaycommentList = [];
  bool replayCommentloadmore = false, replaycommentloding = false;

  getvideodetails(contentid, contenttype) async {
    loading = true;
    detailsModel = await ApiService().videodetails(contentid, contenttype);
    loading = false;
    notifyListeners();
  }

  getprofile(touserid) async {
    loading = true;
    profileModel = await ApiService().profile(touserid);
    loading = false;
    notifyListeners();
  }

  getaddcomment(contenttype, contentid, episodeid, comment, commentid) async {
    setSendingComment(true);
    addCommentModel = await ApiService()
        .addcomment(contenttype, contentid, episodeid, comment, commentid);
    await getComment(contenttype, contentid, "0");
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    debugPrint("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  getaddReplayComment(
      contenttype, contentid, episodeid, comment, commentid) async {
    setSendingReplayComment(true);
    addCommentModel = await ApiService()
        .addcomment(contenttype, contentid, episodeid, comment, commentid);
    await getReplayComment(commentid, "0");
    setSendingReplayComment(false);
  }

  setSendingReplayComment(isSending) {
    debugPrint("isSending ==> $isSending");
    addreplaycommentloading = isSending;
    notifyListeners();
  }

/*  Comment Pagination Start */
  setCommentLoading(bool isLoading) {
    commentloading = isLoading;
    notifyListeners();
  }

  Future<void> getComment(contenttype, videoid, pageNo) async {
    debugPrint("getPostList pageNo :==> $pageNo");
    commentloading = true;
    getcommentModel =
        await ApiService().getcomment(contenttype, videoid, pageNo);
    debugPrint("getPostList status :===> ${getcommentModel.status}");
    debugPrint("getPostList message :==> ${getcommentModel.message}");
    if (getcommentModel.status == 200) {
      setCommentPaginationData(
          getcommentModel.totalRows,
          getcommentModel.totalPage,
          getcommentModel.currentPage,
          getcommentModel.morePage);
      if (getcommentModel.result != null &&
          (getcommentModel.result?.length ?? 0) > 0) {
        debugPrint(
            "postModel length :==> ${(getcommentModel.result?.length ?? 0)}");

        for (var i = 0; i < (getcommentModel.result?.length ?? 0); i++) {
          commentList?.add(getcommentModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> postMap = {};
        commentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        commentList = postMap.values.toList();
        debugPrint("shortVideoList length :==> ${(commentList?.length ?? 0)}");
        setCommentLoadMore(false);
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(int? totalRowsComment, int? totalPageComment,
      int? currentPageComment, bool? morePageComment) {
    this.currentPageComment = currentPageComment;
    this.totalRowsComment = totalRowsComment;
    this.totalPageComment = totalPageComment;
    morePageComment = morePageComment;
    notifyListeners();
  }

  setCommentLoadMore(commentloadmore) {
    this.commentloadmore = commentloadmore;
    notifyListeners();
  }

  Future<void> updateComments(contenttype, contentid) async {
    loading = true;
    getcommentModel =
        await ApiService().getcomment(contenttype, contentid, "0");
    loading = false;
    notifyListeners();
  }
/*  Comment Pagination End */

/* Delete Comment And Replay Comment Both OF Delete */
  getDeleteComment(commentid, isComment, index) async {
    deleteItemIndex = index;
    setDeletePlaylistLoading(true);
    deleteCommentModel = await ApiService().deleteComment(commentid);
    setDeletePlaylistLoading(false);
    if (isComment == true) {
      commentList?.removeAt(index);
      debugPrint("remove Comment Item");
    } else {
      replaycommentList?.removeAt(index);
      debugPrint("remove ReplayComment Item");
    }
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

/* Replay Comment Pagination Start */

  Future<void> getReplayComment(commentid, pageNo) async {
    debugPrint("getPostList pageNo :==> $pageNo");
    replaycommentloding = true;
    replayCommentModel = await ApiService().replayComment(commentid, pageNo);
    debugPrint("getPostList status :===> ${replayCommentModel.status}");
    debugPrint("getPostList message :==> ${replayCommentModel.message}");
    if (replayCommentModel.status == 200) {
      setReplayCommentPaginationData(
          replayCommentModel.totalRows,
          replayCommentModel.totalPage,
          replayCommentModel.currentPage,
          replayCommentModel.morePage);
      if (replayCommentModel.result != null &&
          (replayCommentModel.result?.length ?? 0) > 0) {
        debugPrint(
            "postModel length :==> ${(replayCommentModel.result?.length ?? 0)}");

        for (var i = 0; i < (replayCommentModel.result?.length ?? 0); i++) {
          replaycommentList
              ?.add(replayCommentModel.result?[i] ?? replaycomment.Result());
        }
        final Map<int, replaycomment.Result> postMap = {};
        replaycommentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        replaycommentList = postMap.values.toList();
        debugPrint(
            "shortVideoList length :==> ${(replaycommentList?.length ?? 0)}");
        setReplayCommentLoadMore(false);
      }
    }
    replaycommentloding = false;
    notifyListeners();
  }

  setReplayCommentPaginationData(
      int? totalRowsReplayComment,
      int? totalPageReplayComment,
      int? currentPageReplayComment,
      bool? morePageReplayComment) {
    this.currentPageReplayComment = currentPageReplayComment;
    this.totalRowsReplayComment = totalRowsReplayComment;
    this.totalPageReplayComment = totalPageReplayComment;
    morePageReplayComment = morePageReplayComment;
    notifyListeners();
  }

  setReplayCommentLoadMore(replayCommentloadmore) {
    this.replayCommentloadmore = replayCommentloadmore;
    notifyListeners();
  }

/* Replay Comment Pagination End */

  addremoveSubscribe(touserid, type) {
    if ((detailsModel.result?[0].isSubscribe ?? 0) == 0) {
      detailsModel.result?[0].isSubscribe = 1;
      detailsModel.result?[0].totalSubscriber =
          (detailsModel.result?[0].totalSubscriber ?? 0) + 1;
    } else {
      detailsModel.result?[0].isSubscribe = 0;
      if ((detailsModel.result?[0].totalSubscriber ?? 0) > 0) {
        detailsModel.result?[0].totalSubscriber =
            (detailsModel.result?[0].totalSubscriber ?? 0) - 1;
      }
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

  Future<void> addVideoView(contenttype, contentid) async {
    debugPrint("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    debugPrint("addPostView status :==> ${addViewModel.status}");
    debugPrint("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  like(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDislike = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 2) {
      detailsModel.result?[0].isUserLikeDislike = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
      if ((detailsModel.result?[0].totalDislike ?? 0) > 0) {
        detailsModel.result?[0].totalDislike =
            (detailsModel.result?[0].totalDislike ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDislike = 0;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  dislike(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDislike = 2;
      detailsModel.result?[0].totalDislike =
          (detailsModel.result?[0].totalDislike ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 1) {
      detailsModel.result?[0].isUserLikeDislike = 2;
      detailsModel.result?[0].totalDislike =
          (detailsModel.result?[0].totalDislike ?? 0) + 1;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDislike = 0;
      if ((detailsModel.result?[0].totalDislike ?? 0) > 0) {
        detailsModel.result?[0].totalDislike =
            (detailsModel.result?[0].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  Future<void> addLikeDislike(contenttype, contentid, status, episodeId) async {
    debugPrint("addLikeDislike postId :==> $contentid");
    addRemoveLikeDislikeModel = await ApiService()
        .addRemoveLikeDislike(contenttype, contentid, status, episodeId);
    debugPrint(
        "addLikeDislike status :==> ${addRemoveLikeDislikeModel.status}");
    debugPrint(
        "addLikeDislike message :==> ${addRemoveLikeDislikeModel.message}");
  }

  Future<void> addContentHistory(
      contenttype, contentid, stoptime, episodeid) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService()
        .addContentToHistory(contenttype, contentid, stoptime, episodeid);
    loading = false;
  }

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService()
        .removeContentToHistory(contenttype, contentid, episodeid);
    loading = false;
  }

  storeReplayCommentId(iscommentId) async {
    commentId = iscommentId;
    log("Comment ID ==> $commentId");
    notifyListeners();
  }

  clearProvider() {
    detailsModel = DetailsModel();
    addCommentModel = AddCommentModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    likedislikemodel = SuccessModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    getcommentModel = CommentModel();
    replayCommentModel = ReplayCommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    addcommentloading = false;
    commentloadmore = false;
    addreplaycommentloading = false;
    loading = false;
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }

  clearComment() {
    replayCommentModel = ReplayCommentModel();
    replaycommentList?.clear();
    replaycommentList = [];
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }
}
