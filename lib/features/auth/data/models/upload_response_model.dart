/// Response của `POST /upload`: `{ "url": "/uploads/..." }`.
class UploadResponseModel {
  const UploadResponseModel({required this.url});

  final String url;

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['url'];
    if (raw is! String) {
      throw const FormatException('Upload response missing string "url"');
    }
    return UploadResponseModel(url: raw);
  }
}
