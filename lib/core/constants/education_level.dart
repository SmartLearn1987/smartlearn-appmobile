enum EducationLevel {
  primary,
  secondary,
  highSchool,
  university,
  certification;

  int get sortOrder => switch (this) {
    EducationLevel.primary => 0,
    EducationLevel.secondary => 1,
    EducationLevel.highSchool => 2,
    EducationLevel.university => 3,
    EducationLevel.certification => 4,
  };

  String get displayLabel => switch (this) {
    EducationLevel.primary => '🏫 Tiểu học',
    EducationLevel.secondary => '🏫 Trung học cơ sở',
    EducationLevel.highSchool => '🏫 Trung học Phổ Thông',
    EducationLevel.university => '🎓 Đại Học / Cao Đẳng',
    EducationLevel.certification => '📝 Luyện thi chứng chỉ',
  };

  /// Label không có emoji — dùng chung cho form đăng ký và các nơi khác.
  String get label => switch (this) {
    EducationLevel.primary => 'Tiểu học',
    EducationLevel.secondary => 'Trung học cơ sở',
    EducationLevel.highSchool => 'Trung học phổ thông',
    EducationLevel.university => 'Đại học/Cao đẳng',
    EducationLevel.certification => 'Luyện thi chứng chỉ',
  };

  String get emoji => switch (this) {
    EducationLevel.primary => '🏫',
    EducationLevel.secondary => '🏫',
    EducationLevel.highSchool => '🏫',
    EducationLevel.university => '🎓',
    EducationLevel.certification => '📝',
  };

  String toApiValue() => switch (this) {
    EducationLevel.primary => 'primary',
    EducationLevel.secondary => 'secondary',
    EducationLevel.highSchool => 'high_school',
    EducationLevel.university => 'university',
    EducationLevel.certification => 'certification',
  };

  static EducationLevel? fromApiValue(String? value) => switch (value) {
    'primary' => EducationLevel.primary,
    'secondary' => EducationLevel.secondary,
    'high_school' => EducationLevel.highSchool,
    'university' => EducationLevel.university,
    'certification' => EducationLevel.certification,
    _ => null,
  };
}
