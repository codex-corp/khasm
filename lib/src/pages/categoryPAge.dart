import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:food_delivery_app/src/packageModel.dart';
import 'package:food_delivery_app/src/packageResponse.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final FocusNode _sexN = FocusNode();
  String codeC ='966';
  final FocusNode _oneN = FocusNode();
  final FocusNode _twoN = FocusNode();
  final FocusNode _threeN = FocusNode();
  final FocusNode _fourN = FocusNode();
  final FocusNode _fiveN = FocusNode();
  final _numo = TextEditingController();
  final _numt = TextEditingController();
  final _numth = TextEditingController();
  final _numf = TextEditingController();
  final _numfi = TextEditingController();
  final _nums = TextEditingController();
  packageRes response;
  List<packageAllList> tListall;

  _categoryPage() : super(UserController()) {
    _con = controller;
  }
String userId;
  getValueString() async {
    SharedPreferences   preferences = await SharedPreferences.getInstance();
    userId=preferences.getString('userId');

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
        body: tListall==null?
        Center(
            child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.purple))):
       ListView(children: [Container(child:  Stack(
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
                 S.of(context).selectP,
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
                                     EdgeInsets.fromLTRB(10, 0, 10, 10),
                                     child: Container(
                                       child: ListView.builder(
                                           scrollDirection: Axis.horizontal,
                                           shrinkWrap: true,
                                           itemCount: tListall.length,
                                           itemBuilder:
                                               (BuildContext ctxt, int index) {
                                             return new Padding(
                                               padding: EdgeInsets.fromLTRB(
                                                   0, 0, 0, 10),
                                               child: Container(
                                                 decoration: BoxDecoration(
                                                     color: Colors.white,
                                                     borderRadius: BorderRadius.circular(40),
                                                     border: Border.all(color: Colors.grey,width: 1),
                                                     ),
                                                 margin: const EdgeInsets
                                                     .symmetric(
                                                     horizontal: 8.0),
                                                 child: Stack(
                                                   children: <Widget>[
                                                     //   Image.asset('assets/icons/10 usd.png'),
                                                     Column(
                                                       mainAxisAlignment: MainAxisAlignment.center,
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
                                                             tListall[index].price +  S.of(context).syp,
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
                                                             S.of(context).intervalcount+' :' + tListall[index].intervalcount,
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
                                                             S.of(context).trialperiodays+' : '+ tListall[index].trialperioddays ,
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
                                                           child: BlockButtonWidget(
                                                             text: Text(
                                                                 S.of(context).select,

                                                               style:
                                                               TextStyle(color: Theme.of(context).primaryColor),
                                                             ),
                                                             color:  Colors.red,
                                                             onPressed: () {

                                                               if( tListall[index].price.toString()=='0.00'){

                                                                 showDialog(
                                                                     context: context,
                                                                     builder:
                                                                         (BuildContext
                                                                     context) {
                                                                       return   Center(
                                                                           child: CircularProgressIndicator(
                                                                               valueColor: new AlwaysStoppedAnimation<Color>(
                                                                                   Colors.purple)));
                                                                     });

                                                                 _con.assignCat(userId,tListall[index].id,'000000');

                                                               }else{
                                                                 showDialog(
                                                                     context: context,
                                                                     builder:
                                                                         (BuildContext
                                                                     context) {
                                                                       return showDialogwindowDelete(
                                                                         tListall[index].id
                                                                       );
                                                                     });
                                                               }

                                                             /*  Navigator.of(context)
                                                                   .pushReplacementNamed('/Pages', arguments: 2);*/
                                                             },
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


                     SizedBox(height: 15),

//                      SizedBox(height: 10),
                   ],
                 ),
               ),
             ),
           ),
         ],
       ),height: MediaQuery.of(context).size.height,)],shrinkWrap: true,),
      ),
    );
  }


  Widget showDialogwindowDelete(String planId) {
    return AlertDialog(
      title: Column(children: [
        Text(S.of(context).enterC),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child:Directionality(
                textDirection: TextDirection.ltr,child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                     // width: 8,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                controller: _numo,
                                onChanged: (v){
                                  FocusScope.of(context).requestFocus(_twoN);

                                },

                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      //width: 38,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(

                                textAlign: TextAlign.center,
                                controller: _numt,
                                focusNode: _twoN,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                //  controller: _numo,
                                onChanged: (v){
                                  FocusScope.of(context).requestFocus(_threeN);

                                },
                                onSubmitted: (val) {},
                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      //width: 38,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(

                                textAlign: TextAlign.center,
                                controller: _numth,
                                focusNode: _threeN,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                //  controller: _numo,
                                onChanged: (v){
                                  FocusScope.of(context).requestFocus(_fourN);

                                },
                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5),
                child: Container(color: Colors.black,height: 1,width: 10,),),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      //width: 38,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(

                                textAlign: TextAlign.center,
                                controller: _numf,
                                focusNode: _fourN,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                //  controller: _numo,
                                onChanged: (v){
                                  FocusScope.of(context).requestFocus(_fiveN);

                                },
                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color:Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      //width: 38,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(

                                focusNode: _fiveN,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                //  controller: _numo,
                                onChanged: (v){
                                  FocusScope.of(context).requestFocus(_sexN);

                                },
                                textAlign: TextAlign.center,
                                controller: _numfi,
                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color:Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      //width: 38,
                        height: 50,
                        child: Center(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor:
                                  Colors.transparent,
                                  // accentColor: Colors.orange,
                                  hintColor: Colors.transparent),
                              child: TextField(

                                focusNode: _sexN,
                                textInputAction: TextInputAction.next,
                                //  autofocus: true,

                                //  controller: _numo,

                                textAlign: TextAlign.center,
                                controller: _nums,
                                maxLength: 1,
                                cursorColor: Colors.transparent,
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: 0.0),

                                  filled: true,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor),

                                  fillColor: Colors.transparent,
                                  //can also add icon to the end of the textfiled
                                  //  suffixIcon: Icon(Icons.remove_red_eye),
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            color:Colors.red
                                .withOpacity(1),
                            borderRadius:
                            BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                Colors.red,
                                width: 1))),
                  ),
                ),
              ],
            )),
          ),
        ),

      ],),

      actions: <Widget>[
        // usually buttons at the bottoReminiderItemDatem of the dialog


        GestureDetector(
          child: Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Center(
                child: Text(
                  S.of(context).yes,
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color:  Theme.of(context).hintColor.withOpacity(0.2)),
          ),
          onTap: () async {
            Navigator.pop(context, true);
            showDialog(
                context: context,
                builder:
                    (BuildContext
                context) {
                  return   Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.purple)));
                });
            String codes = _numo.text + _numt.text + _numth.text + _numf.text + _numfi.text + _nums.text ;
            print(codes);
            _con.assignCat(userId,planId,codes);

            //   _buildSubmitForm(context, adsId);
          },
        )
      ],
    );
  }

}
