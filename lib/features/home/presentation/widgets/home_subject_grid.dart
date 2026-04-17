import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/features/subjects/presentation/widgets/subject_card_widget.dart';
import 'package:smart_learn/features/subjects/presentation/models/subject_with_count.dart';

class HomeSubjectGrid extends StatelessWidget {
  const HomeSubjectGrid({required this.subjects, super.key});

  final List<SubjectWithCount> subjects;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          for (int i = 0; i < subjects.length; i += 2)
            Padding(
              padding: EdgeInsets.only(
                bottom: i + 2 < subjects.length ? AppSpacing.sm : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SubjectCardWidget(subjectWithCount: subjects[i]),
                  ),
                  const SizedBox(width: AppSpacing.smMd),
                  if (i + 1 < subjects.length)
                    Expanded(
                      child: SubjectCardWidget(
                        subjectWithCount: subjects[i + 1],
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
