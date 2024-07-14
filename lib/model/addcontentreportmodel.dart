// To parse this JSON data, do
//
//     final addContentReportModel = addContentReportModelFromJson(jsonString);

import 'dart:convert';

AddContentReportModel addContentReportModelFromJson(String str) =>
    AddContentReportModel.fromJson(json.decode(str));

String addContentReportModelToJson(AddContentReportModel data) =>
    json.encode(data.toJson());

class AddContentReportModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddContentReportModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddContentReportModel.fromJson(Map<String, dynamic> json) =>
      AddContentReportModel(
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
