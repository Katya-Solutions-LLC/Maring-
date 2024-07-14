import 'package:maring/model/addcontentreportmodel.dart';
import 'package:maring/model/addremovecontenttoplaylistmodel.dart';
import 'package:maring/model/addremovewatchlatermodel.dart';
import 'package:maring/model/episodebyplaylistmodel.dart' as playlistdata;
import 'package:maring/model/episodebyplaylistmodel.dart';
import 'package:maring/model/episodebypodcastmodel.dart' as podcast;
import 'package:maring/model/episodebypodcastmodel.dart';
import 'package:maring/model/episodebyradio.dart' as radio;
import 'package:maring/model/episodebyradio.dart';
import 'package:maring/model/getcontentbychannelmodel.dart' as playlist;
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/getreportreasonmodel.dart' as report;
import 'package:maring/model/getreportreasonmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class ContentDetailProvider extends ChangeNotifier {
  EpidoseByPodcastModel epidoseByPodcastModel = EpidoseByPodcastModel();
  EpidoseByRadioModel epidoseByRadioModel = EpidoseByRadioModel();
  EpisodebyplaylistModel episodebyplaylistModel = EpisodebyplaylistModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  GetRepostReasonModel getRepostReasonModel = GetRepostReasonModel();
  AddContentReportModel addContentReportModel = AddContentReportModel();
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel createPlaylistModel = SuccessModel();

  bool addwatchlaterloading = false,
      addcontentreportloading = false,
      getcontentbyChannelloading = false,
      addremovecontentplaylistloading = false,
      loading = false,
      loadmore = false;
  bool deletecontentLoading = false;
  int deleteItemIndex = 0;

  int position = 0;
  bool ischack = false;

/* Podcast Episode Pagination */
  List<podcast.Result>? podcastEpisodeList = [];
  int? podcasttotalRows, podcasttotalPage, podcastcurrentPage;
  bool? podcastisMorePage;

/* Radio Episode Pagination */
  List<radio.Result>? radioEpisodeList = [];
  int? radiototalRows, radiototalPage, radiocurrentPage;
  bool? radioisMorePage;

/* Playlist Episode Pagination */
  List<playlistdata.Result>? playlistEpisodeList = [];
  int? playlistdatatotalRows, playlistdatatotalPage, playlistdatacurrentPage;
  bool? playlistdataisMorePage;

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

/* Podcast Episode */
  Future<void> getEpisodeByPodcast(podcastId, pageNo) async {
    loading = true;
    epidoseByPodcastModel =
        await ApiService().episodeByPodcast(podcastId, pageNo);
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
          epidoseByPodcastModel.totalRows,
          epidoseByPodcastModel.totalPage,
          epidoseByPodcastModel.currentPage,
          epidoseByPodcastModel.morePage);
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $podcastcurrentPage');
        if (epidoseByPodcastModel.result != null &&
            (epidoseByPodcastModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (epidoseByPodcastModel.result?.length ?? 0);
              i++) {
            podcastEpisodeList
                ?.add(epidoseByPodcastModel.result?[i] ?? podcast.Result());
          }
          final Map<int, podcast.Result> postMap = {};
          podcastEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          podcastEpisodeList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(podcastEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPodcastPaginationData(int? podcasttotalRows, int? podcasttotalPage,
      int? podcastcurrentPage, bool? podcastisMorePage) {
    this.podcastcurrentPage = podcastcurrentPage;
    this.podcasttotalRows = podcasttotalRows;
    this.podcasttotalPage = podcasttotalPage;
    podcastisMorePage = podcastisMorePage;
    notifyListeners();
  }

/* Radio Episode */
  Future<void> getEpisodeByRadio(radioId, pageNo) async {
    loading = true;
    epidoseByRadioModel = await ApiService().episodeByRadio(radioId, pageNo);
    if (epidoseByRadioModel.status == 200) {
      setRadioPaginationData(
          epidoseByRadioModel.totalRows,
          epidoseByRadioModel.totalPage,
          epidoseByRadioModel.currentPage,
          epidoseByRadioModel.morePage);
      if (epidoseByRadioModel.result != null &&
          (epidoseByRadioModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $podcastcurrentPage');
        if (epidoseByRadioModel.result != null &&
            (epidoseByRadioModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}");
          for (var i = 0; i < (epidoseByRadioModel.result?.length ?? 0); i++) {
            radioEpisodeList
                ?.add(epidoseByRadioModel.result?[i] ?? radio.Result());
          }
          final Map<int, radio.Result> postMap = {};
          radioEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          radioEpisodeList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(radioEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRadioPaginationData(int? radiototalRows, int? radiototalPage,
      int? radiocurrentPage, bool? podcastisMorePage) {
    this.radiocurrentPage = radiocurrentPage;
    this.radiototalRows = radiototalRows;
    this.radiototalPage = radiototalPage;
    radioisMorePage = radioisMorePage;
    notifyListeners();
  }

/* Playlist Episode */
  Future<void> getEpisodeByPlaylist(playlistId, contentType, pageNo) async {
    loading = true;
    episodebyplaylistModel =
        await ApiService().episodeByPlaylist(playlistId, contentType, pageNo);
    if (episodebyplaylistModel.status == 200) {
      setPlaylistDataPaginationData(
          episodebyplaylistModel.totalRows,
          episodebyplaylistModel.totalPage,
          episodebyplaylistModel.currentPage,
          episodebyplaylistModel.morePage);
      if (episodebyplaylistModel.result != null &&
          (episodebyplaylistModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $podcastcurrentPage');
        if (episodebyplaylistModel.result != null &&
            (episodebyplaylistModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (episodebyplaylistModel.result?.length ?? 0);
              i++) {
            playlistEpisodeList?.add(
                episodebyplaylistModel.result?[i] ?? playlistdata.Result());
          }
          final Map<int, playlistdata.Result> postMap = {};
          playlistEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          playlistEpisodeList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(playlistEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPlaylistDataPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistisMorePage) {
    this.playlisttotalRows = playlisttotalRows;
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalPage = playlisttotalPage;
    playlistisMorePage = playlistisMorePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
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

  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    addremovecontentplaylistloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    addremovecontentplaylistloading = false;
    notifyListeners();
  }

  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addwatchlaterloading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    addwatchlaterloading = false;
    notifyListeners();
  }

  addContentReport(reportUserid, contentid, message, contenttype) async {
    addcontentreportloading = true;
    addContentReportModel = await ApiService()
        .addContentReport(reportUserid, contentid, message, contenttype);
    addcontentreportloading = false;
    notifyListeners();
  }

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

  getDeleteContent(index, contenttype, contentid, episodeid) async {
    deleteItemIndex = index;
    setDeletePlaylistLoading(true);
    successModel =
        await ApiService().deleteContent(contenttype, contentid, episodeid);
    setDeletePlaylistLoading(false);
    podcastEpisodeList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecontentLoading = isSending;
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
    epidoseByPodcastModel = EpidoseByPodcastModel();
    epidoseByRadioModel = EpidoseByRadioModel();
    episodebyplaylistModel = EpisodebyplaylistModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    getRepostReasonModel = GetRepostReasonModel();
    addContentReportModel = AddContentReportModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    successModel = SuccessModel();
    createPlaylistModel = SuccessModel();
    addwatchlaterloading = false;
    addcontentreportloading = false;
    getcontentbyChannelloading = false;
    addremovecontentplaylistloading = false;
    loading = false;
    loadmore = false;
    deletecontentLoading = false;
    deleteItemIndex = 0;
    position = 0;
    ischack = false;
/* Podcast Episode Pagination */
    podcastEpisodeList = [];
    podcasttotalRows;
    podcasttotalPage;
    podcastcurrentPage;
    podcastisMorePage;
/* Radio Episode Pagination */
    radioEpisodeList = [];
    radiototalRows;
    radiototalPage;
    radiocurrentPage;
    radioisMorePage;
/* Playlist Episode Pagination */
    playlistEpisodeList = [];
    playlistdatatotalRows;
    playlistdatatotalPage;
    playlistdatacurrentPage;
    playlistdataisMorePage;
/* Report Reason List Field */
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
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
    playlistLoading = false;
    playlistLoadmore = false;
    playlistId = "";
    playlistPosition;
    isSelectPlaylist = false;
    isType = 0;
  }

  clearSelectReportReason() {
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reasonId = "";
    reportPosition = 0;
    isSelectReason = false;
  }
}
