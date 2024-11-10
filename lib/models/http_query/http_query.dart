import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';

const hrFail = 0;
const hrOk = 1;
const hrNetworkError = 2;

class HttpState extends Equatable {
  static int _counter = 0;
  late final int version;
  final bool loading;
  final int errorCode;
  final String errorMessage;
  final dynamic data;
  HttpState(this.loading, this.data, {this.errorCode = 200, this.errorMessage = ''}) {
    version = ++_counter;
  }
  @override
  List<Object?> get props => [];
}

class HttpEvent extends Equatable {
  final String route;
  final Map<String, dynamic> data;
  const HttpEvent(this.route, this.data);
  @override
  List<Object?> get props => [];
}

class HttpBloc extends Bloc<HttpEvent, HttpState> {
  HttpBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpQuery(event));
  }

  void _httpQuery(HttpEvent e) async {
    emit(HttpState(true, ''));
    final data = await HttpQuery(route: e.route, data: e.data).request();
    emit(HttpState(false, data));
  }
}

class HttpQuery {
  final String route;
  Map<String, dynamic> data = {};

  HttpQuery({required this.route, Map<String, dynamic> initData = const {}, required Map<String, dynamic> data}) ;

  void makeJson(Map<String, Object?> other) {
    data[pkFcmToken] = prefs.getString(pkFcmToken);
    data[pkPassHash] = prefs.getString(pkPassHash);
    data.addAll(other);
  }
  
  Future<String> body() async {
    return jsonEncode(data);
  }

  Future<Map<String,dynamic>> request() async {
    String strBody = await body();
    if (kDebugMode) {
      print(strBody);
    }
    final result = <String,dynamic>{};
    try {
      var response = await http.post(
          Uri.https(prefs.string(pkServerAddress), route),
          headers: {
            'Content-Type': 'application/json'
          },
          body: utf8.encode(strBody)).timeout(const Duration(seconds: 10), onTimeout: (){return http.Response('Timeout', 408);});
      String s = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        print('RESPONSE STRING FROM SERVER\r\n$s');
      }
      if (response.statusCode < 299) {
        result.addAll(jsonDecode(s));
        if (result.containsKey('ok')) {
          return result;
        } else {
          result['ok'] = 0;
          result['message'] = s;
          return result;
        }
      } else {
        result['ok'] = 0;
        result['message'] = s;
        return result;
      }
    } catch (e) {
      result['ok'] = 0;
      result['message'] = e.toString();
      return result;
    }
  }
}
