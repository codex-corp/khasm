import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import '../../main/utils/dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/T3Constant.dart';
import '../utils/T3Images.dart';
import '../utils/colors.dart';

class T3WalkThrough extends StatefulWidget {
  static var tag = "/T3WalkThrough";

  @override
  T3WalkThroughState createState() => T3WalkThroughState();
}

class T3WalkThroughState extends State<T3WalkThrough> {
  int currentIndexPage = 0;
  int pageLength;


  @override
  void initState() {
    super.initState();
    currentIndexPage = 0;
    pageLength = 3;
  }

  @override
  Widget build(BuildContext context) {

    var titles = [
      S.of(context).welcome_title_1,
      S.of(context).welcome_title_2,
      S.of(context).welcome_title_3,

    ];
    var subTitles = [
      S.of(context).welcome_msg_1,
      S.of(context).welcome_msg_2,
      S.of(context).welcome_msg_3,
    ];

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PageView(
              children: <Widget>[
                WalkThrough(
                  textContent: t3_ic_walk1,
                ),
                WalkThrough(
                  textContent: t3_ic_walk2,
                ),
                WalkThrough(
                  textContent: t3_ic_walk3,
                ),
              ],
              onPageChanged: (value) {
                setState(() => currentIndexPage = value);
              },
            ),
          ),
          Container(
            child: Positioned(
              width: MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height * 0.43,
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: new DotsIndicator(
                        dotsCount: 3,
                        position: currentIndexPage,
                        decorator: DotsDecorator(
                          color: t3_view_color,
                          activeColor: t3_colorPrimary,
                        )),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(titles[currentIndexPage],
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: fontMedium,
                                color: t3_colorPrimary)),
                        SizedBox(height: 16),
                        Center(
                            child: Text(
                          subTitles[currentIndexPage],
                          style: TextStyle(
                              fontFamily: fontRegular,
                              fontSize: 18,
                              color: t3_textColorSecondary),
                          textAlign: TextAlign.center,
                        )),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 100,
                      child: RaisedButton(
                        textColor: t3_white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(80.0),
                                topLeft: Radius.circular(80.0))),
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: <Color>[
                              t3_colorPrimary,
                              t3_colorPrimaryDark
                            ]),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(80.0),
                                topLeft: Radius.circular(80.0)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                S.of(context).skip,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/Login');
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkThrough extends StatelessWidget {
  final String textContent;

  WalkThrough({Key key, @required this.textContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topCenter,
      child: CachedNetworkImage(
        imageUrl: textContent,
        width: 280,
        height: (MediaQuery.of(context).size.height) / 2.3,
      ),
    );
  }
}
