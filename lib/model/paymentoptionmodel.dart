// To parse this JSON data, do
//
//     final paymentOptionModel = paymentOptionModelFromJson(jsonString);

import 'dart:convert';

PaymentOptionModel paymentOptionModelFromJson(String str) =>
    PaymentOptionModel.fromJson(json.decode(str));

String paymentOptionModelToJson(PaymentOptionModel data) =>
    json.encode(data.toJson());

class PaymentOptionModel {
  int? status;
  String? message;
  Result? result;

  PaymentOptionModel({
    this.status,
    this.message,
    this.result,
  });

  factory PaymentOptionModel.fromJson(Map<String, dynamic> json) =>
      PaymentOptionModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? {} : result?.toJson() ?? {},
      };
}

class Result {
  PaymentGatewayData? inapppurchage;
  PaymentGatewayData? paypal;
  PaymentGatewayData? razorpay;
  PaymentGatewayData? flutterwave;
  PaymentGatewayData? payumoney;
  PaymentGatewayData? paytm;
  PaymentGatewayData? stripe;

  Result({
    this.inapppurchage,
    this.paypal,
    this.razorpay,
    this.flutterwave,
    this.payumoney,
    this.paytm,
    this.stripe,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        inapppurchage: json["inapppurchage"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["inapppurchage"]),
        paypal: json["paypal"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["paypal"]),
        razorpay: json["razorpay"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["razorpay"]),
        flutterwave: json["flutterwave"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["flutterwave"]),
        payumoney: json["payumoney"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["payumoney"]),
        paytm: json["paytm"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["paytm"]),
        stripe: json["stripe"] == null
            ? PaymentGatewayData.fromJson({})
            : PaymentGatewayData.fromJson(json["stripe"]),
      );

  Map<String, dynamic> toJson() => {
        "inapppurchage":
            inapppurchage == null ? {} : inapppurchage?.toJson() ?? {},
        "paypal": paypal == null ? {} : paypal?.toJson() ?? {},
        "razorpay": razorpay == null ? {} : razorpay?.toJson() ?? {},
        "flutterwave": flutterwave == null ? {} : flutterwave?.toJson() ?? {},
        "payumoney": payumoney == null ? {} : payumoney?.toJson() ?? {},
        "paytm": paytm == null ? {} : paytm?.toJson() ?? {},
        "stripe": stripe == null ? {} : stripe?.toJson() ?? {},
      };
}

class PaymentGatewayData {
  int? id;
  String? name;
  String? visibility;
  String? isLive;
  String? key1;
  String? key2;
  String? key3;
  String? createdAt;
  String? updatedAt;

  PaymentGatewayData({
    this.id,
    this.name,
    this.visibility,
    this.isLive,
    this.key1,
    this.key2,
    this.key3,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentGatewayData.fromJson(Map<String, dynamic> json) =>
      PaymentGatewayData(
        id: json["id"],
        name: json["name"],
        visibility: json["visibility"],
        isLive: json["is_live"],
        key1: json["key_1"],
        key2: json["key_2"],
        key3: json["key_3"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "visibility": visibility,
        "is_live": isLive,
        "key_1": key1,
        "key_2": key2,
        "key_3": key3,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
