// To parse this JSON data, do
//
//     final addremoveblockchannelModel = addremoveblockchannelModelFromJson(jsonString);

import 'dart:convert';

AddremoveblockchannelModel addremoveblockchannelModelFromJson(String str) =>
    AddremoveblockchannelModel.fromJson(json.decode(str));

String addremoveblockchannelModelToJson(AddremoveblockchannelModel data) =>
    json.encode(data.toJson());

class AddremoveblockchannelModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddremoveblockchannelModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddremoveblockchannelModel.fromJson(Map<String, dynamic> json) =>
      AddremoveblockchannelModel(
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
