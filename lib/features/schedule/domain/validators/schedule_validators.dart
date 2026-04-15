String? validateSubjectName(String name) {
  if (name.trim().isEmpty) {
    return 'Vui lòng nhập tên môn học';
  }
  return null;
}

String? validateTaskTitle(String title) {
  if (title.trim().isEmpty) {
    return 'Vui lòng nhập tiêu đề nhiệm vụ';
  }
  return null;
}

String? validateNoteContent(String title, String content) {
  if (title.trim().isEmpty && content.trim().isEmpty) {
    return 'Vui lòng nhập tiêu đề hoặc nội dung';
  }
  return null;
}
