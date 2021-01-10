import 'package:food_delivery_app/generated/l10n.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/serviceList.dart';
import 'package:food_delivery_app/src/repository/serviceRepository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class CuisionController extends ControllerMVC {
  ServiceList ServiceLists ;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool loadCart = false;

  CuisionController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForresturantByCuison({String id, String message}) async {
    final Stream<ServiceList> stream = await getResturantByCCuision(id);
    stream.listen((ServiceList _food) {
      setState(() {
        ServiceLists=_food;
      });
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }




}
