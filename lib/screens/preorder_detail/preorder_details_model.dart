import 'package:freezed_annotation/freezed_annotation.dart';

part 'preorder_details_model.freezed.dart';

part 'preorder_details_model.g.dart';

@freezed
class PreorderDetails with _$PreorderDetails {
  const factory PreorderDetails(
      {required String groupname,
      required String goodsname,
      required double qty,
      required double price}) = _PreorderDetails;

  factory PreorderDetails.fromJson(Map<String, Object?> json) =>
      _$PreorderDetailsFromJson(json);
}

class PreordersDetailsModel {
  final List<PreorderDetails> data = [];


}
