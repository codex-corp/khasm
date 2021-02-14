import 'package:dio/dio.dart';
import 'package:food_delivery_app/loginResponse.dart';
import 'package:food_delivery_app/src/packageResponse.dart';
import '../repository/user_repository.dart' as userRepo;



class CityApiProvider{
  final String _endpoint = "http://api.mypharma-order.com:8080/APIS/api/Listing/GetCitiesList";

  Dio _dio = Dio();

  CityApiProvider() {

    _dio.interceptors.clear();
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      // Do something before request is sent
      options.headers["Content-Type"] = "application/json" ;
      return options;
    }, onResponse: (Response response) {
      // Do something with response data
      return response; // continue
    }, onError: (DioError error) async {
      // Do something with response error
      if (error.response?.statusCode == 403) {
        _dio.interceptors.requestLock.lock();
        _dio.interceptors.responseLock.lock();
        RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
        options.headers["Content-Type"] = "application/json" ;

        _dio.interceptors.requestLock.unlock();
        _dio.interceptors.responseLock.unlock();
        return _dio.request(options.path, options: options);
      } else {
        return error;
      }
    }));
  }
  String _handleError(DioError error) {
    String errorDescription = "";
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.CANCEL:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          errorDescription = "Connection timeout with API server";
          break;
        case DioErrorType.DEFAULT:
          errorDescription =
          "Connection to API server failed due to internet connection";
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorDescription = "Receive timeout in connection with API server";
          break;
        case DioErrorType.RESPONSE:
          errorDescription =
          "${error.response.data['message']}";
          break;
//        case DioErrorType.SEND_TIMEOUT:
//          errorDescription =
//              "Send Request to Server Timeout: ${error.response.statusCode}";
          break;
      }
    } else {
      errorDescription = "Unexpected error occured";
    }
    return errorDescription;
  }



  Future<loginResponse> login(String phone,String token) async {

    Response response;
    try {

      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json" ;
        options.headers["Accept"] = "application/json";

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json" ;
          options.headers["Accept"] = "application/json";

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      print('https://khasmapp.com/api/signin?mobile_no='+phone+'&country_code='+'963'+'&otp='+'1'+'&device_token='+token);
      response = await _dio.get('https://khasmapp.com/api/signin?mobile_no='+phone+'&country_code='+'963'+'&otp='+'1'+'&device_token='+token);
      return loginResponse.fromJson(response.data);


    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return loginResponse.withError(_handleError(error));

    }


  }


  Future<loginResponse> verfy(String codev,String mobile,String codeC) async {

    Response response;
    try {

      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json" ;
        options.headers["Accept"] = "application/json";

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json" ;
          options.headers["Accept"] = "application/json";

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      response = await _dio.get('https://khasmapp.com/api/otp_verify?mobile_no='+mobile+'&otp='+codev+'&country_code='+codeC);
      return loginResponse.fromJson(response.data);


    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return loginResponse.withError(_handleError(error));

    }


  }
  Future<packageRes> getPackage() async {

    Response response;
    try {

      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json" ;
        options.headers["Accept"] = "application/json";

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json" ;
          options.headers["Accept"] = "application/json";

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      response = await _dio.get('https://khasmapp.com/api/plans');
      return packageRes.fromJson(response.data);


    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return packageRes.withError(_handleError(error));

    }


  }


}