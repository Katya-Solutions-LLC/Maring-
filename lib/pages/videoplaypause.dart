import 'package:maring/utils/color.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayPause extends StatelessWidget {
  const VideoPlayPause({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 200),
      child: controller.value.isPlaying
          ? const SizedBox(
              height: 60,
              width: 60,
            )
          : Container(
              height: 60,
              width: 60,
              decoration: Utils.setGradTTBBGWithBorder(
                  colorPrimaryDark.withOpacity(0.45),
                  colorPrimary.withOpacity(0.45),
                  transparent,
                  40,
                  0),
              padding: const EdgeInsets.all(20),
              child: MyImage(
                  imagePath: 'ic_play.png',
                  color: white,
                  height: 20,
                  width: 20),
            ),
    );
  }
}
