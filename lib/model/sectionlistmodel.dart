// To parse this JSON data, do
//
//     final sectionListModel = sectionListModelFromJson(jsonString);

import 'dart:convert';

SectionListModel sectionListModelFromJson(String str) =>
    SectionListModel.fromJson(json.decode(str));

String sectionListModelToJson(SectionListModel data) =>
    json.encode(data.toJson());

class SectionListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SectionListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SectionListModel.fromJson(Map<String, dynamic> json) =>
      SectionListModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  String? title;
  String? shortTitle;
  int? isHomeScreen;
  int? contentType;
  int? categoryId;
  int? languageId;
  int? artistId;
  int? orderByView;
  int? orderByLike;
  int? orderByUpload;
  String? screenLayout;
  int? isAdminAdded;
  int? noOfContent;
  int? viewAll;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<Datum>? data;

  Result({
    this.id,
    this.title,
    this.shortTitle,
    this.isHomeScreen,
    this.contentType,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.orderByView,
    this.orderByLike,
    this.orderByUpload,
    this.screenLayout,
    this.isAdminAdded,
    this.noOfContent,
    this.viewAll,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        shortTitle: json["short_title"],
        isHomeScreen: json["is_home_screen"],
        contentType: json["content_type"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        orderByView: json["order_by_view"],
        orderByLike: json["order_by_like"],
        orderByUpload: json["order_by_upload"],
        screenLayout: json["screen_layout"],
        isAdminAdded: json["is_admin_added"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data:
            List<Datum>.from(json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "short_title": shortTitle,
        "is_home_screen": isHomeScreen,
        "content_type": contentType,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "order_by_view": orderByView,
        "order_by_like": orderByLike,
        "order_by_upload": orderByUpload,
        "screen_layout": screenLayout,
        "is_admin_added": isAdminAdded,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
  int? id;
  int? contentType;
  String? channelId;
  int? categoryId;
  int? languageId;
  int? artistId;
  String? hashtagId;
  String? title;
  String? description;
  String? portraitImg;
  String? landscapeImg;
  String? contentUploadType;
  String? content;
  String? contentSize;
  int? contentDuration;
  int? isRent;
  int? rentPrice;
  int? isComment;
  int? isDownload;
  int? isLike;
  int? totalView;
  int? totalLike;
  int? totalDislike;
  int? playlistType;
  int? isAdminAdded;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelName;
  String? channelImage;
  int? userId;
  String? categoryName;
  String? artistName;
  String? languageName;
  int? isUserLikeDislike;
  List<EpisodeArray>? episodeArray;
  List<String>? playlistImage;
  String? name;
  String? image;
  int? type;
  int? totalEpisode;
  int? isBuy;
  int? stopTime;

  Datum({
    this.id,
    this.contentType,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.hashtagId,
    this.title,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.contentUploadType,
    this.content,
    this.contentSize,
    this.contentDuration,
    this.isRent,
    this.rentPrice,
    this.isComment,
    this.isDownload,
    this.isLike,
    this.totalView,
    this.totalLike,
    this.totalDislike,
    this.playlistType,
    this.isAdminAdded,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.channelImage,
    this.userId,
    this.categoryName,
    this.artistName,
    this.languageName,
    this.isUserLikeDislike,
    this.episodeArray,
    this.playlistImage,
    this.name,
    this.image,
    this.type,
    this.totalEpisode,
    this.isBuy,
    this.stopTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        contentType: json["content_type"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        contentUploadType: json["content_upload_type"],
        content: json["content"],
        contentSize: json["content_size"],
        contentDuration: json["content_duration"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isComment: json["is_comment"],
        isDownload: json["is_download"],
        isLike: json["is_like"],
        totalView: json["total_view"],
        totalLike: json["total_like"],
        totalDislike: json["total_dislike"],
        playlistType: json["playlist_type"],
        isAdminAdded: json["is_admin_added"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        channelImage: json["channel_image"],
        userId: json["user_id"],
        categoryName: json["category_name"],
        artistName: json["artist_name"],
        languageName: json["language_name"],
        isUserLikeDislike: json["is_user_like_dislike"],
        episodeArray: List<EpisodeArray>.from(
            json["episode_array"]?.map((x) => EpisodeArray.fromJson(x)) ?? []),
        playlistImage:
            List<String>.from(json["playlist_image"]?.map((x) => x) ?? []),
        name: json["name"],
        image: json["image"],
        type: json["type"],
        totalEpisode: json["total_episode"],
        isBuy: json["is_buy"],
        stopTime: json["stop_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "hashtag_id": hashtagId,
        "title": title,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "content_upload_type": contentUploadType,
        "content": content,
        "content_size": contentSize,
        "content_duration": contentDuration,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_comment": isComment,
        "is_download": isDownload,
        "is_like": isLike,
        "total_view": totalView,
        "total_like": totalLike,
        "total_dislike": totalDislike,
        "playlist_type": playlistType,
        "is_admin_added": isAdminAdded,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "channel_image": channelImage,
        "user_id": userId,
        "category_name": categoryName,
        "artist_name": artistName,
        "language_name": languageName,
        "is_user_like_dislike": isUserLikeDislike,
        "episode_array":
            List<dynamic>.from(episodeArray?.map((x) => x.toJson()) ?? []),
        "playlist_image":
            List<dynamic>.from(playlistImage?.map((x) => x) ?? []),
        "name": name,
        "image": image,
        "type": type,
        "total_episode": totalEpisode,
        "is_buy": isBuy,
        "stop_time": stopTime,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "content_type": contentType,
      "channel_id": channelId,
      "category_id": categoryId,
      "language_id": languageId,
      "artist_id": artistId,
      "hashtag_id": hashtagId,
      "title": title,
      "description": description,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "content_upload_type": contentUploadType,
      "content": content,
      "content_size": contentSize,
      "content_duration": contentDuration,
      "is_rent": isRent,
      "rent_price": rentPrice,
      "is_comment": isComment,
      "is_download": isDownload,
      "is_like": isLike,
      "total_view": totalView,
      "total_like": totalLike,
      "total_dislike": totalDislike,
      "playlist_type": playlistType,
      "is_admin_added": isAdminAdded,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "channel_name": channelName,
      "channel_image": channelImage,
      "user_id": userId,
      "category_name": categoryName,
      "artist_name": artistName,
      "language_name": languageName,
      "is_user_like_dislike": isUserLikeDislike,
      "episode_array":
          List<dynamic>.from(episodeArray?.map((x) => x.toJson()) ?? []),
      "playlist_image": List<dynamic>.from(playlistImage?.map((x) => x) ?? []),
      "name": name,
      "image": image,
      "type": type,
      "total_episode": totalEpisode,
      "is_buy": isBuy,
      "stop_time": stopTime,
    };
  }
}

class EpisodeArray {
  int? id;
  String? name;
  String? portraitImg;
  String? description;

  EpisodeArray({
    this.id,
    this.name,
    this.portraitImg,
    this.description,
  });

  factory EpisodeArray.fromJson(Map<String, dynamic> json) => EpisodeArray(
        id: json["id"],
        name: json["name"],
        portraitImg: json["portrait_img"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "portrait_img": portraitImg,
        "description": description,
      };
}
