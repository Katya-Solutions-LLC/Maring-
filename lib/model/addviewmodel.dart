// To parse this JSON data, do
//
//     final addViewModel = addViewModelFromJson(jsonString);

import 'dart:convert';

AddViewModel addViewModelFromJson(String str) =>
    AddViewModel.fromJson(json.decode(str));

String addViewModelToJson(AddViewModel data) => json.encode(data.toJson());

class AddViewModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddViewModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddViewModel.fromJson(Map<String, dynamic> json) => AddViewModel(
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
