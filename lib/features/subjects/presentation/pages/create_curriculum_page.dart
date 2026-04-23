import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../bloc/curriculum_form/curriculum_form_bloc.dart';
import '../bloc/subject_detail/subject_detail_bloc.dart';
import '../widgets/config_step_form.dart';
import '../widgets/preview_step_content.dart';
import '../widgets/step_indicator.dart';

class CreateCurriculumPage extends StatelessWidget {
  const CreateCurriculumPage({
    required this.subjectId,
    this.subjectName,
    super.key,
  });

  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurriculumFormBloc>(
      create: (_) => getIt<CurriculumFormBloc>(),
      child: _CreateCurriculumView(
        subjectId: subjectId,
        subjectName: subjectName,
      ),
    );
  }
}

class _CreateCurriculumView extends StatelessWidget {
  const _CreateCurriculumView({required this.subjectId, this.subjectName});

  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurriculumFormBloc, CurriculumFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          AppToast.success(context, 'Đã tạo giáo trình mới thành công');
          // Refresh SubjectDetailBloc so the list updates on pop.
          getIt<SubjectDetailBloc>().add(const SubjectDetailRefreshRequested());
          context.pop();
        } else if (state.errorMessage != null && state.step == 1) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _AppBarTitle(subjectName: subjectName),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        ? ConfigStepForm(onCancel: () => context.pop())
                        : PreviewStepContent(subjectId: subjectId),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarTitle({required this.subjectName});

  final String? subjectName;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: Column(
        children: [
          Text(
            'Tạo giáo trình mới',
            style: AppTypography.h3.copyWith(color: AppColors.foreground),
          ),
          Text(
            'Môn học: $subjectName',
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
