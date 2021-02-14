import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';
import 'package:intl/intl.dart' as intl;
import 'package:toast/toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:intl/date_symbol_data_local.dart';
class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  ProfileSettingsDialog({Key key, this.user, this.onChanged}) : super(key: key);

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  int _value = 1;
  var fromdate = GlobalKey<FormState>();
  intl.DateFormat dateFormat ;
@override
  void initState() {
    // TODO: implement initState
  initializeDateFormatting();
  dateFormat   = intl.DateFormat("yyyy-MM-dd");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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

                Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                child:Container(width: MediaQuery.of(context).size.width,
                child: Text(S.of(context).birthday, style: TextStyle(color: Theme.of(context).hintColor),),)),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Visibility(
                          child: Form(
                            key: fromdate,
                            child: DateTimeField(

                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                  fieldHintText: S.of(context).birthday,
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
                                  return  S.of(context).birthday;
                                }
                              },

                              decoration: InputDecoration(labelText:  widget.user.date_of_birth,
                                  hintText: widget.user.date_of_birth,hintStyle: TextStyle(color: Colors.red)),
                              //   initialValue: DateTime.now(), //Add this in your Code.
                              // initialDate: DateTime(2017),
                              onSaved: (value) {
                                //  dateD = value.toString().substring(0, 10);
                                debugPrint(value.toString());
                                widget.user.date_of_birth = value.toString().substring(0, 10);
                              },
                            ),
                          ),
                          visible: true,
                        ),
                      ),
                      widget.user.gender.toString()=="null"?

                      DropdownButton(
                          value:_value,
                          items: [
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).femal)
                              ,
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).male),
                              value: 2,
                            ),


                          ],
                          onChanged: (value) {
                            setState(() {
                              _value =value;
                              widget.user.gender = value.toString();

                            });
                          }):
                      widget.user.gender.toString().toLowerCase()=="male"?
                      DropdownButton(
                          value:2,
                          items: [
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).femal)
                              ,
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).male),
                              value: 2,
                            ),


                          ],
                          onChanged: (value) {
                            setState(() {
                              _value =value;
                              widget.user.gender = value.toString();

                            });
                          }):
                      DropdownButton(
                          value:_value,
                          items: [
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).femal)
                              ,
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child:
                              Text(S.of(context).male),
                              value: 2,
                            ),


                          ],
                          onChanged: (value) {
                            setState(() {
                              _value =value;
                              widget.user.gender = value.toString();

                            });
                          }),

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
              },)

                ;
            });
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyText2,
      ),
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
      fromdate.currentState.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
