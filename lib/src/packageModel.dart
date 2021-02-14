import 'dart:ffi';

import 'package:flutter/material.dart';


class packageList {
  List<packageAllList> listpackage;
  packageList({@required this.listpackage});

  factory packageList.fromJson(List<dynamic> json) {
    return packageList(

        listpackage: json.map((i) => packageAllList.fromJson(i)).toList());
  }
}

class packageAllList {

  String id;
  String title,intervalcount,price,sort,trialperioddays,createdate,updatedate,description;

  packageAllList(
      {@required this.id,
        @required this.price,this.trialperioddays,this.createdate,this.sort,this.title,this.updatedate,
        this.intervalcount,this.description
      });


  factory packageAllList.fromJson(Map<String, dynamic> json) {
    return packageAllList(
      id: json['id'].toString(),
      price:  json['price'].toString(),
      title:  json['name'],
      intervalcount:  json['interval_count'].toString(),
      createdate: json['created_at'].toString(),
      sort:  json['sotr_order'].toString(),
      updatedate: json['updated_at'].toString(),
      trialperioddays: json['trial_period_days'].toString(),
      description:  json['description'].toString(),




    );
  }
}