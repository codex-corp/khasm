



import 'package:food_delivery_app/src/packageModel.dart';

class packageRes {
  final bool msg;
  final packageList results;


  packageRes(this.msg, this.results );

  packageRes.fromJson(Map<String, dynamic> json)
      : results = packageList.fromJson(json["data"]),

        msg = json["success"];


        packageRes.withError(String errorValue)
      : results = null,


        msg = false;
}
