import 'package:flutter/material.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/domain/usecases/get_all_subjects.dart';
import 'package:smart_learn/features/home/domain/usecases/save_user_subjects.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/subjects/presentation/bloc/subjects_list/subjects_list_bloc.dart';

class SubjectSelectionModal extends StatefulWidget {
  const SubjectSelectionModal({
    super.key,
    this.initialSelectedIds = const [],
  });

  /// Shows the subject selection bottom sheet.
  ///
  /// Returns `true` if subjects were saved successfully, `null` otherwise.
  /// [currentSubjectIds] — IDs of subjects already selected by the user
  /// (extracted from [HomeLoaded.subjects]).
  static Future<bool?> show(
    BuildContext context, {
    List<String> currentSubjectIds = const [],
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SubjectSelectionModal(initialSelectedIds: currentSubjectIds),
    );
  }

  final List<String> initialSelectedIds;

  @override
  State<SubjectSelectionModal> createState() => _SubjectSelectionModalState();
}

class _SubjectSelectionModalState extends State<SubjectSelectionModal> {
  List<SubjectEntity> _allSubjects = [];
  Set<String> _selectedIds = {};
  bool _isLoadingSubjects = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedIds.toSet();
    _fetchAllSubjects();
  }

  Future<void> _fetchAllSubjects() async {
    setState(() {
      _isLoadingSubjects = true;
      _loadError = null;
    });

    final useCase = getIt<GetAllSubjectsUseCase>();
    final result = await useCase(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingSubjects = false;
          _loadError = failure.message;
        });
      },
      (subjects) {
        setState(() {
          _isLoadingSubjects = false;
          _allSubjects = subjects;
        });
      },
    );
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final useCase = getIt<SaveUserSubjectsUseCase>();
    final result = await useCase(
      SaveUserSubjectsParams(subjectIds: _selectedIds.toList()),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        AppToast.error(context, failure.message);
      },
      (_) {
        // Refresh both blocs (singletons, always available).
        getIt<HomeBloc>().add(const HomeRefreshSubjects());
        getIt<SubjectsListBloc>().add(const SubjectsListRefreshRequested());
        Navigator.of(context).pop(true);
      },
    );
  }

  void _toggleSubject(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusXxl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.sm,
        AppSpacing.mdLg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          // Title
          Text(
            'Thiết lập môn học',
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Chọn các môn học bạn muốn hiển thị trên trang chủ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Content
          Flexible(child: _buildContent()),
          const SizedBox(height: AppSpacing.md),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isSaving || _isLoadingSubjects || _loadError != null)
                  ? null
                  : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeMd,
                textStyle: AppTypography.buttonLarge,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingSubjects) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.destructive,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _fetchAllSubjects,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allSubjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Không có môn học nào trong hệ thống',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _allSubjects.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final subject = _allSubjects[index];
        final isSelected = _selectedIds.contains(subject.id);

        return _buildSubjectTile(subject, isSelected);
      },
    );
  }

  Widget _buildSubjectTile(SubjectEntity subject, bool isSelected) {
    return InkWell(
      onTap: () => _toggleSubject(subject.id),
      borderRadius: AppBorders.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.smMd,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Subject icon
            if (subject.icon != null && subject.icon!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.smMd),
                child: Text(
                  subject.icon!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            // Subject name
            Expanded(
              child: Text(
                subject.name,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: AppBorders.widthMedium,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
