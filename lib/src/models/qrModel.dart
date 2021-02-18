import '../helpers/custom_trace.dart';

class qrM {
  String msg;
  bool suc;
  String data;

  qrM();

  qrM.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      msg = jsonMap['message'].toString();
      data = jsonMap['data'].toString();

      suc = jsonMap['success'] ;
    } catch (e) {
      msg = '';
      data=null;
      suc = false;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
