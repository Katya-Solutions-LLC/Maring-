// To parse this JSON data, do
//
//     final getRepostReasonModel = getRepostReasonModelFromJson(jsonString);

import 'dart:convert';

GetRepostReasonModel getRepostReasonModelFromJson(String str) =>
    GetRepostReasonModel.fromJson(json.decode(str));

String getRepostReasonModelToJson(GetRepostReasonModel data) =>
    json.encode(data.toJson());

class GetRepostReasonModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetRepostReasonModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetRepostReasonModel.fromJson(Map<String, dynamic> json) =>
      GetRepostReasonModel(
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
  int? type;
  String? reason;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.type,
    this.reason,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        type: json["type"],
        reason: json["reason"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "reason": reason,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
