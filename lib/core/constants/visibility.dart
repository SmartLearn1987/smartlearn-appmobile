enum VisibilityMode {
  public,
  private;

  String get displayLabel => switch (this) {
        VisibilityMode.public => '🌍 Công khai (Mọi người)',
        VisibilityMode.private => '🔒 Không công khai (Cá nhân)',
      };

  bool get value => switch (this) {
        VisibilityMode.public => true,
        VisibilityMode.private => false,
      };
}