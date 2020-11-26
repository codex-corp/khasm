import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:food_delivery_app/src/packageModel.dart';
import 'package:food_delivery_app/src/packageResponse.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;

class categoryPage extends StatefulWidget {
  @override
  _categoryPage createState() => _categoryPage();
}

class _categoryPage extends StateMVC<categoryPage> {
  UserController _con;
  List<String> imag = [
    'assets/5 usd.png',
    'assets/10 usd.png',
    'assets/10 usd.png'
  ];

  packageRes response;
  List<packageAllList> tListall;

  _categoryPage() : super(UserController()) {
    _con = controller;
  }

  getValueString() async {
    //  preferences = await SharedPreferences.getInstance();

    //  blocOffer.getOfferList(sessionId, data);

    final CityRepository _repository = CityRepository();

    response = await _repository.getPachage();
    if (response.msg == true) {
      setState(() {
        tListall = response.results.listpackage;
      });
    } else {}
  }

  @override
  void initState() {
    getValueString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:(){
        Navigator.pop(context);

      },
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: tListall==null?Center(
            child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.purple))):
        Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  'Select Package',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding:
                EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      color: Colors.white,
                                      icon: Icon(Icons.arrow_back),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    // Spacer(flex:1),

                                    // Center(child: title),
                                    Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(10, 60, 10, 10),
                                      child: Container(
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: tListall.length,
                                            itemBuilder:
                                                (BuildContext ctxt, int index) {
                                              return new Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 50, 0, 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              imag[index]),
                                                          fit: BoxFit.fill)),
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      //   Image.asset('assets/icons/10 usd.png'),
                                                      Column(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.fromLTRB(50, 15, 50, 5),
                                                            child: Text(
                                                              tListall[index].title,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                20,
                                                                10,
                                                                20,
                                                                10),
                                                            child: Text(
                                                              tListall[index].price + ' \$ ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                20,
                                                                10,
                                                                20,
                                                                10),
                                                            child: Text(
                                                            'Voucher limit :' + tListall[index].vouvherlimi,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                20,
                                                                10,
                                                                20,
                                                                10),
                                                            child: Text(
                                                             'Period : '+ tListall[index].avaperiod ,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                            ),
                                                          ),

                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                        height: 250,
                                      ),
                                    ),

                                    //   registerForm,
                                    //  Spacer(flex:2),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10),

                      BlockButtonWidget(
                        text: Text(
                          'Finish',
                          style:
                          TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Colors.green,
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/Pages', arguments: 2);
                        },
                      ),
                      SizedBox(height: 15),

//                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
