import 'dart:io';

import 'package:flutter/services.dart';
import 'package:game/bloc/bloc.dart';
import 'package:game/utils/utils.dart';
import 'package:game/view/game_screen/color_picker.dart';
import 'package:game/widget/neu_slider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const platform = const MethodChannel('com.taptap.color');

class NormalMode extends StatefulWidget {
  @override
  _NormalModeState createState() => _NormalModeState();
}

class _NormalModeState extends State<NormalMode>
    with SingleTickerProviderStateMixin {
  ColorPickerBloc _colorPickerBloc;
  HighScoreBloc _highScoreBloc;
  LanguageBloc _languageBloc;
  int level = 1;
  int adLevel = 0;
  int second = 4;
  int millisecond = 500;
  double height;
  double width;
  bool isInit = false;
  bool isGameOver = false;
  bool loading = false;
  AnimationController _animationController;
  RewardedVideoAd _rewardedVideoAd = RewardedVideoAd.instance;
  bool _hasConnect = false;
  int _videoAds = 0;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: Admob.middleID,
        targetingInfo: Admob.targetingInfo,
        listener: (MobileAdEvent event) {});
  }

  secondToWait(bool run) {
    if (isInit) {
      _animationController.duration =
          Duration(milliseconds: second * 1000 + millisecond);
    } else {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: second * 1000 + millisecond),
      );
      isInit = true;
    }

    if (run)
      _animationController.forward();
    else
      _animationController.value = 0;
  }

  double getPercent() =>
      ((second * 1000 + millisecond) -
          _animationController.value * (second * 1000 + millisecond)) /
      (second * 1000 + millisecond);

  List<Widget> gameOverButton() => [
        GestureDetector(
          child:
          Image.asset(
            "assets/images/btn_refresh.png",
            width: width/5,
            height: width/5,
          ),
          onTap: () {
            setState(() => _colorPickerBloc.add(ReplayEvent()));
          },
        ),
        GestureDetector(
            child:
            Image.asset(
              "assets/images/btn_close.png",
              width: width/5,
              height: width/5,
            ),
            onTap: () async {
//              try {
//                final result = await InternetAddress.lookup('google.com');
//                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//                  createInterstitialAd()
//                    ..load()
//                    ..show();
//                }
//              } on SocketException catch (_) {}
              platform.invokeMethod('showInter');
              Navigator.pop(context);
            }),
    GestureDetector(
      child:
      Image.asset(
        "assets/images/btn_share.png",
        width: width/5,
        height: width/5,
      ),
      onTap: () {

      },
    )
      ];

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    secondToWait(false);
    _animationController.addListener(() {
      if (_animationController.value == 1) {
        _animationController.value = 0;

        _colorPickerBloc.add(GameOverEvent(
          level > highScore ? true : false,
        ));
      }

      setState(() {});
    });
    if (!kIsWeb) {
      FirebaseAdMob.instance.initialize(appId: Admob.appID);
      _rewardedVideoAd.listener =
          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
        if (event == RewardedVideoAdEvent.rewarded) {
          _colorPickerBloc.add(ContinueEvent());
          setState(() => _videoAds++);
        }
        if (event == RewardedVideoAdEvent.loaded) {
          _rewardedVideoAd.show();
        }
        if (event == RewardedVideoAdEvent.failedToLoad) {}
      };
      _hasConnectSet();
    }
  }

  _hasConnectSet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _hasConnect = true;
      }
    } on SocketException catch (_) {
      _hasConnect = false;
    }
    setState(() {});
  }

  int numOfColorPerLevel(int level) {
    if (level < 10) {
      return 2;
    } else if (level < 20) {
      return 3;
    } else if (level < 30) {
      return 4;
    } else if (level < 100) {
      return 5;
    } else {
      return 6;
    }
  }

  durationChange(bool run) {
    if (level == 10) {
      second = 3;
      millisecond = 700;
      secondToWait(run);
    } else if (level == 20) {
      second = 3;
      millisecond = 200;
      secondToWait(run);
    } else if (level == 30) {
      second = 3;
      millisecond = 0;
      secondToWait(run);
    } else if (level == 100) {
      second = 2;
      millisecond = 500;
      secondToWait(run);
    }
  }

  durationContinuesChange() {
    if (level <= 10) {
      second = 4;
      millisecond = 500;
      secondToWait(false);
    } else if (level >= 10 && level <= 30) {
      second = 3;
      millisecond = 700;
      secondToWait(false);
    } else if (level >= 30 && level <= 100) {
      second = 3;
      millisecond = 0;
      secondToWait(false);
    } else if (level > 100) {
      second = 2;
      millisecond = 500;
      secondToWait(false);
    }
  }

  Future<bool> _onWillPop() async {
    if (kIsWeb) return true;
//    try {
//      final result = await InternetAddress.lookup('google.com');
//      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//        createInterstitialAd()
//          ..load()
//          ..show();
//      }
//    } on SocketException catch (_) {}
    platform.invokeMethod('showInter');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _colorPickerBloc = BlocProvider.of<ColorPickerBloc>(context);
    _highScoreBloc = BlocProvider.of<HighScoreBloc>(context);
    _languageBloc = BlocProvider.of<LanguageBloc>(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg_main.png"),
                      fit: BoxFit.cover,
                    )
//                    gradient: LinearGradient(
//                        begin: Alignment.topLeft,
//                        end: Alignment.bottomRight,
//                        colors: [AppColors.lightShadow, AppColors.darkShadow])
                ),
                child: SafeArea(
                  child: Stack(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          Container(
                            width: width,
                            child: Center(
                              child: Text(
                                  'Level: $level',
                                  style: TextStyle(
                                      fontFamily: 'Bungee',
                                      fontSize: height / 20,
                                      color: AppColors.textColor)
                              ),
                            ),
                          ),
                          Text(
                              'Time:',
                              style: TextStyle(
                                  fontFamily: 'Bungee',
                                  fontSize: height / 20,
                                  color: AppColors.textColor)),
                          SizedBox(height: 15),
                          AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: NeuSlider(
                                      height: height / 35,
                                      percent: getPercent(),
                                      width: height / 2 + 10,
                                      borderRadius:
                                          BorderRadius.circular(width / 5)))),
                          SizedBox(height: 15),
                        ]),
                        Container(
                          margin: EdgeInsets.only(top: isGameOver ? 0 : height/3),
                          child: BlocConsumer(
                            bloc: _colorPickerBloc,
                            listener: (context, state) async {
                              if (state is ColorPickerDone) {
                                _animationController.value = 0;
                                if (_animationController.isDismissed)
                                  _animationController.forward();
                                durationChange(true);
                                setState(() => level++);
                              }
                              if (state is ColorPickerContinue) {
                                durationChange(false);
                                setState(() {});
                              }
                              if (state is ColorPickerWaitting ||
                                  state is ColorPickerInitial ||
                                  state is ColorPickerDone ||
                                  state is ColorPickerContinue) {
                                setState(() {
                                  isGameOver = false;
                                });
                              }
                              if (state is ColorPickerContinue) {
                                second = 4;
                                millisecond = 500;
                                durationContinuesChange();
                              }
                              if (state is ColorPickerInitial) {
                                second = 4;
                                millisecond = 500;
                                level = 1;
                                _videoAds = 0;
                                durationChange(false);
                              }
                              if (state is ColorPickerGameOver) {
                                setState(() {
                                  isGameOver = true;
                                });
                                secondToWait(false);
                                if (state.isNewHighScore)
                                  _highScoreBloc.add(SetHighScoreEvent(level));
                                if (level > 10 && adLevel % 2 == 1 && !kIsWeb) {
//                                  try {
//                                    final result = await InternetAddress.lookup(
//                                        'google.com');
//                                    if (result.isNotEmpty &&
//                                        result[0].rawAddress.isNotEmpty) {
//                                      createInterstitialAd()
//                                        ..load()
//                                        ..show();
//                                    }
//                                  } on SocketException catch (_) {}
                                }
                                adLevel++;
                              }
                              print(second + millisecond / 1000);
                            },
                            builder: (BuildContext context, state) {
                              if (state is ColorPickerWaitting ||
                                  state is ColorPickerInitial ||
                                  state is ColorPickerDone ||
                                  state is ColorPickerContinue) {
                                return SizedBox(
                                  height: width,
                                  width: width,
                                  child: ColorPicker(
                                    level: level,
                                    numOfColor: numOfColorPerLevel(level),
                                  ),
                                );
                              }
                              if (state is ColorPickerGameOver) {
                                if (state.isNewHighScore) {
                                  return _buildGameOverNoti(context, true);
                                }
                              }
                              return _buildGameOverNoti(context, false);
                            }),
                        ),
                        Positioned(
                          child: loading
                              ?  Container(
                              height: height / 10,
                              child: new Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.pinkAccent),
                                ),
                              ))
                              : Container(),
                        )
                      ]),
                ))));
  }

  Widget _buildGameOverNoti(BuildContext context, bool isNewHighScore) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg_gameover.png"),
              fit: BoxFit.cover,
            )
        ),
        child: GestureDetector(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(height: 15),
                        Text(
                          "Game Over",
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            color: AppColors.textColor,
                            fontSize: width / 10,
                          ),
                        ),
                        Text(
                          'Level: $level',
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            color: AppColors.textColor,
                            fontSize: width / 10,
                          ),
                        ),
                        Container(height: 15),
                        isNewHighScore
                            ? Column(children: [
                                Text(
                                      "Congratulation.",
                                  style: TextStyle(
                                    fontFamily: 'Bungee Inline',
                                    color: Colors.yellow[200],
                                    fontSize: width / 25,
                                  ),
                                ),
                                Text(
                                  "Level $level is your new high score!",
                                  style: TextStyle(
                                    fontFamily: 'Bungee Inline',
                                    color: Colors.yellow[200],
                                    fontSize: width / 25,
                                  ),
                                )
                              ])
                            : Container(height: 0)
                      ]),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: (_hasConnect && _videoAds < 2)
                        ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                              (index) {
                            if (index == 3)
                              return GestureDetector(
                                  child: Image.asset(
                                    "assets/images/btn_ads.png",
                                    width: width/5,
                                    height: width/5,
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    platform.invokeMethod('getRewardedID').then((value) async {
                                      String rewardedID = value;
                                      try {
                                        await _rewardedVideoAd.load(
                                          adUnitId: rewardedID,
                                          targetingInfo: Admob.targetingInfo,
                                        );
                                        setState(() {
                                          loading = false;
                                        });
                                      } catch (PlatformException) {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    });
                                  });
                            List<Widget> _button = gameOverButton();
                            return _button[index];
                          },
                        ))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: gameOverButton(),
                    ),
                  )
                ])));
  }
}
