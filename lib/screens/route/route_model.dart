
part of 'route_screen.dart';



class RouteModel {
  final List<RouteItem> route = [];
  late DateTime date;
  final dateStream = StreamController<String>();

  RouteModel() {
    date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);
  }

  void previousDate() {
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    date = date.add(const Duration(days: -1));
    dateStream.add(DateFormat('dd/MM/yyyy').format(date));
  }

  void nextDate() {
    date = date.add(const Duration(days: 1));
    dateStream.add(DateFormat('dd/MM/yyyy').format(date));
  }
}

extension RouteScreenExt on RouteScreen{
  void refresh(int driver) {
    httpQuery(HttpEvent('hqroute.php', {
      pkDate: DateFormat('dd/MM/yyyy').format(model.date),
      pkDriver: driver
    }));
  }
}
