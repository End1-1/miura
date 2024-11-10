import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/preorder_detail/preorder_details_model.dart';
import 'package:cafe5_shop_mobile_client/screens/preorders/preorders_model.dart';
import 'package:cafe5_shop_mobile_client/screens/screen/app_scaffold.dart';
import 'package:cafe5_shop_mobile_client/utils/data_types.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/utils/dialogs.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreorderDetailsScreen extends MiuraApp {
  final Preorder preorder;
  final model = PreordersDetailsModel();

  PreorderDetailsScreen({super.key, required this.preorder}) {
    httpQuery(HttpEvent('hqpreorderdetails.php', {'id': preorder.id}));
  }

  String total() {
    double total = 0;
    for (var e in model.data) {
      total += e.price * e.qty;
    }
    return mdFormatDouble(total);
  }

  String totalQty() {
    double total = 0;
    for (var e in model.data) {
      total += e.qty;
    }
    return mdFormatDouble(total);
  }

  @override
  Widget body(BuildContext context) {
    return
                BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {
                  for (var e in state.data[pkData]) {
                    model.data.add(PreorderDetails.fromJson(e));
                  }
              return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        Container(
                            height: 30,
                            child: Text(
                                '${preorder.partnername}, ${preorder.address}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo))),
                            Container(
                                height: 30,
                                child: Text(
                                    '${PaymentTypes.name(preorder.payment)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo)))])
                      ]),
                      for (var e in model.data) ...[
                        Container(
                            decoration: const BoxDecoration(
                                border: Border.fromBorderSide(
                                    BorderSide(color: Colors.black12))),
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 70,
                                    width: 120,
                                    child: Text(e.groupname)),
                                SizedBox(
                                    height: 70,
                                    width: 250,
                                    child: Text(e.goodsname)),
                                SizedBox(
                                    height: 70,
                                    width: 100,
                                    child: Text(mdFormatDouble(e.qty))),
                                SizedBox(
                                    height: 70,
                                    width: 100,
                                    child: Text(mdFormatDouble(e.price))),
                                SizedBox(
                                    height: 70,
                                    width: 100,
                                    child:
                                        Text(mdFormatDouble(e.price * e.qty))),
                              ],
                            )),
                      ],
                      const SizedBox(height: 20,),
                      Row(children: [
                        SizedBox(
                            height: 70,
                            width: 120,
                            child: Text(tr('Total'), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo))),
                        SizedBox(
                            height: 70,
                            width: 250,
                            child: Text('')),
                        SizedBox(
                            height: 70,
                            width: 100,
                            child: Text(totalQty(), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo))),
                        SizedBox(
                            height: 70,
                            width: 100,
                            child: Text('')),
                        SizedBox(
                            height: 70,
                            width: 100,
                            child:
                            Text(total(), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo))),
                      ],)
                    ],
                  )));
            });
  }

  @override
  String appTitle() {
    return locale().preordersDetails;
  }
}
