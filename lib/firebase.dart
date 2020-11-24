
import 'dart:io' show Platform;

import 'package:ads/ads.dart';
import 'package:firebase_admob/firebase_admob.dart';

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

class AdManager {
  AdManager(){
    var eventListener = (MobileAdEvent event) {
    };
    String appID = Platform.isIOS
        ? 'ca-app-pub-3940256099942544~1458002511' // iOS Test App ID
        : 'ca-app-pub-2755450101712612~8101773189'; // Android Test App ID

    bool isDebug = true;


    String bannerID = "ca-app-pub-2755450101712612/4676699347";
    String interstitialID = "ca-app-pub-2755450101712612/8297391916";


    if(isDebug == true){
      bannerID = BannerAd.testAdUnitId;
      interstitialID = InterstitialAd.testAdUnitId;
      appID = FirebaseAdMob.testAppId;
    }

    Ads.init(
      appID,
      bannerUnitId: Platform.isAndroid
          ? bannerID
          : 'ca-app-pub-3940256099942544/2934735716',
      screenUnitId: Platform.isAndroid
          ? interstitialID
          : 'ca-app-pub-3940256099942544/4411468910',
      videoUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313',
      keywords: <String>['students', 'foods'],
      contentUrl: 'http://www.ibm.com',
      childDirected: false,
      // testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
      testing: false,
      listener: eventListener,
    );

  }

  static showBanner(){
    // Ads.showBannerAd();
  }

  static hideBanner(){
    Ads.hideBannerAd();
  }
}