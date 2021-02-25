import '../helpers/custom_trace.dart';
import '../models/media.dart';
import '../models/Subscription.dart';

class User {
  String id;
  bool isActive,isTrail;
  String name;
  String email;
  String totals;
  String code;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  String gender;
  String date_of_birth;
  bool isEnded;

  Media image;
  Subscription subS;

int first_time;
  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      totals = jsonMap['smiles_total'].toString()==null?'0': jsonMap['smiles_total'].toString();

      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      code = jsonMap['code'] != null ? jsonMap['code'] : '';
      first_time = jsonMap['first_time'] != null ? jsonMap['first_time'] : 0;
      isActive = jsonMap['isActive'] != null ? jsonMap['isActive'] : false;
      isEnded = jsonMap['isEnded'] != null ? jsonMap['isEnded'] : false;
      isTrail = jsonMap['isTrail'] != null ? jsonMap['isTrail'] : false;
      phone = jsonMap['phone'];

      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];


      gender = jsonMap['gender'] != null ? jsonMap['gender'] : '';
      date_of_birth = jsonMap['date_of_birth'] != null ? jsonMap['date_of_birth'] : '';





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
      subS = jsonMap['subscriptions'] != null && (jsonMap['subscriptions'] as List).length > 0 ? Subscription.fromJSON(jsonMap['subscriptions'][0]) : new Subscription();


    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["smiles_total"] = totals;

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
    map["isTrail"] = isTrail;
    map["isActive"] = isActive;
    map["isEnded"] = isEnded;

    map["bio"] = bio;
    map["media"] = image?.toMap();
    map["subscriptions"] = subS?.toMap();

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
