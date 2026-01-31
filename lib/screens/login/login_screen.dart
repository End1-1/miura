import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/data_download/data_download_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/home/home_screen.dart';
import 'package:cafe5_shop_mobile_client/screens/login/pin_form.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends MiuraApp {
  LoginScreen({super.key}) {
    if ((prefs.getString('sessionkey') ?? '').isNotEmpty) {
      BlocProvider.of<HttpBloc>(prefs.context()).add(
          HttpEvent('login.php', {'method':3}));
    }
  }

  @override
  Widget body(BuildContext context) {
    return BlocListener<HttpBloc, HttpState>(
      listener: (context, state) {
        if (state.errorCode == hrOk) {
          prefs.setInt(pkDriver, state.data['data']['user']['f_id']);
          prefs.setString(pkLastName, state.data['data']['user']['f_last']);
          prefs.setString(pkFirstName, state.data['data']['user']['f_first']);
          prefs.setString('sessionkey', state.data['data']['sessionkey']);
          if (prefs.getBool(pkDataLoaded) ?? false) {
            Navigator.pushAndRemoveUntil(
                prefs.context(),
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                prefs.context(),
                MaterialPageRoute(
                    builder: (context) => DataDownloadScreen(pop: false)),
                (route) => false);
          }
        }
      },
      child: PinForm(),
    );
  }

  @override
  String appTitle() {
    return locale().signIn;
  }

  @override
  bool showBackButton() {
    return false;
  }
}
