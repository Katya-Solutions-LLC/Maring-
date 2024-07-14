// To parse this JSON data, do
//
//     final addCommentModel = addCommentModelFromJson(jsonString);

import 'dart:convert';

AddCommentModel addCommentModelFromJson(String str) =>
    AddCommentModel.fromJson(json.decode(str));

String addCommentModelToJson(AddCommentModel data) =>
    json.encode(data.toJson());

class AddCommentModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddCommentModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddCommentModel.fromJson(Map<String, dynamic> json) =>
      AddCommentModel(
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
