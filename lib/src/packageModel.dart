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
  String title,vouvherlimi,price,level,avaperiod,createdate,updatedate;

  packageAllList(
      {@required this.id,
        @required this.price,this.avaperiod,this.createdate,this.level,this.title,this.updatedate,
        this.vouvherlimi
      });


  factory packageAllList.fromJson(Map<String, dynamic> json) {
    return packageAllList(
      id: json['id'].toString(),
      price:  json['price'].toString(),
      title:  json['title'],
      avaperiod:  json['available_period'].toString(),
      createdate: json['created_at'].toString(),
      level:  json['level'].toString(),
      updatedate: json['updated_at'].toString(),
      vouvherlimi: json['voucher_limit'].toString(),




    );
  }
}