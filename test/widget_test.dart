// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CryptoWalletApp(),
      ),
    );

    // Verify that the app loads (we should see login or home screen)
    await tester.pump();

    // The app should show either login screen or home screen
    // depending on auth state
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
