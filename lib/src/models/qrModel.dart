import '../helpers/custom_trace.dart';

class qrM {
  String msg;
  bool suc;

  qrM();

  qrM.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      msg = jsonMap['message'].toString();
      suc = jsonMap['success'] ;
    } catch (e) {
      msg = '';
      suc = false;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
