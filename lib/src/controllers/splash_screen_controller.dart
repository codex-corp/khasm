import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/uikit/theme3/utils/T3Images.dart';
import 'package:get/get.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    configureFirebase(firebaseMessaging);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null &&
          settingRepo.setting.value.appName != '' &&
          settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 41;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        progress?.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress?.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  void configureFirebase(FirebaseMessaging _firebaseMessaging) {
    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showOverlayNotification((context) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: SafeArea(
                    child: ListTile(
                      leading: SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: CircleAvatar(
                              backgroundImage:
                              CachedNetworkImageProvider(message['data']['image']),
                              radius: 16)),
                      title: Text(message['data']['title']),
                      subtitle: Text(message['data']['body']),
                      trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context).dismiss();
                          }),
                    ),
                  ),
                ),
                decoration: new BoxDecoration(
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black,
                      blurRadius: 20.0,
                    ),
                  ],
                ),
              ),
            );
          },duration: Duration(milliseconds: 50000), position: NotificationPosition.top);

        },
        onLaunch: notificationOnLaunch,
        onResume: notificationOnResume,
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState
            .pushReplacementNamed('/Pages', arguments: 3);
      } else if (message['data']['id'] == "messages") {
        settingRepo.navigatorKey.currentState
            .pushReplacementNamed('/Pages', arguments: 4);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        await settingRepo.saveMessageId(message['google.message_id']);
        if (message['data']['id'] == "orders") {
          settingRepo.navigatorKey.currentState
              .pushReplacementNamed('/Pages', arguments: 3);
        } else if (message['data']['id'] == "messages") {
          settingRepo.navigatorKey.currentState
              .pushReplacementNamed('/Pages', arguments: 4);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    // Fluttertoast.showToast(
    //   msg: message['notification']['title'],
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.TOP,
    //   timeInSecForIosWeb: 6,
    // );
  }

  Future notificationBackgroundMessage(Map<String, dynamic> message) async {

  }
}