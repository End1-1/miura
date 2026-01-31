import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/utils/app_theme.dart';
import 'package:cafe5_shop_mobile_client/utils/prefs.dart';
import 'package:cafe5_shop_mobile_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'screen.part.dart';

abstract class MiuraApp extends StatelessWidget {
  const MiuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPop(),
        child: Scaffold(
            backgroundColor: appBgColor,
            appBar: appBar(),
            body: SafeArea(
                minimum: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Stack(
                    children: [body(context), _loading(), _errorWidget()]))));
  }

  Widget body(BuildContext context);

  Widget _loading() {
    return BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {
      if (state.errorCode == hrLoading) {
        return Container(
            color: Colors.black38,
            child: const Center(child: CircularProgressIndicator()));
      } else {
        return Container();
      }
    });
  }

  Widget _errorWidget() {
    return BlocBuilder<HttpBloc, HttpState>(builder: (context, state) {
      if (state.errorCode != hrFail) {
        return Container();
      }
      if (state.errorMessage.contains('Unauthorized')) {
        state.errorMessage = locale().accessDenied;
      }
      return Container(
          color: Colors.black38,
          child: Center(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                      maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                      minWidth: MediaQuery.sizeOf(context).width * 0.8),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              decoration:
                                  const BoxDecoration(color: Colors.indigo),
                              child: Text(prefs.string('appname'),
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center)))
                    ]),
                    Container(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                        child: SingleChildScrollView(
                            child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Text(state.errorMessage,
                                    textAlign: TextAlign.center)))),
                    rowSpace(),
                    Row(children: [
                      Expanded(
                          child: Container(
                              margin: const EdgeInsets.all(10),
                              child: ElevatedButton(
                                  onPressed: _dissmissDialogs,
                                  style: elevatedButtonStyle,
                                  child: Text(locale().close))))
                    ])
                  ]))));
    });
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(prefs.context()).padding.top),
            child:  Row(children: [
          showBackButton()
              ?
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      InkWell(
                          onTap: () {
                            if (onBackTap() == null) {
                              Navigator.pop(prefs.context());
                            } else {
                              onBackTap()!(prefs.context());
                            }
                          },
                          child: SizedBox(
                              height: 30,
                              width: 30,
                              child: Image.asset('assets/images/back.png'))),
                      const SizedBox(width: 10)
                    ])
              : Container(),
          Expanded(
              child: Text(appTitle(),
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)))
        ])));
  }

  String appTitle();

  List<Widget> headerWidgets() {
    return [];
  }

  bool canPop() {
    return true;
  }

  bool showBackButton() {
    return true;
  }

  Function(BuildContext)? onBackTap() {
    return null;
  }

  Widget rowSpace() {
    return const SizedBox(height: 10);
  }
}
