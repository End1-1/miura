part of 'stock_screen.dart';

class StockModel {
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

extension StockScreenExt on StockScreen {
  void refresh() {
    httpQuery(HttpEvent(
        'hqstock.php', {pkStock: model.store, pkGroup: model.goodsGroup}));
  }
}
