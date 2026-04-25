import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/csv_import_dialog.dart';

void main() {
  testWidgets('CsvImportDialog renders instructions and actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CsvImportDialog(),
        ),
      ),
    );

    expect(find.text('Mỗi dòng là một thẻ, thuật ngữ và định nghĩa cách nhau bằng dấu phẩy (,)'),
        findsOneWidget);
    expect(find.text('Ví dụ: Hello, xin chào'), findsOneWidget);
    expect(find.text('Nhập ngay'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.byKey(const Key('csv_import_textarea')), findsOneWidget);
  });

  testWidgets('CsvImportDialog shows validation for invalid csv', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CsvImportDialog(),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('csv_import_textarea')), 'invalid line');
    await tester.tap(find.text('Nhập ngay'));
    await tester.pump();

    expect(find.text('Không tìm thấy dữ liệu hợp lệ để nhập'), findsOneWidget);
  });
}
