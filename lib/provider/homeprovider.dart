import 'package:maring/model/addcontentreportmodel.dart';
import 'package:maring/model/addremovecontenttoplaylistmodel.dart';
import 'package:maring/model/addremovewatchlatermodel.dart';
import 'package:maring/model/categorymodel.dart';
import 'package:maring/model/getcontentbychannelmodel.dart' as playlist;
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/getreportreasonmodel.dart' as report;
import 'package:maring/model/getreportreasonmodel.dart';
import 'package:maring/model/profilemodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/model/categorymodel.dart' as cat;
import 'package:maring/model/videolistmodel.dart' as video;
import 'package:maring/webservice/apiservice.dart';
import '../model/videolistmodel.dart';

class HomeProvider extends ChangeNotifier {
  VideoListModel videolistmodel = VideoListModel();
  CategoryModel categorymodel = CategoryModel();
  GetRepostReasonModel getRepostReasonModel = GetRepostReasonModel();
  AddContentReportModel addContentReportModel = AddContentReportModel();
  ProfileModel profileModel = ProfileModel();
  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  SuccessModel createPlaylistModel = SuccessModel();
  bool loading = false;
  int catindex = 0;
  String categoryid = "0";
  int position = 0;
  bool ischack = false;

  bool addcontentreortloading = false,
      addremovecontentplaylistloading = false,
      addwatchlaterloading = false;

/* Video List Data */
  List<video.Result>? videoList = [];
  bool videoloadMore = false, videoloading = false;
  int? videolisttotalRows, videolisttotalPage, videolistcurrentPage;
  bool? videolistisMorePage;

  /* Video List Data */
  List<cat.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;

  /* Report Reason List Field */
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  String reasonId = "";
  int? reportPosition = 0;
  bool isSelectReason = false;

  /* Get PlayList Field */
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistmorePage;
  List<playlist.Result>? playlistData = [];
  bool playlistLoading = false, playlistLoadmore = false;
  String playlistId = "";
  int? playlistPosition;
  bool isSelectPlaylist = false;
  int isType = 0;

  setLoading(bool isLoading) {
    categoryloading = isLoading;
    videoloading = isLoading;
    notifyListeners();
  }

  setCategoryLoading(bool isLoading) {
    categoryloading = isLoading;
    notifyListeners();
  }

  setVideoLoading(bool isLoading) {
    videoloading = isLoading;
    notifyListeners();
  }

/* CategoryList Api Start */

  Future<void> getVideoCategory(pageNo) async {
    categoryloading = true;
    categorymodel = await ApiService().videoCategory(pageNo);
    if (categorymodel.status == 200) {
      setCategoryPaginationData(
          categorymodel.totalRows,
          categorymodel.totalPage,
          categorymodel.currentPage,
          categorymodel.morePage);
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(categorymodel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $categorycurrentPage');
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(categorymodel.result?.length ?? 0)}");
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            categorydataList?.add(cat.Result(id: 0, name: "Home"));
            categorydataList?.add(categorymodel.result?[i] ?? cat.Result());
          }
          final Map<int, cat.Result> postMap = {};
          categorydataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          categorydataList = postMap.values.toList();
          debugPrint(
              "categoryList length :==> ${(categorydataList?.length ?? 0)}");
          setCategoryLoadMore(false);
        }
      }
    }
    categoryloading = false;
    notifyListeners();
  }

  setCategoryPaginationData(int? categorytotalRows, int? categorytotalPage,
      int? categorycurrentPage, bool? videolistisMorePage) {
    this.categorycurrentPage = categorycurrentPage;
    this.categorytotalRows = categorytotalRows;
    this.categorytotalPage = categorytotalPage;
    categoryisMorePage = categoryisMorePage;
    notifyListeners();
  }

  setCategoryLoadMore(categoryloadMore) {
    this.categoryloadMore = categoryloadMore;
    notifyListeners();
  }

/* CategoryList Api End */

/* Video List Api Start */

  Future<void> getvideolist(ishomePage, categoryid, pageNo) async {
    videoloading = true;
    videolistmodel =
        await ApiService().videolist(ishomePage, categoryid, pageNo);
    if (videolistmodel.status == 200) {
      setVideoListPaginationData(
          videolistmodel.totalRows,
          videolistmodel.totalPage,
          videolistmodel.currentPage,
          videolistmodel.morePage);

      if (videolistmodel.result != null &&
          (videolistmodel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(videolistmodel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $videolistcurrentPage');
        if (videolistmodel.result != null &&
            (videolistmodel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(videolistmodel.result?.length ?? 0)}");
          for (var i = 0; i < (videolistmodel.result?.length ?? 0); i++) {
            videoList?.add(videolistmodel.result?[i] ?? video.Result());
          }
          final Map<int, video.Result> postMap = {};
          videoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          videoList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(videoList?.length ?? 0)}");
          setVideoListLoadMore(false);
        }
      }
    }
    videoloading = false;
    notifyListeners();
  }

  setVideoListPaginationData(int? videolisttotalRows, int? videolisttotalPage,
      int? videolistcurrentPage, bool? videolistisMorePage) {
    this.videolistcurrentPage = videolistcurrentPage;
    this.videolisttotalRows = videolisttotalRows;
    this.videolisttotalPage = videolisttotalPage;
    videolistisMorePage = videolistisMorePage;
    notifyListeners();
  }

  setVideoListLoadMore(videoloadMore) {
    this.videoloadMore = videoloadMore;
    notifyListeners();
  }

/* Video List Api End */

/* Get Report Reason List With Pagination Start */

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

  selectReportReason(int index, bool selectReason, isReasonId) {
    reportPosition = index;
    isSelectReason = selectReason;
    reasonId = isReasonId;
    debugPrint("reasonId===> $reasonId");
    notifyListeners();
  }

/* Get Report Reason List With Pagination End */

  addContentReport(reportUserid, contentid, message, contenttype) async {
    addcontentreortloading = true;
    addContentReportModel = await ApiService()
        .addContentReport(reportUserid, contentid, message, contenttype);
    addcontentreortloading = false;
    notifyListeners();
  }

  /* Type = 1 = Add */
  /* Type = 2 = Remove */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    addremovecontentplaylistloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    addremovecontentplaylistloading = false;
    notifyListeners();
  }

/* Get Playlist Created By Perticular User Start */

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    debugPrint("Playlist Position :==> $playlistPosition");
    debugPrint("getPostList pageNo :==> $pageNo");
    playlistLoading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    debugPrint(
        "getPlaylistList status :===> ${getContentbyChannelModel.status}");
    debugPrint(
        "getPlaylistList message :==> ${getContentbyChannelModel.message}");
    if (getContentbyChannelModel.status == 200) {
      setPlaylistPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        debugPrint(
            "Playlist length first:==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        debugPrint(
            "Playlist length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        for (var i = 0;
            i < (getContentbyChannelModel.result?.length ?? 0);
            i++) {
          playlistData
              ?.add(getContentbyChannelModel.result?[i] ?? playlist.Result());
        }
        final Map<int, playlist.Result> postMap = {};
        playlistData?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        playlistData = postMap.values.toList();
        debugPrint("Playlist length :==> ${(playlistData?.length ?? 0)}");
        setPlaylistLoadMore(false);
      }
    }
    playlistLoading = false;
    notifyListeners();
  }

  setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistmorePage) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistmorePage = playlistmorePage;
    notifyListeners();
  }

  setPlaylistLoadMore(playlistLoadmore) {
    this.playlistLoadmore = playlistLoadmore;
    notifyListeners();
  }

  selectPlaylist(int index, isPlaylistId, isSelect) {
    playlistPosition = index;
    playlistId = isPlaylistId;
    isSelectPlaylist = isSelect;
    debugPrint("reasonId===> $playlistId");
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
    createPlaylistModel =
        await ApiService().createPlayList(chennelId, title, playlistType);
    loading = false;
  }

/* Get Playlist Created By Perticular User End */

  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addwatchlaterloading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    addwatchlaterloading = false;
    notifyListeners();
  }

  getprofile(touserid) async {
    loading = true;
    profileModel = await ApiService().profile(touserid);
    loading = false;
    notifyListeners();
  }

  selectCategory(int index, catid) {
    catindex = index;
    categoryid = catid;
    notifyListeners();
  }

  fillCheckbox(int index, bool chack) {
    position = index;
    ischack = chack;
    notifyListeners();
  }

  clearPlaylistData() {
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistData?.clear();
    playlistLoading = false;
    playlistLoadmore = false;
    isSelectPlaylist = false;
    playlistId = "";
    playlistPosition;
    isType = 0;
  }

  clearProvider() {
    videolistmodel = VideoListModel();
    categorymodel = CategoryModel();
    getRepostReasonModel = GetRepostReasonModel();
    addContentReportModel = AddContentReportModel();
    profileModel = ProfileModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    createPlaylistModel = SuccessModel();
    loading = false;
    catindex = 0;
    categoryid = "0";
    position = 0;
    ischack = false;
    addcontentreortloading = false;
    addremovecontentplaylistloading = false;
    addwatchlaterloading = false;
/* Video List Data */
    videoList = [];
    videoList?.clear();
    videoloadMore = false;
    videoloading = false;
    videolisttotalRows;
    videolisttotalPage;
    videolistcurrentPage;
    videolistisMorePage;
    /* Video List Data */
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
    /* Report Reason List Field */
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reasonId = "";
    reportPosition = 0;
    isSelectReason = false;
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistData?.clear();
    playlistLoading = false;
    playlistLoadmore = false;
    isSelectPlaylist = false;
    playlistId = "";
    playlistPosition;
    isType = 0;
  }

  clearSelectReportReason() {
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reasonId = "";
    reportPosition = 0;
    isSelectReason = false;
  }

  clearVideoListData() {
    videoList?.clear();
    videoList = [];
    videolistmodel = VideoListModel();
  }
}

class CategoryListModel {
  String categoryid;
  String name;

  CategoryListModel(this.categoryid, this.name);
}
