import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/loginResponse.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:food_delivery_app/src/elements/ProfileSettingsDialog.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropdownMenuItems(_companies);
    _selectedCompany = _dropdownMenuItems[0].value;
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
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
        key: _con.scaffoldKey,
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
                  style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),

          Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  )
                ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                   Row(children: <Widget>[  DropdownButton(
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
                          _value =value;
                          if(value == 1){
                            codeC='963';
                          }else{
                            codeC='974';
                          }

                        });
                      }),
                     Container(padding: EdgeInsets.fromLTRB(3, 9, 3, 0),child: TextFormField(
                     keyboardType: TextInputType.phone,
                     onSaved: (input) => _con.user.phone = input,
                     controller: _email,
                     // validator: (input) => input.length=='10',
                     decoration: InputDecoration(
                       labelText: S.of(context).phone,
                       labelStyle: TextStyle(color: Theme.of(context).accentColor),
                       contentPadding: EdgeInsets.all(12),
                       hintText: '099-999-9999',
                       hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                       prefixIcon: Icon(Icons.phone, color: Theme.of(context).accentColor),
                       border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                     ),
                   ),width: MediaQuery.of(context).size.width/1.8,)],)   ,
                      SizedBox(height: 30),

                      BlockButtonWidget(
                        text: Text(
                          S.of(context).login,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if(codeC==null){
                           if(_value==1){
                             codeC='963';
                           }else{
                             codeC='974';
                           }
                          }
                          print(codeC);

                            _con.login(_email.text,toke,codeC,'1');



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
                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context).home),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
                      Navigator.of(context).pushReplacementNamed('/ForgetPassword');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_forgot_password),
                  ),
                  FlatButton(
                    onPressed: () {
                     // Navigator.of(context).pushReplacementNamed('/SignUp');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showDialogwindowDone();
                          });
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).readPrivacyPolice),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget showDialogwindowDone() {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/backalert.jpg'))),
              child: Form(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Text(
                          'Credential',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text('This application offers you all kinds of offers and discounts available anywhere in exchange for a simple monthly subscription',style: TextStyle(color: Colors.black),),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                      child: new RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();



                            //    _buildSubmitFormCo(context, wareId, offerId, dateD);
                          }
                          //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                          ,
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          color: Colors.lightGreen,
                          child: Center(
                            child: new Text(
                              'Ok',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );

  }
  _buildSubmitForm(BuildContext context) async {


    final CityRepository _repository = CityRepository();
    loginResponse res = await _repository.login(_email.text,toke);




  }

}
