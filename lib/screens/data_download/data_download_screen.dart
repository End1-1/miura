import 'dart:convert';
import 'dart:io';

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/models/lists.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/home/home_screen.dart';
import 'package:cafe5_shop_mobile_client/utils/dir.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataDownloadScreen extends MiuraApp {
  final bool pop;

  DataDownloadScreen({super.key, required this.pop});

  @override
  Widget body(BuildContext context) {
    return BlocListener<HttpBloc, HttpState>(
        listener: (context, state) async {
          if (state.errorCode == 200) {
            String s = jsonEncode(state.data);
            final dir = await Dir.appPath();
            await Directory(dir).create(recursive: true);
            File file = File(await Dir.dataFile());
            await file.writeAsString(s);
            await Lists.load();
            prefs.setBool(pkDataLoaded, true);
            if (pop) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false);
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                height: 36, width: 36, child: CircularProgressIndicator()),
            const Divider(height: 20, color: Colors.indigo),
            Text(tr('Downloading data...'))
          ],
        ));
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
