import 'dart:async';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/screen/app_scaffold.dart';
import 'package:cafe5_shop_mobile_client/utils/data_types.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'goods_list_screen_part.dart';

class GoodsListScreen extends MiuraApp {
  final Map<int, StockItem> stock = {};
  final Map<int, StockItem> preorderStock = {};
  final carouselController = CarouselSliderController();
  final List<Goods> goods = [];
  final StreamController<String?> goodsGroupController = StreamController.broadcast();
  final StreamController<List<Goods>> goodsController = StreamController.broadcast();
  final StreamController<dynamic?> totalController = StreamController();
  final int pricePolitic;
  final int partnerId;
  double totalSaleQty = 0.0;
  double totalBackQty = 0.0;
  double totalAmount = 0.0;
  int currentPage = 0;

  GoodsListScreen(
      {super.key,
      required this.pricePolitic,
      required double discount,
      required this.partnerId}) {
    _init();
    goods.addAll(Lists.goods.values.map((e) {
      var special = false;
      double price = pricePolitic == mdPriceRetail ? e.price1 : e.price2;
      if (e.nospecialprice == 0) {
        if (Lists.specialPrices.containsKey(partnerId)) {
          if (Lists.specialPrices[partnerId]!.containsKey(e.id)) {
            price = Lists.specialPrices[partnerId]![e.id]!;
            special = true;
          }
        }
      }
      Goods g = e.copyWith(intuuid: const Uuid().v1(), price: price,
          discount: (special || (e.nospecialprice == 1)) ? 0 : discount,
          qtyback: 0, qtysale: 0, specialflag: special ? 1 : 0);
      return g;
    }));
  }

  void inputDataChanged(Goods g) {
    Goods gg = goods.firstWhere((element) => element.id == g.id);
    int index = goods.indexOf(gg);
    goods[index] = g;
    totalSaleQty = 0;
    totalBackQty = 0;
    totalAmount = 0;
    for (var e in goods) {
      totalSaleQty += e.qtysale ?? 0;
      totalBackQty += e.qtyback ?? 0;
      double totalPrice = e.qtysale! * e.price!;
      if (e.nospecialprice == 0) {
        totalPrice -= totalPrice * (e.discount! / 100);
      }
      totalAmount += totalPrice;
    }
    totalController.add(null);
  }

  @override
  Widget body(BuildContext context) {
    return  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CarouselSlider(
                options: CarouselOptions(height: double.infinity, autoPlay: false, enableInfiniteScroll: false, enlargeCenterPage: true, viewportFraction: 0.99),
                carouselController: carouselController,
                items: [1,2].map((e) {
                  return Builder(builder: (context) {
                    if (e == 1) {
                    return SingleChildScrollView(child: Column(children: [
                      for (var g in Lists.goodsGroup.values) ... [InkWell(onTap:(){
                        //goodsGroupController.add(g.name);
                        List<Goods> goodsList = goods
                            .where((element) => element.groupname == g.name)
                            .toList();
                        goodsController.add(goodsList);
                        currentPage = 1;
                        carouselController.nextPage(duration: const Duration(milliseconds: 200));
                      }, child: Container(width: MediaQuery.of(context).size.width, height: 60, child: Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))]]));
                    } else {
                      return SingleChildScrollView(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: StreamBuilder<List<Goods>?>(
                                  stream: goodsController.stream,
                                  builder: (context, snapshot) {
                                    return Wrap(
                                      spacing: 5,
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      children: [
                                        for (var e in snapshot.data ?? []) ...[
                                          _GoodsRow(
                                              goods: e,
                                              goodsQty: mdFormatDouble(stockQty(e.id)),
                                              partnerid: partnerId,
                                              inputDataChanged: inputDataChanged)
                                        ]
                                      ],
                                    );
                                  })));
                    }
                  });
                }).toList()
            )),


            StreamBuilder<dynamic?>(
                stream: totalController.stream,
                builder: (context, snashot) {
                  return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: const BoxDecoration(color: Color(0xffbeffff)),
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(tr('Total'),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Expanded(child: Container()),
                          Text('[${mdFormatDouble(totalSaleQty)}]',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('[${mdFormatDouble(totalBackQty)}]',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('[${mdFormatDouble(totalAmount)}]',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold))
                        ],
                      ));
                })
          ],
        );
  }

  @override
  Function(BuildContext) onBackTap() {
      return (context){ if (currentPage == 0) {
        Navigator.pop(context);
      } else {
        carouselController.jumpToPage(0);
        currentPage = 0;
      }};
  }

  @override
  String appTitle() {
    return locale().goodsList;
  }

  @override
  List<Widget> headerWidgets() {
    return  [
    smallSquareImageButton(() {
    final List<Goods> list = [];
    for (var e in goods) {
    if ((e.qtysale ?? 0) > 0 || (e.qtyback ?? 0) > 0) {
    list.add(e);
    }
    }
    Navigator.pop(prefs.context(), list);
    }, 'assets/images/done.png')];
  }

}

class _GoodsRow extends StatelessWidget {
  late Goods goods;
  final int partnerid;
  final String goodsQty;
  final TextEditingController editSale = TextEditingController();
  final TextEditingController editBack = TextEditingController();
  final TextEditingController editPrice = TextEditingController();
  final TextEditingController editStock = TextEditingController();
  final Function(Goods) inputDataChanged;

  _GoodsRow(
      {required this.goods,
        required this.goodsQty,
        required this.partnerid,
      required this.inputDataChanged});

  @override
  Widget build(BuildContext context) {
    editSale.text = mdFormatDouble(goods.qtysale);
    editBack.text = mdFormatDouble(goods.qtyback);
    editStock.text = goodsQty;
    editPrice.text = mdFormatDouble(goods.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xffbcbcec),
                ),
                width: MediaQuery.of(context).size.width * 0.7 ,
                child: Text(goods.goodsname,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            //Quantity sale
            Container(
                height: 55,
                decoration: const BoxDecoration(
                    color: Color(0xffcefdce),
                    border: Border.fromBorderSide(BorderSide(width: 0.2))),
                width: 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(2)),
                  controller: editSale
                    ..addListener(() {
                      goods = goods.copyWith(
                          qtysale: double.tryParse(editSale.text));
                      inputDataChanged(goods);
                    }),
                  onTap: () {
                    editSale.selection = TextSelection(
                        baseOffset: 0, extentOffset: editSale.text.length);
                  },
                )),
            //Quantity back
            Container(
                height: 55,
                decoration: const BoxDecoration(
                    color: Color(0xfffdcece),
                    border: Border.fromBorderSide(BorderSide(width: 0.2))),
                width: 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(2)),
                  controller: editBack
                    ..addListener(() {
                      goods = goods.copyWith(
                          qtyback: double.tryParse(editBack.text));
                      inputDataChanged(goods);
                    }),
                  onTap: () {
                    editBack.selection = TextSelection(
                        baseOffset: 0, extentOffset: editBack.text.length);
                  },
                )),
            //Stock
            //Quantity back
            Container(
                height: 55,
                decoration: const BoxDecoration(
                    color: Color(0xffced0fd),
                    border: Border.fromBorderSide(BorderSide(width: 0.2))),
                width: 70,
                child: TextFormField(
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(2)),
                    controller: editStock)),
            //Price
            Container(
                height: 55,
                decoration: const BoxDecoration(
                    color: Color(0xfffdfcce),
                    border: Border.fromBorderSide(BorderSide(width: 0.2))),
                width: 100,
                child: TextFormField(
                  readOnly: true,
                  controller: editPrice,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(2)),
                )),
          ],
        )
      ],
    );
  }
}
