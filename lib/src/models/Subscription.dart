import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Subscription {

  String id;
  String Subid;
  String subType;
  String planId;
  String name;
  String cancelI;
  String trialED;
  String startD;
  String endD;
  String cancelAt;
  String createAt;
  String updateAt;


  Subscription();

  Subscription.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
  Subid = jsonMap['subscribable_id'].toString();
  subType = jsonMap['subscribable_type'] != null ? jsonMap['subscribable_type'] : '';
  planId = jsonMap['plan_id'].toString();
  name = jsonMap['name'] != null ? jsonMap['name'] : '';
  cancelI = jsonMap['canceled_immediately'] != null ? jsonMap['canceled_immediately'] : '';
  trialED = jsonMap['trial_ends_at'] != null ? jsonMap['trial_ends_at'] : '';
      startD = jsonMap['starts_at'] != null ? jsonMap['starts_at'] : '';
      endD = jsonMap['ends_at'] != null ? jsonMap['ends_at'] : '';
      cancelAt = jsonMap['canceled_at'] != null ? jsonMap['canceled_at'] : '';
  createAt = jsonMap['created_at'] != null ? jsonMap['created_at'] : '';
  updateAt = jsonMap['updated_at'] != null ? jsonMap['updated_at'] : '';





    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id.toString();
    map["subscribable_id"] = Subid.toString();
    map["subscribable_type"] = subType;
    map["plan_id"] = planId.toString();

    map["name"] = name;
    map["canceled_immediately"] = cancelI;
    map["trial_ends_at"] = trialED;

    map["starts_at"] = startD;
    map["ends_at"] = endD;
    map["canceled_at"] = cancelAt;
    map["created_at"] = createAt;

    map["updated_at"] = updateAt;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }


}
