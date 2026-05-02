import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'contants.dart';

/// Vòng tròn chứa icon, đổi màu theo cấp độ ([LevelConfig]).
///
/// - Nếu [level] khớp với một mục trong [levels] (vd: `easy`, `medium`,
///   `hard`, `extreme`) thì dùng `bg`/`border`/`text` của level đó.
/// - Nếu [level] là `null` hoặc không khớp, fallback về màu `primary`.
class LevelIconCircle extends StatelessWidget {
  const LevelIconCircle({
    required this.icon,
    this.level,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final String? level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cfg = level == null
        ? null
        : levels.firstWhereOrNull((c) => c.value == level);

    final bg = cfg?.bg ?? AppColors.primaryLight;
    final borderColor =
        cfg?.border ?? AppColors.primary.withValues(alpha: 0.2);
    final fg = cfg?.text ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: fg),
    );
  }
}
