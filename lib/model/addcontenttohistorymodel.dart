// To parse this JSON data, do
//
//     final addcontenttoHistoryModel = addcontenttoHistoryModelFromJson(jsonString);

import 'dart:convert';

AddcontenttoHistoryModel addcontenttoHistoryModelFromJson(String str) =>
    AddcontenttoHistoryModel.fromJson(json.decode(str));

String addcontenttoHistoryModelToJson(AddcontenttoHistoryModel data) =>
    json.encode(data.toJson());

class AddcontenttoHistoryModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddcontenttoHistoryModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddcontenttoHistoryModel.fromJson(Map<String, dynamic> json) =>
      AddcontenttoHistoryModel(
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
