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

class SpeedMode extends StatefulWidget {
  @override
  _SpeedModeState createState() => _SpeedModeState();
}

class _SpeedModeState extends State<SpeedMode>
    with SingleTickerProviderStateMixin {
  ColorPickerBloc _colorPickerBloc;
  LanguageBloc _languageBloc;
  HighScoreBloc _highScoreBloc;

  int level = 1;
  int adLevel = 0;
  int second = 60;
  double height;
  double width;
  bool isInit = false;
  bool isGameOver = false;
  AnimationController _animationController;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: Admob.middleID,
        targetingInfo: Admob.targetingInfo,
        listener: (MobileAdEvent event) {});
  }

  List<Widget> gameOverButton() {
    return [
      GestureDetector(
        child: Image.asset(
          "assets/images/btn_refresh.png",
          width: width/5,
          height: width/5,
        ),
        onTap: () {
          setState(() {
            level = 1;
            _colorPickerBloc.add(ReplayEvent());
          });
        },
      ),
      GestureDetector(
        child: Image.asset(
          "assets/images/btn_close.png",
          width: width/5,
          height: width/5,
        ),
        onTap: () async {
//          try {
//            final result = await InternetAddress.lookup('google.com');
//            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//              createInterstitialAd()
//                ..load()
//                ..show();
//            }
//          } on SocketException catch (_) {}
          platform.invokeMethod('showInter');
          Navigator.pop(context);
        },
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: second * 1000),
    );
    _animationController.addListener(() {
      if (_animationController.value == 1) {
        _animationController.value = 0;

        _colorPickerBloc.add(GameOverEvent(
          level > highScore ? true : false,
        ));
      }

      setState(() {});
    });

    _animationController.forward();
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

  String _getAmountTime() {
    String res = (second * (1 - _animationController.value)).toStringAsFixed(3);
    return res;
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.lightShadow,
                AppColors.darkShadow,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Level: $level',
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: height / 20,
                        color: AppColors.textColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Time: ',
                              ),
                              TextSpan(text: _getAmountTime()),
                            ],
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: height / 20,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: NeuSlider(
                          height: height / 35,
                          percent: (60000 * (1 - _animationController.value)) /
                              60000,
                          width: height / 2 + 10,
                          borderRadius: BorderRadius.circular(
                            width / 5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: isGameOver ? 0 : height/3),
                  child: BlocConsumer(
                    bloc: _colorPickerBloc,
                    listener: (context, state) async {
                      if (state is ColorPickerDone) {
                        if (level == 1) _animationController.forward();
                        setState(() => level++);
                      }

                      if (state is ColorPickerContinue) setState(() {});
                      if (state is ColorPickerWaitting ||
                          state is ColorPickerInitial ||
                          state is ColorPickerDone ||
                          state is ColorPickerContinue) {
                          setState(() {
                            isGameOver = false;
                          });
                      }

                      if (state is ColorPickerGameOver) {
                        setState(() {
                          isGameOver = true;
                        });
                        if (state.isNewHighScore)
                          _highScoreBloc.add(SetHighScoreEvent(level));
                        _animationController.value = 0;
                        if (level > 10 && adLevel % 2 == 1 && !kIsWeb) {
//                          try {
//                            final result =
//                            await InternetAddress.lookup('google.com');
//                            if (result.isNotEmpty &&
//                                result[0].rawAddress.isNotEmpty) {
//                              createInterstitialAd()
//                                ..load()
//                                ..show();
//                            }
//                          } on SocketException catch (_) {}
                        }
                        adLevel++;
                      }
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverNoti(BuildContext context, bool isNewHighScore) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg_gameover.png"),
          fit: BoxFit.cover,
        )
      ),
//      margin: EdgeInsets.only(top: height/3),
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
                  fontSize: width / 8,
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
                    fontFamily: 'Bungee',
                    color: Color(0xFFFCEE21),
                    fontSize: width / 20,
                  ),
                ),
                Text(
                  "Level $level is your new high score!",
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    color: Color(0xFFFCEE21),
                    fontSize: width / 20,
                  ),
                )
              ])
                  : Container(height: 0)
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: gameOverButton(),
            ),
          ),
        ],
      ),
    );
  }
}
