part of 'screen.dart';

extension SalesHistoryExt on SalesHistoryScreen {
  void _refresh() {
    httpQuery(HttpEvent('hqsales.php', {
      pkDate1: DateFormat("dd/MM/yyyy").format(date1),
      pkDate2 : DateFormat("dd/MM/yyyy").format(date1)
    }));
  }

DateTime previousDate(DateTime d) {
  d = d.add(const Duration(days: -1));
  dateStream.add(DateFormat('dd/MM/yyyy').format(d));
  return d;
}

DateTime nextDate(DateTime d) {
  d = d.add(const Duration(days: 1));
  dateStream.add(DateFormat('dd/MM/yyyy').format(d));
  return d;
}
}