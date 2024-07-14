import 'package:maring/model/addremoveblockchannelmodel.dart';
import 'package:maring/model/getcontentbychannelmodel.dart' as channelcontent;
import 'package:maring/model/getcontentbychannelmodel.dart';
import 'package:maring/model/getuserbyrentcontentmodel.dart' as rent;
import 'package:maring/model/getuserbyrentcontentmodel.dart';
import 'package:maring/model/successmodel.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maring/model/profilemodel.dart';
import 'package:maring/webservice/apiservice.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();

  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  GetUserRentContentModel getUserRentContentModel = GetUserRentContentModel();
  AddremoveblockchannelModel addremoveblockchannelModel =
      AddremoveblockchannelModel();

  bool loading = false, profileloading = false;
  bool loadMore = false;
  bool loadingUpdate = false;
  bool deletecontentLoading = false;
  int deleteItemIndex = 0;
  int position = 0;

  List<channelcontent.Result>? channelContentList = [];
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  List<rent.Result>? rentContentList = [];
  bool rentloadMore = false;
  int? renttotalRows, renttotalPage, rentcurrentPage;
  bool? rentisMorePage;

  Future<void> getprofile(BuildContext context, touserid) async {
    debugPrint("getProfile userID :==> ${Constant.userID}");
    profileloading = true;
    profileModel = await ApiService().profile(touserid);
    debugPrint("get_profile status :==> ${profileModel.status}");
    debugPrint("get_profile message :==> ${profileModel.message}");
    if (profileModel.status == 200 && profileModel.result != null) {
      if ((profileModel.result?.length ?? 0) > 0) {
        Utils.updatePremium(profileModel.result?[0].isBuy.toString() ?? "0");
        if (context.mounted) {
          debugPrint("========= get_profile loadAds =========");
          Utils.loadAds(context);
        }
      }
    }
    profileloading = false;
    notifyListeners();
  }

  getDeleteContent(index, contenttype, contentid, episodeid) async {
    deleteItemIndex = index;
    setDeletePlaylistLoading(true);
    successModel =
        await ApiService().deleteContent(contenttype, contentid, episodeid);
    setDeletePlaylistLoading(false);
    channelContentList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecontentLoading = isSending;
    notifyListeners();
  }

  addremoveBlockChannel(blockUserId, blockChannelId) async {
    loading = true;
    addremoveblockchannelModel =
        await ApiService().addremoveBlockChannel(blockUserId, blockChannelId);
    loading = false;
    notifyListeners();
  }

/* All Content By Channel  */

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    loading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    if (getContentbyChannelModel.status == 200) {
      setPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getContentbyChannelModel.result != null &&
            (getContentbyChannelModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getContentbyChannelModel.result?.length ?? 0);
              i++) {
            channelContentList?.add(
                getContentbyChannelModel.result?[i] ?? channelcontent.Result());
          }
          final Map<int, channelcontent.Result> postMap = {};
          channelContentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          channelContentList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(channelContentList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

/* Rent Video */

  Future<void> getUserbyRentContent(userId, pageNo) async {
    loading = true;
    getUserRentContentModel =
        await ApiService().rentContenetByUser(userId, pageNo);
    if (getUserRentContentModel.status == 200) {
      setRentPaginationData(
          getUserRentContentModel.totalRows,
          getUserRentContentModel.totalPage,
          getUserRentContentModel.currentPage,
          getUserRentContentModel.morePage);
      if (getUserRentContentModel.result != null &&
          (getUserRentContentModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getUserRentContentModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getUserRentContentModel.result != null &&
            (getUserRentContentModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getUserRentContentModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getUserRentContentModel.result?.length ?? 0);
              i++) {
            rentContentList
                ?.add(getUserRentContentModel.result?[i] ?? rent.Result());
          }
          final Map<int, rent.Result> postMap = {};
          rentContentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          rentContentList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(rentContentList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRentPaginationData(int? renttotalRows, int? renttotalPage,
      int? rentcurrentPage, bool? morePage) {
    this.rentcurrentPage = rentcurrentPage;
    this.renttotalRows = renttotalRows;
    this.renttotalPage = renttotalPage;
    rentisMorePage = rentisMorePage;
    notifyListeners();
  }

/* Load More ProgressBar */

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  Future<void> getUpdateDataForPayment(fullName, email, mobileNumber) async {
    debugPrint("getUpdateDataForPayment fullname :==> $fullName");
    debugPrint("getUpdateDataForPayment email :=====> $email");
    debugPrint("getUpdateDataForPayment mobile :====> $mobileNumber");
    loadingUpdate = true;
    successModel =
        await ApiService().updateDataForPayment(fullName, email, mobileNumber);
    debugPrint("getUpdateDataForPayment status :==> ${successModel.status}");
    debugPrint("getUpdateDataForPayment message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingUpdate = isLoading;
    notifyListeners();
  }

  changeTab(index) {
    position = index;
    notifyListeners();
  }

  clearListData() {
    channelContentList = [];
    channelContentList?.clear();
    getContentbyChannelModel = GetContentbyChannelModel();
  }

  clearProvider() {
    loading = false;
    position = 0;
    profileModel = ProfileModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    channelContentList = [];
    channelContentList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
