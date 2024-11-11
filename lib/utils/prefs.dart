import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


const pkServerAddress = 'pkServerAddress';
const pkFcmToken = 'pkFcmToken';
const pkPassHash = 'pkPassHash';
const pkFirstName = 'pkFirstName';
const pkLastName = 'pkLastName';
const pkDataLoaded = 'pkDataLoaded';
const pkAction = 'pkAction';
const pkData = 'pkData';
const pkStorageName = 'pkStorageName';
const pkStock = 'pkStock';
const pkGroup = 'pkGroup';
const pkAppVersion = 'pkAppVersion';
const pkDriver = "pkDriver";
const pkExecutor = "pkExecutor";
const pkDate = "pkDate";
const pkRouteDriver = "pkRouteDriver";
const pkSaleDriver = "pkSaleDriver";
const pkPartner = "pkPartner";
const pkDate1 = "pkDate1";
const pkDate2 = "pkDate2";
const pkReportType = "pkReportType";

const rcServerList = 'serverList';

late final SharedPreferences prefs;

const hqRegisterDevice = 1;
const hqLogin = 2;
const hqDownloadData = 3;
const hqCheckPassHash = 4;
const hqStock = 5;
const hqSaveOrder = 6;
const hqPreorders = 7;
const hqPreorderDetails = 8;
const hqDebts = 9;
const hqRoute = 10;
const hqPreorderStock = 11;
const hqOpenOrder = 12;
const hqRemoveOrderRow = 13;
const hqExportToAS = 14;
const hqDriverList = 15;
const hqVisit = 16;
const hqCompleteDelivery = 17;
const hqGoodsPartners = 18;
const hqSales = 19;

const prStorage = 14;

extension Prefs on SharedPreferences {
  static bool isInitialized = false;
  static final navigatorKey = GlobalKey<NavigatorState>();
  String string(String key) {
    return getString(key) ?? '';
  }

  BuildContext context() {
    return navigatorKey.currentContext!;
  }
}