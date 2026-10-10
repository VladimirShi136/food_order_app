import 'package:flutter_test/flutter_test.dart';
import 'package:gari_grill_admin/main.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  testWidgets('shows staff sign-in screen', (tester) async {
    await tester.pumpWidget(
      GariGrillAdminApp(client: PocketBase('http://127.0.0.1:8090')),
    );

    expect(find.text('Gari Grill'), findsOneWidget);
    expect(find.text('Панель управления заказами'), findsOneWidget);
    expect(find.text('Почта сотрудника'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });
}
