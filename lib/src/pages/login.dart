import 'package:intl/date_symbol_data_local.dart';
import '../repository/user_repository.dart' as repository;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/loginResponse.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:food_delivery_app/src/elements/ProfileSettingsDialog.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class Company {
  int id;
  String name;

  Company(this.id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(963, 'Syria'),
      Company(974, 'Qatar'),
    ];
  }
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  UserController _con;
  DateFormat dateFormat ;
  GlobalKey<FormState> loginFormKey;

  List<Company> _companies = Company.getCompanies();
  List<DropdownMenuItem<Company>> _dropdownMenuItems;
  Company _selectedCompany;
  String toke;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _email = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  int _value = 1;
  String codeC;

  _LoginWidgetState() : super(UserController()) {
    _con = controller;
  }

  List<DropdownMenuItem<Company>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Company>> items = List();
    for (Company company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(Company selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
    });
  }

  String lang;

  Future<void> getVlue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('language');
    print(lang);
  }

  @override
  void initState() {
    getVlue();
    loginFormKey = new GlobalKey<FormState>();

    super.initState();
    _dropdownMenuItems = buildDropdownMenuItems(_companies);
    _selectedCompany = _dropdownMenuItems[0].value;
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

    /* if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }*/
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        toke = token;
      });
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
    //    key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
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
                  S.of(context).lets_start_with_login,
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
                      Row(
                        children: <Widget>[
                          DropdownButton(
                              value: _value,
                              items: [
                                DropdownMenuItem(
                                  child: Text("+963"),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text("+974"),
                                  value: 2,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _value = value;
                                  if (value == 1) {
                                    codeC = '963';
                                  } else {
                                    codeC = '974';
                                  }
                                });
                              }),
                          Container(
                            padding: EdgeInsets.fromLTRB(3, 9, 3, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              onSaved: (input) => _con.user.phone = input,
                              controller: _email,
                             maxLength: 8,
                              decoration: InputDecoration(
                                labelText: S.of(context).phone,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: '9-999-9999',
                                counterText: '8',
                                suffixText: '09',

                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.phone,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width / 1.8,
                          )
                        ],
                      ),
                      SizedBox(height: 30),

                      BlockButtonWidget(
                        text: Text(
                          S.of(context).login,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () async {
                          if (codeC == null) {
                            if (_value == 1) {
                              codeC = '963';
                            } else {
                              codeC = '974';
                            }
                          }
                          print(codeC);
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                         bool pp= prefs.getBool('pp');
                         if(pp==null){
                           String ph='9'+_email.text;
                           showDialog(
                               context: context,
                               barrierDismissible: false,

                               builder: (BuildContext context) {
                                 return
                                   WillPopScope(
                                       onWillPop: () async => false,
                                       child:

                                       dialog(_con,ph.toString(), toke, codeC,context));
                               });
                         }else{
                           if(pp == false){
                             String ph='9'+_email.text;

                             showDialog(
                                 context: context,
                                 barrierDismissible: false,

                                 builder: (BuildContext context) {
                                   return
                                     WillPopScope(
                                         onWillPop: () async => false,
                                         child:

                                         dialog(_con,ph.toString(), toke, codeC,context));
                                 });
                           }else{
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
                             String ph='9'+_email.text;


                             SharedPreferences prefs = await SharedPreferences.getInstance();
                             initializeDateFormatting();
                             dateFormat   = DateFormat("yyyy-MM-dd");
                             repository.login(ph.toString(), toke,codeC, '1').then((value) {
                               print(value);
                               prefs.setString('phoneM', ph.toString());
                               prefs.setString('codeC', codeC);
                               prefs.setString('tok', toke);
                               if (value.deviceToken!=null) {

                                 prefs.setString('phoneM', ph.toString());
                                 prefs.setString('codeC', codeC);
                                 prefs.setString('tok', toke);
                                 prefs.setString('userId', value.id);
                                 prefs.setBool('isTrail', value.isTrail);
                                 prefs.setBool('isEnded', value.isEnded);
                                 prefs.setBool('isActive', value.isActive);

                                 prefs.setString('token', value.apiToken);
                                 print(value.first_time.toString());
                                 Navigator.of(context).pushReplacementNamed('/code');

                                /* if(value.first_time==1){

                                   Navigator.of(context).pushReplacementNamed('/code');

                                 }else{
                                   Navigator.of(context).pushReplacementNamed('/code');
                                   //    Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/category');

                                 }*/


                                 //  Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
                               } else {

                               }
                             }).catchError((e) {
                               Navigator.pop(context);

                               //   loader.remove();

                               Fluttertoast.showToast(
                                 msg:S.of(context).this_account_not_exist,
                                 textColor: Colors.white,
                                 toastLength: Toast.LENGTH_SHORT,
                                 gravity: ToastGravity.BOTTOM,
                                 backgroundColor: Colors.deepOrangeAccent,
                               );

                             }).whenComplete(() {
                               Navigator.pop(context);
                               Navigator.of(context).pushReplacementNamed('/code');

                               //  Helper.hideLoader(loader);
                             });



                            // _con.login(ph.toString(), toke,codeC, '1');
                           }
                         }


                          // _con.login(_email.text,toke);
                          //  _buildSubmitForm(context);
                        },
                      ),
                      SizedBox(height: 15),

                      // FlatButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pushReplacementNamed('/SignUp');
                      //                           },
                      //   shape: StadiumBorder(),
                      //   textColor: Theme.of(context).hintColor,
                      //   child: Text(S.of(context).register),
                      //   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      // ),
                      // SizedBox(height: 15),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/Pages', arguments: 2);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context).home),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),

//                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed('/ForgetPassword');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_forgot_password),
                  ),
                /*  FlatButton(
                    onPressed: () {
                      // Navigator.of(context).pushReplacementNamed('/SignUp');
                      showDialog(
                          context: context,
                          barrierDismissible: false,

                          builder: (BuildContext context) {
                            return
                              WillPopScope(
                                onWillPop: () async => false,
                                child:

                              dialog(_con,_email.text, toke, codeC,));

                          });
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).readPrivacyPolice),
                  ),*/
                ],
              ),
            )
          ],
        ),
      ),
    );
  }



  _buildSubmitForm(BuildContext context) async {
    final CityRepository _repository = CityRepository();
    loginResponse res = await _repository.login(_email.text, toke);
  }
}
class dialog extends StatefulWidget {
  UserController _con;
  String email,token,code;
  BuildContext conn;
dialog(this._con,this.email,this.token,this.code,this.conn);
  @override
  _dialog createState() => _dialog();
}



class _dialog extends StateMVC<dialog> {
  bool _valueMobile = false;
  String lang;

  Future<void> getVlue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('language');
    print(lang);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return AlertDialog(
       contentPadding: EdgeInsets.zero,
       content: Container(
           height: MediaQuery.of(context).size.height,
           width: MediaQuery.of(context).size.width,
           child:

           Column(children: [

             Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                 child:    Container(
                   height: MediaQuery.of(context).size.height-250,
                   width: MediaQuery.of(context).size.width,
                   child: lang == 'en'
                       ? WebView(
                     initialUrl:
                     'https://khasmapp.com/privacy-policy.html',
                   )
                       : WebView(
                     initialUrl:
                     'https://khasmapp.com/privacy-policy-ar.html',
                   ),
                 )),
             Align(alignment: Alignment.bottomCenter,child:   Column(
               children: <Widget>[
                 Padding(
                     padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(S.of(context).agree,style: TextStyle(fontSize: 9),),
                         Checkbox(
                           value: _valueMobile,
                           onChanged: (value) {
                             setState(() {
                               _valueMobile = value;

                             });
                           },
                         ),

                       ],)
                 ),
                 Padding(
                   padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                   child: new RaisedButton(
                       onPressed: () async {
                       //  Navigator.pop(context);
                       if(_valueMobile==false){

                         Fluttertoast.showToast(
                           msg: S.of(context).aggre,
                           textColor: Colors.white,
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           backgroundColor: Colors.deepOrangeAccent,
                         );
                       }else{
                         SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('pp',_valueMobile);
                    //     Navigator.of(context).pop();


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


                         initializeDateFormatting();
                         repository.login(widget.email, widget.token, widget.code, '1').then((value) {
                           print(value);
                           prefs.setString('phoneM', widget.email);
                           prefs.setString('codeC', widget.code);
                           prefs.setString('tok', widget.token);
                           if (value.deviceToken!=null) {

                             prefs.setString('phoneM', widget.email);
                             prefs.setString('codeC', widget.code);
                             prefs.setString('tok', widget.token);
                             prefs.setString('userId', value.id);
                             prefs.setBool('isTrail', value.isTrail);
                             prefs.setBool('isEnded', value.isEnded);
                             prefs.setBool('isActive', value.isActive);

                             prefs.setString('token', value.apiToken);
                             print(value.first_time.toString());
                             Navigator.of(widget.conn).pushReplacementNamed('/code');

                             /* if(value.first_time==1){

                                   Navigator.of(context).pushReplacementNamed('/code');

                                 }else{
                                   Navigator.of(context).pushReplacementNamed('/code');
                                   //    Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/category');

                                 }*/


                             //  Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
                           } else {

                           }
                         }).catchError((e) {
                           Navigator.pop(context);

                           //   loader.remove();

                           Fluttertoast.showToast(
                             msg:S.of(context).this_account_not_exist,
                             textColor: Colors.white,
                             toastLength: Toast.LENGTH_SHORT,
                             gravity: ToastGravity.BOTTOM,
                             backgroundColor: Colors.deepOrangeAccent,
                           );

                         }).whenComplete(() {
                           Navigator.pop(context);
                           Navigator.of(widget.conn).pushReplacementNamed('/code');

                           //  Helper.hideLoader(loader);
                         });







                       }

                         //    _buildSubmitFormCo(context, wareId, offerId, dateD);
                       }
                       //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                       ,
                       padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                       color: Colors.lightGreen,
                       child: Center(
                         child: new Text(
                           S.of(context).yes,
                           style: TextStyle(
                               fontSize: 20,
                               color: Colors.white,
                               fontWeight: FontWeight.bold),
                           textAlign: TextAlign.center,
                         ),
                       )),
                 ),
               ],
             ),)

           ],)
       ));
  }
}