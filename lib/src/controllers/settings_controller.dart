import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class SettingsController extends ControllerMVC {
  CreditCard creditCard = new CreditCard();
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  UserController _con;

  SettingsController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _con=new UserController();

  }

  void update(User user,String isProfile) async {
    user.deviceToken = null;
    repository.update(user).then((value) async {
      setState(() {});
      if(isProfile=='2'){

      }else {
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/category');

     //   Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code');
      }


      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).profile_settings_updated_successfully),
      ));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String mobile = prefs.getString('phoneM');
      String code=   prefs.getString('codeC');
      String tok=   prefs.getString('tok');

      _con.loginUpdatae(mobile,tok,code,'2');
    });

  }

  void updateCreditCard(CreditCard creditCard) {
    repository.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_settings_updated_successfully),
      ));
    });
  }

  void listenForUser() async {
    creditCard = await repository.getCreditCard();
    setState(() {});
  }

  Future<void> refreshSettings() async {
    creditCard = new CreditCard();
  }
}
