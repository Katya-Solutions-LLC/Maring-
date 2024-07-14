// To parse this JSON data, do
//
//     final rentSectionModel = rentSectionModelFromJson(jsonString);

import 'dart:convert';

RentSectionModel rentSectionModelFromJson(String str) =>
    RentSectionModel.fromJson(json.decode(str));

String rentSectionModelToJson(RentSectionModel data) =>
    json.encode(data.toJson());

class RentSectionModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  RentSectionModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory RentSectionModel.fromJson(Map<String, dynamic> json) =>
      RentSectionModel(
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
  int? categoryId;
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
    this.categoryId,
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
        categoryId: json["category_id"],
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
        "category_id": categoryId,
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
  int? userId;
  String? channelName;
  String? channelImage;
  String? categoryName;
  String? languageName;
  int? isUserLikeDislike;
  int? isRentBuy;

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
    this.userId,
    this.channelName,
    this.channelImage,
    this.categoryName,
    this.languageName,
    this.isUserLikeDislike,
    this.isRentBuy,
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
        userId: json["user_id"],
        channelName: json["channel_name"],
        channelImage: json["channel_image"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        isUserLikeDislike: json["is_user_like_dislike"],
        isRentBuy: json["is_rent_buy"],
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
        "user_id": userId,
        "channel_name": channelName,
        "channel_image": channelImage,
        "category_name": categoryName,
        "language_name": languageName,
        "is_user_like_dislike": isUserLikeDislike,
        "is_rent_buy": isRentBuy,
      };
}
