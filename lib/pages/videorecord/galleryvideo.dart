import 'dart:io';
import 'package:maring/main.dart';
import 'package:maring/pages/videorecord/videopreview.dart';
import 'package:maring/provider/galleryvideoprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/log.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GalleryVideo extends StatefulWidget {
  final String vFilePath, vDuration, contestId, hashtagName, hashtagId;

  const GalleryVideo(
      {Key? key,
      required this.vFilePath,
      required this.vDuration,
      required this.contestId,
      required this.hashtagName,
      required this.hashtagId})
      : super(key: key);

  @override
  State<GalleryVideo> createState() => _GalleryVideoState();
}

class _GalleryVideoState extends State<GalleryVideo> with RouteAware {
  late ProgressDialog prDialog;
  VideoPlayerController? _controller;
  late GalleryVideoProvider galleryVideoProvider;
  List<String>? selectedAudioDetails;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    galleryVideoProvider =
        Provider.of<GalleryVideoProvider>(context, listen: false);
    initController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    debugPrint("========= didChangeDependencies =========");
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    debugPrint("========= didPop =========");
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    debugPrint("========= didPopNext =========");
    if (_controller == null) {
      initController();
    }
    super.didPopNext();
  }

  initController() async {
    try {
      _controller = VideoPlayerController.file(
        File(widget.vFilePath),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      )..initialize().then((value) {
          if (!mounted) return;
          setState(() {
            debugPrint(
                "visibleInfo visibleFraction =========> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
            if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
              if (_controller != null) _controller?.pause();
            } else {
              if (_controller != null) _controller?.play();
            }
          });
        });
      _controller?.seekTo(Duration.zero);
      _controller?.setLooping(true);
    } catch (e) {
      debugPrint("videoScreen initController Exception ==> $e");
    }
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    debugPrint(
        "visibleInfo =====didPush====> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
    if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    debugPrint("========= didPush =========");
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    debugPrint(
        "visibleInfo =====didPushNext====> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
    if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    debugPrint("========= didPushNext =========");
    super.didPushNext();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    debugPrint("========= dispose =========");
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('GalleryVideo'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        galleryVideoProvider.setVisibilityInfo(visibilityInfo);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        debugPrint(
            '=========== Widget ${visibilityInfo.key} is $visiblePercentage% visible ===========');
        if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
          if (_controller != null) {
            _controller?.dispose();
            _controller = null;
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: transparent,
          title: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
            onTap: () async {
              // // debugPrint("Clicked on Sound Title!");
              // // selectedAudioDetails = await Navigator.push(
              // //   context,
              // //   MaterialPageRoute(
              // //     builder: (context) {
              // //       return const SoundList();
              // //     },
              // //   ),
              // // );
              // debugPrint("selectedAudioDetails ======> $selectedAudioDetails");
              // if (selectedAudioDetails != null) {
              //   await galleryVideoProvider.setSelectedAudio(
              //       audioPath: selectedAudioDetails?[0] ?? "",
              //       audioId: selectedAudioDetails?[1] ?? "");
              // }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                    width: 18,
                    height: 18,
                    imagePath: "ic_song.png",
                    color: white,
                  ),
                  const SizedBox(width: 10),
                  Consumer<GalleryVideoProvider>(
                    builder: (context, galleryVideoProvider, child) {
                      if ((galleryVideoProvider.selectedAudioPath ?? "") ==
                          "") {
                        return MyText(
                          multilanguage: false,
                          color: white,
                          text: "add_sound",
                          fontsize: 13,
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        );
                      } else {
                        return Expanded(
                          child: MyText(
                            color: white,
                            text: p.basename(
                                galleryVideoProvider.selectedAudioPath ?? ""),
                            fontsize: 13,
                            fontwaight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.start,
                            fontstyle: FontStyle.normal,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                mergeAudioVideo();
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        body: _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return GestureDetector(
        onTap: () {
          if (_controller!.value.isPlaying) {
            if (_controller != null) _controller?.pause();
          } else {
            if (_controller != null) _controller?.play();
          }
        },
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: _controller?.value.size.width,
              height: _controller?.value.size.height,
              child: AspectRatio(
                aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
      );
    }
  }

  void mergeAudioVideo() async {
    File? finalVideo = File(widget.vFilePath);
    debugPrint("finalVideo ========> $finalVideo");
    if (galleryVideoProvider.selectedAudioPath.toString().isNotEmpty &&
        (p.extension(galleryVideoProvider.selectedAudioPath ?? "") == ".mp3" ||
            p.extension(galleryVideoProvider.selectedAudioPath ?? "") ==
                ".aac")) {
      Utils.showProgress(context);
      await mixAudioVideo(
          videoPath: finalVideo.path,
          audioPath: selectedAudioDetails?[0] ?? "");
    } else {
      goToPreview(finalVideo);
    }
  }

  Future mixAudioVideo({
    required String videoPath,
    required String audioPath,
  }) async {
    String? output = "";
    Directory? documentDirectory;
    if (Platform.isAndroid) {
      documentDirectory = await getExternalStorageDirectory();
    } else {
      documentDirectory = await getApplicationDocumentsDirectory();
    }
    File mergeFile = File(p.join(documentDirectory?.path ?? "",
        '${DateTime.now().millisecondsSinceEpoch.toString()}.mp4'));
    output = mergeFile.path;
    debugPrint("mixAudioVideo output ===> $output");
    debugPrint("mixAudioVideo videoPath ===> $videoPath");
    debugPrint("mixAudioVideo audioPath ===> $audioPath");

    if (_controller != null) {
      _controller?.pause();
    }

    await FFmpegKit.executeAsync(
        "-y -i $videoPath -i $audioPath -map 0:v -map 1:a -c:v copy -shortest $output",
        (session) async {
      debugPrint(
          "=============================== EXECUTED ===============================");
      final returnCode = await session.getReturnCode();
      debugPrint("mergingExecuted returnCode ===> $returnCode");
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        try {
          debugPrint("mergeFile =========> ${mergeFile.path}");
        } catch (e) {
          debugPrint("mergingExecuted Exception ===> $e");
        } finally {
          await prDialog.hide();
          session.cancel;
          goToPreview(mergeFile);
        }
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        await prDialog.hide();
        debugPrint("mergingExecuted CANCEL ===> ${session.getLogsAsString()}");
      } else {
        // ERROR
        await prDialog.hide();
        debugPrint("Error");
        final failStackTrace = await session.getFailStackTrace();
        debugPrint("failStackTrace ===> $failStackTrace");
        List<Log> logs = await session.getLogs();
        for (var element in logs) {
          debugPrint("Message ===> ${element.getMessage()}");
        }
        debugPrint(
            "Command failed with state ${await session.getState()} and rc ${await session.getReturnCode()}.${await session.getFailStackTrace()}  ${await session.getAllLogsAsString()}");
      }
    }, (logs) {
      debugPrint("logs ====> ${logs.getMessage()}");
    });
  }

  void goToPreview(File? videoFile) {
    debugPrint("videoFile ===> ${videoFile?.path ?? ""}");
    String soundId = galleryVideoProvider.selectedAudioId ?? "0";
    debugPrint("soundId =====> $soundId");
    final route = MaterialPageRoute(
      maintainState: false,
      fullscreenDialog: true,
      builder: (_) => VideoPreview(
        filePath: videoFile?.path ?? "",
        vDuration: "30",
        soundId: soundId,
        contestId:
            !galleryVideoProvider.isContestRemoved ? (widget.contestId) : "",
        hashtagId: widget.hashtagId,
        hashtagName: widget.hashtagName,
      ),
    );
    galleryVideoProvider.clearProvider();
    Navigator.push(context, route);
  }
}
