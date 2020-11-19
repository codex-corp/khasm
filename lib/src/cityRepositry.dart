



import 'package:food_delivery_app/loginResponse.dart';
import 'package:food_delivery_app/src/packageResponse.dart';
import 'package:food_delivery_app/src/repository/cityApiProvider.dart';

class CityRepository {
  CityApiProvider _apiProvider = CityApiProvider();


  Future<loginResponse> login(String phone, String token) {
    return _apiProvider.login(phone,token);

  }

  Future<loginResponse> verfyAccount(String codev,String mobile,String codeC) {
    return _apiProvider.verfy(codev,mobile,codeC);

  }
  Future<packageRes> getPachage() {
    return _apiProvider.getPackage();

  }


}