import 'package:cafe5_shop_mobile_client/models/model.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/data_download/data_download_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/login/login_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/order/order_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/preorders/preorders_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/preorders_stock/preorder_stock_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/route/route_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/sales_history/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/screen/app_scaffold.dart';
import 'package:cafe5_shop_mobile_client/screens/stock/stock_screen.dart';
import 'package:cafe5_shop_mobile_client/utils/dialogs.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:cafe5_shop_mobile_client/widgets/rect_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends MiuraApp {
  const HomeScreen({super.key});

  @override
  Widget body(BuildContext context) {
    return  Column(
          children: [
            Expanded(
                child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              direction: Axis.horizontal,
              spacing: 10,
              runSpacing: 10,
              children: [
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SalesHistoryScreen()));
                    },
                    title: tr('Sales history'),
                    assetPath: 'assets/images/order.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OrderScreen(pricePolitic: mdPriceRetail)));
                    },
                    title: tr('New order'),
                    assetPath: 'assets/images/order.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StockScreen()));
                    },
                    title: tr('Stock'),
                    assetPath: 'assets/images/stock.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreordersStockScreen()));
                    },
                    title: tr('Quantity of preorders'),
                    assetPath: 'assets/images/stock.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RouteScreen()));
                    },
                    title: tr('Route'),
                    assetPath: 'assets/images/route.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreordersScreen(state: 1)));
                    },
                    title: tr('Pending preorders'),
                    assetPath: 'assets/images/preorders.png'),
                RectButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreordersScreen(state: 2)));
                    },
                    title: tr('Preorders'),
                    assetPath: 'assets/images/preorders.png'),
                RectButton(
                    onTap: () {
                      appDialogQuestion(context, tr('Refresh data?'), () {
                        prefs.setBool(pkDataLoaded, false);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataDownloadScreen(
                                      pop: true,
                                    )));
                      }, null);
                    },
                    title: tr('Refresh data'),
                    assetPath: 'assets/images/refresh.png'),
                RectButton(
                    onTap: () {
                      appDialogQuestion(context, tr('Confirm to logout'), () {
                        prefs.setBool(pkDataLoaded, false);
                        prefs.setString('sessionkey', '');
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false);
                      }, null);
                    },
                    title: tr('Logout'),
                    assetPath: 'assets/images/exit.png'),
              ],
            )),
            Row(children:[Expanded(child: Text(prefs.getString(pkAppVersion)!, textAlign: TextAlign.center))]),
          ],
        );
  }

  @override
  bool showBackButton() {
    return false;
  }

  @override
  String appTitle() {
    return locale().home;
  }
}
