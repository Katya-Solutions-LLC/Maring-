import 'package:flutter/material.dart';
import 'package:maring/pages/bottombar.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  SharedPre sharedPre = SharedPre();
  Constant constant = Constant();
  PageController pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);
  int position = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: constant.introImage.length,
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyImage(
                            imagePath: constant.introImage[index],
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.55,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MyText(
                                    color: white,
                                    text: constant.introText[position],
                                    textalign: TextAlign.center,
                                    fontsize: 26,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 3,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    position = index;
                    currentPageNotifier.value = index;
                    debugPrint("position :==> $position");
                    setState(() {});
                  },
                ),
                Positioned.fill(
                  // bottom: 70,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      focusColor: colorAccent,
                      onTap: () async {
                        if (position == constant.introImage.length - 1) {
                          await sharedPre.save("seen", "1");
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Bottombar();
                              },
                            ),
                          );
                        }
                        pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      child: Stack(
                        children: [
                          MyImage(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.15,
                              imagePath: "ic_halfcir.png"),
                          Positioned.fill(
                            top: 10,
                            left: 10,
                            child: Align(
                              alignment: Alignment.center,
                              child: MyText(
                                  color: white,
                                  text: position ==
                                          Constant().introImage.length - 1
                                      ? "Finish"
                                      : "Next",
                                  textalign: TextAlign.center,
                                  fontsize: 20,
                                  multilanguage: true,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 50,
                  right: 20,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () async {
                        await sharedPre.save("seen", "1");
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const Bottombar();
                            },
                          ),
                        );
                      },
                      child: MyText(
                          color: white,
                          text: "skip",
                          textalign: TextAlign.center,
                          fontsize: 14,
                          inter: false,
                          multilanguage: true,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: constant.introImage.length,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 7,
                          dotColor: colorPrimaryDark,
                          expansionFactor: 3,
                          offset: 1,
                          dotHeight: 5,
                          activeDotColor: colorAccent,
                          radius: 100,
                          strokeWidth: 1,
                          spacing: 5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
