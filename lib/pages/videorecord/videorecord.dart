import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:countdown_progress_indicator/countdown_progress_indicator.dart';
import 'package:maring/pages/videorecord/galleryvideo.dart';
import 'package:maring/pages/videorecord/videopreview.dart';
import 'package:maring/provider/videorecordprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/log.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class VideoRecord extends StatefulWidget {
  final String? contestId, contestImg, hashtagName, hashtagId;

  const VideoRecord(
      {Key? key,
      required this.contestId,
      required this.contestImg,
      required this.hashtagName,
      required this.hashtagId})
      : super(key: key);

  @override
  State<VideoRecord> createState() => _VideoRecordState();
}

class _VideoRecordState extends State<VideoRecord> {
  late ProgressDialog prDialog;
  final audioPlayer = AudioPlayer();
  late VideoRecordProvider videoRecordProvider;
  final ImagePicker picker = ImagePicker();
  File? finalVfile;
  List<CameraDescription>? cameras = [];
  FlashMode flashMode = FlashMode.off;
  CountDownController? _countDownController;
  bool loading = false;
  CameraController? _cameraController;
  double progress = 0;
  int timerProgress = Constant.recordDuration;
  List<String>? selectedAudioDetails;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    videoRecordProvider =
        Provider.of<VideoRecordProvider>(context, listen: false);
    _countDownController = CountDownController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initCamera(null);
    });
    audioPlayer.onPlayerStateChanged.listen((s) async {
      if (s == PlayerState.playing) {
        debugPrint("PLAYING s :===> ${s.name}");
      } else if (s == PlayerState.stopped) {
        debugPrint("STOPPED s :===> ${s.name}");
      } else if (s == PlayerState.completed) {
        debugPrint("COMPLETED s :=> ${s.name}");
      }
    }, onError: (msg) {
      debugPrint("onError msg :=> $msg");
    });

    // audioPlayer.onDurationChanged
    //     .listen((d) => Constant.recordDuration = d.inSeconds);

    super.initState();
  }

  _initCamera(cameraDescription) async {
    try {
      cameras = await availableCameras();

      debugPrint("cameras ==============> ${cameras?.length}");
      if ((cameras?.length ?? 0) == 0) {
        if (!mounted) return;
        Utils.showSnackbar(context, "no_camera_msg");
        return;
      } else {
        cameraDescription ??= cameras?.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);
      }

      _cameraController =
          CameraController(cameraDescription, ResolutionPreset.max);
      await _cameraController?.initialize();
      await _cameraController?.prepareForVideoRecording();
      Future.delayed(const Duration(milliseconds: 100)).then((onValue) {
        _cameraController?.setFlashMode(videoRecordProvider.flashMode);
      });
      Future.delayed(Duration.zero).then(
        (value) {
          if (!mounted) return;
          setState(() {
            videoRecordProvider.setLoading(false);
          });
        },
      );
    } on CameraException catch (e) {
      debugPrint(
          "CameraException  code :=> ${e.code} , description :=> ${e.description}");
    }
  }

  @override
  void dispose() {
    debugPrint("============== dispose ==============");
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleCameraLens() async {
    // get current lens direction (front / rear)
    final lensDirection = _cameraController?.description.lensDirection;
    CameraDescription? newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras?.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = cameras?.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    debugPrint(
        'CAMERA direction =>>>>>> ${newDescription?.lensDirection.name}');
    if (newDescription?.lensDirection.name != "") {
      _cameraController?.setDescription(newDescription!);
      await _cameraController?.prepareForVideoRecording();
      // if (!mounted) return;
      // setState(() {});
      // _initCamera(newDescription);
    } else {
      debugPrint('Asked camera not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoRecordProvider.isLoading) {
      return Utils.pageLoader(context);
    } else {
      return Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _cameraController != null
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CameraPreview(_cameraController!),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
              Positioned(
                bottom: 25,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Consumer<VideoRecordProvider>(
                    builder: (context, videoRecordProvider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /* Gallery */
                          (!videoRecordProvider.isRecording)
                              ? InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  onTap: () {
                                    openGallery();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: MyImage(
                                      width: 27,
                                      height: 27,
                                      imagePath: "ic_gallery.png",
                                      color: white,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 27,
                                  height: 27,
                                ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            width: 27,
                            height: 27,
                          ),

                          /* Record ON/OFF */
                          InkWell(
                            onTap: () => _startStopRecording(),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child:
                                  //  !videoRecordProvider.isRecording
                                  //     ? Container(
                                  //         width: 70,
                                  //         height: 70,
                                  //         decoration: BoxDecoration(
                                  //             color: transparent,
                                  //             borderRadius:
                                  //                 BorderRadius.circular(50),
                                  //             border: Border.all(
                                  //                 width: 3, color: white)),
                                  //       )
                                  //     : SizedBox(
                                  //         height: 80,
                                  //         width: 80,
                                  //         child: CountDownProgressIndicator(
                                  //           autostart: false,
                                  //           strokeWidth: 4,
                                  //           controller: _countDownController,
                                  //           valueColor: colorPrimary,
                                  //           backgroundColor: transparent,
                                  //           duration: Constant.recordDuration,
                                  //           timeFormatter: (seconds) {
                                  //             debugPrint("seconds ==> $seconds");
                                  //             timerProgress = seconds;
                                  //             return seconds.toString();
                                  //           },
                                  //           timeTextStyle: GoogleFonts.cairo(
                                  //             textStyle: const TextStyle(
                                  //               fontWeight: FontWeight.w500,
                                  //               fontSize: 15,
                                  //               color: transparent,
                                  //             ),
                                  //           ),
                                  //           onComplete: () {
                                  //             _recordingDone();
                                  //           },
                                  //         ),
                                  //       ),

                                  MyImage(
                                width: 80,
                                height: 80,
                                imagePath: !videoRecordProvider.isRecording
                                    ? "ic_recoding_no.png"
                                    : "ic_recoding_yes.png",
                              ),
                            ),
                          ),

                          /* Exit Recording */
                          (videoRecordProvider.isRecordDone)
                              ? InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  onTap: () async {
                                    debugPrint("Clicked on Exit!");
                                    await showAlert(
                                        context,
                                        "remove_last_record_text",
                                        "cancel_",
                                        "delete");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: MyImage(
                                      width: 27,
                                      height: 27,
                                      imagePath: "ic_exit.png",
                                      color: white,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 27,
                                  height: 27,
                                ),

                          /* Done */
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                            onTap: () async {
                              debugPrint(
                                  "Clicked on Done! timerProgress ===> $timerProgress");
                              if ((_cameraController?.value.isRecordingVideo ??
                                      false) &&
                                  timerProgress <
                                      (Constant.maxRecordDuration -
                                          Constant.minRecordDuration)) {
                                _countDownController?.pause();
                                final XFile? file = await _cameraController
                                    ?.stopVideoRecording();
                                finalVfile = File(file?.path ?? "");
                                debugPrint("finalVfile path ===> $finalVfile");
                                mergeAudioVideo(finalVfile);
                              } else if (finalVfile != null) {
                                debugPrint("finalVfile path ===> $finalVfile");
                                mergeAudioVideo(finalVfile);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: MyImage(
                                width: 27,
                                height: 27,
                                imagePath: (videoRecordProvider.isRecording &&
                                        timerProgress <
                                            (Constant.maxRecordDuration -
                                                Constant.minRecordDuration))
                                    ? "ic_done.png"
                                    : "ic_not_done.png",
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              /* Back, Recording Progress & Contest */
              Positioned(
                top: 40,
                left: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: MyImage(
                          width: 30, height: 30, imagePath: "ic_roundback.png"),
                    ),
                    const SizedBox(height: 20),
                    /* Recording Progress */
                    SizedBox(
                      height: 65,
                      width: 65,
                      child: CountDownProgressIndicator(
                        autostart: false,
                        strokeWidth: 3,
                        controller: _countDownController,
                        valueColor: colorPrimary,
                        backgroundColor: transparent,
                        duration: Constant.recordDuration,
                        timeFormatter: (seconds) {
                          debugPrint("seconds ==> $seconds");
                          timerProgress = seconds;
                          return seconds.toString();
                        },
                        timeTextStyle: GoogleFonts.cairo(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: colorPrimary,
                          ),
                        ),
                        onComplete: () {
                          _recordingDone();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    /* Contest */
                    Consumer<VideoRecordProvider>(
                      builder: (context, videoRecordProvider, child) {
                        if (widget.contestId != "" &&
                            !videoRecordProvider.isContestRemoved) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    videoRecordProvider.removeContest(true);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: MyImage(
                                      width: 15,
                                      height: 15,
                                      imagePath: "ic_close.png",
                                      color: white,
                                    ),
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: MyNetworkImage(
                                  width: 70,
                                  height: 70,
                                  imagePath: widget.contestImg ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
              /* Toggle Camera & Flash ON/OFF */
              Positioned(
                top: 40,
                right: 15,
                child: Column(
                  children: [
                    /* Toggle Camera */
                    InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      onTap: () {
                        debugPrint("Clicked on Toggle!");
                        _toggleCameraLens();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: MyImage(
                          width: 27,
                          height: 27,
                          imagePath: "camera_toggle.png",
                          color: white,
                        ),
                      ),
                    ),
                    /* Flash ON/OFF */
                    InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      onTap: () {
                        debugPrint(
                            "Clicked on Flash! flashMode ===> ${videoRecordProvider.flashMode}");
                        if (_cameraController != null) {
                          videoRecordProvider.toggleFlash(_cameraController!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Consumer<VideoRecordProvider>(
                          builder: (context, videoRecordProvider, child) {
                            return MyImage(
                              width: 27,
                              height: 27,
                              imagePath:
                                  videoRecordProvider.flashMode == FlashMode.off
                                      ? "flash_on.png"
                                      : "flash_off.png",
                              color: white,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  _startStopRecording() async {
    debugPrint("timerProgress ===> $timerProgress");
    debugPrint(
        "isRecordingVideo ===> ${_cameraController?.value.isRecordingVideo}");
    debugPrint(
        "isRecordingPaused ===> ${_cameraController?.value.isRecordingPaused}");
    if (!(_cameraController?.value.isRecordingVideo ?? false)) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        audioPlayer.setSourceDeviceFile(selectedAudioDetails?[0] ?? "");
        play();
      }
      _countDownController?.resume();
      await videoRecordProvider.setRecording(true);
      await _cameraController?.startVideoRecording();
    } else if ((_cameraController?.value.isRecordingVideo ?? false) &&
        !(_cameraController?.value.isRecordingPaused ?? false)) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        pause();
      }
      _countDownController?.pause();
      await videoRecordProvider.setRecording(false);
      await _cameraController?.pauseVideoRecording();
    } else if (_cameraController?.value.isRecordingPaused ?? false) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        play();
      }
      _countDownController?.resume();
      await videoRecordProvider.setRecording(true);
      await _cameraController?.resumeVideoRecording();
    }
  }

  Future<bool> onBackPress() async {
    await showAlert(context, "video_record_exit_note", "cancel_", "okay");
    return Future.value(false);
  }

  _recordingDone() async {
    try {
      if ((_cameraController?.value.isRecordingVideo ?? false) &&
          timerProgress == 0) {
        _countDownController?.pause();
        final XFile? file = await _cameraController?.stopVideoRecording();
        debugPrint("file path ===> $file");
        finalVfile = File(file?.path ?? "");
        debugPrint("_recordVideo finalVfile ===> ${finalVfile?.path ?? ""}");
        await videoRecordProvider.setRecording(false);
        await videoRecordProvider.setRecordingDone(true);
      }
    } catch (e) {
      debugPrint("cameraException ==> $e");
    }
  }

  Future openGallery() async {
    final XFile? pickedFile =
        await picker.pickVideo(source: ImageSource.gallery);
    debugPrint("openGallery _videoFile ===> $pickedFile");

    if (pickedFile != null) {
      debugPrint("finalVfile ===> ${finalVfile?.path ?? ""}");
      int? fileLength = await pickedFile.length();
      debugPrint("fileLength =========> $fileLength");
      if ((fileLength) <= 0) {
        if (!mounted) return;
        Utils.showSnackbar(context, "no_file_fetch");
        return;
      }
      if ((fileLength) > 10000000) {
        if (!mounted) return;
        Utils.showSnackbar(context, "max_file_length_msg");
        return;
      }
      finalVfile = File(pickedFile.path);
      debugPrint("Gallery finalVfile ==> ${finalVfile?.path}");

      pause();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return GalleryVideo(
              contestId: widget.contestId ?? "",
              hashtagId: widget.hashtagId ?? "",
              hashtagName: widget.hashtagName ?? "",
              vDuration: "30",
              vFilePath: finalVfile?.path ?? "",
            );
          },
        ),
      );
      _countDownController?.pause();
      if (_cameraController?.value.isRecordingVideo ?? false) {
        await _cameraController?.pauseVideoRecording();
      }
    }
  }

  void mergeAudioVideo(File? finalVideo) async {
    debugPrint("mergeAudioVideo finalVideo =========> $finalVideo");
    if (videoRecordProvider.selectedAudioPath.toString().isNotEmpty &&
        (p.extension(videoRecordProvider.selectedAudioPath ?? "") == ".mp3" ||
            p.extension(videoRecordProvider.selectedAudioPath ?? "") ==
                ".aac")) {
      Utils.showProgress(context);
      await mixAudioVideo(
          videoPath: finalVideo?.path ?? "",
          audioPath: videoRecordProvider.selectedAudioPath ?? "");
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

    await FFmpegKit.executeAsync(
        "-y -i $videoPath -i $audioPath -map 0:v -map 1:a -c:v copy -shortest $output",
        (session) async {
      debugPrint(
          "=============================== EXECUTED ===============================");
      final returnCode = await session.getReturnCode();
      debugPrint("mergingExecuted returnCode ===> $returnCode");
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        // Console output generated for this execution
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

  void goToPreview(File? videoFile) async {
    debugPrint("videoFile ===> ${videoFile?.path ?? ""}");
    String soundId = videoRecordProvider.selectedAudioId ?? "0";
    debugPrint("soundId =====> $soundId");
    final route = MaterialPageRoute(
      maintainState: false,
      fullscreenDialog: true,
      builder: (_) => VideoPreview(
        filePath: videoFile?.path ?? "",
        vDuration: "${(Constant.recordDuration - timerProgress)}",
        soundId: soundId,
        contestId: !videoRecordProvider.isContestRemoved
            ? (widget.contestId ?? "")
            : "",
        hashtagId: widget.hashtagId ?? "",
        hashtagName: widget.hashtagName ?? "",
      ),
    );
    pause();
    videoRecordProvider.clearProvider();
    Navigator.push(context, route);
    _countDownController?.pause();
    if (_cameraController?.value.isRecordingVideo ?? false) {
      await _cameraController?.pauseVideoRecording();
    }
  }

  Future play() async {
    await audioPlayer.resume();
  }

  Future pause() async {
    await audioPlayer.pause();
  }

  Future release() async {
    await audioPlayer.release();
  }

  Future<void> showAlert(BuildContext context, String msg, String negative,
      String positive) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(15),
          content: MyText(
            multilanguage: true,
            color: black,
            text: msg,
            fontsize: 16,
            fontwaight: FontWeight.w500,
            maxline: 5,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                foregroundColor: white,
                backgroundColor: lightgray, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: negative,
                fontsize: 15,
                fontwaight: FontWeight.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                foregroundColor: white,
                backgroundColor: colorPrimary, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: positive,
                fontsize: 15,
                fontwaight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () async {
                _countDownController?.pause();
                await videoRecordProvider.clearProvider();
                await release();
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
