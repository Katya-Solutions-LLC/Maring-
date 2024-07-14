// To parse this JSON data, do
//
//     final createPlaylistModel = createPlaylistModelFromJson(jsonString);

import 'dart:convert';

CreatePlaylistModel createPlaylistModelFromJson(String str) =>
    CreatePlaylistModel.fromJson(json.decode(str));

String createPlaylistModelToJson(CreatePlaylistModel data) =>
    json.encode(data.toJson());

class CreatePlaylistModel {
  int? status;
  String? message;
  List<dynamic>? result;

  CreatePlaylistModel({
    this.status,
    this.message,
    this.result,
  });

  factory CreatePlaylistModel.fromJson(Map<String, dynamic> json) =>
      CreatePlaylistModel(
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
