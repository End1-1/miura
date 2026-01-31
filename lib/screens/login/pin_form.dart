import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/screens/base/screen.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/translator.dart';

class PinForm extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  PinForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset('assets/logo.png',height: 100)]),
          const SizedBox(height: 10),
          Align(
              child: SizedBox(
                  width: 72 * 3,
                  child: TextFormField(
                    decoration: InputDecoration(hintText: tr("Enter pin code"),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder()),
                    obscureText: true,
                    controller: _pinController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ))),
          Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          squareButton(() {
                            _pinController.text += '7';
                          }, '7'),
                          squareButton(() {
                            _pinController.text += '8';
                          }, '8'),
                          squareButton(() {
                            _pinController.text += '9';
                          }, '9'),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          squareButton(() {
                            _pinController.text += '4';
                          }, '4'),
                          squareButton(() {
                            _pinController.text += '5';
                          }, '5'),
                          squareButton(() {
                            _pinController.text += '6';
                          }, '6'),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          squareButton(() {
                            _pinController.text += '1';
                          }, '1'),
                          squareButton(() {
                            _pinController.text += '2';
                          }, '2'),
                          squareButton(() {
                            _pinController.text += '3';
                          }, '3'),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          squareImageButton(() {
                            if (_pinController.text == '1981') {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => RegisterDeviceScreen()));
                            }
                            BlocProvider.of<HttpBloc>(context).add(
                                HttpEvent('login.php', {'pin': _pinController.text, 'method':2}));
                          }, 'assets/images/user.png', height: 72),
                          squareButton(() {
                            _pinController.text += '0';
                          }, '0'),
                          squareImageButton(() {
                            _pinController.clear();
                          }, 'assets/images/cancel.png', height: 72),
                        ],
                      ))
                ],
              )),

        ]);
  }
}
