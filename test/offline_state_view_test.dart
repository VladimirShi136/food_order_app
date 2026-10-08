import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/widgets/offline_state_view.dart';

void main() {
  testWidgets('offline state retries when pulled down', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineStateView(
            title: 'Нет связи',
            message: 'Проверьте сеть',
            onRetry: () async {
              retryCount++;
            },
          ),
        ),
      ),
    );

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(retryCount, 1);
  });
}
