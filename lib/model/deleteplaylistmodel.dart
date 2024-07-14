// To parse this JSON data, do
//
//     final deletePlaylistModel = deletePlaylistModelFromJson(jsonString);

import 'dart:convert';

DeletePlaylistModel deletePlaylistModelFromJson(String str) =>
    DeletePlaylistModel.fromJson(json.decode(str));

String deletePlaylistModelToJson(DeletePlaylistModel data) =>
    json.encode(data.toJson());

class DeletePlaylistModel {
  int? status;
  String? message;
  List<dynamic>? result;

  DeletePlaylistModel({
    this.status,
    this.message,
    this.result,
  });

  factory DeletePlaylistModel.fromJson(Map<String, dynamic> json) =>
      DeletePlaylistModel(
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
