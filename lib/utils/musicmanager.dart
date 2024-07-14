import 'dart:developer';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/pages/musicdetails.dart';
import 'package:maring/provider/musicdetailprovider.dart';
import 'package:maring/widget/musicutils.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:maring/model/gethistorymodel.dart';

class MusicManager {
  late ConcatenatingAudioSource playlist;
  dynamic episodeDataList;
  MusicManager();

/* Music */
  void setInitialMusic(
    int cPosition,
    String contenttype,
    dynamic dataList,
    String audioId,
    dynamic callApi,
    dynamic isContinueWatching,
    int stoptime,
    String isBuy,
  ) async {
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = dataList.toList();
    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      log("url     :=====================> ${episodeDataList?[i].content.toString() ?? ""}");
      log("url     :=====================> ${episodeDataList?[i].title.toString() ?? ""}");
      playlist.add(
        buildAudioSource(
          image: episodeDataList?[i].portraitImg.toString() ?? "",
          audioUrl: episodeDataList?[i].content.toString() ?? "",
          extraDetails: episodeDataList?[i].toMap(),
          episodeId: episodeDataList?[i].id.toString() ?? "",
          displaydiscription: episodeDataList?[i].description.toString() ?? "",
          title: episodeDataList?[i].title.toString() ?? "",
          contentId: audioId,
          contentType: contenttype,
          isContinueWatching: isContinueWatching,
        ),
      );
    }

    try {
      log("Enter Try");
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      if (isContinueWatching == true) {
        log("History Play");
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        log("Simple Play");
        play();
      }

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

/* PodCast */
  void setInitialPodcast(
    BuildContext context,
    String episodeId,
    int cPosition,
    String contenttype,
    dynamic podcastEpisodeList,
    String podcastId,
    dynamic callApi,
    dynamic isContinueWatching,
    int stoptime,
    String isBuy,
    String isPodcastPage,
  ) async {
    currentlyPlaying.value = audioPlayer;
    debugPrint("lenght:=====================> ${podcastEpisodeList?.length}");
    debugPrint("Position: $cPosition");
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = podcastEpisodeList;
    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      log("url     :=====================> ${episodeDataList[i].episodeAudio}");
      log("url     :=====================> ${episodeDataList?[i].name.toString() ?? ""}");
      log("episodeId     :=====================> ${episodeDataList?[i].id.toString() ?? ""}");
      playlist.add(
        buildAudioSource(
          image: episodeDataList?[i].portraitImg.toString() ?? "",
          audioUrl: episodeDataList?[i].episodeAudio.toString() ?? "",
          extraDetails: episodeDataList?[i].toMap(),
          episodeId: episodeDataList?[i].id.toString() ?? "",
          displaydiscription: episodeDataList?[i].description.toString() ?? "",
          title: episodeDataList?[i].name.toString() ?? "",
          contentId: podcastId,
          contentType: contenttype,
          isContinueWatching: isContinueWatching,
        ),
      );
    }

    try {
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      if (isContinueWatching == true) {
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        play();
      }

      audioPlayer.positionStream.listen((position) async {
        debugPrint(
            "Total Curation==>${audioPlayer.duration?.inMilliseconds ?? 0}");
        log('Current Position:===> ${position.inMilliseconds}');
        if (isContinueWatching == true &&
            audioPlayer.duration?.inMilliseconds == position.inMilliseconds) {
          log('Call Api');
          final musicDetailProvider =
              Provider.of<MusicDetailProvider>(context, listen: false);
          await musicDetailProvider.removeContentHistory(
              contenttype, podcastId, episodeId);
        }
      });

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void setInitialPodcastEpisode(
    BuildContext context,
    String episodeId,
    int cPosition,
    String contenttype,
    dynamic podcastEpisodeList,
    String podcastId,
    dynamic callApi,
    dynamic isContinueWatching,
    int stoptime,
    String isBuy,
    String isPodcastPage,
  ) async {
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = podcastEpisodeList;
    for (int i = 0; i < (episodeDataList.length); i++) {
      playlist.add(
        buildAudioSource(
          image: episodeDataList?[i].episode?[0].portraitImg.toString() ?? "",
          audioUrl:
              episodeDataList?[i].episode?[0].episodeAudio.toString() ?? "",
          extraDetails: episodeDataList?[i].toMap(),
          episodeId: episodeDataList?[i].episode?[0].id.toString() ?? "",
          displaydiscription:
              episodeDataList?[i].episode?[0].description.toString() ?? "",
          title: episodeDataList?[i].episode?[0].name.toString() ?? "",
          contentId: podcastId,
          contentType: contenttype,
          isContinueWatching: isContinueWatching,
        ),
      );
    }

    try {
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      if (isContinueWatching == true) {
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        play();
      }

      audioPlayer.positionStream.listen((position) async {
        debugPrint(
            "Total Curation==>${audioPlayer.duration?.inMilliseconds ?? 0}");
        log('Current Position:===> ${position.inMilliseconds}');
        if (isContinueWatching == true &&
            audioPlayer.duration?.inMilliseconds == position.inMilliseconds) {
          log('Call Api');
          final musicDetailProvider =
              Provider.of<MusicDetailProvider>(context, listen: false);
          await musicDetailProvider.removeContentHistory(
              contenttype, podcastId, episodeId);
        }
      });

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void setInitialHistory(
    BuildContext context,
    String episodeId,
    int cPosition,
    String contenttype,
    dynamic podcastEpisodeList,
    String podcastId,
    dynamic callApi,
    dynamic isContinueWatching,
    int stoptime,
    String isBuy,
    String isPodcastPage,
  ) async {
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    List<Result> episodeDataList = podcastEpisodeList;
    for (int i = 0; i < (episodeDataList.length); i++) {
      playlist.add(
        buildAudioSource(
          image: episodeDataList[i].episode?[0].portraitImg.toString() ?? "",
          audioUrl:
              episodeDataList[i].episode?[0].episodeAudio.toString() ?? "",
          extraDetails: episodeDataList[i].toMap(),
          episodeId: episodeDataList[i].episode?[0].id.toString() ?? "",
          displaydiscription:
              episodeDataList[i].episode?[0].description.toString() ?? "",
          title: episodeDataList[i].episode?[0].name.toString() ?? "",
          contentId: podcastId,
          contentType: contenttype,
          isContinueWatching: isContinueWatching,
        ),
      );
    }

    try {
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      if (isContinueWatching == true) {
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        play();
      }

      audioPlayer.positionStream.listen((position) async {
        debugPrint(
            "Total Curation==>${audioPlayer.duration?.inMilliseconds ?? 0}");
        log('Current Position:===> ${position.inMilliseconds}');
        if (isContinueWatching == true &&
            audioPlayer.duration?.inMilliseconds == position.inMilliseconds) {
          log('Call Api');
          final musicDetailProvider =
              Provider.of<MusicDetailProvider>(context, listen: false);
          await musicDetailProvider.removeContentHistory(
              contenttype, podcastId, episodeId);
        }
      });

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

/* Radio */
  void setInitialRadio(
      int cPosition,
      String contenttype,
      dynamic radioEpisodeList,
      String radioId,
      dynamic callApi,
      String isBuy) async {
    currentlyPlaying.value = audioPlayer;
    debugPrint("lenght:=====================> ${radioEpisodeList?.length}");
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = radioEpisodeList;
    debugPrint("lenght:=====================> ${episodeDataList?.length}");
    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      log("url     :=====================> ${episodeDataList?[i].content.toString() ?? ""}");
      log("url     :=====================> ${episodeDataList?[i].title.toString() ?? ""}");
      playlist.add(
        buildAudioSource(
          image: episodeDataList?[i].portraitImg.toString() ?? "",
          audioUrl: episodeDataList?[i].content.toString() ?? "",
          extraDetails: episodeDataList?[i].toMap(),
          episodeId: episodeDataList?[i].id.toString() ?? "",
          displaydiscription: episodeDataList?[i].description.toString() ?? "",
          title: episodeDataList?[i].title.toString() ?? "",
          contentId: radioId,
          contentType: contenttype,
        ),
      );
    }

    try {
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      // if (isContinueWatching == true) {
      //   seek(Duration(milliseconds: stoptime));
      play();
      // } else {
      //   play();
      // }

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

/* Playlist */
  void setInitialPlayList(
    int cPosition,
    String contenttype,
    dynamic playlistEpisodeList,
    String playlistId,
    dynamic callApi,
    String isBuy,
  ) async {
    currentlyPlaying.value = audioPlayer;
    debugPrint("lenght:=====================> ${playlistEpisodeList?.length}");
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = playlistEpisodeList;
    debugPrint("lenght:=====================> ${episodeDataList?.length}");
    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      log("url     :=====================> ${episodeDataList?[i].content.toString() ?? ""}");
      log("url     :=====================> ${episodeDataList?[i].title.toString() ?? ""}");
      playlist.add(
        buildAudioSource(
          image: episodeDataList?[i].portraitImg.toString() ?? "",
          audioUrl: episodeDataList?[i].content.toString() ?? "",
          extraDetails: episodeDataList?[i].toMap(),
          episodeId: episodeDataList?[i].id.toString() ?? "",
          displaydiscription: episodeDataList?[i].description.toString() ?? "",
          title: episodeDataList?[i].title.toString() ?? "",
          contentId: playlistId,
          contentType: contenttype,
        ),
      );
    }

    try {
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      // if (isContinueWatching == true) {
      //   seek(Duration(milliseconds: stoptime));
      play();
      // } else {
      //   play();
      // }

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void play() async {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void dispose() {
    audioPlayer.dispose();
  }

  clearMusicPlayer() async {
    episodeDataList = [];
    playlist = ConcatenatingAudioSource(children: []);
    for (var i = 0; i < playlist.length; i++) {
      playlist.removeAt(i);
    }
    playlist.clear();
  }
}
