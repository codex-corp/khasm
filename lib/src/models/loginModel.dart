import 'dart:ffi';

import 'package:flutter/material.dart';





class User {




  String id,name,email,apiToken,deviceT;


  User(
      { this.id,
      this.name,

        this.email,
    this.apiToken,this.deviceT});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
  name: json['name'].toString(),
  email: json['email'].toString(),
  deviceT: json['device_token'].toString(),
  apiToken: json['api_token'].toString(),


    );
  }

}
