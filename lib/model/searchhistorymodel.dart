// To parse this JSON data, do
//
//     final searchHistoryModel = searchHistoryModelFromJson(jsonString);

import 'dart:convert';

SearchHistoryModel searchHistoryModelFromJson(String str) =>
    SearchHistoryModel.fromJson(json.decode(str));

String searchHistoryModelToJson(SearchHistoryModel data) =>
    json.encode(data.toJson());

class SearchHistoryModel {
  int? status;
  String? message;
  List<Result>? result;

  SearchHistoryModel({
    this.status,
    this.message,
    this.result,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) =>
      SearchHistoryModel(
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  int? userId;
  String? title;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.userId,
    this.title,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
