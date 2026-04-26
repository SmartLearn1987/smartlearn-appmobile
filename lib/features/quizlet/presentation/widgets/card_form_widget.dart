import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';

class CardFormWidget extends StatelessWidget {
  final int index;
  final CardFormData data;
  final bool canDelete;
  final ValueChanged<String> onTermChanged;
  final ValueChanged<String> onDefinitionChanged;
  final VoidCallback onDelete;

  const CardFormWidget({
    super.key,
    required this.index,
    required this.data,
    required this.canDelete,
    required this.onTermChanged,
    required this.onDefinitionChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Thẻ ${index + 1}'),
                const Spacer(),
                IconButton(
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Xóa thẻ',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: Key('card_term_$index'),
              initialValue: data.term,
              onChanged: onTermChanged,
              decoration: const InputDecoration(
                labelText: 'Thuật ngữ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: Key('card_definition_$index'),
              initialValue: data.definition,
              onChanged: onDefinitionChanged,
              decoration: const InputDecoration(
                labelText: 'Định nghĩa',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
