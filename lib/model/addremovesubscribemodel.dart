// To parse this JSON data, do
//
//     final addremoveSubscribeModel = addremoveSubscribeModelFromJson(jsonString);

import 'dart:convert';

AddremoveSubscribeModel addremoveSubscribeModelFromJson(String str) =>
    AddremoveSubscribeModel.fromJson(json.decode(str));

String addremoveSubscribeModelToJson(AddremoveSubscribeModel data) =>
    json.encode(data.toJson());

class AddremoveSubscribeModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddremoveSubscribeModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddremoveSubscribeModel.fromJson(Map<String, dynamic> json) =>
      AddremoveSubscribeModel(
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
