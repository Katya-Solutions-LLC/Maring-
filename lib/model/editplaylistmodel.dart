// To parse this JSON data, do
//
//     final editPlaylistModel = editPlaylistModelFromJson(jsonString);

import 'dart:convert';

EditPlaylistModel editPlaylistModelFromJson(String str) =>
    EditPlaylistModel.fromJson(json.decode(str));

String editPlaylistModelToJson(EditPlaylistModel data) =>
    json.encode(data.toJson());

class EditPlaylistModel {
  int? status;
  String? message;
  List<dynamic>? result;

  EditPlaylistModel({
    this.status,
    this.message,
    this.result,
  });

  factory EditPlaylistModel.fromJson(Map<String, dynamic> json) =>
      EditPlaylistModel(
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
