import 'dart:developer';
import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/pages/login.dart';
import 'package:maring/provider/contentdetailprovider.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/provider/musicprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/musicmanager.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/musicutils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mymarqueetext.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';

AudioPlayer audioPlayer = AudioPlayer();

Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class MusicDetails extends StatefulWidget {
  final bool ishomepage;
  final String contentid, episodeid, contenttype, stoptime;
  const MusicDetails({
    Key? key,
    required this.ishomepage,
    required this.contenttype,
    required this.contentid,
    required this.episodeid,
    required this.stoptime,
  }) : super(key: key);

  @override
  State<MusicDetails> createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails> {
  final MusicManager _musicManager = MusicManager();
  late ScrollController _scrollcontroller;
  late MusicDetailProvider musicDetailProvider;
  int currentstoptime = 0;

  @override
  void initState() {
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    _scrollcontroller = ScrollController();
    super.initState();
    _scrollcontroller.addListener(_scrollListener);
  }

  _scrollListener() async {
    if (!_scrollcontroller.hasClients) return;
    if (_scrollcontroller.offset >=
            _scrollcontroller.position.maxScrollExtent &&
        !_scrollcontroller.position.outOfRange) {
      await musicDetailProvider.setLoadMore(true);
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "4") {
        if ((musicDetailProvider.podcastcurrentPage ?? 0) <
            (musicDetailProvider.podcasttotalPage ?? 0)) {
          _fetchDataPodcast(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.podcastcurrentPage ?? 0);
        }
      } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "5") {
        if ((musicDetailProvider.playlistcurrentPage ?? 0) <
            (musicDetailProvider.playlisttotalPage ?? 0)) {
          _fetchDataPlaylist(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              "5",
              musicDetailProvider.playlistcurrentPage ?? 0);
        }
      } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "6") {
        if ((musicDetailProvider.radiocurrentPage ?? 0) <
            (musicDetailProvider.radiototalPage ?? 0)) {
          _fetchDataRadio(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.radiocurrentPage ?? 0);
        }
      }
    }
  }

  Future<void> _fetchDataPodcast(podcastId, int? nextPage) async {
    debugPrint("isMorePage  ======> ${musicDetailProvider.podcastisMorePage}");
    debugPrint("currentPage ======> ${musicDetailProvider.podcastcurrentPage}");
    debugPrint("totalPage   ======> ${musicDetailProvider.podcasttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.getEpisodeByPodcast(
        podcastId, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  Future<void> _fetchDataPlaylist(
      playlistId, contentType, int? nextPage) async {
    debugPrint("isMorePage  ======> ${musicDetailProvider.playlistisMorePage}");
    debugPrint(
        "currentPage ======> ${musicDetailProvider.playlistcurrentPage}");
    debugPrint("totalPage   ======> ${musicDetailProvider.playlisttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.getEpisodeByPlaylist(
        playlistId, contentType, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  Future<void> _fetchDataRadio(radioId, int? nextPage) async {
    debugPrint("isMorePage  ======> ${musicDetailProvider.radioisMorePage}");
    debugPrint("currentPage ======> ${musicDetailProvider.radiocurrentPage}");
    debugPrint("totalPage   ======> ${musicDetailProvider.radiototalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.getEpisodeByRadio(radioId, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PositionData>(
        stream: positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          currentstoptime = positionData?.position.inMilliseconds ?? 0;
          return Miniplayer(
            valueNotifier: playerExpandProgress,
            minHeight: playerMinHeight,
            duration: const Duration(seconds: 1),
            maxHeight: MediaQuery.of(context).size.height,
            controller: controller,
            elevation: 4,
            backgroundColor: colorPrimaryDark,
            onDismiss: () {},
            onDismissed: () async {
              debugPrint(
                  "is Contiue Watching=>${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.playable}");
              currentlyPlaying.value = null;
              debugPrint("contentType=>${widget.contenttype}");
              debugPrint("contentId=>${widget.contentid}");
              debugPrint("episodeid=>${widget.episodeid}");
              debugPrint("stopTime=>${widget.stoptime}");

              if (Constant.userID != null) {
                await musicDetailProvider.addContentHistory(widget.contenttype,
                    widget.contentid, currentstoptime, widget.episodeid);
              }

              currentlyPlaying.value = null;
              await audioPlayer.pause();
              await audioPlayer.stop();
              if (mounted) {
                setState(() {});
              }

              _musicManager.clearMusicPlayer();
              musicDetailProvider.clearProvider();
            },
            curve: Curves.easeInOutCubicEmphasized,
            builder: (height, percentage) {
              final bool miniplayer =
                  percentage < miniplayerPercentageDeclaration;

              // debugPrint("percentage==> $percentage");
              // debugPrint("height==> $miniplayerPercentageDeclaration");
              // debugPrint("minimum height==> $playerMinHeight");

              if (!miniplayer) {
                return Scaffold(
                  backgroundColor: colorPrimary,
                  body: SafeArea(
                    bottom: false,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: colorPrimary,
                      ),
                      child: Column(
                        children: [
                          _buildAppBar(),
                          Expanded(child: buildMusicPage()),
                        ],
                      ),
                    ),
                  ),
                );
              }

              //Miniplayer
              final percentageMiniplayer = percentageFromValueInRange(
                  min: playerMinHeight,
                  max: MediaQuery.of(context).size.height,
                  value: height);

              final elementOpacity = 1 - 1 * percentageMiniplayer;
              final progressIndicatorHeight = 2 - 2 * percentageMiniplayer;

              return Scaffold(
                body: _buildMusicPanel(
                    height, elementOpacity, progressIndicatorHeight),
              );
            },
          );
        });
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FittedBox(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 11,
                  child: MyImage(
                      height: 25,
                      width: 25,
                      imagePath: "ic_roundback.png",
                      fit: BoxFit.contain,
                      color: white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MyText(
              color: white,
              text: "playingstart",
              maxline: 1,
              fontsize: 16,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget buildMusicPage() {
    return NestedScrollView(
      controller: _scrollcontroller,
      floatHeaderSlivers: false,
      physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
      scrollDirection: Axis.vertical,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          /* UserProfile Section */
          SliverAppBar(
            floating: false,
            forceElevated: false,
            snap: false,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height * 0.72,
            automaticallyImplyLeading: false,
            backgroundColor: colorPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Music Image With Song Title
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          StreamBuilder<SequenceState?>(
                              stream: audioPlayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(width: 3.0, color: white),
                                      bottom:
                                          BorderSide(width: 3.0, color: white),
                                    ),
                                  ),
                                  child: MyNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.30,
                                    imagePath: ((audioPlayer
                                                .sequenceState
                                                ?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.artUri)
                                        .toString(),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }),
                          const SizedBox(height: 15),
                          StreamBuilder<SequenceState?>(
                              stream: audioPlayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return Container(
                                  height: 35,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: MyMarqueeText(
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      fontsize: Dimens.textBig,
                                      color: white),
                                );
                              }),
                          const SizedBox(height: 15),
                          // Like & Dislike & Comment & Save & Share Button
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            // color: colorAccent,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (audioPlayer.sequenceState?.currentSource?.tag
                                                      as MediaItem?)
                                                  ?.genre ==
                                              "5" ||
                                          (audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.genre ==
                                              "6"
                                      ? const SizedBox.shrink()
                                      : (audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.extras?['is_like'] ==
                                              1
                                          ? Container(
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 8, 15, 8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: colorPrimaryDark,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      if (Constant.userID ==
                                                          null) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) {
                                                              return const Login();
                                                            },
                                                          ),
                                                        );
                                                      } else {
                                                        if ((audioPlayer
                                                                    .sequenceState
                                                                    ?.currentSource
                                                                    ?.tag as MediaItem?)
                                                                ?.extras?['is_like'] ==
                                                            0) {
                                                          Utils.showSnackbar(
                                                              context,
                                                              "youcannotlikethiscontent");
                                                        } else {
                                                          like();
                                                        }
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        (audioPlayer.sequenceState?.currentSource
                                                                            ?.tag
                                                                        as MediaItem?)
                                                                    ?.extras?['is_user_like_dislike'] ==
                                                                1
                                                            ? MyImage(
                                                                width: 25,
                                                                height: 25,
                                                                imagePath:
                                                                    "ic_likefill.png",
                                                              )
                                                            : MyImage(
                                                                width: 25,
                                                                height: 25,
                                                                imagePath:
                                                                    "ic_like.png",
                                                              ),
                                                        const SizedBox(
                                                            width: 8),
                                                        MyText(
                                                            color: white,
                                                            text: Utils.kmbGenerator(int.parse(
                                                                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                                                                            ?.extras?[
                                                                        'total_like'])
                                                                    .toString())),
                                                            multilanguage:
                                                                false,
                                                            textalign: TextAlign
                                                                .center,
                                                            fontsize: Dimens
                                                                .textTitle,
                                                            inter: false,
                                                            maxline: 6,
                                                            fontwaight:
                                                                FontWeight.w600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontstyle: FontStyle
                                                                .normal),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: white,
                                                  ),
                                                  const SizedBox(width: 15),
                                                  InkWell(
                                                    onTap: () async {
                                                      if ((audioPlayer
                                                                  .sequenceState
                                                                  ?.currentSource
                                                                  ?.tag as MediaItem?)
                                                              ?.extras?['is_like'] ==
                                                          0) {
                                                        Utils.showSnackbar(
                                                            context,
                                                            "youcannotlikethiscontent");
                                                      } else {
                                                        dislike();
                                                      }
                                                    },
                                                    child: (audioPlayer
                                                                    .sequenceState
                                                                    ?.currentSource
                                                                    ?.tag as MediaItem?)
                                                                ?.extras?['is_user_like_dislike'] ==
                                                            2
                                                        ? MyImage(
                                                            width: 25,
                                                            height: 25,
                                                            imagePath:
                                                                "ic_dislikefill.png",
                                                          )
                                                        : MyImage(
                                                            width: 25,
                                                            height: 25,
                                                            imagePath:
                                                                "ic_dislike.png",
                                                          ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                  const SizedBox(width: 10),
                                  // Container(
                                  //   padding: const EdgeInsets.fromLTRB(
                                  //       15, 10, 15, 10),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(20),
                                  //     color: colorPrimaryDark,
                                  //   ),
                                  //   child: Row(
                                  //     children: [
                                  //       MyImage(
                                  //         width: 20,
                                  //         height: 20,
                                  //         imagePath: "ic_download.png",
                                  //         color: white,
                                  //       ),
                                  //       const SizedBox(width: 8),
                                  //       MyText(
                                  //           color: white,
                                  //           text: "save",
                                  //           multilanguage: true,
                                  //           textalign: TextAlign.center,
                                  //           fontsize: Dimens.textTitle,
                                  //           inter: false,
                                  //           maxline: 6,
                                  //           fontwaight: FontWeight.w600,
                                  //           overflow: TextOverflow.ellipsis,
                                  //           fontstyle: FontStyle.normal),
                                  //     ],
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Utils.shareApp(Platform.isIOS
                                          ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                          : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 10, 15, 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: colorPrimaryDark,
                                      ),
                                      child: Row(
                                        children: [
                                          MyImage(
                                            width: 20,
                                            height: 20,
                                            imagePath: "ic_share.png",
                                            color: white,
                                          ),
                                          const SizedBox(width: 8),
                                          MyText(
                                              color: white,
                                              text: "share",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsize: Dimens.textTitle,
                                              inter: false,
                                              maxline: 6,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // All Buttons
                    Container(
                      // height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: StreamBuilder<PositionData>(
                              stream: positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                return ProgressBar(
                                  progress:
                                      positionData?.position ?? Duration.zero,
                                  buffered: positionData?.bufferedPosition ??
                                      Duration.zero,
                                  total:
                                      positionData?.duration ?? Duration.zero,
                                  progressBarColor: white,
                                  baseBarColor: colorAccent,
                                  bufferedBarColor: gray,
                                  thumbColor: white,
                                  barHeight: 2.0,
                                  thumbRadius: 5.0,
                                  timeLabelPadding: 5.0,
                                  timeLabelType: TimeLabelType.totalTime,
                                  timeLabelTextStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSeek: (duration) {
                                    audioPlayer.seek(duration);
                                  },
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Privious Audio Setup
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // 10 Second Privious
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: MyImage(
                                            width: 30,
                                            height: 30,
                                            imagePath: "ic_tenprevious.png"),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Pause and Play Controll
                              StreamBuilder<PlayerState>(
                                stream: audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playerState = snapshot.data;
                                  final processingState =
                                      playerState?.processingState;
                                  final playing = playerState?.playing;
                                  if (processingState ==
                                          ProcessingState.loading ||
                                      processingState ==
                                          ProcessingState.buffering) {
                                    return Container(
                                      margin: const EdgeInsets.all(8.0),
                                      width: 50.0,
                                      height: 50.0,
                                      child: const CircularProgressIndicator(
                                        color: colorAccent,
                                      ),
                                    );
                                  } else if (playing != true) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: white,
                                        ),
                                        color: white,
                                        iconSize: 50.0,
                                        onPressed: audioPlayer.play,
                                      ),
                                    );
                                  } else if (processingState !=
                                      ProcessingState.completed) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.pause_rounded,
                                          color: white,
                                        ),
                                        iconSize: 50.0,
                                        color: white,
                                        onPressed: audioPlayer.pause,
                                      ),
                                    );
                                  } else {
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.replay_rounded,
                                        color: white,
                                      ),
                                      iconSize: 60.0,
                                      onPressed: () => audioPlayer.seek(
                                          Duration.zero,
                                          index: audioPlayer
                                              .effectiveIndices!.first),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 15),
                              // 10 Second Next
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;

                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: MyImage(
                                            width: 30,
                                            height: 30,
                                            imagePath: "ic_tennext.png"),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Next Audio Play
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            decoration: const BoxDecoration(
                                // color: colorAccent,
                                ),
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Volumn Costome Set
                                IconButton(
                                  iconSize: 30.0,
                                  icon: const Icon(Icons.volume_up),
                                  color: white,
                                  onPressed: () {
                                    showSliderDialog(
                                      context: context,
                                      title: "Adjust volume",
                                      divisions: 10,
                                      min: 0.0,
                                      max: 2.0,
                                      value: audioPlayer.volume,
                                      stream: audioPlayer.volumeStream,
                                      onChanged: audioPlayer.setVolume,
                                    );
                                  },
                                ),
                                // Audio Speed Costomized
                                StreamBuilder<double>(
                                  stream: audioPlayer.speedStream,
                                  builder: (context, snapshot) => IconButton(
                                    icon: Text(
                                      overflow: TextOverflow.ellipsis,
                                      "${snapshot.data?.toStringAsFixed(1)}x",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                          fontSize: 14),
                                    ),
                                    onPressed: () {
                                      showSliderDialog(
                                        context: context,
                                        title: "Adjust speed",
                                        divisions: 10,
                                        min: 0.5,
                                        max: 2.0,
                                        value: audioPlayer.speed,
                                        stream: audioPlayer.speedStream,
                                        onChanged: audioPlayer.setSpeed,
                                      );
                                    },
                                  ),
                                ),
                                // Loop Node Button
                                StreamBuilder<LoopMode>(
                                  stream: audioPlayer.loopModeStream,
                                  builder: (context, snapshot) {
                                    final loopMode =
                                        snapshot.data ?? LoopMode.off;
                                    const icons = [
                                      Icon(Icons.repeat,
                                          color: white, size: 30.0),
                                      Icon(Icons.repeat,
                                          color: colorAccent, size: 30.0),
                                      Icon(Icons.repeat_one,
                                          color: colorAccent, size: 30.0),
                                    ];
                                    const cycleModes = [
                                      LoopMode.off,
                                      LoopMode.all,
                                      LoopMode.one,
                                    ];
                                    final index = cycleModes.indexOf(loopMode);
                                    return IconButton(
                                      icon: icons[index],
                                      onPressed: () {
                                        audioPlayer.setLoopMode(cycleModes[
                                            (cycleModes.indexOf(loopMode) + 1) %
                                                cycleModes.length]);
                                      },
                                    );
                                  },
                                ),
                                // Suffle Button
                                StreamBuilder<bool>(
                                  stream: audioPlayer.shuffleModeEnabledStream,
                                  builder: (context, snapshot) {
                                    final shuffleModeEnabled =
                                        snapshot.data ?? false;
                                    return IconButton(
                                      iconSize: 30.0,
                                      icon: shuffleModeEnabled
                                          ? const Icon(Icons.shuffle,
                                              color: colorAccent)
                                          : const Icon(Icons.shuffle,
                                              color: white),
                                      onPressed: () async {
                                        final enable = !shuffleModeEnabled;
                                        if (enable) {
                                          await audioPlayer.shuffle();
                                        }
                                        await audioPlayer
                                            .setShuffleModeEnabled(enable);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // Bottom Sheet
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre)
                  .toString() ==
              "2"
          ? const SizedBox.shrink()
          : Consumer<MusicDetailProvider>(
              builder: (context, seactionprovider, child) {
              return Container(
                decoration: const BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  seactionprovider.changeMusicTab("episode");
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  // height: 50,
                                  alignment: Alignment.center,
                                  // color: colorAccent,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: white,
                                          text: "episodes",
                                          multilanguage: true,
                                          textalign: TextAlign.center,
                                          fontsize: Dimens.textDesc,
                                          inter: false,
                                          maxline: 6,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      seactionprovider.istype == "episode"
                                          ? Container(
                                              width: 100,
                                              height: 1,
                                              color: colorAccent,
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  seactionprovider.changeMusicTab("details");
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  // height: 50,
                                  // color: colorAccent,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: white,
                                          text: "details",
                                          multilanguage: true,
                                          textalign: TextAlign.center,
                                          fontsize: Dimens.textDesc,
                                          inter: false,
                                          maxline: 6,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      seactionprovider.istype == "details"
                                          ? Container(
                                              width: 100,
                                              height: 1,
                                              color: colorAccent,
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre ==
                          "4")
                        seactionprovider.istype == "episode"
                            ? buildPodcastEpisode()
                            : detailItemPodcast()
                      else if ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre ==
                          "6")
                        seactionprovider.istype == "episode"
                            ? buildRadioEpisode()
                            : detailItemRadioPlaylist()
                      else if ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre ==
                          "5")
                        seactionprovider.istype == "episode"
                            ? buildPlaylistEpisode()
                            : detailItemRadioPlaylist()
                    ],
                  ),
                ),
              );
            }),
    );
  }

  Widget _buildMusicPanel(
      dynamicPanelHeight, elementOpacity, progressIndicatorHeight) {
    return Container(
      decoration: const BoxDecoration(
        color: colorPrimaryDark,
      ),
      child: Column(
        children: [
          Expanded(
            child: Opacity(
              opacity: elementOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Music Image */
                  StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      return Container(
                        width: 80,
                        height: dynamicPanelHeight,
                        padding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MyNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            imagePath: ((audioPlayer.sequenceState
                                        ?.currentSource?.tag as MediaItem?)
                                    ?.artUri)
                                .toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                child: MyMarqueeText(
                                    text: ((audioPlayer
                                                .sequenceState
                                                ?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.title)
                                        .toString(),
                                    fontsize: Dimens.textBig,
                                    color: white),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              MyText(
                                  color: white,
                                  text: ((audioPlayer
                                              .sequenceState
                                              ?.currentSource
                                              ?.tag as MediaItem?)
                                          ?.displaySubtitle)
                                      .toString(),
                                  textalign: TextAlign.left,
                                  fontsize: 12,
                                  inter: true,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          );
                        }),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasPrevious) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Play/Pause */
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 35.0,
                                  height: 35.0,
                                  child: Utils.pageLoader(context),
                                );
                              } else if (playing != true) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: white,
                                    ),
                                    color: white,
                                    iconSize: 25.0,
                                    onPressed: audioPlayer.play,
                                  ),
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.pause_rounded,
                                      color: white,
                                    ),
                                    iconSize: 25.0,
                                    color: white,
                                    onPressed: audioPlayer.pause,
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.replay_rounded,
                                    color: white,
                                  ),
                                  iconSize: 35.0,
                                  onPressed: () => audioPlayer.seek(
                                      Duration.zero,
                                      index:
                                          audioPlayer.effectiveIndices!.first),
                                );
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Next */
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasNext) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  /* Previous */
                ],
              ),
            ),
          ),
          Opacity(
            opacity: elementOpacity,
            child: StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  progressBarColor: white,
                  baseBarColor: colorAccent,
                  bufferedBarColor: white.withOpacity(0.24),
                  barCapShape: BarCapShape.square,
                  barHeight: progressIndicatorHeight,
                  thumbRadius: 0.0,
                  timeLabelLocation: TimeLabelLocation.none,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPodcastEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      if (episodeprovider.epidoseByPodcastModel.status == 200 &&
          episodeprovider.podcastEpisodeList != null) {
        if ((episodeprovider.podcastEpisodeList?.length ?? 0) > 0) {
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                episodeprovider.podcastEpisodeList?.length ?? 0, (index) {
              return InkWell(
                onTap: () async {
                  _musicManager.setInitialPodcast(
                    context,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.id)
                        .toString(),
                    index,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.genre)
                        .toString(),
                    episodeprovider.podcastEpisodeList,
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.album)
                        .toString(),
                    addView(
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre)
                          .toString(),
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.album)
                          .toString(),
                    ),
                    false,
                    0,
                    (audioPlayer.sequenceState?.currentSource?.tag
                            as MediaItem?)
                        ?.extras?['is_buy'],
                    "podcast",
                  );
                },
                child: Container(
                  color: ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.id)
                              .toString() ==
                          episodeprovider.podcastEpisodeList?[index].id
                              .toString()
                      ? colorAccent.withOpacity(0.10)
                      : colorPrimaryDark,
                  height: 75,
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 70,
                              imagePath: episodeprovider
                                      .podcastEpisodeList?[index].portraitImg
                                      .toString() ??
                                  ""),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ((audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.id)
                                        .toString() ==
                                    episodeprovider
                                        .podcastEpisodeList?[index].id
                                        .toString()
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif")
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: episodeprovider
                                      .podcastEpisodeList?[index].name
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textMedium,
                              inter: false,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: episodeprovider
                                      .podcastEpisodeList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget buildRadioEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
            episodeprovider.epidoseByRadioModel.result?.length ?? 0, (index) {
          return InkWell(
            onTap: () {
              _musicManager.setInitialRadio(
                  index,
                  ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                          ?.genre)
                      .toString(),
                  episodeprovider.epidoseByPodcastModel.result,
                  ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                          ?.album)
                      .toString(),
                  addView(
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.genre)
                        .toString(),
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.album)
                        .toString(),
                  ),
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['is_buy']);
            },
            child: Container(
              color:
                  ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                                  ?.id)
                              .toString() ==
                          episodeprovider.epidoseByRadioModel.result?[index].id
                              .toString()
                      ? colorAccent.withOpacity(0.10)
                      : colorPrimaryDark,
              height: 85,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: colorAccent),
                      ),
                      child: MyNetworkImage(
                          fit: BoxFit.cover,
                          width: 70,
                          imagePath: episodeprovider.epidoseByRadioModel
                                  .result?[index].portraitImg
                                  .toString() ??
                              ""),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.id)
                                    .toString() ==
                                episodeprovider
                                    .epidoseByRadioModel.result?[index].id
                                    .toString()
                            ? MyImage(
                                width: 30, height: 30, imagePath: "music.gif")
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: episodeprovider
                                  .epidoseByRadioModel.result?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textMedium,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: episodeprovider.epidoseByRadioModel
                                  .result?[index].description
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textSmall,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                )
              ]),
            ),
          );
        }),
      );
    });
  }

  Widget buildPlaylistEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, episodeprovider, child) {
      if (episodeprovider.episodebyplaylistModel.status == 200 &&
          episodeprovider.playlistEpisodeList != null) {
        if ((episodeprovider.playlistEpisodeList?.length ?? 0) > 0) {
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                episodeprovider.playlistEpisodeList?.length ?? 0, (index) {
              return InkWell(
                onTap: () {
                  _musicManager.setInitialPlayList(
                      index,
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.genre)
                          .toString(),
                      episodeprovider.playlistEpisodeList,
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                  as MediaItem?)
                              ?.album)
                          .toString(),
                      addView(
                        ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.genre)
                            .toString(),
                        ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.album)
                            .toString(),
                      ),
                      (audioPlayer.sequenceState?.currentSource?.tag
                              as MediaItem?)
                          ?.extras?['is_buy']);
                },
                child: Container(
                  color: ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.id)
                              .toString() ==
                          episodeprovider.playlistEpisodeList?[index].id
                              .toString()
                      ? colorAccent.withOpacity(0.10)
                      : colorPrimaryDark,
                  height: 85,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 70,
                              imagePath: episodeprovider
                                      .playlistEpisodeList?[index].portraitImg
                                      .toString() ??
                                  ""),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ((audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.id)
                                        .toString() ==
                                    episodeprovider
                                        .playlistEpisodeList?[index].id
                                        .toString()
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif")
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: episodeprovider
                                      .playlistEpisodeList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textMedium,
                              inter: false,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 8),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: episodeprovider
                                      .playlistEpisodeList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textSmall,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    )
                  ]),
                ),
              );
            }),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget detailItemPodcast() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsize: Dimens.textBig,
              inter: false,
              maxline: 5,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsize: Dimens.textMedium,
              inter: false,
              maxline: 100,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['podcasts_name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsize: Dimens.textTitle,
              inter: false,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget detailItemRadioPlaylist() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['title'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsize: Dimens.textBig,
              inter: false,
              maxline: 5,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsize: Dimens.textMedium,
              inter: false,
              maxline: 100,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre)
                      .toString() ==
                  "playlist"
              ? MyText(
                  color: white,
                  text: (audioPlayer.sequenceState?.currentSource?.tag
                          as MediaItem?)
                      ?.extras?['channel_name'],
                  multilanguage: false,
                  textalign: TextAlign.left,
                  fontsize: Dimens.textMedium,
                  inter: false,
                  maxline: 100,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

/* 10 Second Next And Previous Functionality */
// bool isnext = true > next Audio Seek
// bool isnext = false > previous Audio Seek
  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    _musicManager.seek(movePosition);
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }

/* Music And PodcastEpisode Like */
  like() async {
    final musicprovider = Provider.of<MusicProvider>(context, listen: false);
    final contentDetailprovider =
        Provider.of<ContentDetailProvider>(context, listen: false);

    String songid = (audioPlayer
                    .sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre ==
            "4"
        ? ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album)
            .toString()
        : ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.id)
            .toString();

    log("is_user_like_dislike==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_user_like_dislike']}");
    log("contentType==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre}");

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 1;
      log("is_user_like_dislike1==> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_user_like_dislike']}");
      log("Like Succsessfully");
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] =
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_like']) +
              1;

      /* Add Like Api for Music */
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "1",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        2) {
      log("Call This APi");
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 1;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_like'] +
              1;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_dislike'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_dislike'] -
                1;
      }
      /* Like Api After Calling the Dislike Music Already */
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "1",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 0;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_like'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_like'] -
                1;
        log("Dislike Succsessfully");
        await musicDetailProvider.addLikeDislike(
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre,
            songid,
            "0",
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre ==
                    "4"
                ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.id
                : "0");
      }
    }

    if (!mounted) return;
    setState(() {});

    /* Update Music Section */
    await musicprovider.getSeactionList("1", "0", "1");
    await contentDetailprovider.getEpisodeByPodcast(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByRadio(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByPlaylist(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "2",
        "1");
  }

/* Music And PodcastEpisode DisLike */
  dislike() async {
    final musicprovider = Provider.of<MusicProvider>(context, listen: false);

    final contentDetailprovider =
        Provider.of<ContentDetailProvider>(context, listen: false);

    String songid = (audioPlayer
                    .sequenceState?.currentSource?.tag as MediaItem?)
                ?.genre ==
            "4"
        ? ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album)
            .toString()
        : ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.id)
            .toString();

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 2;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_dislike'] +
              1;
    } else if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        1) {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 2;
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] =
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.extras?['total_dislike'] +
              1;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_like'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_like'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_like'] -
                1;
      }
    } else {
      (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
          ?.extras?['is_user_like_dislike'] = 0;
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.extras?['total_dislike'] >
          0) {
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['total_dislike'] =
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['total_dislike'] -
                1;
      }
    }

    if (!mounted) return;
    setState(() {});

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.extras?['is_user_like_dislike'] ==
        0) {
      log("Remove Dislike");
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "0",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    } else {
      log("ADD Dislike");
      await musicDetailProvider.addLikeDislike(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre,
          songid,
          "2",
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre ==
                  "4"
              ? (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.id
              : "0");
    }

    await musicprovider.getSeactionList("1", "0", "1");

    await contentDetailprovider.getEpisodeByPodcast(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByRadio(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "1");

    await contentDetailprovider.getEpisodeByPlaylist(
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.album,
        "2",
        "1");
  }
}
