import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_at_home_mobile/widgets/bottom_nav_bar.dart';

void main() {
  group('AppBottomNavBar Widget Tests', () {
    testWidgets('Bottom nav bar displays all 4 items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      // Vérifie que les 4 labels sont présents
      expect(find.text('Tableau'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Tâches'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('Dashboard icon is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('Calendar icon is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 1),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Tasks icon is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 2),
          ),
        ),
      );

      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('Chat icon is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 3),
          ),
        ),
      );

      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });

    testWidgets('Current index 0 shows dashboard as active', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(0));
    });

    testWidgets('Current index 2 shows tasks as active', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 2),
          ),
        ),
      );

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(2));
    });

    testWidgets('Has correct number of navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.items.length, equals(4));
    });

    testWidgets('Selected item color is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.selectedItemColor, equals(const Color(0xFF4A90A4)));
    });
  });
}
