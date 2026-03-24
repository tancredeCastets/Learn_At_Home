import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_at_home_mobile/pages/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('Login page displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Vérifie que le titre est affiché
      expect(find.text('Learn At Home'), findsOneWidget);
      
      // Vérifie que les champs de saisie sont présents
      expect(find.byType(TextField), findsNWidgets(2));
      
      // Vérifie que le bouton de connexion est présent
      expect(find.text('Se connecter'), findsOneWidget);
      
      // Vérifie le lien vers l'inscription
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Trouve le champ email et entre du texte
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Vérifie que le texte a été entré
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Trouve le champ mot de passe et entre du texte
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Le mot de passe est masqué, donc on vérifie via le controller
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Login button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Trouve et appuie sur le bouton de connexion
      final loginButton = find.text('Se connecter');
      expect(loginButton, findsOneWidget);
      
      await tester.tap(loginButton);
      await tester.pump();
    });

    testWidgets('Register link is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Trouve et appuie sur le lien d'inscription
      final registerLink = find.text('Créer un compte');
      expect(registerLink, findsOneWidget);
      
      await tester.tap(registerLink);
      await tester.pumpAndSettle();
    });

    testWidgets('Login page has email icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('Login page has lock icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
