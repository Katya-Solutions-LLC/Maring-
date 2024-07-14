import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GalleryVideoProvider extends ChangeNotifier {
  VisibilityInfo? visibleInfo;
  bool isLoading = true,
      isRecording = false,
      isRecordDone = false,
      isContestRemoved = false;
  String? selectedAudioPath, selectedAudioId;

  setSelectedAudio({required String audioPath, required String audioId}) {
    selectedAudioPath = audioPath;
    selectedAudioId = audioId;
    debugPrint("selectedAudioPath =====> $selectedAudioPath");
    debugPrint("selectedAudioId =======> $selectedAudioId");
    notifyListeners();
  }

  removeContest(bool value) {
    debugPrint("removeContest value ===> $value");
    isContestRemoved = value;
    notifyListeners();
  }

  setVisibilityInfo(VisibilityInfo? visibleInfo) {
    this.visibleInfo = visibleInfo;
    notifyListeners();
  }

  clearProvider() {
    isLoading = true;
    isRecording = false;
    isRecordDone = false;
    isContestRemoved = false;
    selectedAudioPath = "";
    selectedAudioId = "";
  }
}
