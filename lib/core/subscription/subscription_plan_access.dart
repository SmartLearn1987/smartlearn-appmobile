import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';

/// Giống [Index.tsx]: chỉ khóa với role `user` / `teacher` khi có [UserEntity.planEndDate]
/// và thời điểm hiện tại đã sau ngày hết hạn.
bool isBlockedByExpiredSubscriptionPlan(UserEntity user) {
  final role = user.role;
  if (role != 'user' && role != 'teacher') return false;
  final end = user.planEndDate;
  if (end == null) return false;
  return DateTime.now().isAfter(end);
}
