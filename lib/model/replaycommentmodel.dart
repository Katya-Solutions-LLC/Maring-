// To parse this JSON data, do
//
//     final replayCommentModel = replayCommentModelFromJson(jsonString);

import 'dart:convert';

ReplayCommentModel replayCommentModelFromJson(String str) =>
    ReplayCommentModel.fromJson(json.decode(str));

String replayCommentModelToJson(ReplayCommentModel data) =>
    json.encode(data.toJson());

class ReplayCommentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  ReplayCommentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory ReplayCommentModel.fromJson(Map<String, dynamic> json) =>
      ReplayCommentModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(json["result"] == null
            ? []
            : json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(
            result == null ? [] : result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  int? commentId;
  int? userId;
  int? contentType;
  int? contentId;
  int? episodeId;
  String? comment;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelName;
  String? fullName;
  String? image;
  int? isReply;
  int? totalReply;

  Result({
    this.id,
    this.commentId,
    this.userId,
    this.contentType,
    this.contentId,
    this.episodeId,
    this.comment,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.fullName,
    this.image,
    this.isReply,
    this.totalReply,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        commentId: json["comment_id"],
        userId: json["user_id"],
        contentType: json["content_type"],
        contentId: json["content_id"],
        episodeId: json["episode_id"],
        comment: json["comment"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        image: json["image"],
        isReply: json["is_reply"],
        totalReply: json["total_reply"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment_id": commentId,
        "user_id": userId,
        "content_type": contentType,
        "content_id": contentId,
        "episode_id": episodeId,
        "comment": comment,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "full_name": fullName,
        "image": image,
        "is_reply": isReply,
        "total_reply": totalReply,
      };
}
