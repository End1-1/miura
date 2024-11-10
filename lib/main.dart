import 'dart:io';

import 'package:cafe5_shop_mobile_client/local_notification_service.dart';
import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/screens/register_device/server_list.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  Intl.defaultLocale = 'en_US';
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('en_US', null);
  prefs = await SharedPreferences.getInstance();
  await LocalNotificationService().setup();
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    prefs.setString(pkAppVersion, '$version.$buildNumber');
  });
  runApp( MultiBlocProvider(providers: [
    BlocProvider<HttpBloc>(create: (_) => HttpBloc(HttpState(false, {})))
  ],
    child: const MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Prefs.navigatorKey,
      title: 'Miura',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('hy'),
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder(
          future: _initApp(),
          builder: (builder, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return _logo();
              case ConnectionState.done:
                return Builder(builder: (builder)  { return _firstScreen();});
            }

          }));
  }
  Future<Object?> _initApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (prefs.string(pkServerAddress).isEmpty) {
      return true;
    }
  }

  Widget _logo() {
    return Container(color: Colors.white, child: Center(
        child: SizedBox(
            height: 200,
            width: 200,
            child: Image.asset('assets/logo.png'))));
  }

  Widget _firstScreen() {
    if (prefs.string(pkServerAddress).isEmpty) {
      return ServerList();
    }
    return Container();
  }
}
