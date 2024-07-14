import 'package:maring/model/addcommentmodel.dart';
import 'package:maring/model/addcontentreportmodel.dart';
import 'package:maring/model/addremovecontenttoplaylistmodel.dart';
import 'package:maring/model/addremovelikedislikemodel.dart';
import 'package:maring/model/addremovesubscribemodel.dart';
import 'package:maring/model/addremovewatchlatermodel.dart';
import 'package:maring/model/commentmodel.dart' as comment;
import 'package:maring/model/commentmodel.dart';
import 'package:maring/model/deletecommentmodel.dart';
import 'package:maring/model/getcontentbychannelmodel.dart' as usercontent;
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/getreportreasonmodel.dart' as report;
import 'package:maring/model/getreportreasonmodel.dart';
import 'package:maring/model/replaycommentmodel.dart' as replaycomment;
import 'package:maring/model/replaycommentmodel.dart';
import 'package:maring/model/shortmodel.dart' as shortlist;
import 'package:maring/model/watchlatermodel.dart' as watchlatershort;
import 'package:maring/model/watchlatermodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import '../model/shortmodel.dart';

class ShortProvider extends ChangeNotifier {
  ShortModel shortModel = ShortModel();
  CommentModel getcommentModel = CommentModel();
  AddCommentModel addCommentModel = AddCommentModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  GetWatchlaterModel watchlaterModel = GetWatchlaterModel();

  bool loading = false;
  int catindex = 0;

  /* All Short Field */
  List<shortlist.Result>? shortVideoList = [];
  int? totalRows, totalPage, currentPage;
  bool? morePage;

  /* Perticular User Short Field */
  List<usercontent.Result>? profileShortList = [];
  int? profileShorttotalRows, profileShorttotalPage, profileShortcurrentPage;
  bool? userShortmorePage;

  /* WatchLater Short Field */
  List<watchlatershort.Result>? watchlaterShortList = [];
  int? watchlaterShorttotalRows,
      watchlaterShorttotalPage,
      watchlaterShortcurrentPage;
  bool? watchlaterShortmorePage;

  /* Get Comment Field */
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentLoadmore = false;
  bool addreplaycommentloading = false;
  bool addcommentloading = false;
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;

  /* Report Reason Field */
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  int? repostposition = 0;
  bool isSelectReason = false;
  String reasonId = "";

  GetRepostReasonModel getRepostReasonModel = GetRepostReasonModel();
  AddContentReportModel addContentReportModel = AddContentReportModel();
  bool addcontentreortloading = false;

  ReplayCommentModel replayCommentModel = ReplayCommentModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  bool addremovecontentplaylistloading = false,
      getcontentbyChannelloading = false;
  int selectPlaylistindex = 0;
  bool isselectplaylist = false;

  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  bool addwatchlaterloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  List<replaycomment.Result>? replaycommentList = [];
  bool replayCommentloadmore = false, replaycommentloding = false;
  String replayCommentId = "";
  String commentId = "";

/* Bottom Navigation All Short Api Start */
  Future<void> getShortList(pageNo) async {
    debugPrint("getPostList pageNo :==> $pageNo");
    loading = true;
    shortModel = await ApiService().shrotslist(pageNo);
    debugPrint("getPostList status :===> ${shortModel.status}");
    debugPrint("getPostList message :==> ${shortModel.message}");
    if (shortModel.status == 200) {
      setPaginationData(shortModel.totalRows, shortModel.totalPage,
          shortModel.currentPage, shortModel.morePage);
      if (shortModel.result != null && (shortModel.result?.length ?? 0) > 0) {
        debugPrint("postModel length :==> ${(shortModel.result?.length ?? 0)}");
        int lastPosition = 0;
        if ((shortVideoList?.length ?? 0) == 0) {
          lastPosition = 0;
        } else {
          lastPosition = (shortVideoList?.length ?? 0);
        }
        debugPrint("lastPosition :============> $lastPosition");
        for (var i = 0; i < (shortModel.result?.length ?? 0); i++) {
          shortVideoList?.add(shortModel.result?[i] ?? shortlist.Result());
        }
        final Map<int, shortlist.Result> postMap = {};
        shortVideoList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        shortVideoList = postMap.values.toList();
        debugPrint(
            "shortVideoList length :==> ${(shortVideoList?.length ?? 0)}");
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
    this.morePage = morePage;
    notifyListeners();
  }
/* Bottom Navigation All Short Api End*/

/* Profile Page Perticular User Short Api Start */
  Future<void> getcontentbyChannelShort(
      userid, chennelId, contenttype, pageNo) async {
    loading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    if (getContentbyChannelModel.status == 200) {
      setUserShortPaginationData(
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
            profileShortList?.add(
                getContentbyChannelModel.result?[i] ?? usercontent.Result());
          }
          final Map<int, usercontent.Result> postMap = {};
          profileShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          profileShortList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(profileShortList?.length ?? 0)}");
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setUserShortPaginationData(
      int? profileShorttotalRows,
      int? profileShorttotalPage,
      int? profileShortcurrentPage,
      bool? profileShortmorePage) {
    this.profileShortcurrentPage = profileShortcurrentPage;
    this.profileShorttotalRows = profileShorttotalRows;
    this.profileShorttotalPage = profileShorttotalPage;
    profileShortmorePage = profileShortmorePage;
    notifyListeners();
  }
/* Profile Page Perticular User Short Api End */

/* Get Content By WatchLater Section Start*/
  Future<void> getContentByWatchLater(contentType, pageNo) async {
    loading = true;
    watchlaterModel = await ApiService().watchLaterList(contentType, pageNo);
    if (watchlaterModel.status == 200) {
      setWatchLaterShortPaginationData(
          watchlaterModel.totalRows,
          watchlaterModel.totalPage,
          watchlaterModel.currentPage,
          watchlaterModel.morePage);
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
            watchlaterShortList
                ?.add(watchlaterModel.result?[i] ?? watchlatershort.Result());
          }
          final Map<int, watchlatershort.Result> postMap = {};
          watchlaterShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          watchlaterShortList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(watchlaterShortList?.length ?? 0)}");
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setWatchLaterShortPaginationData(
      int? watchlaterShorttotalRows,
      int? watchlaterShorttotalPage,
      int? watchlaterShortcurrentPage,
      bool? watchlaterShortmorePage) {
    this.watchlaterShortcurrentPage = watchlaterShortcurrentPage;
    this.watchlaterShorttotalRows = watchlaterShorttotalRows;
    this.watchlaterShorttotalPage = watchlaterShorttotalPage;
    watchlaterShortmorePage = watchlaterShortmorePage;
    notifyListeners();
  }

/* Get Content By WatchLater Section End */
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

  setCommentLoadMore(commentLoadmore) {
    this.commentLoadmore = commentLoadmore;
    notifyListeners();
  }

/* Add Comment And Add Replay Comment Short */
  getaddcomment(position, contenttype, contentid, episodeid, comment, commentid,
      isShortPage) {
    if (isShortPage == "profile") {
      profileShortList?[position].totalComment =
          (profileShortList?[position].totalComment ?? 0) + 1;
    } else if (isShortPage == "watchlater") {
      watchlaterShortList?[position].totalComment =
          (watchlaterShortList?[position].totalComment ?? 0) + 1;
    } else {
      shortVideoList?[position].totalComment =
          (shortVideoList?[position].totalComment ?? 0) + 1;
    }
    notifyListeners();
    addcomment(contenttype, contentid, episodeid, comment, commentid);
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

  addcomment(contenttype, contentid, episodeid, comment, commentid) async {
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

/* Delete Comment And Delete Replay Comment */

  getDeleteComment(commentid, isComment, index, isShortPage) async {
    deleteItemIndex = index;
    if (isComment == true) {
      if (isShortPage == "profile") {
        profileShortList?[index].totalComment =
            (profileShortList?[index].totalComment ?? 0) - 1;
      } else if (isShortPage == "watchlater") {
        watchlaterShortList?[index].totalComment =
            (watchlaterShortList?[index].totalComment ?? 0) - 1;
      } else {
        shortVideoList?[index].totalComment =
            (shortVideoList?[index].totalComment ?? 0) - 1;
      }
    }
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

/* Simple Short Like And Dislike */
  shortLike(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDislike = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 2) {
      shortVideoList?[position].isUserLikeDislike = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
      if ((shortVideoList?[position].totalDislike ?? 0) > 0) {
        shortVideoList?[position].totalDislike =
            (shortVideoList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDislike = 0;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  shortDislike(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDislike = 2;
      shortVideoList?[position].totalDislike =
          (shortVideoList?[position].totalDislike ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 1) {
      shortVideoList?[position].isUserLikeDislike = 2;
      shortVideoList?[position].totalDislike =
          (shortVideoList?[position].totalDislike ?? 0) + 1;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDislike = 0;
      if ((shortVideoList?[position].totalDislike ?? 0) > 0) {
        shortVideoList?[position].totalDislike =
            (shortVideoList?[position].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

/* Profile Short Like And Dislike */
  profileShortLike(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDislike ?? 0) == 0) {
      profileShortList?[position].isUserLikeDislike = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDislike ?? 0) == 2) {
      profileShortList?[position].isUserLikeDislike = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
      if ((profileShortList?[position].totalDislike ?? 0) > 0) {
        profileShortList?[position].totalDislike =
            (profileShortList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDislike = 0;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  profileShortDislike(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDislike ?? 0) == 0) {
      profileShortList?[position].isUserLikeDislike = 2;
      profileShortList?[position].totalDislike =
          (profileShortList?[position].totalDislike ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDislike ?? 0) == 1) {
      profileShortList?[position].isUserLikeDislike = 2;
      profileShortList?[position].totalDislike =
          (profileShortList?[position].totalDislike ?? 0) + 1;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDislike = 0;
      if ((profileShortList?[position].totalDislike ?? 0) > 0) {
        profileShortList?[position].totalDislike =
            (profileShortList?[position].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

/* WatchLater Short Like And Dislike */
  watchLaterShortLike(position, contenttype, contentid, status, episodeId) {
    if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDislike = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 2) {
      watchlaterShortList?[position].isUserLikeDislike = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
      if ((watchlaterShortList?[position].totalDislike ?? 0) > 0) {
        watchlaterShortList?[position].totalDislike =
            (watchlaterShortList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDislike = 0;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  watchLaterShortDislike(position, contenttype, contentid, status, episodeId) {
    if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDislike = 2;
      watchlaterShortList?[position].totalDislike =
          (watchlaterShortList?[position].totalDislike ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 1) {
      watchlaterShortList?[position].isUserLikeDislike = 2;
      watchlaterShortList?[position].totalDislike =
          (watchlaterShortList?[position].totalDislike ?? 0) + 1;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDislike = 0;
      if ((watchlaterShortList?[position].totalDislike ?? 0) > 0) {
        watchlaterShortList?[position].totalDislike =
            (watchlaterShortList?[position].totalDislike ?? 0) - 1;
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

/* Get Report Reason List With Pagination */
  Future<void> getReportReason(type, pageNo) async {
    debugPrint("getPostList pageNo :==> $pageNo");
    getcontentreportloading = true;
    getRepostReasonModel = await ApiService().reportReason(type, pageNo);
    debugPrint("getPostList status :===> ${getRepostReasonModel.status}");
    debugPrint("getPostList message :==> ${getRepostReasonModel.message}");
    if (getRepostReasonModel.status == 200) {
      setReportReasonPaginationData(
          getRepostReasonModel.totalRows,
          getRepostReasonModel.totalPage,
          getRepostReasonModel.currentPage,
          getRepostReasonModel.morePage);
      if (getRepostReasonModel.result != null &&
          (getRepostReasonModel.result?.length ?? 0) > 0) {
        debugPrint(
            "postModel length first:==> ${(getRepostReasonModel.result?.length ?? 0)}");

        debugPrint(
            "postModel length :==> ${(getRepostReasonModel.result?.length ?? 0)}");

        for (var i = 0; i < (getRepostReasonModel.result?.length ?? 0); i++) {
          reportReasonList
              ?.add(getRepostReasonModel.result?[i] ?? report.Result());
        }
        final Map<int, report.Result> postMap = {};
        reportReasonList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        reportReasonList = postMap.values.toList();
        debugPrint(
            "Report Reason length :==> ${(reportReasonList?.length ?? 0)}");
        setReportReasonLoadMore(false);
      }
    } else {
      debugPrint("else Api");
    }
    getcontentreportloading = false;
    notifyListeners();
  }

  setReportReasonPaginationData(int? reporttotalRows, int? reporttotalPage,
      int? reportcurrentPage, bool? reportmorePage) {
    this.reportcurrentPage = reportcurrentPage;
    this.reporttotalRows = reporttotalRows;
    this.reporttotalPage = reporttotalPage;
    reportmorePage = reportmorePage;
    notifyListeners();
  }

  setReportReasonLoadMore(getcontentreportloadmore) {
    this.getcontentreportloadmore = getcontentreportloadmore;
    notifyListeners();
  }

/* Add Report By Perticular Content */
  addContentReport(reportUserid, contentid, message, contenttype) async {
    addcontentreortloading = true;
    addContentReportModel = await ApiService()
        .addContentReport(reportUserid, contentid, message, contenttype);
    addcontentreortloading = false;
    notifyListeners();
  }

/* Add Remove To Playlist */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    addremovecontentplaylistloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    addremovecontentplaylistloading = false;
    notifyListeners();
  }

/* Get All Playlist For Perticular User */
  getcontentbyChannel(userid, chennelId, contenttype, pageNo) async {
    getcontentbyChannelloading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    getcontentbyChannelloading = false;
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

/* Add Remove Subscribe For Any Channel */
  addremoveSubscribe(touserid, type, isShortPage) {
    if (isShortPage == "profile") {
      if ((profileShortList?[0].isSubscribe ?? 0) == 0) {
        profileShortList?[0].isSubscribe = 1;
      } else {
        profileShortList?[0].isSubscribe = 0;
      }
    } else if (isShortPage == "watchlater") {
      if ((watchlaterShortList?[0].isSubscribe ?? 0) == 0) {
        watchlaterShortList?[0].isSubscribe = 1;
      } else {
        watchlaterShortList?[0].isSubscribe = 0;
      }
    } else {
      if ((shortVideoList?[0].isSubscribe ?? 0) == 0) {
        shortVideoList?[0].isSubscribe = 1;
      } else {
        shortVideoList?[0].isSubscribe = 0;
      }
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

/* Add Remove Watch Later For Short */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addwatchlaterloading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    addwatchlaterloading = false;
    notifyListeners();
  }

/* Some Helper Method Start */
  selectReportReason(int index, selectReason, isReasonId) {
    repostposition = index;
    isSelectReason = selectReason;
    reasonId = isReasonId;
    debugPrint("reasonId===> $reasonId");
    notifyListeners();
  }

  selectPlaylist(int index, bool chack) {
    selectPlaylistindex = index;
    isselectplaylist = chack;
    notifyListeners();
  }
/* Some Helper Method End */

  storeReplayCommentId(isReplayCommentId) async {
    replayCommentId = isReplayCommentId;
    notifyListeners();
  }

  storeContentId(isContentId) async {
    commentId = isContentId;
    notifyListeners();
  }

/* Clear Provider And Perticular Array */
  clearProvider() {
    shortModel = ShortModel();
    getcommentModel = CommentModel();
    addCommentModel = AddCommentModel();
    addRemoveLikeDislikeModel = AddRemoveLikeDislikeModel();
    deleteCommentModel = DeleteCommentModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    watchlaterModel = GetWatchlaterModel();
    loading = false;
    catindex = 0;
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    isSelectReason = false;
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    /* All Short Field */
    shortVideoList = [];
    shortVideoList?.clear();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    /* Perticular User Short Field */
    profileShortList = [];
    profileShortList?.clear();
    profileShorttotalRows;
    profileShorttotalPage;
    profileShortcurrentPage;
    userShortmorePage;
    /* WatchLater Short Field */
    watchlaterShortList = [];
    watchlaterShortList?.clear();
    watchlaterShorttotalRows;
    watchlaterShorttotalPage;
    watchlaterShortcurrentPage;
    watchlaterShortmorePage;
    /* Get Comment Field */
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    addreplaycommentloading = false;
    getRepostReasonModel = GetRepostReasonModel();
    addContentReportModel = AddContentReportModel();
    getcontentreportloading = false;
    addcontentreortloading = false;
    repostposition = 0;
    reasonId = "";
    replayCommentModel = ReplayCommentModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremovecontentplaylistloading = false;
    getcontentbyChannelloading = false;
    selectPlaylistindex = 0;
    isselectplaylist = false;
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    addwatchlaterloading = false;
  }

  clearComment() {
    /* Get Comment Field */
    getcommentModel = CommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentloading = false;
    addreplaycommentloading = false;
    addcommentloading = false;
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }

  clearReplayComment() {
    totalRowsReplayComment;
    totalPageReplayComment;
    currentPageReplayComment;
    morePageReplayComment;
    replaycommentList = [];
    replayCommentloadmore = false;
    replaycommentloding = false;
    replayCommentId = "";
  }

  clearSelectReportReason() {
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    repostposition = 0;
    isSelectReason = false;
    reasonId = "";
  }
}
