import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:maring/provider/subscriptionprovider.dart';
import 'package:maring/subscription/payuhashservice.dart';
import 'package:maring/subscription/payuparams.dart';
import 'package:maring/utils/color.dart';
import 'package:maring/utils/constant.dart';
import 'package:maring/utils/dimens.dart';
import 'package:maring/utils/sharedpre.dart';
import 'package:maring/utils/utils.dart';
import 'package:maring/widget/myimage.dart';
import 'package:maring/widget/mytext.dart';
import 'package:maring/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:uuid/uuid.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final String? payType,
      itemId,
      price,
      itemTitle,
      typeId,
      videoType,
      productPackage,
      currency;
  const AllPayment({
    Key? key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.itemTitle,
    required this.typeId,
    required this.videoType,
    required this.productPackage,
    required this.currency,
  }) : super(key: key);

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment>
    implements PayUCheckoutProProtocol {
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late SubscriptionProvider subscriptionProvider;
  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  /* PayU */
  late PayUCheckoutProFlutter _payUCheckoutPro;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _getData();
    if (!kIsWeb) {
      /* PayU */
      _payUCheckoutPro = PayUCheckoutProFlutter(this);

      /* InApp Purchase */
      _kProductIds = <String>[widget.productPackage ?? ""];
      prDialog = ProgressDialog(context);
      _getData();
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
        debugPrint("onError ============> ${error.toString()}");
      });
      initStoreInfo();
    }
    super.initState();
  }

  _getData() async {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    await subscriptionProvider.getPaymentOption();
    await subscriptionProvider.setFinalAmount(widget.price ?? "");

    if (subscriptionProvider.paymentOptionModel.status == 200) {
      if (subscriptionProvider.paymentOptionModel.result != null) {
        if (subscriptionProvider.paymentOptionModel.result?.flutterwave !=
            null) {}
      }
    }

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    debugPrint('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userId ==> $userId');
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    if (!kIsWeb) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    couponController.dispose();
    super.dispose();
  }

  /* add_transaction API */
  Future addTransaction(
      packageId, description, amount, paymentId, currencyCode) async {
    // final videoDetailsProvider =
    //     Provider.of<VideoDetailsProvider>(context, listen: false);
    // final showDetailsProvider =
    //     Provider.of<ShowDetailsProvider>(context, listen: false);
    // final channelSectionProvider =
    //     Provider.of<ChannelSectionProvider>(context, listen: false);
    // final profileProvider =
    //     Provider.of<ProfileProvider>(context, listen: false);

    Utils.showProgress(context);
    await subscriptionProvider.addTransaction(packageId, amount, description);

    if (!subscriptionProvider.payLoading) {
      await prDialog.hide();

      if (subscriptionProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;

        // await profileProvider.getProfile(context);
        // await videoDetailsProvider.updatePrimiumPurchase();
        // await showDetailsProvider.updatePrimiumPurchase();
        // await channelSectionProvider.updatePrimiumPurchase();
        // await videoDetailsProvider.updateRentPurchase();
        // await showDetailsProvider.updateRentPurchase();

        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, subscriptionProvider.successModel.message ?? "");
      }
    }
  }

  /* add_rent_transaction API */
  Future addRentTransaction(videoId, amount, typeId, videoType) async {
    // final videoDetailsProvider =
    //     Provider.of<VideoDetailsProvider>(context, listen: false);
    // final showDetailsProvider =
    //     Provider.of<ShowDetailsProvider>(context, listen: false);

    Utils.showProgress(context);
    await subscriptionProvider.getRentTransaction(videoId, amount, "", "");

    if (!subscriptionProvider.payLoading) {
      await prDialog.hide();

      if (subscriptionProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, subscriptionProvider.successModel.message ?? "");
      }
    }
  }

  /* apply_coupon API */
  // Future applyCoupon() async {
  //   FocusManager.instance.primaryFocus?.unfocus();
  //   Utils.showProgress(context);
  //   if (widget.payType == "Package") {
  //     // /* Package Coupon */
  //     // await subscriptionProvider.applyPackageCouponCode(
  //     //     strCouponCode, widget.itemId);

  //     if (!subscriptionProvider.couponLoading) {
  //       await prDialog.hide();
  //       if (paymentProvider.couponModel.status == 200) {
  //         couponController.clear();
  //         await paymentProvider.setFinalAmount(
  //             paymentProvider.couponModel.result?.discountAmount.toString());
  //         strCouponCode =
  //             paymentProvider.couponModel.result?.uniqueId.toString();
  //         debugPrint("strCouponCode =============> $strCouponCode");
  //         debugPrint(
  //             "finalAmount =============> ${paymentProvider.finalAmount}");
  //         if (!mounted) return;
  //         Utils.showSnackbar(context, "success",
  //             paymentProvider.couponModel.message ?? "", false);
  //       } else {
  //         if (!mounted) return;
  //         Utils.showSnackbar(context, "fail",
  //             paymentProvider.couponModel.message ?? "", false);
  //       }
  //     }
  //   } else if (widget.payType == "Rent") {
  //     /* Rent Coupon */
  //     await paymentProvider.applyRentCouponCode(strCouponCode, widget.itemId,
  //         widget.typeId, widget.videoType, widget.price);

  //     if (!paymentProvider.couponLoading) {
  //       await prDialog.hide();
  //       if (paymentProvider.couponModel.status == 200) {
  //         couponController.clear();
  //         await paymentProvider.setFinalAmount(
  //             paymentProvider.couponModel.result?.discountAmount.toString());
  //         strCouponCode =
  //             paymentProvider.couponModel.result?.uniqueId.toString();
  //         debugPrint("strCouponCode =============> $strCouponCode");
  //         debugPrint(
  //             "finalAmount =============> ${paymentProvider.finalAmount}");
  //         if (!mounted) return;
  //         Utils.showSnackbar(context, "success",
  //             paymentProvider.couponModel.message ?? "", false);
  //       } else {
  //         if (!mounted) return;
  //         Utils.showSnackbar(context, "fail",
  //             paymentProvider.couponModel.message ?? "", false);
  //       }
  //     }
  //   } else {
  //     await prDialog.hide();
  //   }
  // }

  openPayment({required String pgName}) async {
    debugPrint(
        "finalAmount =============> ${subscriptionProvider.finalAmount}");
    if (subscriptionProvider.finalAmount != "0") {
      if (pgName == "paypal") {
        _paypalInit();
      } else if (pgName == "inapp") {
        _initInAppPurchase();
      } else if (pgName == "razorpay") {
        _initializeRazorpay();
      } else if (pgName == "flutterwave") {
        _flutterwaveInit();
      } else if (pgName == "payumoney") {
        _payUInit();
      } else if (pgName == "stripe") {
        _stripeInit();
      } else if (pgName == "cash") {
        if (!mounted) return;
        Utils.showSnackbar(context, "cash_payment_msg");
      }
    } else {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            subscriptionProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
    }
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed");
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed");
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed");
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed");
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "payment_methods", true),
      body: SafeArea(
        child: Center(
          child: _buildMobilePage(),
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width:
          ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
      margin: (kIsWeb || Constant.isTV)
          ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
          : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Coupon Code Box & Total Amount */
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              color: colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: Utils.setBackground(colorPrimary, 0),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.centerLeft,
                      child: Consumer<SubscriptionProvider>(
                        builder: (context, paymentProvider, child) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: "Amount : ",
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: colorAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${Constant.currencySymbol}${paymentProvider.finalAmount ?? ""}",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
              child: subscriptionProvider.payLoading
                  ? Container(
                      height: 230,
                      padding: const EdgeInsets.all(20),
                      child: Utils.pageLoader(context),
                    )
                  : subscriptionProvider.paymentOptionModel.status == 200
                      ? subscriptionProvider.paymentOptionModel.result != null
                          ? _buildPaymentPage()
                          : const NoData(
                              title: 'no_payment', subTitle: 'no_payment_desc')
                      : const NoData(
                          title: 'no_payment', subTitle: 'no_payment_desc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: white,
            text: "payment_methods",
            fontsize: Dimens.textTitle,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: white,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsize: Dimens.textMedium,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: white,
            text: "pay_with",
            multilanguage: true,
            fontsize: Dimens.textTitle,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* /* Payments */ */
          (!kIsWeb)
              ? (/* Platform.isIOS ? buildIOSPG() : */ _buildAndroidPG())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildIOSPG() {
    /* In-App purchase */
    return _buildIOSPGButton("In-App Purchase", 35, 110, onClick: () async {
      await subscriptionProvider.setCurrentPayment("inapp");
      _initInAppPurchase();
    });
  }

  Widget _buildIOSPGButton(String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsize: Dimens.textSmall,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                MyImage(
                  imagePath: "ic_right.png",
                  fit: BoxFit.contain,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidPG() {
    return Column(
      children: [
        /* In-App purchase */
        subscriptionProvider.paymentOptionModel.result?.inapppurchage != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.inapppurchage?.visibility ==
                    "1"
                ? _buildPGButton("pg_inapp.png", "InApp Purchase", 35, 110,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("inapp");
                    openPayment(pgName: "inapp");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paypal */
        subscriptionProvider.paymentOptionModel.result?.paypal != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.paypal?.visibility ==
                    "1"
                ? _buildPGButton("pg_paypal.png", "Paypal", 35, 130,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("paypal");
                    openPayment(pgName: "paypal");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Razorpay */
        subscriptionProvider.paymentOptionModel.result?.razorpay != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.razorpay?.visibility ==
                    "1"
                ? _buildPGButton("pg_razorpay.png", "Razorpay", 35, 130,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("razorpay");
                    openPayment(pgName: "razorpay");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paytm */
        subscriptionProvider.paymentOptionModel.result?.paytm != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.paytm?.visibility ==
                    "1"
                ? _buildPGButton("pg_paytm.png", "Paytm", 30, 90,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("paytm");
                    openPayment(pgName: "paytm");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Flutterwave */
        subscriptionProvider.paymentOptionModel.result?.flutterwave != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.flutterwave?.visibility ==
                    "1"
                ? _buildPGButton("pg_flutterwave.png", "Flutterwave", 35, 130,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("flutterwave");
                    openPayment(pgName: "flutterwave");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* PayUMoney */
        subscriptionProvider.paymentOptionModel.result?.payumoney != null
            ? subscriptionProvider
                        .paymentOptionModel.result?.payumoney?.visibility ==
                    "1"
                ? _buildPGButton("pg_payumoney.png", "PayU Money", 35, 130,
                    onClick: () async {
                    await subscriptionProvider.setCurrentPayment("payumoney");
                    openPayment(pgName: "payumoney");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildPGButton(
      String imageName, String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MyImage(
                  imagePath: imageName,
                  fit: BoxFit.contain,
                  height: imgHeight,
                  width: imgWidth,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsize: Dimens.textMedium,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.end,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 15),
                MyImage(
                  imagePath: "ic_right.png",
                  fit: BoxFit.fill,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {});
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  _initInAppPurchase() async {
    debugPrint(
        "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      Utils().showToast("Please check SKU");
      return;
    }
    debugPrint("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam =
          GooglePlayPurchaseParam(productDetails: response.productDetails[0]);
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint(
              "purchaseDetails ============> ${purchaseDetails.error.toString()}");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint("===> status ${purchaseDetails.status}");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          debugPrint(
              "===> pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint("===> productID ${purchaseDetails.productID}");
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            subscriptionProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
      setState(() {});
    } else {
      debugPrint("===> consumables else $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    debugPrint("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    if (subscriptionProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.isLive ??
                ""),
        isBothKeyReq: false,
        liveKey1:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                ""),
        liveKey2: "",
        testKey1:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */

      Razorpay razorpay = Razorpay();
      var options = {
        'key': (subscriptionProvider
                    .paymentOptionModel.result?.razorpay?.isLive ==
                "1")
            ? (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                "")
            : (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                ""),
        'currency': Constant.currency,
        'amount': (double.parse(subscriptionProvider.finalAmount ?? "") * 100),
        'name': widget.itemTitle ?? "",
        'description': widget.itemTitle ?? "",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

      try {
        razorpay.open(options);
      } catch (e) {
        debugPrint('Razorpay Error :=========> $e');
      }
    } else {
      Utils.showSnackbar(
        context,
        "payment_not_processed",
      );
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    Utils.showSnackbar(context, "payment_fail");
    await subscriptionProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    paymentId = response.paymentId.toString();
    debugPrint("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "payment_success");
    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          subscriptionProvider.finalAmount, paymentId, widget.currency);
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
          widget.typeId, widget.videoType);
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    debugPrint("============ External Wallet Selected ============");
  }
  /* ********* Razorpay END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (subscriptionProvider.paymentOptionModel.result?.paypal != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.isLive ??
                ""),
        isBothKeyReq: true,
        liveKey1:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key1 ??
                ""),
        liveKey2:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key2 ??
                ""),
        testKey1:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key1 ??
                ""),
        testKey2:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key2 ??
                ""),
      );
      if (!isContinue) return;
      /* Check Keys */

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              sandboxMode: (subscriptionProvider.paymentOptionModel.result?.paypal
                              ?.isLive ??
                          "") ==
                      "1"
                  ? false
                  : true,
              clientId: (subscriptionProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1")
                  ? (subscriptionProvider
                          .paymentOptionModel.result?.paypal?.key1 ??
                      "")
                  : (subscriptionProvider
                          .paymentOptionModel.result?.paypal?.key1 ??
                      ""),
              secretKey:
                  (subscriptionProvider
                              .paymentOptionModel.result?.paypal?.isLive ==
                          "1")
                      ? (subscriptionProvider
                              .paymentOptionModel.result?.paypal?.key2 ??
                          "")
                      : (subscriptionProvider
                              .paymentOptionModel.result?.paypal?.key2 ??
                          ""),
              returnURL: "return.example.com",
              cancelURL: "cancel.example.com",
              transactions: [
                {
                  "amount": {
                    "total": '${subscriptionProvider.finalAmount}',
                    "currency": Constant.currency,
                    "details": {
                      "subtotal": '${subscriptionProvider.finalAmount}',
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": widget.payType ?? "",
                  "item_list": {
                    "items": [
                      {
                        "name": "${widget.itemTitle}",
                        "quantity": 1,
                        "price": '${subscriptionProvider.finalAmount}',
                        "currency": Constant.currency
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (params) async {
                debugPrint("onSuccess: ${params["paymentId"]}");
                if (widget.payType == "Package") {
                  addTransaction(
                      widget.itemId,
                      widget.itemTitle,
                      subscriptionProvider.finalAmount,
                      params["paymentId"],
                      widget.currency);
                } else if (widget.payType == "Rent") {
                  addRentTransaction(
                      widget.itemId,
                      subscriptionProvider.finalAmount,
                      widget.typeId,
                      widget.videoType);
                }
              },
              onError: (params) {
                debugPrint("onError: ${params["message"]}");
                Utils.showSnackbar(context, params["message"].toString());
              },
              onCancel: (params) {
                debugPrint('cancelled: $params');
                Utils.showSnackbar(context, params.toString());
              }),
        ),
      );
    } else {
      Utils.showSnackbar(context, "payment_not_processed");
    }
  }
  /* ********* Paypal END ********* */

  /* ********* Stripe START ********* */
  Future<void> _stripeInit() async {
    if (subscriptionProvider.paymentOptionModel.result?.stripe != null) {
      stripe.Stripe.publishableKey = (subscriptionProvider
                  .paymentOptionModel.result?.stripe?.isLive ==
              "1")
          ? (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ?? "")
          : (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ??
              "");
      try {
        //STEP 1: Create Payment Intent
        paymentIntent = await createPaymentIntent(
            subscriptionProvider.finalAmount ?? "", Constant.currency);

        //STEP 2: Initialize Payment Sheet
        await stripe.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: Constant.appName,
            ))
            .then((value) {});

        //STEP 3: Display Payment sheet
        displayPaymentSheet();
      } catch (err) {
        throw Exception(err);
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed");
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'description': widget.itemTitle,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${(subscriptionProvider.paymentOptionModel.result?.stripe?.isLive == "1") ? (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ?? "") : (subscriptionProvider.paymentOptionModel.result?.stripe?.key2 ?? "")}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((value) {
        Utils.showSnackbar(context, "payment_success");
        if (widget.payType == "Package") {
          addTransaction(widget.itemId, widget.itemTitle,
              subscriptionProvider.finalAmount, paymentId, widget.currency);
        } else if (widget.payType == "Rent") {
          addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
              widget.typeId, widget.videoType);
        }

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on stripe.StripeException catch (e) {
      debugPrint('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('$e');
    }
  }
  /* ********* Stripe END ********* */

  /* ********* Flutterwave START ********* */
  _flutterwaveInit() async {
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive: (subscriptionProvider
              .paymentOptionModel.result?.flutterwave?.isLive ??
          ""),
      isBothKeyReq: false,
      liveKey1:
          (subscriptionProvider.paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      liveKey2: "",
      testKey1:
          (subscriptionProvider.paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      testKey2: "",
    );
    if (!isContinue) return;
    /* Check Keys */

    final Customer customer = Customer(
        email: userEmail ?? "",
        name: userName ?? "",
        phoneNumber: userMobileNo ?? '');

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: (subscriptionProvider
                  .paymentOptionModel.result?.flutterwave?.isLive ==
              "1")
          ? (subscriptionProvider
                  .paymentOptionModel.result?.flutterwave?.key1 ??
              "")
          : (subscriptionProvider
                  .paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      currency: Constant.currency,
      redirectUrl: 'https://www.divinetechs.com',
      txRef: const Uuid().v1(),
      amount: widget.price.toString().trim(),
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer, ussd",
      customization: Customization(title: widget.itemTitle),
      isTestMode:
          subscriptionProvider.paymentOptionModel.result?.flutterwave?.isLive !=
              "1",
    );
    ChargeResponse? response = await flutterwave.charge();
    debugPrint("Flutterwave response =====> ${response.toJson()}");
    if (response.status == "success" && response.success == true) {
      paymentId = response.transactionId.toString();
      debugPrint("paymentId ========> $paymentId");
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_success");

      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            subscriptionProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
    } else if (response.status == "cancel" && response.status == "cancelled") {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_cancel");
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_fail");
    }
  }
  /* ********* Flutterwave END ********* */

  /* ********* PayU START ********* */
  _payUInit() async {
    debugPrint(
        "_payUInit isLive ======> ${subscriptionProvider.paymentOptionModel.result?.payumoney?.isLive}");
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.isLive ??
              ""),
      isBothKeyReq: false,
      liveKey1:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.key3 ??
              ""),
      liveKey2:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ??
              ""),
      testKey1:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.key3 ??
              ""),
      testKey2:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ??
              ""),
    );
    if (!isContinue) return;
    /* Check Keys */

    Map<dynamic, dynamic> additionalParam = {
      PayUAdditionalParamKeys.udf1: "udf1",
      PayUAdditionalParamKeys.udf2: "udf2",
      PayUAdditionalParamKeys.udf3: "udf3",
      PayUAdditionalParamKeys.udf4: "udf4",
      PayUAdditionalParamKeys.udf5: "udf5",
    };

    Map<dynamic, dynamic> payUPaymentParams = {
      PayUPaymentParamKey.key: (subscriptionProvider
                  .paymentOptionModel.result?.payumoney?.isLive ==
              "1")
          ? (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ??
              "")
          : (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ??
              ""),
      PayUPaymentParamKey.transactionId: paymentId ?? "",
      PayUPaymentParamKey.amount: double.parse(widget.price ?? "0").toString(),
      PayUPaymentParamKey.productInfo: widget.itemTitle ?? "",
      PayUPaymentParamKey.firstName: userName ?? "",
      PayUPaymentParamKey.email: userEmail ?? "",
      PayUPaymentParamKey.phone: userMobileNo ?? "",
      PayUPaymentParamKey.ios_surl: "https://payu.herokuapp.com/ios_success",
      PayUPaymentParamKey.ios_furl: "https://payu.herokuapp.com/ios_failure",
      PayUPaymentParamKey.android_surl: "https://payu.herokuapp.com/success",
      PayUPaymentParamKey.android_furl: "https://payu.herokuapp.com/failure",
      PayUPaymentParamKey.environment:
          (subscriptionProvider.paymentOptionModel.result?.payumoney?.isLive ==
                  "1")
              ? "0"
              : "1", //0 => Production, 1 => Test
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.userCredential:
          ('${(subscriptionProvider.paymentOptionModel.result?.payumoney?.isLive == "1") ? (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ?? "") : (subscriptionProvider.paymentOptionModel.result?.payumoney?.key2 ?? "")}:${userEmail ?? ""}')
    };
    debugPrint("payUPaymentParams ======> ${payUPaymentParams.toString()}");

    try {
      _payUCheckoutPro.openCheckoutScreen(
        payUPaymentParams: payUPaymentParams,
        payUCheckoutProConfig: PayUParams.createPayUConfigParams(),
      );
    } on Exception catch (e) {
      debugPrint("_payUInit Exception ======> ${e.toString()}");
    }
  }

  @override
  generateHash(Map response) {
    // Pass response param to your backend server
    // Backend will generate the hash and will callback to
    Map<dynamic, dynamic> hashResponse = PayUHashService((subscriptionProvider
                    .paymentOptionModel.result?.payumoney?.isLive ==
                "1")
            ? (subscriptionProvider
                    .paymentOptionModel.result?.payumoney?.key3 ??
                "")
            : (subscriptionProvider
                    .paymentOptionModel.result?.payumoney?.key3 ??
                ""))
        .generateHash(response);
    debugPrint("hashResponse =====> $hashResponse");
    _payUCheckoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onError(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(
      context,
      "payment_fail",
    );
  }

  @override
  onPaymentCancel(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "payment_cancel");
  }

  @override
  onPaymentFailure(response) {
    Utils.showSnackbar(context, "payment_fail");
  }

  @override
  onPaymentSuccess(response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "payment_success");

    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          subscriptionProvider.finalAmount, paymentId, widget.currency);
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, subscriptionProvider.finalAmount,
          widget.typeId, widget.videoType);
    }
  }
  /* ********* PayU END ********* */

  Future<bool> onBackPressed() async {
    if (!mounted) return Future.value(false);
    Navigator.pop(context, isPaymentDone);
    return Future.value(isPaymentDone == true ? true : false);
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
