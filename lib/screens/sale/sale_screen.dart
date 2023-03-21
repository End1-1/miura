import 'dart:convert';
import 'dart:typed_data';

import 'package:cafe5_shop_mobile_client/base_widget.dart';
import 'package:cafe5_shop_mobile_client/class_outlinedbutton.dart';
import 'package:cafe5_shop_mobile_client/class_sale_goods.dart';
import 'package:cafe5_shop_mobile_client/class_sale_goods_record.dart';
import 'package:cafe5_shop_mobile_client/class_set_qty_dlg.dart';
import 'package:cafe5_shop_mobile_client/config.dart';
import 'package:cafe5_shop_mobile_client/freezed/stock.dart';
import 'package:cafe5_shop_mobile_client/network_table.dart';
import 'package:cafe5_shop_mobile_client/screens/partners/partners_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/sale/sale_model.dart';
import 'package:cafe5_shop_mobile_client/socket_message.dart';
import 'package:cafe5_shop_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../freezed/partner.dart';
import '../../freezed/sale.dart';
import '../../models/lists.dart';
import '../../utils/app_fonts.dart';
import '../pricemode/price_mode_popup_screen.dart';

class SaleScreen extends StatefulWidget {
  String saleUuid;
  Partner? partner;

  SaleScreen({super.key, required this.saleUuid, this.partner});

  @override
  State<StatefulWidget> createState() {
    return SaleScreenState();
  }
}

class SaleScreenState extends BaseWidgetState<SaleScreen>
    with TickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  final NetworkTable _ntData = NetworkTable();
  List<SaleGoodsRecord> _goods = [];
  final List<double> _goodsColumnWidths = [0, 0, 0, 100, 80, 80, 80];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _animationController2;
  late Animation<double> _animation2;
  List<SaleGoods> _indexOfGoods = [];
  final SaleModel _model = SaleModel();

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
          String jsonStr = m.getString();
          _model.saleHeader = SaleHeader.fromJson(jsonDecode(jsonStr));
          setState(() {});
          getStock();
          break;
        case SocketMessage.op_add_goods_to_draft:
          SaleGoodsRecord s = SaleGoodsRecord(
              id: m.getString(),
              state: m.getInt(),
              goods: m.getInt(),
              name: m.getString(),
              qty: m.getDouble(),
              back: m.getDouble(),
              price: m.getDouble());
          _model.saleHeader =
              _model.saleHeader!.copyWith(amount: m.getDouble());
          if (s.state == 2) {
            for (int i = 0; i < _goods.length; i++) {
              if (_goods[i].id == s.id) {
                _goods.removeAt(i);
                break;
              }
            }
          } else {
            bool isnew = true;
            for (int i = 0; i < _goods.length; i++) {
              if (_goods[i].id == s.id) {
                _goods[i] = s;
                isnew = false;
                break;
              }
            }
            if (isnew) {
              _goods.add(s);
            }
          }
          setState(() {});
          break;
        case SocketMessage.op_open_sale_draft_document:
          String jsonStr = m.getString();
          _model.saleHeader = SaleHeader.fromJson(jsonDecode(jsonStr));
          if (_model.saleHeader!.partner > 0) {
            _model.partner = Lists.findPartner(_model.saleHeader!.partner);
            _model.partnerTextController.text = _model.partner?.taxname ?? '';
            getDebt();
          }
          setState(() {});

          m = SocketMessage.dllplugin(SocketMessage.op_open_sale_draft_body);
          m.addString(widget.saleUuid);
          sendSocketMessage(m);
          break;
        case SocketMessage.op_open_sale_draft_body:
          _ntData.readFromSocketMessage(m);
          for (int i = 0; i < _ntData.rowCount; i++) {
            SaleGoodsRecord s = SaleGoodsRecord(
                id: _ntData.getRawData(i, 0),
                state: 1,
                goods: _ntData.getRawData(i, 1),
                qty: _ntData.getRawData(i, 2),
                back: _ntData.getRawData(i, 3),
                price: _ntData.getRawData(i, 4),
                name: _ntData.getRawData(i, 5));
            _goods.add(s);
          }
          setState(() {});
          getStock();
          break;
        case SocketMessage.op_check_qty:
          _ntData.readFromSocketMessage(m);
          _indexOfGoods.clear();
          for (int i = 0; i < _ntData.rowCount; i++) {
            _indexOfGoods.add(SaleGoods(
                goods: _ntData.getRawData(i, 6),
                currency: 1,
                name: _ntData.getRawData(i, 1),
                barcode: _ntData.getRawData(i, 5),
                price1: _ntData.getRawData(i, 3),
                price2: _ntData.getRawData(i, 4)));
          }
          setState(() {});
          break;
        case SocketMessage.op_json_stock_all:
          String json = m.getString();
          _model.stockItems =
              StockItemList.fromJson({'list': jsonDecode(json)});
          setState(() {});
          break;
        case SocketMessage.op_json_partner_debt:
          String json = m.getString();
          List<dynamic> data = jsonDecode(json);
          _model.debtController.text = data[0]['debt'].toString();
          setState(() {

          });
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    _animationController2 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation2 = CurvedAnimation(
      parent: _animationController2,
      curve: Curves.linear,
    );
    if (widget.saleUuid.isEmpty) {
      SocketMessage m =
          SocketMessage.dllplugin(SocketMessage.op_create_empty_sale);
      sendSocketMessage(m);
    } else {
      SocketMessage m =
          SocketMessage.dllplugin(SocketMessage.op_open_sale_draft_document);
      m.addString(widget.saleUuid);
      sendSocketMessage(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum:
                const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 35),
            child: Stack(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClassOutlinedButton.createTextAndImage(() {
                        Navigator.pop(context);
                      }, tr("Sale document"), "images/back.png", w: 280),
                      Expanded(child: Container()),
                      ClassOutlinedButton.createImage(
                          _showAppendGoods, "images/plus.png"),
                      ClassOutlinedButton.createImage(
                          _showMainMenu, "images/menu.png")
                    ]),
                    const Divider(
                        height: 20, thickness: 2, color: Colors.black26),
                    _appendMenu(),
                    const Divider(),
                    Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: _listOfGoods(),
                                )))),
                    const Divider(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(tr("Total")),
                        const VerticalDivider(width: 5),
                        _model.saleHeader == null
                            ? Container()
                            : Text(_model.saleHeader!.amount.toString())
                      ],
                    )
                  ]),
              _showMenu()
            ])));
  }

  List<Widget> _listOfGoods() {
    List<Widget> l = [];
    for (int i = 0; i < _goods.length; i++) {
      SaleGoodsRecord s = _goods[i];
      l.add(Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 0.2)),
          child: Row(children: [
            ClassOutlinedButton.createImage(() {
              sq(tr("Confirm to remove row"), () {
                SocketMessage m = SocketMessage.dllplugin(
                    SocketMessage.op_add_goods_to_draft);
                m.addString(s.id);
                m.addString(widget.saleUuid);
                m.addInt(s.goods);
                m.addInt(2); //state
                m.addDouble(s.qty);
                m.addDouble(s.back);
                m.addDouble(s.price);
                sendSocketMessage(m);
              }, () {});
            }, "images/cancel.png"),
            Container(
                width: 200,
                padding: const EdgeInsets.all(3),
                child: Text(s.name)),
            Container(
                padding: const EdgeInsets.all(3),
                width: 80,
                child: GestureDetector(
                    onTap: () {
                      ClassSetQtyDlg.getQty(context, s.name).then((value) {
                        if (value != null) {
                          s = s.copyWith(qty: value);
                          SocketMessage m = SocketMessage.dllplugin(
                              SocketMessage.op_add_goods_to_draft);
                          m.addString(s.id);
                          m.addString(widget.saleUuid);
                          m.addInt(s.goods);
                          m.addInt(value == -1000 ? 2 : 1); //state
                          m.addDouble(s.qty);
                          m.addDouble(s.back);
                          m.addDouble(s.price);
                          sendSocketMessage(m);
                        }
                      });
                    },
                    child: Text(s.qty.toString(),
                        style: const TextStyle(
                            color: Color(0xff07570A),
                            fontWeight: FontWeight.bold)))),
            Container(
                padding: const EdgeInsets.all(3),
                width: 80,
                child: GestureDetector(
                    onTap: () {
                      ClassSetQtyDlg.getQty(context, s.name).then((value) {
                        if (value != null) {
                          s = s.copyWith(back: value);
                          SocketMessage m = SocketMessage.dllplugin(
                              SocketMessage.op_add_goods_to_draft);
                          m.addString(s.id);
                          m.addString(widget.saleUuid);
                          m.addInt(s.goods);
                          m.addInt(value == -1000 ? 2 : 1); //state
                          m.addDouble(s.qty);
                          m.addDouble(s.back);
                          m.addDouble(s.price);
                          sendSocketMessage(m);
                        }
                      });
                    },
                    child: Text(s.back.toString(),
                        style: const TextStyle(
                            color: Color(0xffff0000),
                            fontWeight: FontWeight.bold)))),
            Container(
                padding: const EdgeInsets.all(3),
                width: 80,
                child: Text(_model.stockItems.stockItem(s.goods)?.total().toString() ?? "0",
                    style: const TextStyle(
                        color: Color(0xff620185),
                        fontWeight: FontWeight.bold))),
            Column(children: [
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      padding: const EdgeInsets.all(3),
                      width: 80,
                      child: Text(s.price.toString()))),
              Container(
                  padding: const EdgeInsets.all(3),
                  width: 80,
                  child: Text('${s.qty * s.price}',
                      style: const TextStyle(fontWeight: FontWeight.bold)))
            ])
          ])));
    }
    return l;
  }

  List<Widget> _listOfSuggestions() {
    List<Widget> l = [];
    for (int i = 0; i < _indexOfGoods.length; i++) {
      final SaleGoods s = _indexOfGoods[i];
      l.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClassOutlinedButton.createImage(() {
            SocketMessage m =
                SocketMessage.dllplugin(SocketMessage.op_add_goods_to_draft);
            m.addString("");
            m.addString(widget.saleUuid);
            m.addInt(s.goods);
            m.addInt(1); //state
            m.addDouble(1);
            m.addDouble(0);
            m.addDouble(_model.priceMode.id == 2 ? s.price2 : s.price1);
            sendSocketMessage(m);
          }, "images/plus.png", h: 30, w: 30),
          const VerticalDivider(width: 5),
          Container(
              width: 100, child: Text(s.barcode, textAlign: TextAlign.start)),
          const VerticalDivider(
            width: 5,
          ),
          Container(
              width: 150,
              child: Text(
                s.name,
                textAlign: TextAlign.start,
              )),
          const VerticalDivider(
            width: 5,
          ),
          SizedBox(
              width: 100,
              child: Text(Config.getInt(key_local_price_type) == 2
                  ? s.price2.toString()
                  : s.price1.toString()))
        ],
      ));
      l.add(const Divider(
        height: 5,
      ));
    }
    return l;
  }

  void _showAppendGoods() {
    if (_animation.status == AnimationStatus.completed) {
      _animationController.animateBack(0,
          duration: const Duration(milliseconds: 300));
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
              alignment: Alignment.center,
              contentPadding: const EdgeInsets.all(20),
              children: [
                Column(children: [
                  SizedBox(
                      height: 50,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _animationController.forward();
                          },
                          child: Text(tr('Scancode'),
                              style: const TextStyle(fontSize: 16)))),
                  SizedBox(
                      height: 50,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            for (var e in SaleModel.predefinedGoodsList.goods) {
                              SocketMessage m = SocketMessage.dllplugin(
                                  SocketMessage.op_add_goods_to_draft);
                              m.addString("");
                              m.addString(widget.saleUuid);
                              m.addInt(e.id);
                              m.addInt(1); //state
                              m.addDouble(0);
                              m.addDouble(0);
                              m.addDouble(_model.priceMode.id == 2
                                  ? e.price2
                                  : e.price1);
                              sendSocketMessage(m);
                            }
                          },
                          child: Text(tr('Predefined list'),
                              style: const TextStyle(fontSize: 16))))
                ])
              ]);
        });
  }

  void _showMainMenu() {
    if (_animation2.status != AnimationStatus.completed) {
      _animationController2.forward();
    } else {
      _animationController2.animateBack(0,
          duration: const Duration(milliseconds: 300));
      SocketMessage m =
          SocketMessage.dllplugin(SocketMessage.op_update_draft_header);
      m.addString(jsonEncode(_model.saleHeader!.toJson()));
      sendSocketMessage(m);
    }
  }

  Widget _appendMenu() {
    _model.priceModeController.text = _model.priceMode.name;
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
                          controller: _barcodeController,
                        ))),
                ClassOutlinedButton.createImage(() {
                  _barcodeController.clear();
                }, "images/cancel.png"),
                ClassOutlinedButton.createImage(_search, "images/search.png"),
                ClassOutlinedButton.createImage(
                    _readBarcode, "images/barcode.png")
              ]),
              const Divider(
                height: 15,
              ),
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
    _model.discountController.text =
        '${_model.partner != null ? _model.partner!.discount * 100 : 0}%';
    return SizeTransition(
        sizeFactor: _animation2,
        axis: Axis.horizontal,
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      const VerticalDivider(
                        width: 5,
                      ),
                      ClassOutlinedButton.createImage(
                          _showMainMenu, "images/done.png")
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr("Price")),
                      const VerticalDivider(width: 5),
                      Row(children: [
                        Expanded(
                            child: TextFormField(
                          readOnly: true,
                          controller: _model.priceModeController,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return PriceModePopupScreen();
                                }).then((pricemode) {
                              if (pricemode != null) {
                                _model.priceMode = pricemode;
                                _model.priceModeController.text =
                                    pricemode.name;
                              }
                            });
                          },
                        ))
                      ]),
                      const Divider(
                        height: 10,
                      ),
                      Text(tr('Partner'), style: const TextStyle()),
                      Row(children: [
                        Expanded(
                            child: TextFormField(
                          controller: _model.partnerTextController,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return SimpleDialog(
                                    contentPadding: const EdgeInsets.all(5),
                                    insetPadding: const EdgeInsets.all(5),
                                    children: [PartnersScreen()],
                                  );
                                }).then((p) {
                              if (p != null) {
                                _model.partner = p;
                                _model.partnerTextController.text = p.taxname;
                                _model.discountController.text =
                                    '${p.discount * 100}%';
                                _model.saleHeader = _model.saleHeader!.copyWith(
                                    partner: p.id, discount: p.discount);
                                getDebt();
                              } else {
                                _model.saleHeader = _model.saleHeader!
                                    .copyWith(partner: 0, discount: 0);
                              }
                            });
                          },
                          decoration:
                              InputDecoration(hintText: tr('Tap to select')),
                        )),
                        InkWell(
                            onTap: () {
                              _model.partnerTextController.clear();
                              _model.partner = null;
                            },
                            child: Image.asset(
                              'images/cancel.png',
                              width: 36,
                              height: 36,
                            ))
                      ]),
                      Text(tr('Credit'), style: const TextStyle()),
                      TextFormField(
                        readOnly: true,
                        controller: _model.debtController,
                      ),
                      const Divider(
                        height: 10,
                      ),
                      Text(tr("Discount")),
                      const VerticalDivider(width: 5),
                      Row(children: [
                        Expanded(
                            child: TextFormField(
                          readOnly: true,
                          controller: _model.discountController,
                        ))
                      ]),
                      const Divider(
                        height: 10,
                      ),
                      Row(children: [
                        Checkbox(
                            value: _model.saleHeader == null
                                ? false
                                : _model.saleHeader!.isdebt == 1,
                            onChanged: (v) {
                              v ??= false;
                              int debt = v ? 1 : 0;
                              _model.saleHeader =
                                  _model.saleHeader!.copyWith(isdebt: debt);
                              setState(() {});
                            }),
                        Text(tr('Debt'), style: AppFonts.standardText)
                      ]),
                      const Divider(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ClassOutlinedButton.createTextAndImage(() {
                            sd(tr('Access denied'));
                          }, tr('Write order'), 'images/printer.png'))
                        ],
                      )
                    ],
                  )
                ])));
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
    FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .then((barcodeScanRes) {
      if (barcodeScanRes != "-1") {
        _barcodeController.text = barcodeScanRes;
        _search();
      }
    });
  }

  void getStock() {
    SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_json_stock_all);
    sendSocketMessage(m);
  }

  void getDebt() {
    SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_json_partner_debt);
    m.addInt(_model.partner?.id ?? 0);
    sendSocketMessage(m);
  }
}
