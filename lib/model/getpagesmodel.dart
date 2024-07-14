// To parse this JSON data, do
//
//     final getpagesModel = getpagesModelFromJson(jsonString);

import 'dart:convert';

GetpagesModel getpagesModelFromJson(String str) =>
    GetpagesModel.fromJson(json.decode(str));

String getpagesModelToJson(GetpagesModel data) => json.encode(data.toJson());

class GetpagesModel {
  int? status;
  String? message;
  List<Result>? result;

  GetpagesModel({
    this.status,
    this.message,
    this.result,
  });

  factory GetpagesModel.fromJson(Map<String, dynamic> json) => GetpagesModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  String? pageName;
  String? title;
  String? url;
  String? icon;

  Result({
    this.pageName,
    this.title,
    this.url,
    this.icon,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        pageName: json["page_name"],
        title: json["title"],
        url: json["url"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "page_name": pageName,
        "title": title,
        "url": url,
        "icon": icon,
      };
}
