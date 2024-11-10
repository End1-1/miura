import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/screens/login/login_screen.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:cafe5_shop_mobile_client/widgets/text_form.dart';
import 'package:flutter/material.dart';

part 'server_list.part.dart';

class ServerList extends MiuraApp {
  final _serverController = TextEditingController();

  ServerList({super.key}) {
    _serverController.text = prefs.string(pkServerAddress);
  }

  @override
  Widget body(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowSpace(),
        Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Expanded(
              child: MiuraTextFormField(
                  controller: _serverController,
                  hintText: locale().serverAddress))
        ]),
        rowSpace(),
        Row(children: [
          OutlinedButton(
              onPressed: _save,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(2),
              ),
              child: Text(
                locale().save,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ))
        ]),
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedBox(width: 100, child: OutlinedButton(
            onPressed: _setDemoAddress,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(2),
            ),
            child: Text(
              'DEMO',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )))]),
        rowSpace(),
        rowSpace()
      ],
    );
  }

  @override
  String appTitle() {
    return locale().servers;
  }
}
