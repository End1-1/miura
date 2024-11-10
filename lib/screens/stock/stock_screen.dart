import 'dart:async';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/utils/data_types.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'stock_model.dart';

class StockScreen extends MiuraApp {
  final model = StockModel();

  StockScreen({super.key}) {
    refresh();
  }

  @override
  Widget body(BuildContext context) {
    return Column(children: [
      StreamBuilder(
          stream: model.filterController.stream,
          builder: (context, snapshot) {
            return Row(
              children: [
                Text(model.stockName()),
                Expanded(child: Container()),
                Text(model.groupName())
              ],
            );
          }),
      BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {
        model.stock.clear();
        for (var e in state.data[pkData]) {
          model.stock.add(StockItem.fromJson(e));
        }

        return Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          for (var e in model.stock) ...[
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: const BoxDecoration(color: Colors.black12),
                child: Row(
                  children: [
                    Container(height: 60, width: 100, child: Text(e.groupname)),
                    Expanded(
                        child: Container(height: 60, child: Text(e.goodsname))),
                    Container(
                        height: 60,
                        width: 60,
                        child: Text(mdFormatDouble(e.qty)))
                  ],
                ))
          ]
        ])));
      })
    ]);
  }

  void popupWindow(BuildContext context) {
    showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return SimpleDialog(children: [
            //Payment type
            ListTile(
                dense: false,
                title: Text(tr('Storage')),
                leading: Image.asset('assets/images/stock.png'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: prefs.context(),
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                model.store = 0;
                                model.filterController.add(null);
                                refresh();
                              },
                              child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(30, 30, 30, 0),
                                  height: 60,
                                  width: 200,
                                  child: Text(tr('All'),
                                      style: const TextStyle(fontSize: 18)))),
                          const Divider(height: 20, color: Colors.black12),
                          for (var e in Lists.storages.values) ...[
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  model.store = e.id;
                                  model.filterController.add(null);
                                  refresh();
                                },
                                child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                    height: 60,
                                    width: 200,
                                    child: Text(e.name,
                                        style: const TextStyle(fontSize: 18)))),
                            const Divider(height: 20, color: Colors.black12),
                          ]
                        ],
                      );
                    },
                  );
                }),
            //Groups
            ListTile(
                dense: false,
                title: Text(tr('Goods group')),
                leading: Image.asset('assets/images/goods.png'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: prefs.context(),
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                model.goodsGroup = 0;
                                model.filterController.add(null);
                                refresh();
                              },
                              child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(30, 30, 30, 0),
                                  height: 60,
                                  width: 200,
                                  child: Text(tr('All'),
                                      style: const TextStyle(fontSize: 18)))),
                          const Divider(height: 20, color: Colors.black12),
                          for (var e in Lists.goodsGroup.values) ...[
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  model.goodsGroup = e.id;
                                  model.filterController.add(null);
                                  refresh();
                                },
                                child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                    height: 60,
                                    width: 200,
                                    child: Text(e.name,
                                        style: const TextStyle(fontSize: 18)))),
                            const Divider(height: 20, color: Colors.black12),
                          ]
                        ],
                      );
                    },
                  );
                })
          ]);
        });
  }

  @override
  String appTitle() {
    return locale().stock;
  }

  @override
  List<Widget> headerWidgets() {
    return [
      squareImageButton(() {
        popupWindow(prefs.context());
      }, 'assets/images/filter.png', height: 40)
    ];
  }
}
