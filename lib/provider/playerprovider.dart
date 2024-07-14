import 'package:maring/model/addcontenttohistorymodel.dart';
import 'package:maring/model/addviewmodel.dart';
import 'package:maring/model/removecontenttohistorymodel.dart';
import 'package:flutter/material.dart';
import 'package:maring/webservice/apiservice.dart';

class PlayerProvider extends ChangeNotifier {
  AddViewModel addViewModel = AddViewModel();

  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();

  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  bool loading = false;

  Future<void> addVideoView(contenttype, contentid) async {
    debugPrint("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    debugPrint("addPostView status :==> ${addViewModel.status}");
    debugPrint("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  Future<void> addContentHistory(
      contenttype, contentid, stoptime, episodeid) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService()
        .addContentToHistory(contenttype, contentid, stoptime, episodeid);
    loading = false;
  }

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService()
        .removeContentToHistory(contenttype, contentid, episodeid);
    loading = false;
  }
}
