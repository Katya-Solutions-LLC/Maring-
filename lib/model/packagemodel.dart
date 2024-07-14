// To parse this JSON data, do
//
//     final packageModel = packageModelFromJson(jsonString);

import 'dart:convert';

PackageModel packageModelFromJson(String str) =>
    PackageModel.fromJson(json.decode(str));

String packageModelToJson(PackageModel data) => json.encode(data.toJson());

class PackageModel {
  int? status;
  String? message;
  List<Result>? result;

  PackageModel({
    this.status,
    this.message,
    this.result,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
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
  int? id;
  String? name;
  int? price;
  String? image;
  String? time;
  String? type;
  String? androidProductPackage;
  String? iosProductPackage;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  List<Datum>? data;

  Result({
    this.id,
    this.name,
    this.price,
    this.image,
    this.time,
    this.type,
    this.androidProductPackage,
    this.iosProductPackage,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        image: json["image"],
        time: json["time"],
        type: json["type"],
        androidProductPackage: json["android_product_package"],
        iosProductPackage: json["ios_product_package"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        data:
            List<Datum>.from(json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
        "time": time,
        "type": type,
        "android_product_package": androidProductPackage,
        "ios_product_package": iosProductPackage,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
  int? id;
  int? packageId;
  String? packageKey;
  String? packageValue;

  Datum({
    this.id,
    this.packageId,
    this.packageKey,
    this.packageValue,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        packageId: json["package_Id"],
        packageKey: json["package_key"],
        packageValue: json["package_value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "package_Id": packageId,
        "package_key": packageKey,
        "package_value": packageValue,
      };
}
