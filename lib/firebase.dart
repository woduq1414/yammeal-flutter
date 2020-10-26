
import 'dart:io' show Platform;
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

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: interstitialID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  showInterstitialAd() {
    _interstitialAd..load()..show();
  }
}