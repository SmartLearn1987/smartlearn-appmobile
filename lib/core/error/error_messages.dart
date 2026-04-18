/// Bảng dịch error message từ API (tiếng Anh → tiếng Việt).
///
/// Thêm message mới vào map bên dưới.
/// Tham khảo danh sách đầy đủ tại: .kiro/steering/api-error-messages.md
const _errorTranslations = <String, String>{
  // ─── Auth ───
  // TODO: Thêm message từ API vào đây
};

/// Dịch error message từ API sang tiếng Việt.
///
/// Tìm exact match trước, nếu không có thì tìm theo contains.
/// Trả về message gốc nếu không tìm thấy bản dịch.
String translateErrorMessage(String message) {
  // Exact match
  final exact = _errorTranslations[message];
  if (exact != null) return exact;

  // Partial match (cho message có chứa giá trị động, ví dụ "User xxx not found")
  for (final entry in _errorTranslations.entries) {
    if (message.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  return message;
}
