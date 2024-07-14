import 'package:flutter/material.dart';
import 'package:maring/model/generalsettingmodel.dart';
import 'package:maring/model/loginmodel.dart';
import 'package:maring/webservice/apiservice.dart';

class GeneralProvider extends ChangeNotifier {
  GeneralsettingModel generalsettingModel = GeneralsettingModel();
  LoginModel loginModel = LoginModel();
  bool loading = false;

  getGeneralsetting() async {
    loading = true;
    generalsettingModel = await ApiService().generalsetting();
    loading = false;
    notifyListeners();
  }

  login(String type, String email, String mobile, String devicetype,
      String devicetoken) async {
    loading = true;
    loginModel =
        await ApiService().login(type, email, mobile, devicetype, devicetoken);
    loading = false;
    notifyListeners();
  }
}
