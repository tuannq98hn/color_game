import 'package:flutter/services.dart';
import 'package:game/bloc/bloc.dart';
import 'package:game/utils/utils.dart';
import 'package:game/view/game_mode.dart';
import 'package:game/widget/neu_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

const platform = const MethodChannel('com.taptap.color');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LanguageBloc _languageBloc;
  HighScoreBloc _highScoreBloc;
  bool _isInit = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  changeLanguage(String language) {
    if (_languageBloc.language != "us") {
      _languageBloc.add(ChangeLanguageEvent(language: "us"));
      setState(() {});
    } else if (_languageBloc.language != "vn") {
      _languageBloc.add(ChangeLanguageEvent(language: "vn"));
      setState(() {});
    }
  }

  Drawer _buildDrawer(context, width, height) {
    return new Drawer(
        child: new Container(
          height: height,
          color: AppColors.lightShadow,
          child: ListView(
            children: <Widget>[
              new Container(
                height: height / 50,
                color: AppColors.lightShadow,
              ),
              Container(
                color: AppColors.lightShadow,
                child: Center(
                    child: Container(
                      color: AppColors.lightShadow,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.asset(
                          "assets/logo.png",
                          width: width / 3,
                          height: width / 3,
                        ),
                      ),
                    )),
              ),
              new Container(
//              height: height,
                color: AppColors.lightShadow,
                child: new Column(
                  children: <Widget>[
//                new SizedBox(
//                  height: height / 50,
//                ),
//                new Container(
//                    width: width / 3.5,
//                    child: new ClipRRect(
//                      child: new Image.asset(
//                        'assets/logo.png',
//                        width: width / 3,
//                      ),
//                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                    )),
                    new SizedBox(
                      height: height / 100,
                    ),
                    new Container(
                      child: new Text(
                        "Tap Tap Color",
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Comfortaa'),
                      ),
                    ),
                    new Divider(
                      color: Colors.white,
                      indent: 0.0,
                    ),
//                    new GestureDetector(
//                      onTap: () {
////                        _showDialog(width, height);
//                      },
//                      child: new Container(
//                        color: AppColors.lightShadow,
//                        height: height / 12,
//                        child: new Row(
//                          children: <Widget>[
//                            new Container(
//                              width: width / 6,
//                              child: new Icon(
//                                Icons.settings,
//                                color: Colors.white,
//                              ),
//                            ),
//                            new Text(
//                              "Change Language",
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontSize: 20,
//                                  fontFamily: 'Comfortaa'),
//                            )
//                          ],
//                        ),
//                      ),
//                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () {
                          platform.invokeMethod('rate');
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Image.asset(
                                "assets/images/ic_rating.png",
                                width: width / 10,
                                height: width / 10,
                              ),
                            ),
                            Container(
                              child: Text(
                                "Rating",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Comfortaa'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () {
                          platform.invokeMethod('moreApp');
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Image.asset(
                                "assets/images/ic_more.png",
                                width: width / 10,
                                height: width / 10,
                              ),
                            ),
                            Container(
                              child: Text(
                                "More App",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Comfortaa'),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    _languageBloc = Provider.of<LanguageBloc>(context);
    _highScoreBloc = Provider.of<HighScoreBloc>(context);
    if (_isInit == false) {
      _languageBloc.add(OpenAppEvent());
      _highScoreBloc.add(OpenHighScoreEvent());
      _isInit = true;
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_main.png"),
            fit: BoxFit.cover,
          )
//          gradient: LinearGradient(
//            begin: Alignment.topLeft,
//            end: Alignment.bottomRight,
//            colors: [
//              AppColors.lightShadow,
//              AppColors.darkShadow,
//            ],
//          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: _header(context),
            ),
            Expanded(
              flex: 3,
              child: Image.asset(
                "assets/images/app_name.png",
                width: width/1.5,
                height: width*0.6727/1.5,
              ),
            ),
            Expanded(
              flex: 7,
              child: _body(),
            ),
          ],
        ),
      ),
    );
  }

  Row _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.menu, size: 30,color: Colors.white,),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        Container(),
//        Center(
//          child: Text(
//            'Color Game',
//            style: TextStyle(
//              fontWeight: FontWeight.w100,
//              fontFamily: 'Bungee Inline',
//              fontSize: 30,
//              color: AppColors.textColor,
//            ),
//            textAlign: TextAlign.center,
//          ),
//        ),
        Container()
      ],
    );
  }

  BlocBuilder<LanguageBloc, LanguageState> _body() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: _languageBloc,
      builder: (context, langState) {
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: _play(context, _languageBloc.language),
            ),
            Expanded(
              flex: 2,
              child: _highScore(context, _languageBloc.language),
            ),
          ],
        );
      },
    );
  }

  Widget _highScore(BuildContext context, String language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocBuilder<HighScoreBloc, HighScoreState>(
          bloc: Provider.of<HighScoreBloc>(context),
          builder: (context, state) {
            if (state is HighScoreValue) {
              return Text(
                'High score: ${state.score}',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'SGALS',
                  fontSize: MediaQuery.of(context).size.width / 10.5,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              );
            }
            return Container();
          },
        ),
        SizedBox(height: 20),
//        _languageChoose(),
      ],
    );
  }

  Center _play(BuildContext context, String language) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: GestureDetector(
        child: Image.asset(
          "assets/images/btn_start.png",
          width: width/1.5,
          height: width*0.2644/1.5,
        ),
        onTap: () {
          platform.invokeMethod('showInter');
          Navigator.push(context,
              PageTransition(type: PageTransitionType.fade, child: GameMode()));
        },
      ),
    );
  }

  BlocBuilder<LanguageBloc, LanguageState> _languageChoose() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: _languageBloc,
      builder: (context, state) {
        if (state is LanguageInApp) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeuButton(
                    isChoose: state.language == "vn" ? true : false,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height / 10,
                    ),
                    position: 7,
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.height / 10,
                    shadowLength: 4,
                    onTap: () {
                      if (_languageBloc.language != "vn") {
                        _languageBloc.add(ChangeLanguageEvent(language: "vn"));
                        setState(() {});
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  'assets/vn.png',
                                ))))),
                NeuButton(
                    isChoose: state.language == "us" ? true : false,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height / 10,
                    ),
                    position: 7,
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.height / 10,
                    shadowLength: 4,
                    onTap: () {
                      if (_languageBloc.language != "us") {
                        _languageBloc.add(ChangeLanguageEvent(language: "us"));
                        setState(() {});
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset('assets/us.png')))))
              ]);
        }
      },
    );
  }
}
