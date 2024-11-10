import 'dart:async';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'preorders_model.freezed.dart';
part 'preorders_model.g.dart';

@freezed
class Preorder with _$Preorder {
  const factory Preorder({required String id,
    required int state,
    required int payment,
  required String date,
  required String partnername,
  required String address,
  required double amount}) = _Preorder;

  factory Preorder.fromJson(Map<String, Object?> json) => _$PreorderFromJson(json);
}

class PreordersModel {
  final List<Preorder> data = [];
  final dateStream = StreamController<String>();
  int state = 1;
  late DateTime date;

  PreordersModel() {
    date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);
  }

  void previousDate() {
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    date = date.add(const Duration(days: -1));
    dateStream.add(DateFormat('dd/MM/yyyy').format(date));
  }

  void nextDate() {
    date = date.add(const Duration(days: 1));
    dateStream.add(DateFormat('dd/MM/yyyy').format(date));
  }

  void refresh(int driver) {
    BlocProvider.of<HttpBloc>(prefs.context()).add(HttpEvent('hqpreorders.php', {
    pkDate: DateFormat('dd/MM/yyyy').format(date),
    pkDriver: driver,
    'state': state
    }));
  }
}