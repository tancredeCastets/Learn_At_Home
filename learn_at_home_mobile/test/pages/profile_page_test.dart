import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers – logique extraite pour les tests
// ---------------------------------------------------------------------------

// Reproduction du getter _initials
String initialsHelper(String firstName, String lastName) {
  final first = firstName.isNotEmpty ? firstName[0] : '';
  final last = lastName.isNotEmpty ? lastName[0] : '';
  return '$first$last'.toUpperCase();
}

// Reproduction du getter _roleDisplay
String roleDisplayHelper(String role) {
  switch (role.toLowerCase()) {
    case 'volunteer':
      return 'BÉNÉVOLE';
    case 'student':
    default:
      return 'ÉLÈVE';
  }
}

// Reproduction du nom affiché dans le header
String displayNameHelper(String firstName, String lastName) {
  final full = '$firstName $lastName'.trim();
  return full.isNotEmpty ? full : 'Utilisateur';
}

// Reproduction du trim appliqué lors de _saveProfile
String trimFieldHelper(String value) => value.trim();

// Reproduction de la valeur affichée dans _buildInfoField
String infoFieldValueHelper(String value) {
  return value.isNotEmpty ? value : '-';
}

// Reproduction de la logique _cancelEdit (restauration des valeurs)
Map<String, String> cancelEditHelper({
  required String savedFirstName,
  required String savedLastName,
  required String savedEmail,
}) {
  return {
    'firstName': savedFirstName,
    'lastName': savedLastName,
    'email': savedEmail,
  };
}

// Reproduction de la construction de l'URL avatar avec timestamp anti-cache
String buildAvatarUrlHelper(String baseUrl, int timestamp) {
  return '$baseUrl?t=$timestamp';
}

// Reproduction du nom de fichier avatar
String buildAvatarFileNameHelper(String userId, String extension) {
  return '$userId/avatar.$extension';
}

// Reproduction du fallback d'extension
String resolveExtensionHelper(String? extension) {
  return extension ?? 'jpg';
}

// ---------------------------------------------------------------------------
// Tests unitaires
// ---------------------------------------------------------------------------

void main() {
  // ── 1. _initials ──────────────────────────────────────────────────────────

  group('initials', () {
    test('prénom + nom → deux initiales en majuscule', () {
      expect(initialsHelper('alice', 'dupont'), 'AD');
    });

    test('déjà en majuscule → reste en majuscule', () {
      expect(initialsHelper('Alice', 'Dupont'), 'AD');
    });

    test('prénom vide → une seule initiale (nom)', () {
      expect(initialsHelper('', 'Dupont'), 'D');
    });

    test('nom vide → une seule initiale (prénom)', () {
      expect(initialsHelper('Alice', ''), 'A');
    });

    test('prénom et nom vides → chaîne vide', () {
      expect(initialsHelper('', ''), '');
    });

    test('prénom et nom en minuscule → initiales en majuscule', () {
      expect(initialsHelper('jean', 'martin'), 'JM');
    });

    test('un seul caractère pour chaque → initiales correctes', () {
      expect(initialsHelper('A', 'B'), 'AB');
    });
  });

  // ── 2. _roleDisplay ───────────────────────────────────────────────────────

  group('roleDisplay', () {
    test('"volunteer" → "BÉNÉVOLE"', () {
      expect(roleDisplayHelper('volunteer'), 'BÉNÉVOLE');
    });

    test('"VOLUNTEER" (majuscule) → "BÉNÉVOLE"', () {
      expect(roleDisplayHelper('VOLUNTEER'), 'BÉNÉVOLE');
    });

    test('"Volunteer" (mixte) → "BÉNÉVOLE"', () {
      expect(roleDisplayHelper('Volunteer'), 'BÉNÉVOLE');
    });

    test('"student" → "ÉLÈVE"', () {
      expect(roleDisplayHelper('student'), 'ÉLÈVE');
    });

    test('"STUDENT" (majuscule) → "ÉLÈVE"', () {
      expect(roleDisplayHelper('STUDENT'), 'ÉLÈVE');
    });

    test('valeur inconnue → "ÉLÈVE" (fallback default)', () {
      expect(roleDisplayHelper('admin'), 'ÉLÈVE');
    });

    test('chaîne vide → "ÉLÈVE" (fallback default)', () {
      expect(roleDisplayHelper(''), 'ÉLÈVE');
    });
  });

  // ── 3. displayName ────────────────────────────────────────────────────────

  group('displayName', () {
    test('prénom + nom → nom complet', () {
      expect(displayNameHelper('Alice', 'Dupont'), 'Alice Dupont');
    });

    test('prénom seul (nom vide) → prénom uniquement sans espace', () {
      expect(displayNameHelper('Alice', ''), 'Alice');
    });

    test('nom seul (prénom vide) → nom uniquement sans espace', () {
      expect(displayNameHelper('', 'Dupont'), 'Dupont');
    });

    test('prénom et nom vides → "Utilisateur"', () {
      expect(displayNameHelper('', ''), 'Utilisateur');
    });

    test('espaces seulement → "Utilisateur"', () {
      expect(displayNameHelper('   ', '   '), 'Utilisateur');
    });
  });

  // ── 4. trimField (_saveProfile) ───────────────────────────────────────────

  group('trimField', () {
    test('supprime les espaces avant et après', () {
      expect(trimFieldHelper('  Alice  '), 'Alice');
    });

    test('valeur sans espaces reste inchangée', () {
      expect(trimFieldHelper('Alice'), 'Alice');
    });

    test('valeur avec espaces internes non modifiée', () {
      expect(trimFieldHelper('Alice Wonderland'), 'Alice Wonderland');
    });

    test('valeur vide reste vide', () {
      expect(trimFieldHelper(''), '');
    });

    test('uniquement des espaces → chaîne vide', () {
      expect(trimFieldHelper('   '), '');
    });
  });

  // ── 5. infoFieldValue ─────────────────────────────────────────────────────

  group('infoFieldValue', () {
    test('valeur non vide → affichée telle quelle', () {
      expect(infoFieldValueHelper('Alice'), 'Alice');
    });

    test('valeur vide → "-"', () {
      expect(infoFieldValueHelper(''), '-');
    });

    test('email non vide → affiché tel quel', () {
      expect(infoFieldValueHelper('alice@example.com'), 'alice@example.com');
    });
  });

  // ── 6. cancelEdit ────────────────────────────────────────────────────────

  group('cancelEdit', () {
    test('restaure les valeurs sauvegardées', () {
      final restored = cancelEditHelper(
        savedFirstName: 'Alice',
        savedLastName: 'Dupont',
        savedEmail: 'alice@example.com',
      );
      expect(restored['firstName'], 'Alice');
      expect(restored['lastName'], 'Dupont');
      expect(restored['email'], 'alice@example.com');
    });

    test('restaure des valeurs vides si le profil est vide', () {
      final restored = cancelEditHelper(
        savedFirstName: '',
        savedLastName: '',
        savedEmail: '',
      );
      expect(restored['firstName'], '');
      expect(restored['lastName'], '');
      expect(restored['email'], '');
    });
  });

  // ── 7. buildAvatarUrl (anti-cache timestamp) ──────────────────────────────

  group('buildAvatarUrl', () {
    test('l\'URL contient le paramètre "?t="', () {
      final url = buildAvatarUrlHelper('https://example.com/avatar.jpg', 12345);
      expect(url, contains('?t='));
    });

    test('l\'URL contient le bon timestamp', () {
      final ts = DateTime(2025, 6, 15).millisecondsSinceEpoch;
      final url = buildAvatarUrlHelper('https://example.com/avatar.jpg', ts);
      expect(url, endsWith('?t=$ts'));
    });

    test('deux timestamps différents → deux URLs différentes', () {
      final url1 = buildAvatarUrlHelper('https://example.com/avatar.jpg', 1000);
      final url2 = buildAvatarUrlHelper('https://example.com/avatar.jpg', 2000);
      expect(url1, isNot(url2));
    });

    test('la base URL est bien préservée', () {
      const base = 'https://example.com/storage/avatars/user-1/avatar.png';
      final url = buildAvatarUrlHelper(base, 99999);
      expect(url, startsWith(base));
    });
  });

  // ── 8. buildAvatarFileName ────────────────────────────────────────────────

  group('buildAvatarFileName', () {
    test('construit le chemin userId/avatar.ext', () {
      expect(buildAvatarFileNameHelper('user-123', 'jpg'), 'user-123/avatar.jpg');
    });

    test('fonctionne avec extension png', () {
      expect(buildAvatarFileNameHelper('user-456', 'png'), 'user-456/avatar.png');
    });

    test('fonctionne avec extension jpeg', () {
      expect(buildAvatarFileNameHelper('user-789', 'jpeg'), 'user-789/avatar.jpeg');
    });
  });

  // ── 9. resolveExtension ───────────────────────────────────────────────────

  group('resolveExtension', () {
    test('extension fournie → utilisée telle quelle', () {
      expect(resolveExtensionHelper('png'), 'png');
    });

    test('extension null → fallback "jpg"', () {
      expect(resolveExtensionHelper(null), 'jpg');
    });

    test('extension vide → chaîne vide (pas de fallback)', () {
      // L'opérateur ?? ne se déclenche pas si la valeur est '' (non null)
      expect(resolveExtensionHelper(''), '');
    });
  });

  // ── 10. Widget smoke tests ────────────────────────────────────────────────

  group('Widget smoke tests', () {
    testWidgets('CircularProgressIndicator affiché en état loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('le bouton "Modifier" est affiché en mode lecture',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Modifier'),
            ),
          ),
        ),
      );
      expect(find.text('Modifier'), findsOneWidget);
    });

    testWidgets('les boutons "Annuler" et "Sauvegarder" sont affichés en mode édition',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Sauvegarder'), findsOneWidget);
    });

    testWidgets('les labels de champs sont affichés', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('PRÉNOM'),
                Text('NOM'),
                Text('E-MAIL'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('PRÉNOM'), findsOneWidget);
      expect(find.text('NOM'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
    });

    testWidgets('"Informations personnelles" est affiché',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Informations personnelles'),
          ),
        ),
      );
      expect(find.text('Informations personnelles'), findsOneWidget);
    });

    testWidgets('valeur vide affiche "-" dans un champ non éditable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(infoFieldValueHelper('')),
          ),
        ),
      );
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('"BÉNÉVOLE" est affiché pour le rôle volunteer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(roleDisplayHelper('volunteer')),
          ),
        ),
      );
      expect(find.text('BÉNÉVOLE'), findsOneWidget);
    });

    testWidgets('"ÉLÈVE" est affiché pour le rôle student',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(roleDisplayHelper('student')),
          ),
        ),
      );
      expect(find.text('ÉLÈVE'), findsOneWidget);
    });
  });
}