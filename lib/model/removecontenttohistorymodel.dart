// To parse this JSON data, do
//
//     final removeContentHistoryModel = removeContentHistoryModelFromJson(jsonString);

import 'dart:convert';

RemoveContentHistoryModel removeContentHistoryModelFromJson(String str) =>
    RemoveContentHistoryModel.fromJson(json.decode(str));

String removeContentHistoryModelToJson(RemoveContentHistoryModel data) =>
    json.encode(data.toJson());

class RemoveContentHistoryModel {
  int? status;
  String? message;
  List<dynamic>? result;

  RemoveContentHistoryModel({
    this.status,
    this.message,
    this.result,
  });

  factory RemoveContentHistoryModel.fromJson(Map<String, dynamic> json) =>
      RemoveContentHistoryModel(
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
