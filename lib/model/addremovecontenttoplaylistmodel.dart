// To parse this JSON data, do
//
//     final addremoveContentToPlaylistModel = addremoveContentToPlaylistModelFromJson(jsonString);

import 'dart:convert';

AddremoveContentToPlaylistModel addremoveContentToPlaylistModelFromJson(
        String str) =>
    AddremoveContentToPlaylistModel.fromJson(json.decode(str));

String addremoveContentToPlaylistModelToJson(
        AddremoveContentToPlaylistModel data) =>
    json.encode(data.toJson());

class AddremoveContentToPlaylistModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddremoveContentToPlaylistModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddremoveContentToPlaylistModel.fromJson(Map<String, dynamic> json) =>
      AddremoveContentToPlaylistModel(
        status: json["status"],
        message: json["message"],
        result: List<dynamic>.from(json["result"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x) ?? []),
      };
}
