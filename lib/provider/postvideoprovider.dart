import 'dart:io';
import 'package:maring/model/successmodel.dart';
import 'package:maring/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PostVideoProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();

  bool loading = false,
      uploading = false,
      isComment = false,
      isSaveGallery = false,
      uploadLoading = false;

  String? coverTick = "tick1",
      thumbnail1 = "",
      thumbnail2 = "",
      thumbnail3 = "",
      finalThumb = "";
  File? watermarkedFile, videoThumb;

  Future<void> uploadNewVideo(title, video, portraitImage) async {
    finalThumb = portraitImage?.path ?? "";
    debugPrint("Title:=========> $title");
    debugPrint("Video :===> $video");
    debugPrint("Image:=======> $portraitImage");
    loading = true;
    uploading = true;
    setSendingComment(true);
    successModel = await ApiService().uploadVideo(title, video, portraitImage);
    debugPrint("uploadNewVideo status :==> ${successModel.status}");
    debugPrint("uploadNewVideo message :==> ${successModel.message}");
    loading = false;
    uploading = false;
    setSendingComment(false);
    notifyListeners();
  }

  setSendingComment(isSending) {
    debugPrint("isSending ==> $isSending");
    uploadLoading = isSending;
    notifyListeners();
  }

  getThumbnailCovers(File? watermarkFile) async {
    loading = true;
    debugPrint('getThumbnailCovers watermarkFile ===> $watermarkFile');
    thumbnail1 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 10,
    );
    debugPrint('getThumbnailCovers thumbnail1 ===> $thumbnail1');

    thumbnail2 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 50,
    );
    debugPrint('getThumbnailCovers thumbnail2 ===> $thumbnail2');

    thumbnail3 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 100,
    );
    debugPrint('getThumbnailCovers thumbnail3 ===> $thumbnail3');
    loading = false;
    notifyListeners();
  }

  void saveInGallery(String videoPath) async {
    await GallerySaver.saveVideo(videoPath).then((success) {
      debugPrint("saveInGallery success ===> $success");
    });
  }

  setCoverTick(String tick) {
    coverTick = tick;
    debugPrint("coverTick ===> $coverTick");
    notifyListeners();
  }

  toggleComment(bool value) async {
    if (isComment == false) {
      isComment = true;
    } else {
      isComment = false;
    }
    debugPrint('toggleSwitch isComment ==> $isComment');
    notifyListeners();
  }

  void toggleGallery(bool value) async {
    if (isSaveGallery == false) {
      isSaveGallery = true;
    } else {
      isSaveGallery = false;
    }
    debugPrint('toggleSwitch isSaveGallery ==> $isSaveGallery');
    notifyListeners();
  }

  clearProvider() {
    successModel = SuccessModel();
    loading = false;
    uploading = false;
    isComment = false;
    isSaveGallery = false;
    coverTick = "tick1";
    thumbnail1 = "";
    thumbnail2 = "";
    thumbnail3 = "";
    finalThumb = "";
    watermarkedFile;
    videoThumb;
  }
}
