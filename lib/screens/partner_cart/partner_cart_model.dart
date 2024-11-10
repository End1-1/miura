

import 'package:cafe5_shop_mobile_client/models/http_query/http_query.dart';
import 'package:cafe5_shop_mobile_client/utils/data_types.dart' show Partner;

class PartnerCartModel {
  final Partner partner;

  PartnerCartModel({required this.partner}) {
    HttpQuery(route: 'hqhttppartnercart.php', data:{'partnerId': partner.id}).request().then((value) {
      if (value['ok'] == hrOk) {

      }
    });
  }
}