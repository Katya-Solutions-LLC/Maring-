import 'package:maring/model/packagemodel.dart';
import 'package:maring/model/paymentoptionmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class SubscriptionProvider extends ChangeNotifier {
  PackageModel packageModel = PackageModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel rentTransectionModel = SuccessModel();
  PaymentOptionModel paymentOptionModel = PaymentOptionModel();
  bool loading = false, payLoading = false;
  bool isSelectpackage = false;
  int? selectPackagePosition = 0;
  String selectPackagePrice = "";
  String? currentPayment = "", finalAmount = "";

  getPackage() async {
    loading = true;
    packageModel = await ApiService().package();
    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(packageid, price, description) async {
    payLoading = true;
    successModel =
        await ApiService().addTransaction(packageid, price, description);
    payLoading = false;
    notifyListeners();
  }

  Future<void> getRentTransaction(
      contentId, price, discription, transectionId) async {
    payLoading = true;
    rentTransectionModel = await ApiService()
        .rentTransection(contentId, price, discription, transectionId);
    payLoading = false;
    notifyListeners();
  }

  Future<void> getPaymentOption() async {
    payLoading = true;
    paymentOptionModel = await ApiService().getPaymentOption();
    payLoading = false;
    notifyListeners();
  }

  selectPackage(int index, bool selectpackage, String packagePrice) {
    selectPackagePosition = index;
    isSelectpackage = selectpackage;
    selectPackagePrice = packagePrice;
    notifyListeners();
  }

  setFinalAmount(String? amount) {
    finalAmount = amount;
    debugPrint("setFinalAmount finalAmount :==> $finalAmount");
    notifyListeners();
  }

  setCurrentPayment(String? payment) {
    currentPayment = payment;
    notifyListeners();
  }

  clearProvider() async {
    packageModel = PackageModel();
    successModel = SuccessModel();
    rentTransectionModel = SuccessModel();
    paymentOptionModel = PaymentOptionModel();
    loading = false;
    payLoading = false;
    isSelectpackage = false;
    selectPackagePosition = 0;
    currentPayment = "";
    finalAmount = "";
    selectPackagePrice = "";
  }
}
