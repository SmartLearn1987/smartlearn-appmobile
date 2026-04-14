import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/curriculum_entity.dart';
import '../../domain/usecases/get_curricula_by_subject_use_case.dart';
import '../bloc/curriculum_form/curriculum_form_bloc.dart';
import '../widgets/config_step_form.dart';
import '../widgets/preview_step_content.dart';
import '../widgets/step_indicator.dart';

class EditCurriculumPage extends StatelessWidget {
  const EditCurriculumPage({
    required this.subjectId,
    required this.curriculumId,
    super.key,
  });

  final String subjectId;
  final String curriculumId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurriculumFormBloc>(
      create: (_) => getIt<CurriculumFormBloc>(),
      child: _EditCurriculumView(
        subjectId: subjectId,
        curriculumId: curriculumId,
      ),
    );
  }
}

class _EditCurriculumView extends StatefulWidget {
  const _EditCurriculumView({
    required this.subjectId,
    required this.curriculumId,
  });

  final String subjectId;
  final String curriculumId;

  @override
  State<_EditCurriculumView> createState() => _EditCurriculumViewState();
}

class _EditCurriculumViewState extends State<_EditCurriculumView> {
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCurriculum();
  }

  Future<void> _loadCurriculum() async {
    final useCase = getIt<GetCurriculaBySubjectUseCase>();
    final result = await useCase(widget.subjectId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _loadError = failure.message;
        });
      },
      (curricula) {
        final curriculum = curricula.cast<CurriculumEntity?>().firstWhere(
              (c) => c!.id == widget.curriculumId,
              orElse: () => null,
            );

        if (curriculum != null) {
          context.read<CurriculumFormBloc>().add(
                CurriculumFormInitialized(curriculum: curriculum),
              );
        } else {
          _loadError = 'Không tìm thấy giáo trình';
        }

        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<CurriculumFormBloc, CurriculumFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          AppToast.success(context, 'Đã cập nhật giáo trình thành công');
          context.pop();
        } else if (state.errorMessage != null && state.step == 1) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<CurriculumFormBloc, CurriculumFormState>(
                  buildWhen: (prev, curr) => prev.step != curr.step,
                  builder: (context, state) =>
                      StepIndicator(currentStep: state.step),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocBuilder<CurriculumFormBloc, CurriculumFormState>(
                    buildWhen: (prev, curr) => prev.step != curr.step,
                    builder: (context, state) => state.step == 0
                        ? ConfigStepForm(
                            onCancel: () => context.pop(),
                          )
                        : PreviewStepContent(subjectId: widget.subjectId),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📚', style: TextStyle(fontSize: 32)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Chỉnh sửa giáo trình',
          style: AppTypography.h3.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
