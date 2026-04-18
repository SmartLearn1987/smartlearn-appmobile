import 'package:collection/collection.dart';
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
        children: subjects
            .mapIndexed(
              (index, subject) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < subjects.length - 1 ? AppSpacing.smMd : 0,
                ),
                child: SubjectCardWidget(subjectWithCount: subject),
              ),
            )
            .toList(),
      ),
    );
  }
}
