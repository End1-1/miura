import 'dart:async';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'screen.part.dart';

class SalesHistoryScreen extends MiuraApp {
  DateTime date1 = DateTime.now();
  DateTime date2 = DateTime.now();
  final dateStream =  StreamController();
  int viewType = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _blocKey = GlobalKey<ScaffoldState>();

  SalesHistoryScreen({super.key}) {
    _refresh();
  }

  @override
Widget body(BuildContext context) {
  return    Column(children: [

                ]);
  }

  @override
  String appTitle() {
    return locale().salesHistory;
  }

  @override
  List<Widget> headerWidgets() {
    return [
      squareImageButton(_refresh, 'assets/images/filter.png', height: 40)
    ];
  }

  Future<bool> filterWindow(BuildContext context) async {
    bool? result = await showDialog(
        context: context,
        builder: (builder) {
          return SimpleDialog(children: [
            Row(children: [
              Text(tr('Start date')),
              const SizedBox(
                width: 10,
              ),
              squareImageButton(() {
                date1 = previousDate(date1);
              }, 'assets/images/left.png'),
              StreamBuilder(
                  stream: dateStream.stream,
                  builder: (context, snapshot) {
                    return Text(DateFormat('dd/MM/yyyy').format(date1));
                  }),
              squareImageButton(() {
                date1 = nextDate(date1);
              }, 'assets/images/right.png'),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(children: [
              Text(tr('End date')),
              const SizedBox(
                width: 10,
              ),
              squareImageButton(() {
                date2 = previousDate(date2);
              }, 'assets/images/left.png'),
              StreamBuilder(
                  stream: dateStream.stream,
                  builder: (context, snapshot) {
                    return Text(DateFormat('dd/MM/yyyy').format(date2));
                  }),
              squareImageButton(() {
                date2 = nextDate(date2);
              }, 'assets/images/right.png'),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(child: Container(),),
                squareImageButton(() {
                  Navigator.pop(context, true);
                }, 'assets/images/done.png'),
                const SizedBox(
                  width: 10,
                ),
                squareImageButton(() {
                  Navigator.pop(context);
                }, 'assets/images/cancel.png'),
                Expanded(child: Container(),),
              ],
            ),
          ]);
        });
      return result ?? false;
  }
}
