import 'src/models/loginModel.dart';

class loginResponse {
  final String msg;
  final bool result;
  final User data;

  loginResponse(this.result, this.msg,this.data);

  loginResponse.fromJson(Map<String, dynamic> json)
      :
        data = User.fromJson(json["data"]),
        result = json['success'],
        msg = json['message'];

  loginResponse.withError(String errorValue)
      :
        data = null,
        result = false,
        msg = 'error';
}
