part of 'goods_list_screen.dart';

extension GoodsListScreenExt on GoodsListScreen {


  void _init() async {
   final data1 = await HttpQuery(route: 'hqstock.php', data: {
      pkStock: 0,
      pkGroup : 0
    }).request();
      for (var e in data1['data']) {
        stock[e['goodsid']] = StockItem.fromJson(e);
      }

    final data2 = await HttpQuery(route: 'hqpreorderStock.php', data: {
      pkStock: 0,
      pkGroup : 0
    }).request();
      for (var e in data2['data']) {
        preorderStock[e['goodsid']] = StockItem.fromJson(e);
      }
  }

  double stockQty(int id) {
    double s = stock.containsKey(id) ? stock[id]!.qty : 0;
    double p = preorderStock.containsKey(id) ? preorderStock[id]!.qty : 0;
    return s - p;
  }
}