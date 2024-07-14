// To parse this JSON data, do
//
//     final addCommentModel = addCommentModelFromJson(jsonString);

import 'dart:convert';

DeleteCommentModel deleteCommentModelFromJson(String str) =>
    DeleteCommentModel.fromJson(json.decode(str));

String deleteCommentModelToJson(DeleteCommentModel data) =>
    json.encode(data.toJson());

class DeleteCommentModel {
  int? status;
  String? message;
  List<dynamic>? result;

  DeleteCommentModel({
    this.status,
    this.message,
    this.result,
  });

  factory DeleteCommentModel.fromJson(Map<String, dynamic> json) =>
      DeleteCommentModel(
        status: json["status"],
        message: json["message"],
        result: List<dynamic>.from(
            json["result"] == null ? [] : json["result"]?.map((x) => x) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(
            result == null ? [] : result?.map((x) => x) ?? []),
      };
}
