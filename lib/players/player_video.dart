import 'package:chewie/chewie.dart';
import 'package:maring/provider/playerprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerVideo extends StatefulWidget {
  final String? videoId, videoUrl, vUploadType, videoThumb, stoptime;
  final bool? iscontinueWatching;
  const PlayerVideo(this.videoId, this.videoUrl, this.vUploadType,
      this.videoThumb, this.stoptime, this.iscontinueWatching,
      {Key? key})
      : super(key: key);

  @override
  State<PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<PlayerVideo> {
  late PlayerProvider playerProvider;
  int? playerCPosition, videoDuration;
  ChewieController? _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    debugPrint("videoUrl ========> ${widget.videoUrl}");
    debugPrint("stoptime ========> ${widget.stoptime}");
    debugPrint("vUploadType ========> ${widget.vUploadType}");
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerInit();
    });
    super.initState();
  }

  _playerInit() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl ?? ""),
    );
    await Future.wait([_videoPlayerController.initialize()]);

    /* Chewie Controller */
    _setupController();
    await playerProvider.addVideoView("1", widget.videoId);

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  _setupController() async {
    double convertToDouble = widget.iscontinueWatching == true
        ? double.parse(widget.stoptime.toString())
        : 0;
    int stoptime = convertToDouble.round();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      startAt: widget.iscontinueWatching == true
          ? Duration(seconds: stoptime)
          : const Duration(seconds: 0),
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: false,
      allowFullScreen: true,
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      allowedScreenSleep: false,
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorAccent,
        backgroundColor: gray,
        bufferedColor: colorAccent,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorAccent,
        backgroundColor: gray,
        bufferedColor: colorAccent,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: MyText(
            color: white,
            text: errorMessage,
            textalign: TextAlign.center,
            fontsize: Dimens.textMedium,
            fontwaight: FontWeight.w600,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        );
      },
    );
    _videoPlayerController.addListener(() {
      playerCPosition =
          (_chewieController?.videoPlayerController.value.position)
                  ?.inMilliseconds ??
              0;
      videoDuration = (_chewieController?.videoPlayerController.value.duration)
              ?.inMilliseconds ??
          0;
      debugPrint("playerCPosition :===> $playerCPosition");
      debugPrint("videoDuration :=====> $videoDuration");
      if (!(_chewieController?.isFullScreen ?? false)) {
        if (kIsWeb) {
          onBackPressed();
        }
        if (!(kIsWeb)) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
      }
    });
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      _chewieController?.removeListener(() {});
      _chewieController?.videoPlayerController.dispose();
    }
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _buildPage(),
              ),
              if (!kIsWeb)
                Positioned(
                  top: 15,
                  left: 15,
                  child: SafeArea(
                    child: InkWell(
                      onTap: onBackPressed,
                      focusColor: gray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      child: Utils.buildBackBtnDesign(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return _buildPlayer();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Utils.pageLoader(context),
          ),
          const SizedBox(height: 20),
          MyText(
            color: white,
            text: "Loading...",
            textalign: TextAlign.center,
            fontwaight: FontWeight.w600,
            fontsize: Dimens.textTitle,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      );
    }
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: _chewieController?.aspectRatio ??
          (_chewieController?.videoPlayerController.value.aspectRatio ??
              16 / 9),
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

  Future<bool> onBackPressed() async {
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    debugPrint("onBackPressed playerCPosition :===> $playerCPosition");
    debugPrint("onBackPressed videoDuration :===> $videoDuration");
    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      await playerProvider.removeContentHistory("1", "${widget.videoId}", "0");
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else if ((playerCPosition ?? 0) > 0) {
      await playerProvider.addContentHistory(
          "1", widget.videoId, "$playerCPosition", "0");
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, false);
      return Future.value(true);
    }
  }
}
