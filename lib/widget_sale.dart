import 'dart:math';
import 'dart:typed_data';

import 'package:cafe5_shop_mobile_client/base_widget.dart';
import 'package:cafe5_shop_mobile_client/class_currency.dart';
import 'package:cafe5_shop_mobile_client/class_outlinedbutton.dart';
import 'package:cafe5_shop_mobile_client/class_sale_goods.dart';
import 'package:cafe5_shop_mobile_client/config.dart';
import 'package:cafe5_shop_mobile_client/network_table.dart';
import 'package:cafe5_shop_mobile_client/socket_message.dart';
import 'package:cafe5_shop_mobile_client/translator.dart';
import 'package:cafe5_shop_mobile_client/widget_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class WidgetSaleDocument extends StatefulWidget {
  String saleUuid;

  WidgetSaleDocument({super.key, required this.saleUuid});

  @override
  State<StatefulWidget> createState() {
    return WidgetSaleDocumentState();
  }
}

class WidgetSaleDocumentState extends BaseWidgetState<WidgetSaleDocument> with TickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  final NetworkTable _ntData = NetworkTable();
  int _menuAnimationDuration = 300;
  bool _hideMenu = true;
  double _startMenuY = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _animationController2;
  late Animation<double> _animation2;
  List<int> _indexOfSugges = [];

  @override
  void handler(Uint8List data) async {
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    if (!checkSocketMessage(m)) {
      return;
    }
    print("command ${m.command}");
    if (m.command == SocketMessage.c_dllplugin) {
      int op = m.getInt();
      int dllok = m.getByte();
      if (dllok == 0) {
        sd(m.getString());
        return;
      }
      switch (op) {
        case SocketMessage.op_create_empty_sale:
          widget.saleUuid = m.getString();
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _animationController2 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation2 = CurvedAnimation(
      parent: _animationController2,
      curve: Curves.linear,
    );
    if (widget.saleUuid.isEmpty) {
      SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_create_empty_sale);
      sendSocketMessage(m);
    } else {
      SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_open_sale_document);
      sendSocketMessage(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 35),
            child: Stack(children: [Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                ClassOutlinedButton.createTextAndImage(() {
                  Navigator.pop(context);
                }, tr("Sale document"), "images/back.png", w: 300),
                Expanded(child: Container()),
                ClassOutlinedButton.createImage(_showAppendGoods, "images/plus.png"),
                ClassOutlinedButton.createImage(_showMainMenu, "images/menu.png")
              ]),
              const Divider(height: 20, thickness: 2, color: Colors.black26),
              _appendMenu(),
              const Divider(),
              Expanded(
                  child: WidgetNetworkDataTable(
                networkTable: _ntData,
              ))
            ]),
              _showMenu()
            ])));
  }

  void _buildSearchList(String suggestion) {
    _indexOfSugges.clear();
    if (suggestion.length < 4) {
      setState(() {});
      return;
    }
    for (int i = 0; i < SaleGoods.list.length; i++) {
      final SaleGoods s = SaleGoods.list[i];
      if (s.currency != Config.getInt(key_local_currency_id)) {
        continue;
      }
      if (s.name.toLowerCase().contains(suggestion.toLowerCase()) || s.barcode.contains(suggestion)) {
        _indexOfSugges.add(i);
      }
    }
    setState(() {});
  }

  List<Widget> _listOfSuggestions() {
    List<Widget> l = [];
    for (int i = 0; i < _indexOfSugges.length; i++) {
      final SaleGoods s = SaleGoods.list[_indexOfSugges[i]];
      l.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClassOutlinedButton.createImage((){}, "images/plus.png", h: 30, w: 30),
          const VerticalDivider(width: 5),
          Container(width: 100, child: Text(s.barcode, textAlign: TextAlign.start)),
          const VerticalDivider(width: 5,),
          Container(width: 150, child: Text(s.name, textAlign: TextAlign.start,)),
          const VerticalDivider(width: 5,),
          Container(width: 100, child: Text(s.price1.toString()))
        ],
      ));
      l.add(const Divider(height: 5,));
    }
    return l;
  }

  void _showAppendGoods() {
    if (_animation.status != AnimationStatus.completed) {
      _animationController.forward();
    } else {
      _animationController.animateBack(0, duration: const Duration(seconds: 1));
    }
  }

  void _showMainMenu() {
    if (_animation2.status != AnimationStatus.completed) {
      _animationController2.forward();
    } else {
      _animationController2.animateBack(0, duration: const Duration(seconds: 1));
    }
  }

  Widget _appendMenu() {
    return SizeTransition(
        sizeFactor: _animation,
        axis: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          Row(children: [
            Expanded(
                child: Container(
                    margin: const EdgeInsets.only(right: 3),
                    child: TextFormField(
                      onChanged: _buildSearchList,
                      controller: _barcodeController,
                    ))),
            ClassOutlinedButton.createImage(() {
              _barcodeController.clear();
              _buildSearchList("");
            }, "images/cancel.png"),
            ClassOutlinedButton.createImage(_search, "images/search.png"),
            ClassOutlinedButton.createImage(_readBarcode, "images/barcode.png")
          ]),
               const Divider(height: 15,),
               SizedBox(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _listOfSuggestions(),
                          ))))
        ]));
  }

  Widget _showMenu() {
    return SizeTransition(
        sizeFactor: _animation2,
        axis: Axis.horizontal,
        child: Container(width: MediaQuery.of(context).size.width,
          color: Colors.white,
            child: Column(
          children:[
            Row(
              children: [
                Text(tr("Currency")),
                const VerticalDivider(width: 5),
                DropdownButton<Currency>(
                  value: Currency.valueOf(Config.getInt(key_local_currency_id)),
                  items: Currency.list.map((Currency value) {
                    return DropdownMenuItem<Currency>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: (v) {Config.setInt(key_local_currency_id, v!.id);},
                ),
        Expanded(child: Container()),
                const VerticalDivider(width: 5,),
                ClassOutlinedButton.createImage(_showMainMenu, "images/cancel.png")
              ],
            )
          ]
        )));
  }

  void _search() {
    if (_barcodeController.text.isEmpty) {
      return;
    }
    SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_check_qty);
    m.addString(_barcodeController.text);
    m.addInt(1);
    sendSocketMessage(m);
  }

  void _readBarcode() {
    FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE).then((barcodeScanRes) {
      if (barcodeScanRes != "-1") {
        _barcodeController.text = barcodeScanRes;
        _search();
      }
    });
  }
}