String? validateCurriculumName(String name) {
  if (name.trim().isEmpty) {
    return 'Vui lòng nhập tên giáo trình';
  }
  return null;
}
