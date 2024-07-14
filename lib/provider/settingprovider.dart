import 'package:maring/model/getpagesmodel.dart';
import 'package:maring/model/profilemodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class SettingProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ProfileModel profileModel = ProfileModel();
  GetpagesModel getpagesModel = GetpagesModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  String isUserpanelType = "off";
  bool isActive = true;
  int isActiveType = 0;
  bool isPasswordVisible = false;

  getActiveUserPanel(password, userpanelStatus) async {
    loading = true;
    updateprofileModel =
        await ApiService().activeUserPanel(password, userpanelStatus);
    loading = false;
    notifyListeners();
  }

  getprofile(touserid) async {
    loading = true;
    profileModel = await ApiService().profile(touserid);
    loading = false;
    notifyListeners();
  }

  getPages() async {
    loading = true;
    getpagesModel = await ApiService().getPages();
    loading = false;
    notifyListeners();
  }

  getLogout() async {
    loading = true;
    successModel = await ApiService().logout();
    loading = false;
    notifyListeners();
  }

  selectUserPanel(String userpanelType, bool active) {
    isUserpanelType = userpanelType;
    isActive = active;
    if (userpanelType == "on") {
      isActiveType = 1;
    } else {
      isActiveType = 0;
    }
    notifyListeners();
  }

  passwordHideShow() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  clearUserPanel() {
    updateprofileModel = SuccessModel();
    isUserpanelType = "off";
    isActive = true;
    isActiveType = 0;
  }

  clearProvider() {
    updateprofileModel = SuccessModel();
    profileModel = ProfileModel();
    getpagesModel = GetpagesModel();
    loading = false;
  }
}
