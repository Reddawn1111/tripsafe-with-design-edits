import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsafe/app/app.dart';

void main() {
  group('TripSafe Foundation & Navigation Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const TripSafeApp());
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen renders TRIPSAFE brand header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TripSafeApp());
      await tester.pump();
      expect(find.text('TRIPSAFE'), findsWidgets);
    });

    testWidgets('HomeScreen shows Explore Nearby and Plan a Trip action cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TripSafeApp());
      await tester.pump();
      expect(find.text('Explore Nearby'), findsWidgets);
      expect(find.text('Plan a Trip & Budget'), findsWidgets);
      expect(find.text('Active Journey & Dwell Tracker'), findsWidgets);
    });
  });
}
