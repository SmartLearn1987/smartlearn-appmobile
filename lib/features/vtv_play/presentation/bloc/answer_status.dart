/// Trạng thái câu trả lời của mỗi câu hỏi trong trò chơi Vua Tiếng Việt.
enum AnswerStatus {
  /// Chưa nhập gì
  unanswered,

  /// Đã nhập nhưng chưa kiểm tra
  answered,

  /// Đã kiểm tra — đúng
  checkedCorrect,

  /// Đã kiểm tra — sai
  checkedIncorrect,
}
