import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/settings_controller.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/cityRepositry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  int _value = 1;

  bool hidePassword = true;
  final CityRepository _repository = CityRepository();
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  var fromdate = GlobalKey<FormState>();
  DateFormat dateFormat ;
  bool loading = false;
  SettingsController _con;

  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login(String phone,String token,String codeC,String islog) async {
   // FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initializeDateFormatting();
    dateFormat   = DateFormat("yyyy-MM-dd");
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(phone,token,codeC,islog).then((value) {
        if (value.deviceToken!=null) {

          prefs.setString('phoneM', phone);
          prefs.setString('codeC', codeC);
          prefs.setString('tok', token);

          prefs.setString('token', value.apiToken);
           print(value.first_time.toString());
           if(value.first_time==1){

             Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code');

             /* ProfileSettingsDialog(
               user: currentUser.value,
               onChanged: () {
                 update(currentUser.value);
//                                  setState(() {});
               },
             );*/
           }else{
             Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code');

           }


          //  Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
        /*  scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(value.msg),
          ));*/
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
  void loginUpdatae(String phone,String token,String codeC,String islog) async {
    // FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initializeDateFormatting();
    repository.login(phone,token,codeC,islog).then((value) {
      if (value.deviceToken!=null) {

        prefs.setString('phoneM', phone);
        prefs.setString('codeC', codeC);
        prefs.setString('tok', token);

        prefs.setString('token', value.apiToken);
        print(value.first_time.toString());



        //  Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        /*  scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(value.msg),
          ));*/
      }
    }).catchError((e) {
     // loader.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).this_account_not_exist),
      ));
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }

  void verfy(String codev) async {
    var preferences = await SharedPreferences.getInstance();
   String mobile = preferences.getString('phoneM');
    String codec = preferences.getString('codeC');
    FocusScope.of(context).unfocus();

    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      _repository.verfyAccount(codev,mobile,codec).then((value) {
        if (value.result==true) {
          if(currentUser.value.first_time==1){
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/edit');
        }
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(value.msg),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader?.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).focusColor),
      ),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();
      //onChanged();
     // updateregister(currentUser.value);
      if (currentUser.value.deviceToken!=null) {
        Navigator.pop(context);

        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code');



        //  Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        /*  scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(value.msg),
          ));*/
      }
    }
  }
}
