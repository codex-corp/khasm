import '../helpers/custom_trace.dart';
import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String code;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  String gender;
  String date_of_birth;
  bool isActive;
  bool isEnded;

  Media image;
int first_time;
  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      code = jsonMap['code'] != null ? jsonMap['code'] : '';
      first_time = jsonMap['first_time'] != null ? jsonMap['first_time'] : '0';
      isActive = jsonMap['isActive'] != null ? jsonMap['isActive'] : false;
      isEnded = jsonMap['isEnded'] != null ? jsonMap['isEnded'] : false;

      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }


      try {
        gender = jsonMap['custom_fields']['gender']['view'].toString();
      } catch (e) {
        gender = "";
      }
      try {
        date_of_birth = jsonMap['custom_fields'][' date_of_birth']['view'];
      } catch (e) {
        date_of_birth = "";
      }



      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["code"] = code;
    map["first_time"] = first_time;

    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["date_of_birth"] = date_of_birth;
    map["gender"] = gender.toString();

    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '';
  }
}
