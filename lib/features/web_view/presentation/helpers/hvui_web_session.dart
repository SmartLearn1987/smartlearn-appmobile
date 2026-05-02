import 'dart:convert';

import 'package:smart_learn/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';

/// Khớp Smart Learn Web: lib auth (SESSION_KEY) và apiFetch (sessionToken, refreshToken…).
const hvuiSessionStorageKey = 'hvui-session-v1';

/// Khớp Smart Learn Web AuthContext (hvui-last-activity).
const hvuiLastActivityStorageKey = 'hvui-last-activity';

Future<Map<String, dynamic>?> buildHvuiSessionPayload({
  required UserEntity user,
  required AuthLocalDatasource local,
}) async {
  final sessionToken = await local.getSessionToken();
  if (sessionToken == null || sessionToken.isEmpty) return null;

  final refreshToken = await local.getRefreshToken();
  final expiresAt = await local.getAccessTokenExpiresAt();

  return <String, dynamic>{
    'id': user.id,
    'username': user.username,
    'email': user.email,
    'displayName': user.displayName,
    'role': user.role,
    'isActive': user.isActive,
    if (user.educationLevel != null) 'educationLevel': user.educationLevel,
    if (user.plan != null) 'plan': user.plan,
    if (user.planStartDate != null)
      'planStartDate': user.planStartDate!.toUtc().toIso8601String(),
    if (user.planEndDate != null)
      'planEndDate': user.planEndDate!.toUtc().toIso8601String(),
    if (user.avatarUrl != null) 'avatarUrl': user.avatarUrl,
    'createdAt': user.createdAt.toUtc().toIso8601String(),
    'sessionToken': sessionToken,
    if (refreshToken != null && refreshToken.isNotEmpty)
      'refreshToken': refreshToken,
    if (expiresAt != null && expiresAt.isNotEmpty)
      'accessTokenExpiresAt': expiresAt,
  };
}

/// Ghi session + activity trước khi bundle React chạy (AT_DOCUMENT_START).
///
/// [sessionStorage.setItem] chỉ nhận **string**. Không được truyền object (kể cả từ
/// `JSON.parse` của JSON user) — nếu không trình duyệt ép thành `"[object Object]"`.
/// Dùng [jsonEncode] của chuỗi JSON đã có để sinh literal hợp lệ trong JS.
String buildHvuiSessionInjectUserScript(Map<String, dynamic> payload) {
  final innerJson = jsonEncode(payload);
  final jsStringLiteral = jsonEncode(innerJson);
  return '''
(function(){try{
  sessionStorage.setItem('$hvuiSessionStorageKey', $jsStringLiteral);
  sessionStorage.setItem('$hvuiLastActivityStorageKey', String(Date.now()));
}catch(_){}})();
''';
}
