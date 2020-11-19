import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;

class packagePAge extends StatefulWidget {
  @override
  _packagePAge createState() => _packagePAge();
}

class _packagePAge extends StateMVC<packagePAge> {
  UserController _con;
  AnimationController animController;
  Animation<double> openOptions;
 // geo.Position res;
  bool _isChecked = true;
  String _currText = '';

  List<String> text = ["InduceSmile.com", "Flutter.io", "google.com"];
  _packagePAge() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
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
                  'Select Category',
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
                      ListView(
                        children: <Widget>[Stack(children: <Widget>[
                          Column(children: <Widget>[

                            Padding(padding:EdgeInsets.all(10),child:  Row(children: <Widget>[IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )],),),
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // Spacer(flex:1),
                               //   Center(child: title),
                                  Container(
                                 //   height: 350.0,
                                    child: Column(
                                      children: text
                                          .map((t) => CheckboxListTile(
                                        title: Text(t,style: TextStyle(fontWeight: FontWeight.bold),),
                                        value: _isChecked,
                                        onChanged: (val) {
                                          setState(() {
                                            _isChecked = val;
                                            if (val == true) {
                                              _currText = t;
                                            }
                                          });
                                        },
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                  //   registerForm,
                                  //  Spacer(flex:2),



                                ],
                              ),
                            )
                          ],),



                        ])],shrinkWrap: true,),
                      SizedBox(height: 30),

                      BlockButtonWidget(
                        text: Text(
                          'Done',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/category', arguments: 2);

                          // _con.login();
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
