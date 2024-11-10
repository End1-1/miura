import 'dart:async';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/drivers_list/driver_list_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/order/order_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/route/route_item.dart';
import 'package:cafe5_shop_mobile_client/utils/data_types.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'package:cafe5_shop_mobile_client/screens/route/route_model.dart';

class RouteScreen extends MiuraApp {
  final model = RouteModel();

  RouteScreen({super.key}) {
    refresh(prefs.getInt(pkRouteDriver) ?? 0);
  }

  @override
  Widget body(BuildContext context) {
    return BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {
      model.route.clear();
      for (var e in state.data[pkData]) {
        model.route.add(RouteItem.fromJson(e));
      }

      int row = 1;
      return SingleChildScrollView(
          child: Column(
        children: [
          for (final e in model.route) ...[
            InkWell(
                onLongPress: () {
                  Partner? p = Lists.findPartner(e.partnerid);
                  if (p == null) {
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderScreen(
                              pricePolitic: p.pricepolitic,
                              partner: p))).then((value) {
                    refresh(prefs.getInt(pkRouteDriver) ?? 0);
                  });
                },
                child: Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    decoration: const BoxDecoration(color: Colors.black12),
                    child: Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${row++}. ${e.partnername}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo)),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (e.action.contains('1'))
                                      Image.asset(
                                          'assets/images/goodsnotneeded.png',
                                          height: 20,
                                          width: 20),
                                    if (e.action.contains('2'))
                                      Image.asset('assets/images/order.png',
                                          height: 20, width: 20),
                                    if (e.action.contains('3'))
                                      Image.asset(
                                          'assets/images/visitclosed.png',
                                          height: 20,
                                          width: 20),
                                    if (e.orders > 0)
                                      Image.asset('assets/images/delivery.png',
                                          height: 20, width: 20),
                                    if (e.action.contains('4'))
                                      Image.asset(
                                          'assets/images/completedelivery.png',
                                          height: 20,
                                          width: 20),
                                    //Expanded(child: Container())
                                  ])
                            ]),
                        const SizedBox(width: 5),
                        Expanded(
                            child:
                                SizedBox(height: 50, child: Text(e.address))),
                      ],
                    )))
          ]
        ],
      ));
    });
  }

  @override
  String appTitle() {
    return locale().route;
  }

  @override
  List<Widget> headerWidgets() {
    return [
      squareImageButton(() {
        model.previousDate();
        refresh(prefs.getInt(pkRouteDriver) ?? 0);
      }, 'assets/images/left.png'),
      StreamBuilder<String>(
          stream: model.dateStream.stream,
          builder: (context, snapshot) {
            return Text(
                snapshot.data ?? DateFormat('dd/MM/yyyy').format(model.date));
          }),
      squareImageButton(() {
        model.nextDate();
        refresh(prefs.getInt(pkRouteDriver) ?? 0);
      }, 'assets/images/right.png'),
      squareImageButton(() {
        showDialog(
            context: prefs.context(),
            builder: (context) {
              return const SimpleDialog(children: [DriverListScreen()]);
            }).then((value) {
          if (value != null) {
            prefs.setInt(pkRouteDriver, value);
            refresh(prefs.getInt(pkRouteDriver) ?? 0);
          }
        });
      }, 'assets/images/filter.png')
    ];
  }
}
