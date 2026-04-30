import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_cached_image.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/domain/usecases/upload_file_usecase.dart';
import 'package:smart_learn/features/home/presentation/bloc/profile/profile_bloc.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({
    super.key,
    required this.user,
    required this.profileBloc,
  });

  final UserEntity user;
  final ProfileBloc profileBloc;

  static void show(
    BuildContext context,
    UserEntity user,
    ProfileBloc profileBloc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => EditProfileBottomSheet(
        user: user,
        profileBloc: profileBloc,
      ),
    );
  }

  @override
  State<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  String? _newAvatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên hiển thị không được để trống';
    }
    return null;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final uploadFileUseCase = getIt<UploadFileUseCase>();
    final result = await uploadFileUseCase(File(pickedFile.path));

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isUploading = false);
        AppToast.error(context, 'Upload thất bại: ${failure.message}');
      },
      (url) {
        setState(() {
          _newAvatarUrl = url;
          _isUploading = false;
        });
      },
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final displayName = _displayNameController.text.trim();
    widget.profileBloc.add(
      UpdateProfile(
        displayName: displayName,
        avatarUrl: _newAvatarUrl ?? widget.user.avatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            AppToast.error(context, state.message);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.mdLg,
              AppSpacing.sm,
              AppSpacing.mdLg,
              AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Drag handle ───
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppBorders.borderRadiusFull,
                      ),
                    ),
                  ),
                  Text(
                    'Thông tin cá nhân',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ─── Avatar section ───
                  Center(child: _buildAvatarSection()),
                  const SizedBox(height: AppSpacing.lg),
                  // ─── Display name field ───
                  Text(
                    'Tên hiển thị',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _displayNameController,
                    validator: _validateDisplayName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hiển thị',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smMd,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ─── Save button ───
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        final isUpdating = state is ProfileUpdating;
                        return ElevatedButton(
                          onPressed: isUpdating ? null : _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                            shape: AppBorders.shapeSm,
                            textStyle: AppTypography.buttonLarge,
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Lưu'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            _buildAvatarImage(),
            if (_isUploading)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: Text(
            'Thay đổi',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    final avatarUrl = _newAvatarUrl ?? widget.user.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AppCachedImage(
        imageUrl: avatarUrl,
        width: 80,
        height: 80,
        shape: BoxShape.circle,
        errorWidget: _buildInitialAvatar(),
      );
    }
    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.user.displayName.isNotEmpty
            ? widget.user.displayName[0].toUpperCase()
            : 'U',
        style: AppTypography.h2.copyWith(
          color: AppColors.primaryForeground,
        ),
      ),
    );
  }
}
