import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPreviewProvider extends ChangeNotifier {
  VisibilityInfo? visibleInfo;

  setVisibilityInfo(VisibilityInfo? visibleInfo) {
    this.visibleInfo = visibleInfo;
    notifyListeners();
  }
}
