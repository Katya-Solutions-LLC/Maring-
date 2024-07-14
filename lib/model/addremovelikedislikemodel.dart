// To parse this JSON data, do
//
//     final addRemoveLikeDislikeModel = addRemoveLikeDislikeModelFromJson(jsonString);

import 'dart:convert';

AddRemoveLikeDislikeModel addRemoveLikeDislikeModelFromJson(String str) =>
    AddRemoveLikeDislikeModel.fromJson(json.decode(str));

String addRemoveLikeDislikeModelToJson(AddRemoveLikeDislikeModel data) =>
    json.encode(data.toJson());

class AddRemoveLikeDislikeModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddRemoveLikeDislikeModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddRemoveLikeDislikeModel.fromJson(Map<String, dynamic> json) =>
      AddRemoveLikeDislikeModel(
        status: json["status"],
        message: json["message"],
        result: List<dynamic>.from(json["result"]?.map((x) => x) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x) ?? []),
      };
}
