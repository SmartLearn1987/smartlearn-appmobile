enum EducationLevel {
  primary,
  secondary,
  highSchool,
  university,
  other;

  int get sortOrder => switch (this) {
        EducationLevel.primary => 0,
        EducationLevel.secondary => 1,
        EducationLevel.highSchool => 2,
        EducationLevel.university => 3,
        EducationLevel.other => 4,
      };

  String get displayLabel => switch (this) {
        EducationLevel.primary => '🏫 Tiểu học',
        EducationLevel.secondary => '🏫 Trung học cơ sở',
        EducationLevel.highSchool => '🏫 Trung học Phổ Thông',
        EducationLevel.university => '🎓 Đại Học / Cao Đẳng',
        EducationLevel.other => '✨ Khác',
      };

  String get emoji => switch (this) {
        EducationLevel.primary => '🏫',
        EducationLevel.secondary => '🏫',
        EducationLevel.highSchool => '🏫',
        EducationLevel.university => '🎓',
        EducationLevel.other => '✨',
      };

  String toApiValue() => switch (this) {
        EducationLevel.primary => 'primary',
        EducationLevel.secondary => 'secondary',
        EducationLevel.highSchool => 'high_school',
        EducationLevel.university => 'university',
        EducationLevel.other => 'other',
      };

  static EducationLevel? fromApiValue(String? value) => switch (value) {
        'primary' => EducationLevel.primary,
        'secondary' => EducationLevel.secondary,
        'high_school' => EducationLevel.highSchool,
        'university' => EducationLevel.university,
        'other' => EducationLevel.other,
        _ => null,
      };
}
