import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      /* if (progress == 100) {
        try {
          Navigator.of(context).pushReplacementNamed('/Login', arguments: 2);
        } catch (e) {}
      }*/
      if (progress == 100) {
        try {
          print(currentUser.value.apiToken);
          //  userRepo.currentUser.value.apiToken != null
          if (currentUser.value.apiToken != null) {
            // Navigator.of(context).pushReplacementNamed('/Login');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool isEnd = prefs.getBool('isEnded');
            bool isAc = prefs.getBool('isActive');
            bool check = prefs.getBool('checkk');
            if (check == null) {
              Navigator.of(context).pushReplacementNamed('/Login');

            } else {
              if (check == true) {
                if (isEnd == null && isAc == null) {
                  Navigator.of(context).pushReplacementNamed('/Login');
                  //  Navigator.of(context).pushReplacementNamed('/category');

                } else if (isAc == false) {
                  Navigator.of(context).pushReplacementNamed('/category');
                } else if (isAc == true && isEnd == false) {
                  Navigator.of(context)
                      .pushReplacementNamed('/Pages', arguments: 2);
                } else if (isAc == true && isEnd == true) {
                  Navigator.of(context)
                      .pushReplacementNamed('/Pages', arguments: 2);
                }
              } else {
                Navigator.of(context).pushReplacementNamed('/Login');

              }
            }
            print(isEnd.toString());

            //  Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          } else {
            Navigator.of(context).pushReplacementNamed('/Welcome');
          }
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logg.png',
                width: 193,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
