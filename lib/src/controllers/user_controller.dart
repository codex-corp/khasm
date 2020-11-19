
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/settings_controller.dart';
import 'package:food_delivery_app/src/elements/ProfileSettingsDialog.dart';
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

  void login(String phone,String token,String codeC) async {
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initializeDateFormatting();
    dateFormat   = DateFormat("yyyy-MM-dd");
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(phone,token,codeC).then((value) {
        if (value.deviceToken!=null) {

          prefs.setString('phoneM', phone);
          prefs.setString('codeC', codeC);

          prefs.setString('token', value.apiToken);
           print(value.first_time.toString());
           if(value.first_time==1){
             Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/edit');


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

            Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/category');
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
class birthDialog extends StatefulWidget {
  final User user;

  birthDialog({Key key, this.user}) : super(key: key);

  @override
  _birthDialog createState() => _birthDialog();
}

class _birthDialog extends State<birthDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  int _value = 1;
  var fromdate = GlobalKey<FormState>();
  DateFormat dateFormat ;
  GlobalKey<ScaffoldState> scaffoldKey;
  SettingsController _con;

  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting();
    dateFormat   = DateFormat("yyyy-MM-dd");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Row(
        children: <Widget>[
          Icon(Icons.person),
          SizedBox(width: 10),
          Text(
            S.of(context).profile_settings,
            style: Theme.of(context).textTheme.bodyText1,
          )
        ],
      ),
      children: <Widget>[
        Form(
          key: _profileSettingsFormKey,
          child: Column(
            children: <Widget>[
              new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(hintText: S.of(context).john_doe, labelText: S.of(context).full_name),
                initialValue: widget.user.name,
                validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_full_name : null,
                onSaved: (input) => widget.user.name = input,
              ),
              new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.emailAddress,
                decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: S.of(context).email_address),
                initialValue: widget.user.email,
                validator: (input) => !input.contains('@') ? S.of(context).not_a_valid_email : null,
                onSaved: (input) => widget.user.email = input,
              ),
              new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(hintText: '+136 269 9765', labelText: S.of(context).phone),
                initialValue: widget.user.phone,
                validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_phone : null,
                onSaved: (input) => widget.user.phone = input,
              ),
              new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(hintText: S.of(context).your_address, labelText: S.of(context).address),
                initialValue: widget.user.address,
                validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_address : null,
                onSaved: (input) => widget.user.address = input,
              ),
              new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(hintText: S.of(context).your_biography, labelText: S.of(context).about),
                initialValue: widget.user.bio,
                validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_biography : null,
                onSaved: (input) => widget.user.bio = input,
              ),
              DropdownButton(
                  value: _value,
                  items: [
                    DropdownMenuItem(
                      child: Text("Female"),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text("Male"),
                      value: 2,
                    ),


                  ],
                  onChanged: (value) {
                    setState(() {
                      _value =value;


                    });
                  }),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Visibility(
                  child: Form(
                    key: fromdate,
                    child: DateTimeField(
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      format: dateFormat,
                      validator: (val) {
                        if (val != null) {
                          return null;
                        } else {
                          return  'Birthday';
                        }
                      },
                      decoration: InputDecoration(labelText:  'Birthday'),
                      //   initialValue: DateTime.now(), //Add this in your Code.
                      // initialDate: DateTime(2017),
                      onSaved: (value) {
                        //  dateD = value.toString().substring(0, 10);
                        debugPrint(value.toString());
                      },
                    ),
                  ),
                  visible: true,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).cancel),
            ),
            MaterialButton(
              onPressed: _submit,
              child: Text(
                S.of(context).save,
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        SizedBox(height: 10),
      ],
    );
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
      _con.update(currentUser.value);
      repository.update(currentUser.value).then((value) {
        setState(() {});
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/code');

      });
      Navigator.pop(context);
    }
  }
}