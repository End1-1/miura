import 'package:cafe5_shop_mobile_client/utils/translator.dart';
import 'package:intl/intl.dart';

const mdPriceRetail = 1;
const mdPriceWhosale = 2;
final mdDoubleFormatter = NumberFormat.decimalPattern('en_us');

String mdFormatDouble(double? value) {
  return value == null ? '0' : mdDoubleFormatter.format(value).replaceAll(RegExp('r(?!\d[\.\,][1-9]+)0+\$'), '').replaceAll('[\.\,]\$', '');
}

String saleTypeName(int politic) {
  switch (politic) {
    case mdPriceRetail:
      return tr('Retail sale');
    case mdPriceWhosale:
      return tr('Whosale sale');
    default:
      return tr('Unknown sale');
  }
}