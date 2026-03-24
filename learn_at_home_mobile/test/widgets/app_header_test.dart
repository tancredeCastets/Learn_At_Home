import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_at_home_mobile/widgets/app_header.dart';

// Note: Ces tests sont limités car AppHeader nécessite Supabase
// Pour des tests complets, il faudrait mocker Supabase
void main() {
  group('AppHeader Widget Tests', () {
    testWidgets('AppHeader can be instantiated', (WidgetTester tester) async {
      // Vérifie que le widget peut être créé avec les paramètres requis
      const header = AppHeader(title: 'Test Title');
      expect(header.title, equals('Test Title'));
    });

    testWidgets('AppHeader has correct preferredSize', (WidgetTester tester) async {
      const header = AppHeader(title: 'Test');
      expect(header.preferredSize.height, equals(kToolbarHeight));
    });

    testWidgets('AppHeader accepts extraActions parameter', (WidgetTester tester) async {
      final extraActions = [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ];
      
      final header = AppHeader(
        title: 'Test',
        extraActions: extraActions,
      );
      
      expect(header.extraActions, isNotNull);
      expect(header.extraActions!.length, equals(1));
    });

    testWidgets('AppHeader accepts onRefresh callback', (WidgetTester tester) async {
      bool refreshCalled = false;
      
      final header = AppHeader(
        title: 'Test',
        onRefresh: () {
          refreshCalled = true;
        },
      );
      
      expect(header.onRefresh, isNotNull);
      header.onRefresh!();
      expect(refreshCalled, isTrue);
    });

    testWidgets('AppHeader implements PreferredSizeWidget', (WidgetTester tester) async {
      const header = AppHeader(title: 'Test');
      expect(header, isA<PreferredSizeWidget>());
    });
  });
}
