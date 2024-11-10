part of 'screen.dart';

extension MiuraAppExt on MiuraApp {
  void _dissmissDialogs() {
    BlocProvider.of<HttpBloc>(prefs.context()).add(HttpEvent('', {}));
  }

  AppLocalizations locale() {
    return AppLocalizations.of(prefs.context())!;
  }

  void httpQuery(HttpEvent e) {
    BlocProvider.of<HttpBloc>(prefs.context()).add(e);
  }
}