import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoRecordProvider extends ChangeNotifier {
  bool isLoading = true,
      isRecording = false,
      isRecordDone = false,
      isContestRemoved = false;
  FlashMode flashMode = FlashMode.off;

  String? selectedAudioPath, selectedAudioId;

  setSelectedAudio({required String audioPath, required String audioId}) {
    selectedAudioPath = audioPath;
    selectedAudioId = audioId;
    debugPrint("selectedAudioPath =====> $selectedAudioPath");
    debugPrint("selectedAudioId =======> $selectedAudioId");
    notifyListeners();
  }

  setLoading(bool value) {
    debugPrint("setLoading value ===> $value");
    isLoading = value;
    notifyListeners();
  }

  setRecording(bool value) {
    debugPrint("setRecording value ===> $value");
    isRecording = value;
    notifyListeners();
  }

  setRecordingDone(bool value) {
    debugPrint("setRecordingDone value ===> $value");
    isRecordDone = value;
    notifyListeners();
  }

  toggleFlash(CameraController cameraController) async {
    debugPrint("toggleFlash mode ===> $flashMode");
    if (cameraController.value.isInitialized) {
      if (flashMode == FlashMode.torch) {
        await cameraController.setFlashMode(FlashMode.off);
        flashMode = FlashMode.off;
      } else {
        await cameraController.setFlashMode(FlashMode.torch);
        flashMode = FlashMode.torch;
      }
    }
    notifyListeners();
  }

  removeContest(bool value) {
    debugPrint("removeContest value ===> $value");
    isContestRemoved = value;
    notifyListeners();
  }

  clearProvider() {
    isLoading = true;
    isRecording = false;
    isRecordDone = false;
    isContestRemoved = false;
    flashMode = FlashMode.off;
    selectedAudioPath = "";
    selectedAudioId = "";
  }
}
