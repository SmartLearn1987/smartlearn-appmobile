import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/presentation/bloc/profile/profile_bloc.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.profileBloc});

  final ProfileBloc profileBloc;

  /// Mở dialog xác nhận xoá tài khoản. Trả về `true` nếu user đã xác nhận
  /// (đã dispatch event), `null`/`false` nếu user huỷ.
  static Future<bool?> show(
    BuildContext context, {
    required ProfileBloc profileBloc,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: profileBloc,
        child: DeleteAccountDialog(profileBloc: profileBloc),
      ),
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  static const List<String> _reasons = [
    'Không còn nhu cầu sử dụng',
    'Tìm được dịch vụ tốt hơn',
    'Vấn đề về quyền riêng tư / bảo mật',
    'Khác',
  ];

  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  bool get _isOther => _selectedReason == 'Khác';

  bool get _canConfirm {
    if (_selectedReason == null) return false;
    if (_isOther && _otherReasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _onConfirm(BuildContext context) {
    if (!_canConfirm) return;
    final reason = _isOther
        ? 'Khác: ${_otherReasonController.text.trim()}'
        : _selectedReason!;
    widget.profileBloc.add(AccountDeleteRequested(reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr is AccountDeleted || curr is ProfileError,
      listener: (dialogContext, state) {
        if (state is AccountDeleted) {
          Navigator.of(dialogContext).pop(true);
        } else if (state is ProfileError) {
          AppToast.error(dialogContext, state.message);
        }
      },
      builder: (context, state) {
        final isDeleting = state is AccountDeleting;
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: AppBorders.shapeSm,
          titlePadding: const EdgeInsets.fromLTRB(
            AppSpacing.mdLg,
            AppSpacing.mdLg,
            AppSpacing.mdLg,
            AppSpacing.sm,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.mdLg,
            0,
            AppSpacing.mdLg,
            AppSpacing.sm,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.mdLg,
            0,
            AppSpacing.mdLg,
            AppSpacing.mdLg,
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColors.destructive,
                ),
              ),
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: Text(
                  'Xác nhận xóa tài khoản',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.smMd),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withValues(alpha: 0.08),
                      borderRadius: AppBorders.borderRadiusSm,
                      border: Border.all(
                        color: AppColors.destructive.withValues(alpha: 0.25),
                        width: AppBorders.widthThin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cảnh báo: Hành động này không thể hoàn tác!',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.destructive,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toàn bộ bài học, flashcard và kết quả của bạn sẽ '
                          'bị xoá vĩnh viễn và không thể khôi phục.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Vui lòng cho biết lý do bạn muốn rời đi:',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RadioGroup<String>(
                    groupValue: _selectedReason,
                    onChanged: (value) {
                      if (isDeleting) return;
                      setState(() => _selectedReason = value);
                    },
                    child: Column(
                      children: [
                        for (final reason in _reasons)
                          RadioListTile<String>(
                            value: reason,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -2,
                            ),
                            activeColor: AppColors.primary,
                            title: Text(
                              reason,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_isOther) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _otherReasonController,
                      enabled: !isDeleting,
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Vui lòng cho chúng tôi biết lý do…',
                        border: OutlineInputBorder(
                          borderRadius: AppBorders.borderRadiusSm,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                'Quay lại',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (!_canConfirm || isDeleting)
                  ? null
                  : () => _onConfirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: AppColors.destructiveForeground,
                disabledBackgroundColor:
                    AppColors.destructive.withValues(alpha: 0.4),
                shape: AppBorders.shapeSm,
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.destructiveForeground,
                        ),
                      ),
                    )
                  : Text(
                      'Xác nhận xóa vĩnh viễn',
                      style: AppTypography.buttonMedium.copyWith(
                        color: AppColors.destructiveForeground,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
