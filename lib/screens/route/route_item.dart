import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_item.freezed.dart';
part 'route_item.g.dart';

@freezed
class RouteItem with _$RouteItem {
  const factory RouteItem(
      {required int partnerid,
      required String partnername,
      required String address,
      required int orders,
      required String action}) = _RouteItem;

  factory RouteItem.fromJson(Map<String, Object?> json) =>
      _$RouteItemFromJson(json);
}
