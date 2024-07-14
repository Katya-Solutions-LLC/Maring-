// To parse this JSON data, do
//
//     final addremoveWatchlaterModel = addremoveWatchlaterModelFromJson(jsonString);

import 'dart:convert';

AddremoveWatchlaterModel addremoveWatchlaterModelFromJson(String str) =>
    AddremoveWatchlaterModel.fromJson(json.decode(str));

String addremoveWatchlaterModelToJson(AddremoveWatchlaterModel data) =>
    json.encode(data.toJson());

class AddremoveWatchlaterModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddremoveWatchlaterModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddremoveWatchlaterModel.fromJson(Map<String, dynamic> json) =>
      AddremoveWatchlaterModel(
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
