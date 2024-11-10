part of 'preorder_stock_screen.dart';

class PreordersStockModel {
  final StreamController filterController = StreamController();
  List<StockItem> stock = [];
  int goodsGroup = 0;
  int store = Lists.config.storage;

  String stockName() {
    return store == 0 ? '' : Lists.storages[store]!.name;
  }

  String groupName() {
    return goodsGroup == 0 ? '' : Lists.goodsGroup[goodsGroup]!.name;
  }
}

extension PreordersStockScreenExt on PreordersStockScreen {
  void refresh() {
    httpQuery(HttpEvent('hqpreorderstock.php',
        {pkStock: model.store, pkGroup: model.goodsGroup}));
  }
}
