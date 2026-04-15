# Smart Learn

Ứng dụng mobile học tập thông minh dành cho học sinh Việt Nam, xây dựng bằng Flutter theo kiến trúc Clean Architecture.

## Tính năng

- **Xác thực** — Đăng nhập, đăng ký, quên mật khẩu (token-based authentication)
- **Trang chủ** — Dashboard tổng quan, hồ sơ cá nhân, trắc nghiệm nhanh
- **Môn học** — Duyệt môn học, khóa học, chương trình giảng dạy (CRUD)
- **Thời gian biểu** — Quản lý thời khóa biểu, nhiệm vụ và ghi chú (lưu trữ cục bộ)
  - Thời khóa biểu: nhóm lịch học, phân chia buổi sáng/chiều theo ngày
  - Nhiệm vụ: lọc theo trạng thái, nhóm theo tháng, thanh tiến độ
  - Ghi chú: lưới 2 cột, 12 màu sắc, chỉnh sửa inline

## Tech Stack

| Thành phần | Thư viện |
|---|---|
| Ngôn ngữ | Dart (SDK ^3.11.4) |
| Framework | Flutter |
| State Management | flutter_bloc (Cubit / Bloc) |
| Navigation | go_router |
| Networking | retrofit + dio |
| DI | get_it + injectable |
| Serialization | json_serializable + json_annotation |
| Local Storage | shared_preferences, flutter_secure_storage |
| FP | dartz (Either) |
| Testing | glados (PBT), mocktail, bloc_test |

## Kiến trúc

Feature-based Clean Architecture:

```
lib/
├── app/              # MaterialApp, DI setup
├── core/             # Theme, error, network, storage, widgets dùng chung
├── features/
│   ├── auth/         # Xác thực
│   ├── home/         # Trang chủ, hồ sơ, trắc nghiệm
│   ├── subjects/     # Môn học, khóa học
│   └── schedule/     # Thời gian biểu (timetable, tasks, notes)
├── router/           # GoRouter config
└── main.dart
```

Mỗi feature theo cấu trúc:

```
feature/
├── data/             # Models, datasources, repository impl
├── domain/           # Entities, repository contracts, validators
└── presentation/     # Cubits/Blocs, pages, widgets, helpers
```

## Bắt đầu

```bash
# Cài đặt dependencies
flutter pub get

# Chạy code generation (injectable, retrofit, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Chạy ứng dụng
flutter run

# Chạy tests
flutter test

# Phân tích code
flutter analyze
```

## License

Private — không phân phối công khai.
