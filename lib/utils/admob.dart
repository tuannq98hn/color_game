import 'package:firebase_admob/firebase_admob.dart';

class Admob {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    // testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: false,
    childDirected: true,
    keywords: <String>['Game', 'Color', 'Puzzle Game'],
  );

  static const String appID = "ca-app-pub-7224518266029611~5643305504";

  static const String bannerID = "ca-app-pub-3940256099942544/6300978111";

  static const String middleID = "ca-app-pub-3940256099942544/1033173712";

  static const String continuationID = "ca-app-pub-3940256099942544/5224354917";


//  static const String appID = "ca-app-pub-6065970673322847~6065217533";
//
//  static const String bannerID = "ca-app-pub-6065970673322847/4752135860";
//
//  static const String middleID = "ca-app-pub-6065970673322847/2125972529";
//
//  static const String continuationID = "ca-app-pub-6065970673322847/3649687621";
}
