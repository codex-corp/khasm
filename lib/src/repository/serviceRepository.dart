import 'dart:convert';

import 'package:food_delivery_app/src/models/serviceList.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';

import '../models/filter.dart';
import '../models/food.dart';




Future<Stream<ServiceList>> getResturantByCCuision(categoryId) async {
  Uri uri = Helper.getUri('api/cuisines/'+categoryId);
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
 /* _queryParams['with'] = 'restaurant';
  _queryParams['search'] = 'category_id:$categoryId';
  _queryParams['searchFields'] = 'category_id:=';

  _queryParams = filter.toQuery(oldQuery: _queryParams);
  uri = uri.replace(queryParameters: _queryParams);*/
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
      return ServiceList.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new ServiceList.fromJSON({}));
  }
}



