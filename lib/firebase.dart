
import 'dart:io' show Platform;

import 'package:ads/ads.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

class AdMobManager {
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  String appID = Platform.isIOS
      ? 'ca-app-pub-3940256099942544~1458002511' // iOS Test App ID
      : 'ca-app-pub-2755450101712612~8101773189'; // Android Test App ID

  bool isDebug = false;


  String bannerID = "ca-app-pub-2755450101712612/4676699347";
  String interstitialID = "ca-app-pub-2755450101712612/8297391916";


  AdMobManager(){
    if(isDebug == true){
      bannerID = BannerAd.testAdUnitId;
      interstitialID = InterstitialAd.testAdUnitId;
      appID = FirebaseAdMob.testAppId;
    }
  }

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  init() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd = createBannerAd();
    _interstitialAd = createInterstitialAd();
    _bannerAd..load()..show();
  }

  dispose() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd.dispose();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: interstitialID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
      },
    );
  }

  showInterstitialAd() {
    _interstitialAd..load()..show();
  }
}

// class AdManager {
//   AdManager(){
//     var eventListener = (MobileAdEvent event) {
//     };
//     String appID = Platform.isIOS
//         ? 'ca-app-pub-3940256099942544~1458002511' // iOS Test App ID
//         : 'ca-app-pub-2755450101712612~8101773189'; // Android Test App ID
//
//     bool isDebug = false;
//
//
//     String bannerID = "ca-app-pub-2755450101712612/4676699347";
//     String interstitialID = "ca-app-pub-2755450101712612/8297391916";
//
//
//     if(isDebug == true){
//       bannerID = BannerAd.testAdUnitId;
//       interstitialID = InterstitialAd.testAdUnitId;
//       appID = FirebaseAdMob.testAppId;
//     }
//
//     Ads.init(
//       appID,
//       bannerUnitId: Platform.isAndroid
//           ? bannerID
//           : 'ca-app-pub-3940256099942544/2934735716',
//       screenUnitId: Platform.isAndroid
//           ? interstitialID
//           : 'ca-app-pub-3940256099942544/4411468910',
//       videoUnitId: Platform.isAndroid
//           ? 'ca-app-pub-3940256099942544/5224354917'
//           : 'ca-app-pub-3940256099942544/1712485313',
//       keywords: <String>['students', 'foods'],
//       contentUrl: 'http://www.ibm.com',
//       childDirected: false,
//       // testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
//       testing: false,
//       listener: eventListener,
//     );
//
//   }
//
//   static showBanner(){
//     Ads.showBannerAd();
//   }
//
//   static hideBanner(){
//     Ads.hideBannerAd();
//   }
// }


class AdManager {
  static Ads _ads;

  static String _appId =  Platform.isIOS
      ? 'ca-app-pub-3940256099942544~1458002511' // iOS Test App ID
      : 'ca-app-pub-2755450101712612~8101773189';

  bool isDebug = false;


  static String _bannerUnitId ="ca-app-pub-2755450101712612/4676699347";
  static String _interstitialUnitId = "ca-app-pub-2755450101712612/8297391916";

  AdManager(){
    if(isDebug == true){
      _bannerUnitId = BannerAd.testAdUnitId;
      _interstitialUnitId = InterstitialAd.testAdUnitId;
      _appId = FirebaseAdMob.testAppId;
    }
  }






  /// Assign a listener.
  static MobileAdListener _eventListener = (MobileAdEvent event) {
    if (event == MobileAdEvent.clicked) {
      print("_eventListener: The opened ad is clicked on.");
    }
  };

  static void showBanner(
      {String adUnitId,
        AdSize size,
        List<String> keywords,
        String contentUrl,
        bool childDirected,
        List<String> testDevices,
        bool testing,
        MobileAdListener listener,
        State state,
        double anchorOffset,
        AnchorType anchorType}) =>
      _ads?.showBannerAd(
          adUnitId: adUnitId,
          size: size,
          keywords: keywords,
          contentUrl: contentUrl,
          childDirected: childDirected,
          testDevices: testDevices,
          testing: testing,
          listener: listener,
          state: state,
          anchorOffset: anchorOffset,
          anchorType: anchorType);

  static void hideBanner() => _ads?.closeBannerAd();

  /// Call this static function in your State object's initState() function.
  static void init() => _ads ??= Ads(
    _appId,
    bannerUnitId: _bannerUnitId,
    keywords: <String>['ibm', 'computers'],
    contentUrl: 'http://www.ibm.com',
    childDirected: false,
    testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
    testing: false,
    listener: _eventListener,
  );

  /// Remember to call this in the State object's dispose() function.
  static void dispose() => _ads?.dispose();
}