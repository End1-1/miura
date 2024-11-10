import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/drivers_list/driver_list_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/preorder_detail/preorder_details_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/preorders/preorders_model.dart';
import 'package:cafe5_shop_mobile_client/utils/dialogs.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PreordersScreen extends MiuraApp {
  final model = PreordersModel();

  PreordersScreen({super.key, required int state}) {
    model.state = state;
    model.refresh(prefs.getInt(pkSaleDriver) ?? 0);
  }

  @override
  Widget body(BuildContext context) {
    return
                BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {

                model.data.clear();
                for (var e in state.data[pkData]) {
                  model.data.add(Preorder.fromJson(e));
                }
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var e in model.data) ...[
                          Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              decoration: const BoxDecoration(
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.black12))),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PreorderDetailsScreen(
                                                    preorder: e)));
                                  },
                                  onLongPress: () {
                                    appDialogQuestion(
                                        context, tr('Is delivery complete?'),
                                        () {

                                      HttpQuery(route:'hqcompletedelivery.php', data: {'id': e.id})
                                          .request()
                                          .then((value) {
                                        if (value['ok'] == hrOk) {
                                          model.refresh(prefs.getInt(pkSaleDriver) ?? 0);
                                        } else {
                                          appDialog(prefs.context(), value[pkData]);
                                        }
                                      });
                                    }, null);
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          height: 50,
                                          width: 100,
                                          child: Text(e.date)),
                                      SizedBox(
                                          height: 50,
                                          width: 150,
                                          child: Text(e.partnername)),
                                      SizedBox(
                                          height: 50,
                                          width: 300,
                                          child: Text(e.address)),
                                      SizedBox(
                                          height: 50,
                                          width: 100,
                                          child: Text(mdFormatDouble(e.amount)))
                                    ],
                                  )))
                        ]
                      ],
                    )));
              }

            );
  }

  @override
  List<Widget> headerWidget(BuildContext context) {
    return [
      squareImageButton(() {
        model.previousDate();
        model.refresh(prefs.getInt(pkSaleDriver) ?? 0);
      }, 'assets/images/left.png'),
      StreamBuilder<String>(
          stream: model.dateStream.stream,
          builder: (context, snapshot) {
            return Text(
                snapshot.data ?? DateFormat('dd/MM/yyyy').format(model.date));
          }),
      squareImageButton(() {
        model.nextDate();
        model.refresh(prefs.getInt(pkSaleDriver) ?? 0);
      }, 'assets/images/right.png'),
      squareImageButton(() {
        showDialog(
            context: prefs.context(),
            builder: (context) {
              return const SimpleDialog(children: [DriverListScreen()]);
            }).then((value) {
          if (value != null) {
            prefs.setInt(pkSaleDriver, value);
            model.refresh(prefs.getInt(pkSaleDriver) ?? 0);
          }
        });
      }, 'assets/images/filter.png')
    ];
  }

  @override
  String appTitle() {
    return  model.state == 1 ? locale().pendingPreorders : locale().preorders;
  }
}
