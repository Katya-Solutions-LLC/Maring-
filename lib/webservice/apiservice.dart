import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:maring/model/addcommentmodel.dart';
import 'package:maring/model/addcontentreportmodel.dart';
import 'package:maring/model/addcontenttohistorymodel.dart';
import 'package:maring/model/addremoveblockchannelmodel.dart';
import 'package:maring/model/addremovelikedislikemodel.dart';
import 'package:maring/model/addremovesubscribemodel.dart';
import 'package:maring/model/addremovewatchlatermodel.dart';
import 'package:maring/model/addviewmodel.dart';
import 'package:maring/model/deletecommentmodel.dart';
import 'package:maring/model/deleteplaylistmodel.dart';
import 'package:maring/model/editplaylistmodel.dart';
import 'package:maring/model/episodebyplaylistmodel.dart';
import 'package:maring/model/episodebypodcastmodel.dart';
import 'package:maring/model/episodebyradio.dart';
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/getcontentbyplaylistmodel.dart';
import 'package:maring/model/gethistorymodel.dart';
import 'package:maring/model/getmusicbycategorymodel.dart';
import 'package:maring/model/getmusicbylanguagemodel.dart';
import 'package:maring/model/getnotificationmodel.dart';
import 'package:maring/model/getpagesmodel.dart';
import 'package:maring/model/getplaylistcontentmodel.dart';
import 'package:maring/model/getrentcontentbychannelmodel.dart';
import 'package:maring/model/getreportreasonmodel.dart';
import 'package:maring/model/getuserbyrentcontentmodel.dart';
import 'package:maring/model/likevideosmodel.dart';
import 'package:maring/model/packagemodel.dart';
import 'package:maring/model/paymentoptionmodel.dart';
import 'package:maring/model/removecontenttohistorymodel.dart';
import 'package:maring/model/rentsectiondetailmodel.dart';
import 'package:maring/model/rentsectionmodel.dart';
import 'package:maring/model/replaycommentmodel.dart';
import 'package:maring/model/sectiondetailmodel.dart';
import 'package:maring/model/sectionlistmodel.dart';
import 'package:maring/model/shortmodel.dart';
import 'package:maring/model/watchlatermodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/model/categorymodel.dart';
import 'package:maring/model/commentmodel.dart';
import 'package:maring/model/generalsettingmodel.dart';
import 'package:maring/model/loginmodel.dart';
import 'package:maring/model/profilemodel.dart';
import 'package:maring/model/searchhistorymodel.dart';
import 'package:maring/model/searchmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/model/detailmodel.dart';
import 'package:maring/model/videolistmodel.dart';
import 'package:maring/utils/constant.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../model/addremovecontenttoplaylistmodel.dart';

class ApiService {
  String baseurl = Constant().baseurl;
  late Dio dio;

  ApiService() {
    dio = Dio();
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
    );
  }

  Future<GeneralsettingModel> generalsetting() async {
    GeneralsettingModel generalsettingModel;
    String apiname = "general_setting";
    Response response = await dio.post('$baseurl$apiname');
    generalsettingModel = GeneralsettingModel.fromJson(response.data);
    return generalsettingModel;
  }

  Future<LoginModel> login(String type, String email, String mobile,
      String devicetype, String devicetoken) async {
    LoginModel loginModel;
    String apiname = "login";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
          'email': email,
          'mobile_number': mobile,
          'device_type': devicetype,
          'device_token': devicetoken,
        }));

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<LoginModel> otpLogin(
    String type,
    String mobile,
  ) async {
    LoginModel loginModel;
    String apiname = "login";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
          'mobile_number': mobile,
        }));

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<CategoryModel> videoCategory(pageNo) async {
    CategoryModel categoryModel;
    String apiname = "get_video_category";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'page_no': pageNo,
        }));
    categoryModel = CategoryModel.fromJson(response.data);
    return categoryModel;
  }

  Future<SuccessModel> removesearchhistory(id) async {
    SuccessModel removesearchhistoryModel;
    String apiname = "remove_search_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'id': id,
        }));
    removesearchhistoryModel = SuccessModel.fromJson(response.data);
    return removesearchhistoryModel;
  }

  Future<VideoListModel> videolist(ishomePage, categoryid, pageNo) async {
    VideoListModel videolistModel;
    String getvideolist = "get_video_list";
    Response response = await dio.post('$baseurl$getvideolist',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_page': ishomePage,
          'category_id': categoryid,
          'page_no': pageNo,
        }));
    videolistModel = VideoListModel.fromJson(response.data);
    return videolistModel;
  }

  Future<ShortModel> shrotslist(pageNo) async {
    ShortModel shortModel;
    String apiname = "get_reels_list";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    shortModel = ShortModel.fromJson(response.data);
    return shortModel;
  }

  Future<DetailsModel> videodetails(contentid, contenttype) async {
    debugPrint("contentid===>$contentid");
    debugPrint("contenttype===>$contenttype");
    debugPrint("contenttype===>${Constant.userID}");
    DetailsModel detailsModel;
    String apiname = "get_content_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_id': contentid,
          'content_type': contenttype,
        }));
    detailsModel = DetailsModel.fromJson(response.data);
    return detailsModel;
  }

  Future<SearchHistoryModel> searchvideohistory(userid) async {
    SearchHistoryModel searchvideohistoryModel;
    String apiname = "get_search_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        }));
    searchvideohistoryModel = SearchHistoryModel.fromJson(response.data);
    return searchvideohistoryModel;
  }

  Future<SearchModel> searchvideo(userid, String title) async {
    SearchModel searchvideoModel;
    String apiname = "search_video";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'title': title,
        }));
    searchvideoModel = SearchModel.fromJson(response.data);
    return searchvideoModel;
  }

  Future<AddCommentModel> addcomment(
      contenttype, contentid, episodeid, comment, commentid) async {
    AddCommentModel addCommentModel;
    String apiname = "add_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
          'comment': comment,
          'comment_id': commentid,
        }));
    addCommentModel = AddCommentModel.fromJson(response.data);
    return addCommentModel;
  }

  Future<DeleteCommentModel> deleteComment(commentid) async {
    DeleteCommentModel deleteCommentModel;
    String apiname = "delete_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'comment_id': commentid,
        }));
    deleteCommentModel = DeleteCommentModel.fromJson(response.data);
    return deleteCommentModel;
  }

  Future<CommentModel> getcomment(contenttype, videoid, pageNo) async {
    CommentModel getcommentModel;
    String apiname = "get_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': videoid,
          'page_no': pageNo,
        }));
    getcommentModel = CommentModel.fromJson(response.data);
    return getcommentModel;
  }

  Future<ReplayCommentModel> replayComment(commentid, pageNo) async {
    ReplayCommentModel replayCommentModel;
    String apiname = "get_reply_comment";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'comment_id': commentid,
          'page_no': pageNo,
        }));
    replayCommentModel = ReplayCommentModel.fromJson(response.data);
    return replayCommentModel;
  }

  Future<ProfileModel> profile(touserid) async {
    ProfileModel profileModel;
    String apiname = "get_profile";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'to_user_id': touserid,
        }));
    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  Future<SuccessModel> updateprofile(
      String userid,
      String fullname,
      String channelName,
      String email,
      String number,
      File image,
      File coverImage) async {
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userid.isEmpty || userid == "" ? "0" : userid,
          'full_name': fullname,
          'channel_name': channelName,
          'email': email,
          'mobile_number': number,
          "image": (image.path.isNotEmpty)
              ? MultipartFile.fromFileSync(
                  image.path,
                  filename: (image.path),
                )
              : "",
          "cover_img": (coverImage.path.isNotEmpty)
              ? MultipartFile.fromFileSync(
                  coverImage.path,
                  filename: (coverImage.path),
                )
              : "",
        }));
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<PackageModel> package() async {
    PackageModel getpackageModel;
    String apiname = "get_package";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        }));
    getpackageModel = PackageModel.fromJson(response.data);
    return getpackageModel;
  }

  Future<AddViewModel> addView(contenttype, contentid) async {
    AddViewModel addViewModel;
    String apiname = "add_view";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
        }));
    addViewModel = AddViewModel.fromJson(response.data);
    return addViewModel;
  }

  Future<SectionListModel> sectionList(
      ishomescreen, contenttype, pageNo) async {
    log("UserId==> ${Constant.userID}");
    SectionListModel sectionListModel;
    String apiname = "get_music_section";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_screen': ishomescreen,
          'content_type': contenttype,
          'page_no': pageNo,
        }));
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  Future<SuccessModel> createPlayList(chennelId, title, playlistType) async {
    SuccessModel successModel;
    String apiname = "create_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'channel_id': chennelId,
          'title': title,
          'playlist_type': playlistType,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddremoveContentToPlaylistModel> addremoveContenttoPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    AddremoveContentToPlaylistModel addremoveContentToPlaylistModel;
    String apiname = "add_remove_content_to_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'channel_id': chennelId,
          'playlist_id': playlistId,
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
          'type': type,
        }));
    addremoveContentToPlaylistModel =
        AddremoveContentToPlaylistModel.fromJson(response.data);
    return addremoveContentToPlaylistModel;
  }

  Future<GetContentbyChannelModel> contentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    GetContentbyChannelModel getContentbyChannelModel;
    String apiname = "get_content_by_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'channel_id': chennelId,
          'content_type': contenttype,
          'page_no': pageNo,
        }));
    getContentbyChannelModel = GetContentbyChannelModel.fromJson(response.data);
    return getContentbyChannelModel;
  }

  Future<EditPlaylistModel> editPlaylist(
      playlistId, title, playlistType) async {
    EditPlaylistModel editPlaylistModel;
    String apiname = "edit_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'content_id': playlistId,
          'title': title,
          'playlist_type': playlistType,
        }));
    editPlaylistModel = EditPlaylistModel.fromJson(response.data);
    return editPlaylistModel;
  }

  Future<DeletePlaylistModel> deletePlaylist(playlistId) async {
    DeletePlaylistModel deletePlaylistModel;
    String apiname = "delete_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'content_id': playlistId,
        }));
    deletePlaylistModel = DeletePlaylistModel.fromJson(response.data);
    return deletePlaylistModel;
  }

  Future<AddRemoveLikeDislikeModel> addRemoveLikeDislike(
      contenttype, contentid, status, episodeId) async {
    log("UserId==> ${Constant.userID}");
    AddRemoveLikeDislikeModel addRemoveLikeDislikeModel;
    String apiname = "add_remove_like_dislike";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'status': status,
          'episode_id': episodeId,
        }));
    addRemoveLikeDislikeModel =
        AddRemoveLikeDislikeModel.fromJson(response.data);
    return addRemoveLikeDislikeModel;
  }

  Future<GetRepostReasonModel> reportReason(type, pageNo) async {
    GetRepostReasonModel getRepostReasonModel;
    String apiname = "get_report_reason";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'type': type,
          'page_no': pageNo,
        }));
    getRepostReasonModel = GetRepostReasonModel.fromJson(response.data);
    return getRepostReasonModel;
  }

  Future<AddContentReportModel> addContentReport(
      reportUserid, contentid, message, contenttype) async {
    AddContentReportModel addContentReportModel;
    String apiname = "add_content_report";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'report_user_id': reportUserid,
          'content_id': contentid,
          'message': message,
          'content_type': contenttype,
        }));
    addContentReportModel = AddContentReportModel.fromJson(response.data);
    return addContentReportModel;
  }

  Future<GetWatchlaterModel> watchLaterList(contentType, pageNo) async {
    GetWatchlaterModel watchlaterModel;
    String apiname = "get_watch_later_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    watchlaterModel = GetWatchlaterModel.fromJson(response.data);
    return watchlaterModel;
  }

  Future<LikeContentModel> likeVideos(contentType, pageNo) async {
    log("pageNo========>$pageNo");
    LikeContentModel likeContentModel;
    String apiname = "get_like_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    likeContentModel = LikeContentModel.fromJson(response.data);
    return likeContentModel;
  }

  Future<AddremoveWatchlaterModel> addremoveWatchLater(
      contenttype, contentid, episodeid, type) async {
    AddremoveWatchlaterModel addremoveWatchlaterModel;
    String apiname = "add_remove_watch_later";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
          'type': type,
        }));
    addremoveWatchlaterModel = AddremoveWatchlaterModel.fromJson(response.data);
    return addremoveWatchlaterModel;
  }

  Future<AddremoveSubscribeModel> addremoveSubscribe(touserid, type) async {
    AddremoveSubscribeModel addremoveSubscribeModel;
    String apiname = "add_remove_subscribe";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'to_user_id': touserid,
          'type': type,
        }));
    addremoveSubscribeModel = AddremoveSubscribeModel.fromJson(response.data);
    return addremoveSubscribeModel;
  }

  Future<AddcontenttoHistoryModel> addContentToHistory(
      contenttype, contentid, stoptime, episodeid) async {
    AddcontenttoHistoryModel addcontenttoHistoryModel;
    String apiname = "add_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'stop_time': stoptime,
          'episode_id': episodeid,
        }));
    addcontenttoHistoryModel = AddcontenttoHistoryModel.fromJson(response.data);
    return addcontenttoHistoryModel;
  }

  Future<RemoveContentHistoryModel> removeContentToHistory(
      contenttype, contentid, episodeid) async {
    RemoveContentHistoryModel removeContentHistoryModel;
    String apiname = "remove_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contenttype,
          'content_id': contentid,
          'episode_id': episodeid,
        }));
    removeContentHistoryModel =
        RemoveContentHistoryModel.fromJson(response.data);
    return removeContentHistoryModel;
  }

  Future<GetHistoryModel> historyList(contentType, pageNo) async {
    log("pageNo========>$pageNo");
    GetHistoryModel getHistoryModel;
    String apiname = "get_content_to_history";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    getHistoryModel = GetHistoryModel.fromJson(response.data);
    return getHistoryModel;
  }

  Future<AddremoveblockchannelModel> addremoveBlockChannel(
      blockUserId, blockChannelId) async {
    AddremoveblockchannelModel addremoveblockchannelModel;
    String apiname = "add_remove_block_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'block_user_id': blockUserId,
          'block_channel_id': blockChannelId,
        }));
    addremoveblockchannelModel =
        AddremoveblockchannelModel.fromJson(response.data);
    return addremoveblockchannelModel;
  }

  Future<EpidoseByPodcastModel> episodeByPodcast(podcastId, pageNo) async {
    EpidoseByPodcastModel epidoseByPodcastModel;
    String apiname = "get_episode_by_podcasts";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'podcasts_id': podcastId,
          'page_no': pageNo,
        }));
    epidoseByPodcastModel = EpidoseByPodcastModel.fromJson(response.data);
    return epidoseByPodcastModel;
  }

  Future<EpidoseByRadioModel> episodeByRadio(radioId, pageNo) async {
    EpidoseByRadioModel epidoseByRadioModel;
    String apiname = "get_radio_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'radio_id': radioId,
          'page_no': pageNo,
        }));
    epidoseByRadioModel = EpidoseByRadioModel.fromJson(response.data);
    return epidoseByRadioModel;
  }

  Future<SearchModel> search(name, type) async {
    SearchModel searchModel;
    String apiname = "search_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'name': name,
          'type': type,
        }));
    searchModel = SearchModel.fromJson(response.data);
    return searchModel;
  }

  Future<SuccessModel> addTransaction(packageid, price, discription) async {
    SuccessModel successModel;
    String apiname = "add_transaction";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'package_id': packageid,
          'price': price,
          'description': discription,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String apiname = "get_payment_option";
    Response response = await dio.post('$baseurl$apiname');
    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  Future<EpisodebyplaylistModel> episodeByPlaylist(
      playlistId, contentType, pageNo) async {
    EpisodebyplaylistModel episodebyplaylistModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'playlist_id': playlistId,
          'content_type': contentType,
          'page_no': pageNo,
        }));
    episodebyplaylistModel = EpisodebyplaylistModel.fromJson(response.data);
    return episodebyplaylistModel;
  }

  Future<SectionDetailModel> sectionDetail(sectionId, pageNo) async {
    SectionDetailModel sectionDetailModel;
    String apiname = "get_music_section_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'section_id': sectionId,
          'page_no': pageNo,
        }));
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  Future<GetMusicByCategoryModel> getMusicbyCategory(categoryId, pageNo) async {
    GetMusicByCategoryModel getMusicByCategoryModel;
    String apiname = "get_music_by_category";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'category_id': categoryId,
          'page_no': pageNo,
        }));
    getMusicByCategoryModel = GetMusicByCategoryModel.fromJson(response.data);
    return getMusicByCategoryModel;
  }

  Future<GetMusicByLanguageModel> getMusicbyLanguage(languageId, pageNo) async {
    GetMusicByLanguageModel getMusicByLanguageModel;
    String apiname = "get_music_by_language";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'language_id': languageId,
          'page_no': pageNo,
        }));
    getMusicByLanguageModel = GetMusicByLanguageModel.fromJson(response.data);
    return getMusicByLanguageModel;
  }

  Future<GetNotificationModel> notification(pageNo) async {
    GetNotificationModel getNotificationModel;
    String apiname = "get_notification";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    getNotificationModel = GetNotificationModel.fromJson(response.data);
    return getNotificationModel;
  }

  Future<SuccessModel> readNotification(notificationId) async {
    SuccessModel successModel;
    String apiname = "read_notification";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'notification_id': notificationId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> deleteContent(contentType, contentId, episodeId) async {
    SuccessModel successModel;
    String apiname = "delete_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'content_id': contentId,
          'episode_id': episodeId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> activeUserPanel(password, userpanelStatus) async {
    log("Password====>$password");
    log("userpanalType====>$userpanelStatus");
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'password': password,
          'user_penal_status': userpanelStatus,
        }));
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<RentSectionModel> rentSection(pageNo) async {
    RentSectionModel rentSectionModel;
    String apiname = "get_rent_section";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    rentSectionModel = RentSectionModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<GetRentContentbyChannel> getRentContentByChannel(
      userId, channelId, pageNo) async {
    GetRentContentbyChannel getRentContentbyChannel;
    String apiname = "get_rent_content_by_channel";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'channel_id': channelId,
          'page_no': pageNo,
        }));
    getRentContentbyChannel = GetRentContentbyChannel.fromJson(response.data);
    return getRentContentbyChannel;
  }

  Future<RentSectionDetailModel> rentSectionDetail(sectionId, pageNo) async {
    RentSectionDetailModel rentSectionModel;
    String apiname = "get_rent_section_detail";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'section_id': sectionId,
          'page_no': pageNo,
        }));
    rentSectionModel = RentSectionDetailModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<SuccessModel> rentTransection(
      contentId, price, discription, transectionId) async {
    SuccessModel successModel;
    String apiname = "add_rent_transaction";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_id': contentId,
          'price': price,
          'description': discription,
          'transaction_id': transectionId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetUserRentContentModel> rentContenetByUser(userId, pageNo) async {
    GetUserRentContentModel getUserRentContentModel;
    String apiname = "get_user_rent_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': userId == null || userId == "" ? "0" : userId,
          'page_no': pageNo,
        }));
    getUserRentContentModel = GetUserRentContentModel.fromJson(response.data);
    return getUserRentContentModel;
  }

  Future<GetContentByPlaylistModel> contentByPlaylist(
      contentType, pageNo) async {
    GetContentByPlaylistModel getContentByPlaylistModel;
    String apiname = "get_content_to_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'content_type': contentType,
          'page_no': pageNo,
        }));
    getContentByPlaylistModel =
        GetContentByPlaylistModel.fromJson(response.data);
    return getContentByPlaylistModel;
  }

  Future<SuccessModel> addMultipleContentToPlaylist(
      playlistId, contentType, contentIds) async {
    SuccessModel successModel;
    String apiname = "add_multipal_content_to_playlist";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'playlist_id': playlistId,
          'content_type': contentType,
          'content_id': contentIds,
          'channel_id': Constant.channelID,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetPlaylistContentModel> getPlaylistContent(
      playlistId, contentType, pageNo) async {
    GetPlaylistContentModel getPlaylistContentModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'playlist_id': playlistId,
          'content_type': contentType,
          'page_no': pageNo,
        }));
    getPlaylistContentModel = GetPlaylistContentModel.fromJson(response.data);
    return getPlaylistContentModel;
  }

  Future<GetpagesModel> getPages() async {
    GetpagesModel getpagesModel;
    String apiname = "get_pages";
    Response response = await dio.post('$baseurl$apiname');
    getpagesModel = GetpagesModel.fromJson(response.data);
    return getpagesModel;
  }

  // update_profile API
  Future<SuccessModel> updateDataForPayment(
      fullName, email, mobileNumber) async {
    debugPrint("updateDataForPayment userID :====> ${Constant.userID}");
    debugPrint("updateDataForPayment fullName :==> $fullName");
    debugPrint("updateDataForPayment email :=====> $email");
    debugPrint("updateProfile mobileNumber :=====> $mobileNumber");
    SuccessModel responseModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
    );

    responseModel = SuccessModel.fromJson(response.data);
    return responseModel;
  }

  Future<SuccessModel> uploadVideo(title, video, portraitImage) async {
    debugPrint("Title:=========> $title");
    debugPrint("Video :===> $video");
    debugPrint("Image:=======> $portraitImage");
    SuccessModel successModel;
    String uploadVideo = "upload_reels";
    Response response = await dio.post(
      '$baseurl$uploadVideo',
      data: FormData.fromMap({
        'channel_id': Constant.channelID,
        'title': title,
        "video": (video?.path ?? "") != ""
            ? (MultipartFile.fromFileSync(
                video?.path ?? "",
                filename: video?.path.split('/').last ?? "",
              ))
            : "",
        "portrait_img": (portraitImage?.path ?? "") != ""
            ? (MultipartFile.fromFileSync(
                portraitImage?.path ?? "",
                filename: portraitImage?.path.split('/').last ?? "",
              ))
            : "",
      }),
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> logout() async {
    SuccessModel successModel;
    String apiname = "logout";
    Response response = await dio.post('$baseurl$apiname',
        data: FormData.fromMap({'user_id': Constant.userID}));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }
}
