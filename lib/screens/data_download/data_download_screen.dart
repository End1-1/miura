import 'dart:convert';
import 'dart:io';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/home/home_screen.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DataDownloadScreen extends MiuraApp {
  final bool pop;

  DataDownloadScreen({super.key, required this.pop}) {
    httpQuery(HttpEvent('hqdownloaddata.php', {}));
  }

  @override
  Widget body(BuildContext context) {
    return BlocConsumer<HttpBloc, HttpState>(listener: (context, state) async {
      if (state.errorCode == hrOk) {
        String s = jsonEncode(state.data);
        Hive.init((await path_provider.getApplicationDocumentsDirectory()).path);
        final box = await Hive.openBox('data');
        box.put('data', s);
        await Lists.load();
        prefs.setBool(pkDataLoaded, true);
        if (pop) {
          Navigator.pop(prefs.context());
        } else {
          Navigator.pushAndRemoveUntil(
              prefs.context(),
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false);
        }
      }
    }, builder: (builder, state) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [button(() {
              httpQuery(HttpEvent('hqdownloaddata.php', {}));
            }, locale().retry)])

          ]);
     });
  }

  @override
  String appTitle() {
    return locale().dataDownload;
  }

  @override
  bool showBackButton() {
    return false;
  }
}
