import 'package:json_annotation/json_annotation.dart';

part 'upload_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UploadResponseModel {
  final String url;

  const UploadResponseModel({required this.url});

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseModelToJson(this);
}
