import 'package:maring/model/addcontenttohistorymodel.dart';
import 'package:maring/model/addremovelikedislikemodel.dart';
import 'package:maring/model/addviewmodel.dart';
import 'package:maring/model/episodebyplaylistmodel.dart' as playlist;
import 'package:maring/model/episodebyplaylistmodel.dart';
import 'package:maring/model/episodebypodcastmodel.dart' as podcast;
import 'package:maring/model/episodebypodcastmodel.dart';
import 'package:maring/model/episodebyradio.dart' as radio;
import 'package:maring/model/episodebyradio.dart';
import 'package:maring/model/removecontenttohistorymodel.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MusicDetailProvider extends ChangeNotifier {
  EpidoseByPodcastModel epidoseByPodcastModel = EpidoseByPodcastModel();
  EpidoseByRadioModel epidoseByRadioModel = EpidoseByRadioModel();
  EpisodebyplaylistModel episodebyplaylistModel = EpisodebyplaylistModel();
  AddViewModel addViewModel = AddViewModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();
  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  bool loading = false;
  int tabindex = 0;
  bool isexpend = false;
  String istype = "episode";
  double isheight = Dimens.musicdetailAnimateContainerheightNormal;

  List<podcast.Result>? podcastEpisodeList = [];
  int? podcasttotalRows, podcasttotalPage, podcastcurrentPage;
  bool? podcastisMorePage;

  List<playlist.Result>? playlistEpisodeList = [];
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistisMorePage;

  List<radio.Result>? radioEpisodeList = [];
  int? radiototalRows, radiototalPage, radiocurrentPage;
  bool? radioisMorePage;

  bool loadmore = false;

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
        debugPrint('Now on page ==========> $playlistcurrentPage');
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
              "Podcast EpisodeList length :==> ${(podcastEpisodeList?.length ?? 0)}");
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
        debugPrint('Now on page ==========> $playlistcurrentPage');
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
              "RadioList length :==> ${(radioEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRadioPaginationData(int? radiototalRows, int? radiototalPage,
      int? radiocurrentPage, bool? radioisMorePage) {
    this.radiocurrentPage = radiocurrentPage;
    this.radiototalRows = radiototalRows;
    this.radiototalPage = radiototalPage;
    radioisMorePage = radioisMorePage;
    notifyListeners();
  }

/* PlayList Episode */
  Future<void> getEpisodeByPlaylist(playlistId, contentType, pageNo) async {
    loading = true;
    episodebyplaylistModel =
        await ApiService().episodeByPlaylist(playlistId, contentType, pageNo);
    if (episodebyplaylistModel.status == 200) {
      setPlaylistPaginationData(
          episodebyplaylistModel.totalRows,
          episodebyplaylistModel.totalPage,
          episodebyplaylistModel.currentPage,
          episodebyplaylistModel.morePage);
      if (episodebyplaylistModel.result != null &&
          (episodebyplaylistModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $playlistcurrentPage');
        if (episodebyplaylistModel.result != null &&
            (episodebyplaylistModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (episodebyplaylistModel.result?.length ?? 0);
              i++) {
            playlistEpisodeList
                ?.add(episodebyplaylistModel.result?[i] ?? playlist.Result());
          }
          final Map<int, playlist.Result> postMap = {};
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

  setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistisMorePage) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistisMorePage = playlistisMorePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
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

  Future<void> addLikeDislike(contenttype, contentid, status, episodeId) async {
    debugPrint("addLikeDislike postId :==> $contentid");
    addRemoveLikeDislikeModel = await ApiService()
        .addRemoveLikeDislike(contenttype, contentid, status, episodeId);
    debugPrint(
        "addLikeDislike status :==> ${addRemoveLikeDislikeModel.status}");
    debugPrint(
        "addLikeDislike message :==> ${addRemoveLikeDislikeModel.message}");
  }

  animateSheet(bool expend, double height) {
    isexpend = expend;
    isheight = height;
    notifyListeners();
  }

  changeMusicTab(type) {
    istype = type;
    notifyListeners();
  }

  Future<void> addView(contenttype, contentid) async {
    debugPrint("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    debugPrint("addPostView status :==> ${addViewModel.status}");
    debugPrint("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  clearProvider() {
    epidoseByPodcastModel = EpidoseByPodcastModel();
    epidoseByRadioModel = EpidoseByRadioModel();
    episodebyplaylistModel = EpisodebyplaylistModel();
    addViewModel = AddViewModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    removeContentHistoryModel = RemoveContentHistoryModel();
    addRemoveLikeDislikeModel = AddRemoveLikeDislikeModel();
    loading = false;
    tabindex = 0;
    isexpend = false;
    istype = "episode";
    isheight = Dimens.musicdetailAnimateContainerheightNormal;

    podcastEpisodeList = [];
    podcastEpisodeList?.clear();
    podcasttotalRows;
    podcasttotalPage;
    podcastcurrentPage;
    podcastisMorePage;

    playlistEpisodeList = [];
    playlistEpisodeList?.clear();
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistisMorePage;

    radioEpisodeList = [];
    radioEpisodeList?.clear();
    radiototalRows;
    radiototalPage;
    radiocurrentPage;
    radioisMorePage;

    loadmore = false;
  }
}
