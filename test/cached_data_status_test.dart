import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/widgets/cached_data_status.dart';

void main() {
  testWidgets('shows offline status and refresh action', (tester) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CachedDataStatus(
            isOffline: true,
            isStale: true,
            onRefresh: () => refreshCount++,
          ),
        ),
      ),
    );

    expect(find.text('Нет сети'), findsOneWidget);
    expect(find.text('Кеш устарел'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('network-status'))).height,
      tester.getSize(find.byKey(const ValueKey('cache-status'))).height,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('network-status'))).dy,
      tester.getTopLeft(find.byKey(const ValueKey('cache-status'))).dy,
    );

    await tester.tap(find.byTooltip('Обновить'));
    expect(refreshCount, 1);
  });

  testWidgets('uses neutral status when server is unreachable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CachedDataStatus(isOffline: false, isStale: false),
        ),
      ),
    );

    expect(find.text('Нет связи'), findsOneWidget);
    expect(find.text('Данные из кеша'), findsOneWidget);
  });
}
