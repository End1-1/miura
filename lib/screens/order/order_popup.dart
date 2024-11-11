import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/utils/dialogs.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:flutter/material.dart';

import 'order_screen.dart';

extension popup on OrderScreen {
  void popupMenu(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: _children(context),
        );
      },
    );
  }

  List<Widget> _children(BuildContext context) {
    return [
      //Payment type
      ListTile(
          dense: false,
          title: Text(tr('Payment type')),
          leading: Image.asset('assets/images/payment.png'),
          onTap: () async {
            Navigator.pop(context);
            showDialog(
              context: prefs.context(),
              builder: (BuildContext context) {
                return SimpleDialog(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context, 1);
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                            height: 60,
                            width: 200,
                            child: Text(tr('Cash'),
                                style: const TextStyle(fontSize: 18)))),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context, 2);
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                            height: 60,
                            width: 200,
                            child: Text(tr('Card'),
                                style: const TextStyle(fontSize: 18)))),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context, 3);
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                            height: 60,
                            width: 200,
                            child: Text(tr('Bank transfer'),
                                style: const TextStyle(fontSize: 18))))
                  ],
                );
              },
            ).then((value) {
              if (value != null) {
                model.paymentType = value;
                model.partnerController.add(model.partner);
              }
            });
          }),
      //Visit
      ListTile(
          dense: false,
          title: Text(tr('Visit')),
          leading: Image.asset('assets/images/visit.png'),
          onTap: () {
            Navigator.pop(context);
            if (model.partner.id == 0) {
              appDialog(prefs.context(), tr('Select partner'));
              return;
            }
            visitScreen(context);
          }),
      const SizedBox(height: 10),
      //Storage
      ListTile(
          dense: false,
          title: Text(tr('Storage')),
          leading: Image.asset('assets/images/stock.png'),
          onTap: () async {
            Navigator.pop(context);
            showDialog(
                context: prefs.context(),
                builder: (context) {
                  return SimpleDialog(
                    children: [
                      for (var e in Lists.storages.values) ...[
                        InkWell(
                            onTap: () {
                              Navigator.pop(context, e.id);
                            },
                            child: Container(
                                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                height: 60,
                                width: 200,
                                child: Text(e.name,
                                    style: const TextStyle(fontSize: 18)))),
                        const Divider(height: 4, color: Colors.black12)
                      ]
                    ],
                  );
                }).then((value) {
              if (value != null) {
                model.storage = value;
                model.partnerController.add(model.partner);
              }
            });
          }),
      const SizedBox(height: 10),
      //Upload order
      ListTile(
          dense: false,
          title: Text(tr('Complete order')),
          leading: Image.asset('assets/images/upload.png'),
          onTap: () async {
            Navigator.pop(context);
            String err = '';
            if (model.partner.id == 0) {
              err += '${tr('Select partner')}\r\n';
            }
            if (model.goods.isEmpty) {
              err += '${tr('Goods list is empty')}\r\n';
            }
            for (var e in model.goods) {
              if ((e.qtysale ?? 0) == 0 && (e.qtyback ?? 0) == 0) {
                err += '${tr('Check quantity of rows')}\r\n';
                break;
              }
            }
            if (err.isNotEmpty) {
              appDialog(prefs.context(), err);
              return;
            }

            appDialogQuestion(prefs.context(),
                tr('Confirm to save order and quit'), () async {
              showDialog(
                context: prefs.context(),
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        Text(tr('Saving')),
                      ],
                    ),
                  );
                },
              );

              Map<String, Object?> requiestMap = model.toMap();
              final data = await HttpQuery(route: 'hqsaveorder.php', data:{}).request();
              Navigator.pop(prefs.context());
              switch (data['ok']) {
                case hrFail:
                  appDialog(prefs.context(),
                      requiestMap['message'].toString());
                  return;
                case hrOk:
                  Navigator.of(prefs.context()).pop();
                  break;
              }
            }, null);
          }),
      //mark
      const SizedBox(height: 40),
      ListTile(
          dense: false,
          title: Text(tr('Mark')),
          leading: Image.asset('assets/images/flag.png'),
          onTap: () async {
            Navigator.pop(context);
            model.mark = !model.mark;
            model.partnerController.add(model.partner);
          }),
      //Exit
      const SizedBox(height: 40),
      ListTile(
          dense: false,
          title: Text(tr('Exit')),
          leading: Image.asset('assets/images/exit.png'),
          onTap: () async {
            Navigator.pop(context);
            appDialogQuestion(context, tr('Confirm to quit without saving'),
                () {
              Navigator.pop(prefs.context());
            }, null);
          })
    ];
  }
}
