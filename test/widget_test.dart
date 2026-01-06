import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rainyun_app/main.dart';

void main() {
  testWidgets('Rainyun app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RainyunApp()));
    await tester.pumpAndSettle();

    expect(find.text('我的服务器'), findsOneWidget);
  });
}
