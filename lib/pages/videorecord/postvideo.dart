import 'dart:io';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/provider/postvideoprovider.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mynetworkimg.dart';
import 'package:maring/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class PostVideo extends StatefulWidget {
  final String? vDuration, soundId, contestId, hashtagName, hashtagId;
  final File videoFile;
  const PostVideo(
      {required this.videoFile,
      required this.vDuration,
      required this.soundId,
      required this.contestId,
      required this.hashtagName,
      required this.hashtagId,
      super.key});

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  late PostVideoProvider postVideoProvider;
  SharedPre sharePref = SharedPre();
  File? finalVideoFile;
  late ProgressDialog prDialog;
  String? imageFromVideo, userProfile;
  final mCommentController = TextEditingController();

  @override
  void initState() {
    postVideoProvider = Provider.of<PostVideoProvider>(context, listen: false);
    finalVideoFile = widget.videoFile;
    prDialog = ProgressDialog(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    userProfile = await sharePref.read("image");
    debugPrint("_getData userProfile ===> $userProfile");
    debugPrint("_getData videoFile ===> ${finalVideoFile?.path ?? ""}");
    await postVideoProvider.getThumbnailCovers(finalVideoFile);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.hashtagName ?? "").isNotEmpty) {
      if (mCommentController.text.toString().isEmpty) {
        mCommentController.text = (widget.hashtagName ?? "").contains("#")
            ? (widget.hashtagName ?? "")
            : "#${(widget.hashtagName ?? "")}";
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "uploadpost", true),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* Profile Image & Video description */
                  _buildUserVideoDesc(),
                  const SizedBox(height: 40),

                  /* Select Cover */
                  MyText(
                    multilanguage: true,
                    color: white,
                    text: "selectcover",
                    fontsize: 15,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 12),
                  _buildCovers(),
                  const SizedBox(height: 30),

                  /* Comment ON/OFF */
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   constraints: const BoxConstraints(
                  //     minHeight: 45,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       MyText(
                  //         multilanguage: true,
                  //         color: white,
                  //         text: "comment_off",
                  //         fontsize: 15,
                  //         maxline: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         fontwaight: FontWeight.w500,
                  //         textalign: TextAlign.center,
                  //         fontstyle: FontStyle.normal,
                  //       ),
                  //       const SizedBox(width: 15),
                  //       Consumer<PostVideoProvider>(
                  //         builder: (context, postVideoProvider, child) {
                  //           return Switch(
                  //             activeColor: colorPrimary,
                  //             activeTrackColor: white,
                  //             inactiveTrackColor: gray,
                  //             value: postVideoProvider.isComment,
                  //             onChanged: postVideoProvider.toggleComment,
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  /* Save Gallery ON/OFF */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(
                      minHeight: 45,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          multilanguage: true,
                          color: white,
                          text: "save_to_gallery",
                          fontsize: 15,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 15),
                        Consumer<PostVideoProvider>(
                          builder: (context, postVideoProvider, child) {
                            return Switch(
                              activeColor: colorPrimary,
                              activeTrackColor: white,
                              inactiveTrackColor: gray,
                              value: postVideoProvider.isSaveGallery,
                              onChanged: postVideoProvider.toggleGallery,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          /* Post Video Button */
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            alignment: Alignment.bottomCenter,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                validateAndUpload();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyImage(
                      width: 25,
                      height: 20,
                      imagePath: "ic_upload.png",
                      fit: BoxFit.cover,
                      color: black,
                    ),
                    const SizedBox(width: 8),
                    MyText(
                      multilanguage: true,
                      color: black,
                      text: "postvideo",
                      fontsize: 17,
                      fontwaight: FontWeight.w700,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 15),
                    Consumer<PostVideoProvider>(
                        builder: (context, postvideoprovider, child) {
                      if (postvideoprovider.uploadLoading) {
                        return SizedBox(
                          width: 25,
                          height: 25,
                          child: Utils.pageLoader(context),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserVideoDesc() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: white, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: MyNetworkImage(
                width: 55,
                height: 55,
                imagePath: userProfile ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 130,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                // decoration: Utils.r10BGWithBorder(),
                child: DetectableTextField(
                  detectionRegExp: detectionRegExp(
                          hashtag: true, atSign: false, url: false) ??
                      RegExp(""),
                  controller: mCommentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "title",
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      color: gray,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                    border: InputBorder.none,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                  ),
                  decoratedStyle: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: colorPrimary,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  basicStyle: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: white,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCovers() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: Consumer<PostVideoProvider>(
        builder: (context, postVideoProvider, child) {
          if (postVideoProvider.loading) {
            return Utils.pageLoader(context);
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick1");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail1 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick1"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick2");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail2 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick2"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick3");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail3 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick3"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCoverItem({required String thumbnail}) {
    debugPrint("thumbnail ---------------> $thumbnail");
    if (thumbnail != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(thumbnail),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: MyNetworkImage(
          fit: BoxFit.cover,
          imagePath: '',
        ),
      );
    }
  }

  Widget _buildTick() {
    return SizedBox(
      width: 25,
      height: 25,
      child: MyImage(
        imagePath: "true.png",
        fit: BoxFit.contain,
        height: 20,
        width: 20,
      ),
    );
  }

  validateAndUpload() async {
    String videoDesc = mCommentController.text.toString().trim();
    File? finalThumbnail;
    debugPrint("videoDesc ==> $videoDesc");
    if (videoDesc.isEmpty) {
      Utils.showSnackbar(context, "pleaseentervideotitle");
      return;
    }
    if (postVideoProvider.coverTick == "tick1") {
      finalThumbnail = File(postVideoProvider.thumbnail1 ?? "");
    } else if (postVideoProvider.coverTick == "tick2") {
      finalThumbnail = File(postVideoProvider.thumbnail2 ?? "");
    } else if (postVideoProvider.coverTick == "tick3") {
      finalThumbnail = File(postVideoProvider.thumbnail3 ?? "");
    }

    debugPrint("videoFile ==> ${finalVideoFile?.path}");
    if (postVideoProvider.isSaveGallery) {
      postVideoProvider.saveInGallery(finalVideoFile?.path ?? "");
    }
    debugPrint("finalThumbnail ===> ${finalThumbnail?.path ?? ""}");
    await postVideoProvider.uploadNewVideo(
      videoDesc,
      finalVideoFile,
      finalThumbnail,
    );
    if (!mounted) return;
    if (postVideoProvider.successModel.status == 200) {
      Utils.showSnackbar(context, "videouploadsuccsessfully");
    } else {
      Utils.showSnackbar(
        context,
        "videouploadfail",
      );
    }
    postVideoProvider.clearProvider();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const Bottombar(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
