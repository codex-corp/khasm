import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:quiver/async.dart';

class codePAge extends StatefulWidget {
  @override
  _codePAge createState() => _codePAge();
}

class _codePAge extends StateMVC<codePAge> {
  UserController _con;
  final CityRepository _repository = CityRepository();

  final _code = TextEditingController();

  _codePAge() : super(UserController()) {
    _con = controller;
  }

  int _start = 60;
  int _current = 60;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  void initState() {
    startTimer();

    super.initState();
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
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (input) => _con.user.code = input,
                        controller: _code,

                        //   validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).verification_code,
                          labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'xxx',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.code,
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
                      SizedBox(height: 30),

                      BlockButtonWidget(
                        text: Text(
                          S.of(context).confirmation,
                          style:
                          TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).primaryColorDark,
                        onPressed: () async {
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



                          var preferences = await SharedPreferences.getInstance();
                          String mobile = preferences.getString('phoneM');
                          String codec = preferences.getString('codeC');
                          FocusScope.of(context).unfocus();

                          _repository.verfyAccount(_code.text,mobile,codec).then((value) async {
                            //  print(value.result);
                            Navigator.pop(context);

                            print(currentUser.value.first_time);
                            if (value.result==true) {
                              if(currentUser.value.first_time==1){
                                Navigator.of(context).pushReplacementNamed('/edit');
                                SharedPreferences prefs = await SharedPreferences.getInstance();

                                prefs.setBool('checkk',true);
                              }
                              else{
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                bool isEnd= prefs.getBool('isEnded');
                                bool isAc= prefs.getBool('isActive');
                                prefs.setBool('checkk',true);

                                print(isAc.toString());
                                if(isAc == null){
                                  Navigator.of(context).pushReplacementNamed('/category');

                                }else{
                                  if(isAc == false) {
                                    Navigator.of(context).pushReplacementNamed(
                                        '/category');
                                  }else{
                                    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);


                                  }
                                }
                              }

                            }
                            else {
                              /* this?.currentState?.showSnackBar(SnackBar(
                                content: Text(value.msg),
                              ));*/
                              //    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);

                            }
                          }).catchError((e) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg:S.of(context).this_account_not_exist,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.deepOrangeAccent,
                            );
                            //loader.remove();
                            print(e.toString());
                            /* scaffoldKey?.currentState?.showSnackBar(SnackBar(
                              content: Text(S.of(context).this_account_not_exist),
                            ));*/
                          });



                          //      _con.verfy(_code.text);
                          //  Navigator.of(context).pushReplacementNamed('/package', arguments: 2);
                        },
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: Text(
                          "$_current",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      _current == 0
                          ? Center(
                        child: Visibility(
                          child: GestureDetector(
                            child: Text('resend',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColorDark)),
                            onTap: () async {
                              //  _con.login(_email.text,toke,codeC,'1');
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                              String phone = prefs.getString('phoneM');
                              String codeC = prefs.getString('codeC');
                              String toke = prefs.getString('tok');

                              _con.login(phone, toke, codeC, '1');
                            },
                          ),
                          visible: true,
                        ),
                      )
                          : Visibility(
                        visible: false,
                        child: Text('tr'),
                      )

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