// To parse this JSON data, do
//
//     final epidoseByPodcastModel = epidoseByPodcastModelFromJson(jsonString);

import 'dart:convert';

EpidoseByPodcastModel epidoseByPodcastModelFromJson(String str) =>
    EpidoseByPodcastModel.fromJson(json.decode(str));

String epidoseByPodcastModelToJson(EpidoseByPodcastModel data) =>
    json.encode(data.toJson());

class EpidoseByPodcastModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  EpidoseByPodcastModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory EpidoseByPodcastModel.fromJson(Map<String, dynamic> json) =>
      EpidoseByPodcastModel(
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
  int? podcastsId;
  String? name;
  String? description;
  String? portraitImg;
  String? landscapeImg;
  String? episodeUploadType;
  String? episodeAudio;
  String? episodeSize;
  int? isComment;
  int? isDownload;
  int? isLike;
  int? totalView;
  int? totalLike;
  int? totalDislike;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? podcastsName;
  int? isUserLikeDislike;
  int? userId;
  int? stopTime;
  int? isBuy;

  Result({
    this.id,
    this.podcastsId,
    this.name,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.episodeUploadType,
    this.episodeAudio,
    this.episodeSize,
    this.isComment,
    this.isDownload,
    this.isLike,
    this.totalView,
    this.totalLike,
    this.totalDislike,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastsName,
    this.isUserLikeDislike,
    this.userId,
    this.stopTime,
    this.isBuy,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        podcastsId: json["podcasts_id"],
        name: json["name"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        episodeUploadType: json["episode_upload_type"],
        episodeAudio: json["episode_audio"],
        episodeSize: json["episode_size"],
        isComment: json["is_comment"],
        isDownload: json["is_download"],
        isLike: json["is_like"],
        totalView: json["total_view"],
        totalLike: json["total_like"],
        totalDislike: json["total_dislike"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        podcastsName: json["podcasts_name"],
        isUserLikeDislike: json["is_user_like_dislike"],
        userId: json["user_id"],
        stopTime: json["stop_time"],
        isBuy: json["is_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "podcasts_id": podcastsId,
        "name": name,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "episode_upload_type": episodeUploadType,
        "episode_audio": episodeAudio,
        "episode_size": episodeSize,
        "is_comment": isComment,
        "is_download": isDownload,
        "is_like": isLike,
        "total_view": totalView,
        "total_like": totalLike,
        "total_dislike": totalDislike,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "podcasts_name": podcastsName,
        "is_user_like_dislike": isUserLikeDislike,
        "user_id": userId,
        "stop_time": stopTime,
        "is_buy": isBuy,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "podcasts_id": podcastsId,
      "name": name,
      "description": description,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "episode_upload_type": episodeUploadType,
      "episode_audio": episodeAudio,
      "episode_size": episodeSize,
      "is_comment": isComment,
      "is_download": isDownload,
      "is_like": isLike,
      "total_view": totalView,
      "total_like": totalLike,
      "total_dislike": totalDislike,
      "sortable": sortable,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "podcasts_name": podcastsName,
      "is_user_like_dislike": isUserLikeDislike,
      "user_id": userId,
      "stop_time": stopTime,
      "is_buy": isBuy,
    };
  }
}
