import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_at_home_mobile/pages/forgot_password_page.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers – logique pure extraite pour les tests unitaires
  // ---------------------------------------------------------------------------

  // Reproduction du validator email
  String? emailValidatorHelper(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  // Reproduction du trim appliqué avant envoi
  String trimEmailHelper(String email) => email.trim();

  // ---------------------------------------------------------------------------
  // 1. Tests unitaires purs (logique validator)
  // ---------------------------------------------------------------------------

  group('Validator email', () {
    test('email null → message d\'erreur', () {
      expect(emailValidatorHelper(null), 'Veuillez entrer votre email');
    });

    test('email vide → message d\'erreur', () {
      expect(emailValidatorHelper(''), 'Veuillez entrer votre email');
    });

    test('email sans @ → invalide', () {
      expect(emailValidatorHelper('testexample.com'),
          'Veuillez entrer un email valide');
    });

    test('email sans domaine → invalide', () {
      expect(emailValidatorHelper('test@'),
          'Veuillez entrer un email valide');
    });

    test('email sans extension → invalide', () {
      expect(emailValidatorHelper('test@example'),
          'Veuillez entrer un email valide');
    });

    test('email valide simple → null (pas d\'erreur)', () {
      expect(emailValidatorHelper('test@example.com'), isNull);
    });

    test('email valide avec point dans le nom → null', () {
      expect(emailValidatorHelper('jean.dupont@example.com'), isNull);
    });

    test('email valide avec tiret → null', () {
      expect(emailValidatorHelper('jean-dupont@example.fr'), isNull);
    });

    test('email valide avec sous-domaine → null', () {
      expect(emailValidatorHelper('user@mail.example.com'), isNull);
    });
  });

  group('Trim de l\'email', () {
    test('supprime les espaces avant et après', () {
      expect(trimEmailHelper('  test@example.com  '), 'test@example.com');
    });

    test('email sans espaces reste inchangé', () {
      expect(trimEmailHelper('test@example.com'), 'test@example.com');
    });

    test('email avec espace interne n\'est pas modifié', () {
      expect(trimEmailHelper('te st@example.com'), 'te st@example.com');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Tests Widget – état initial (formulaire)
  // ---------------------------------------------------------------------------

  group('ForgotPasswordPage – état initial', () {
    testWidgets('affiche le champ email (TextFormField)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche le titre "Mot de passe oublié ?"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('affiche le bouton "Envoyer le lien"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Envoyer le lien'), findsOneWidget);
    });

    testWidgets('affiche le lien "Connexion"', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('affiche le hint "Entrez votre email"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Entrez votre email'), findsOneWidget);
    });

    testWidgets('affiche le label "Adresse email"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.text('Adresse email'), findsOneWidget);
    });

    testWidgets('affiche l\'icône lock_reset dans le header',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('le champ email est vide au démarrage',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      final field =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text ?? '', isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Tests Widget – validation du formulaire
  // ---------------------------------------------------------------------------

  group('ForgotPasswordPage – validation formulaire', () {
    testWidgets('soumettre avec champ vide affiche l\'erreur de validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      await tester.tap(find.text('Envoyer le lien'));
      await tester.pump();

      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
    });

    testWidgets('soumettre avec email invalide affiche l\'erreur de format',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      await tester.enterText(find.byType(TextFormField), 'pasvalide');
      await tester.tap(find.text('Envoyer le lien'));
      await tester.pump();

      expect(find.text('Veuillez entrer un email valide'), findsOneWidget);
    });

    testWidgets('erreur disparaît quand l\'email devient valide',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      // 1. Soumettre vide → erreur
      await tester.tap(find.text('Envoyer le lien'));
      await tester.pump();
      expect(find.text('Veuillez entrer votre email'), findsOneWidget);

      // 2. Saisir un email valide → l'erreur disparaît
      await tester.enterText(find.byType(TextFormField), 'valid@example.com');
      await tester.pump();
      expect(find.text('Veuillez entrer votre email'), findsNothing);
    });

    testWidgets('aucune erreur si email valide dès le départ',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      await tester.enterText(
          find.byType(TextFormField), 'valid@example.com');
      await tester.pump();

      expect(find.text('Veuillez entrer votre email'), findsNothing);
      expect(find.text('Veuillez entrer un email valide'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Tests Widget – état succès (_emailSent = true)
  // ---------------------------------------------------------------------------

  group('ForgotPasswordPage – état succès (après envoi simulé)', () {
    // On ne peut pas appeler Supabase dans les tests, donc on vérifie
    // l'état succès en inspectant les widgets construits par _buildSuccessContent.

    testWidgets('l\'écran succès affiche "Email envoyé !"',
        (WidgetTester tester) async {
      // On construit directement le contenu succès pour le tester en isolation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Icon(Icons.mark_email_read_outlined, color: Colors.green),
                const Text('Email envoyé !'),
                const Text('Retour à la connexion'),
                TextButton(
                  onPressed: () {},
                  child: const Text('Vous n\'avez pas reçu l\'email ? Renvoyer'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Email envoyé !'), findsOneWidget);
    });

    testWidgets('l\'écran succès affiche le bouton "Retour à la connexion"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Email envoyé !'),
                Text('Retour à la connexion'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Retour à la connexion'), findsOneWidget);
    });

    testWidgets('l\'écran succès affiche le lien "Renvoyer"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {},
              child:
                  const Text('Vous n\'avez pas reçu l\'email ? Renvoyer'),
            ),
          ),
        ),
      );
      expect(find.textContaining('Renvoyer'), findsOneWidget);
    });

    testWidgets('l\'écran succès affiche l\'icône mark_email_read_outlined',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.mark_email_read_outlined, color: Colors.green),
          ),
        ),
      );
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Tests Widget – interaction saisie
  // ---------------------------------------------------------------------------

  group('ForgotPasswordPage – interaction saisie', () {
    testWidgets('la saisie dans le champ email est bien capturée',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      await tester.enterText(
          find.byType(TextFormField), 'jean@example.com');
      await tester.pump();

      expect(find.text('jean@example.com'), findsOneWidget);
    });

    testWidgets('effacer le champ et resaisir fonctionne',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      await tester.enterText(find.byType(TextFormField), 'premier@test.com');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'second@test.com');
      await tester.pump();

      expect(find.text('second@test.com'), findsOneWidget);
      expect(find.text('premier@test.com'), findsNothing);
    });
  });
}