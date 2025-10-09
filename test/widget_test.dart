import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polislot/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows PoliSlot text and icon',
      (WidgetTester tester) async {
    // Bungkus SplashScreen dengan MaterialApp biar ada Theme & Navigator
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verifikasi text "PoliSlot" ada
    expect(find.text('PoliSlot'), findsOneWidget);

    // Verifikasi icon ada
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });
}
