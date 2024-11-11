import 'dart:convert';

import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

const hrIdle = -2;
const hrLoading = -1;
const hrFail = 0;
const hrOk = 1;

class HttpState extends Equatable {
  static int _counter = 0;
  late final int version;
  final int errorCode;
  var errorMessage = '';
  final dynamic data;

  HttpState(this.data, {this.errorCode = hrIdle, this.errorMessage = ''}) {
    version = ++_counter;
    if (kDebugMode) {
      print('NEW VERSION OF STATE $version');
    }
  }

  @override
  List<Object?> get props => [version, errorCode, errorMessage, data];
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
    if (e.route.isEmpty) {
      emit(HttpState({}, errorCode: hrIdle));
      return;
    }
    emit(HttpState(errorCode: hrLoading, ''));
    final data = await HttpQuery(route: e.route, data: e.data).request();
    emit(HttpState(data,
        errorCode: data['ok'],
        errorMessage: data['ok'] != hrOk ? data['message'] : ''));
  }
}

class HttpQuery {
  final String route;
  Map<String, dynamic> data = {};

  HttpQuery({required this.route, this.data = const {}});

  Future<Map<String, dynamic>> request() async {
    data[pkFcmToken] = prefs.getString(pkFcmToken);
    data['sessionkey'] = prefs.getString('sessionkey');
    String strBody = jsonEncode(data);
    if (kDebugMode) {
      print('REQUEST');
      print(strBody);
    }
    final result = <String, dynamic>{};
    try {
      var response = await http
          .post(
              Uri.https(prefs.string(pkServerAddress), '/engine/miura/$route'),
              headers: {'Content-Type': 'application/json'},
              body: utf8.encode(strBody))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        return http.Response('Timeout', 408);
      });
      String s = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        print(
            'RESPONSE ${prefs.string(pkServerAddress)}/engine/miura/$route , size: ${mdDoubleFormatter.format(response.bodyBytes.length)} \r\n ${response.statusCode}: $s');
      }
      if (response.statusCode < 299) {
        try {
          result.addAll(jsonDecode(s));
        } catch (e) {
          result['ok'] = hrFail;
          result['message'] = e.toString();
          return result;
        }
        if (result.containsKey('ok')) {
          return result;
        } else {
          result['ok'] = hrOk;
          result['message'] = s;
          return result;
        }
      } else {
        result['ok'] = hrFail;
        result['message'] = s;
        return result;
      }
    } catch (e) {
      result['ok'] = hrFail;
      result['message'] = e.toString();
      return result;
    }
  }
}
