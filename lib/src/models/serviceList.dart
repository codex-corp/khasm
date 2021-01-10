import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';
import '../models/category.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/media.dart';
import '../models/nutrition.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'coupon.dart';

class ServiceList {
  String id;
  String name;
  String image;

  List<Restaurant> restaurant;


  ServiceList();
  ServiceList.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();

      name = jsonMap['name'];

    //  restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : Restaurant.fromJSON({});
      image = jsonMap['icon'] != null ? jsonMap['icon'] : "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      restaurant = jsonMap['restaurants'] != null && (jsonMap['restaurants'] as List).length > 0
          ? List.from(jsonMap['restaurants']).map((element) => Restaurant.fromJSON(element)).toSet().toList()
          : [];


    } catch (e) {
      id = '';
      name = '';


      image = "";
      restaurant = [];

      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;


    map["name"] = name;


    return map;
  }

 /* double getRate() {
    double _rate = 0;
    foodReviews.forEach((e) => _rate += double.parse(e.rate));
    _rate = _rate > 0 ? (_rate / foodReviews.length) : 0;
    return _rate;
  }*/

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;


}
