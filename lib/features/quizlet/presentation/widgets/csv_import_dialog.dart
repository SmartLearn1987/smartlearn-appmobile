import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';

class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog({super.key});

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  final TextEditingController _csvController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _onImportNow() {
    final cards = parseCsvToCards(_csvController.text);
    if (cards.isEmpty) {
      setState(() {
        _errorText = 'Không tìm thấy dữ liệu hợp lệ để nhập';
      });
      return;
    }

    Navigator.of(context).pop(_csvController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập danh sách từ CSV'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mỗi dòng là một thẻ, thuật ngữ và định nghĩa cách nhau bằng dấu phẩy (,)',
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Ví dụ: Hello, xin chào',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('csv_import_textarea'),
              controller: _csvController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Hello, xin chào',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _onImportNow, child: const Text('Nhập ngay')),
      ],
    );
  }
}
