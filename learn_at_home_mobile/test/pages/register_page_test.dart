import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_at_home_mobile/pages/register_page.dart';

void main() {
  group('RegisterPage Widget Tests', () {
    testWidgets('Register page displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Vérifie que le titre est affiché
      expect(find.text('Créer un compte'), findsOneWidget);
      
      // Vérifie que les champs de saisie sont présents (prénom, nom, email, mot de passe, confirmation)
      expect(find.byType(TextField), findsNWidgets(5));
      
      // Vérifie que le bouton d'inscription est présent
      expect(find.text("S'inscrire"), findsOneWidget);
    });

    testWidgets('First name field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Trouve le champ prénom
      final firstNameField = find.byType(TextField).at(0);
      await tester.enterText(firstNameField, 'Jean');
      await tester.pump();

      expect(find.text('Jean'), findsOneWidget);
    });

    testWidgets('Last name field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Trouve le champ nom
      final lastNameField = find.byType(TextField).at(1);
      await tester.enterText(lastNameField, 'Dupont');
      await tester.pump();

      expect(find.text('Dupont'), findsOneWidget);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Trouve le champ email
      final emailField = find.byType(TextField).at(2);
      await tester.enterText(emailField, 'jean@example.com');
      await tester.pump();

      expect(find.text('jean@example.com'), findsOneWidget);
    });

    testWidgets('Password fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Trouve les champs mot de passe
      final passwordField = find.byType(TextField).at(3);
      final confirmField = find.byType(TextField).at(4);
      
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password123');
      await tester.pump();

      // Vérifie que les champs existent
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('Register button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      final registerButton = find.text("S'inscrire");
      expect(registerButton, findsOneWidget);
    });

    testWidgets('Login link is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      expect(find.text('Déjà un compte ? '), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('Role selector is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Vérifie qu'il y a un sélecteur de rôle (Élève/Bénévole)
      expect(find.text('Je suis'), findsOneWidget);
      expect(find.text('Élève'), findsOneWidget);
      expect(find.text('Bénévole'), findsOneWidget);
    });

    testWidgets('Register page has person icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Vérifie les icônes
      expect(find.byIcon(Icons.person_outline), findsWidgets);
    });
  });
}
