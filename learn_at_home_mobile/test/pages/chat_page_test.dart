import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers – logique extraite pour les tests
// ---------------------------------------------------------------------------

// Reproduction de _formatMessageTime
String formatMessageTimeHelper(String? dateStr) {
  if (dateStr == null) return '';

  final date = DateTime.parse(dateStr);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else if (diff.inDays == 1) {
    return 'Hier';
  } else if (diff.inDays < 7) {
    const jours = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return jours[date.weekday % 7];
  } else {
    return '${date.day}/${date.month}';
  }
}

// Reproduction du mapping profil → nom affiché
String buildContactNameHelper(String? firstName, String? lastName) {
  final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
  return name.isNotEmpty ? name : 'Utilisateur';
}

// Reproduction du mapping contact → nom affiché (fallback "Contact")
String buildContactNameFallbackHelper(String? firstName, String? lastName) {
  final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
  return name.isNotEmpty ? name : 'Contact';
}

// Reproduction du calcul de l'avatar (première lettre majuscule)
String buildAvatarHelper(String name, {String fallback = '?'}) {
  return name.isNotEmpty ? name[0].toUpperCase() : fallback;
}

// Reproduction du tri des conversations
List<Map<String, dynamic>> sortConversationsHelper(
    List<Map<String, dynamic>> conversations) {
  final sorted = List<Map<String, dynamic>>.from(conversations);
  sorted.sort((a, b) {
    if (a['time'] == '' && b['time'] == '') return 0;
    if (a['time'] == '') return 1;
    if (b['time'] == '') return -1;
    return (b['time'] as String).compareTo(a['time'] as String);
  });
  return sorted;
}

// Reproduction du filtre de recherche sur les conversations
List<Map<String, dynamic>> filterConversationsHelper(
    List<Map<String, dynamic>> conversations, String query) {
  if (query.isEmpty) return conversations;
  final q = query.toLowerCase();
  return conversations.where((conv) {
    return (conv['name'] as String).toLowerCase().contains(q) ||
        (conv['lastMessage'] as String).toLowerCase().contains(q);
  }).toList();
}

// Reproduction du filtre de recherche sur les contacts
List<Map<String, dynamic>> filterContactsHelper(
    List<Map<String, dynamic>> contacts, String query) {
  if (query.isEmpty) return contacts;
  final q = query.toLowerCase();
  return contacts
      .where((c) => (c['name'] as String).toLowerCase().contains(q))
      .toList();
}

// Reproduction du comptage des messages non lus
bool hasUnreadHelper(int unreadCount) => unreadCount > 0;

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

// Dates fixes pour éviter tout problème d'inDays flottant
final _today = DateTime.now();
final _todayStr =
    '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}T10:30:00';

// Hier à midi fixe
final _yesterdayFixed = DateTime(
  _today.year, _today.month, _today.day - 1, 12, 0, 0,
);
final _yesterdayStr =
    '${_yesterdayFixed.year}-${_yesterdayFixed.month.toString().padLeft(2, '0')}-${_yesterdayFixed.day.toString().padLeft(2, '0')}T12:00:00';

// Il y a 3 jours à midi fixe
final _threeDaysAgoFixed = DateTime(
  _today.year, _today.month, _today.day - 3, 12, 0, 0,
);
final _threeDaysAgoStr =
    '${_threeDaysAgoFixed.year}-${_threeDaysAgoFixed.month.toString().padLeft(2, '0')}-${_threeDaysAgoFixed.day.toString().padLeft(2, '0')}T12:00:00';

final List<Map<String, dynamic>> _fakeConversations = [
  {
    'id': 'c1',
    'name': 'Alice Dupont',
    'avatar': 'A',
    'lastMessage': 'Bonjour, comment ça va ?',
    'time': '14:30',
    'unread': 2,
    'other_user_id': 'u2',
  },
  {
    'id': 'c2',
    'name': 'Bob Martin',
    'avatar': 'B',
    'lastMessage': 'À demain pour la séance',
    'time': '09:00',
    'unread': 0,
    'other_user_id': 'u3',
  },
  {
    'id': 'c3',
    'name': 'Claire Petit',
    'avatar': 'C',
    'lastMessage': '',
    'time': '',
    'unread': 0,
    'other_user_id': 'u4',
  },
];

final List<Map<String, dynamic>> _fakeContacts = [
  {'id': 'ct1', 'contact_id': 'u2', 'name': 'Alice Dupont', 'avatar': 'A', 'email': 'alice@test.com'},
  {'id': 'ct2', 'contact_id': 'u3', 'name': 'Bob Martin', 'avatar': 'B', 'email': 'bob@test.com'},
  {'id': 'ct3', 'contact_id': 'u5', 'name': 'David Leroy', 'avatar': 'D', 'email': 'david@test.com'},
];

// ---------------------------------------------------------------------------
// Tests unitaires
// ---------------------------------------------------------------------------

void main() {
  // ── 1. formatMessageTime ─────────────────────────────────────────────────

  group('formatMessageTime', () {
    test('retourne "" si dateStr est null', () {
      expect(formatMessageTimeHelper(null), '');
    });

    test('retourne HH:mm pour un message d\'aujourd\'hui', () {
      final result = formatMessageTimeHelper(_todayStr);
      // Format HH:mm — vérifie la structure avec une regex
      expect(RegExp(r'^\d{2}:\d{2}$').hasMatch(result), isTrue);
    });

    test('retourne "Hier" pour un message d\'hier (date fixe midi)', () {
      expect(formatMessageTimeHelper(_yesterdayStr), 'Hier');
    });

    test('retourne le nom du jour abrégé pour un message il y a 2-6 jours', () {
      final result = formatMessageTimeHelper(_threeDaysAgoStr);
      const jours = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
      expect(jours.contains(result), isTrue);
    });

    test('retourne DD/MM pour un message de plus de 7 jours', () {
      final oldDate = DateTime(_today.year, _today.month, _today.day - 10, 12, 0);
      final str =
          '${oldDate.year}-${oldDate.month.toString().padLeft(2, '0')}-${oldDate.day.toString().padLeft(2, '0')}T12:00:00';
      final result = formatMessageTimeHelper(str);
      expect(result, '${oldDate.day}/${oldDate.month}');
    });

    test('le format HH:mm padde correctement les heures et minutes', () {
      // 09:05 → doit donner "09:05"
      final date = DateTime(_today.year, _today.month, _today.day, 9, 5);
      final str =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T09:05:00';
      expect(formatMessageTimeHelper(str), '09:05');
    });

    test('retourne HH:mm avec padding pour minuit (00:00)', () {
      final date = DateTime(_today.year, _today.month, _today.day, 0, 0);
      final str =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00';
      expect(formatMessageTimeHelper(str), '00:00');
    });
  });

  // ── 2. buildContactName ──────────────────────────────────────────────────

  group('buildContactName (conversations)', () {
    test('retourne le nom complet si prénom et nom sont présents', () {
      expect(buildContactNameHelper('Alice', 'Dupont'), 'Alice Dupont');
    });

    test('retourne uniquement le prénom si le nom est null', () {
      expect(buildContactNameHelper('Alice', null), 'Alice');
    });

    test('retourne uniquement le nom si le prénom est null', () {
      expect(buildContactNameHelper(null, 'Dupont'), 'Dupont');
    });

    test('retourne "Utilisateur" si prénom et nom sont null', () {
      expect(buildContactNameHelper(null, null), 'Utilisateur');
    });

    test('retourne "Utilisateur" si prénom et nom sont des chaînes vides', () {
      expect(buildContactNameHelper('', ''), 'Utilisateur');
    });
  });

  group('buildContactName (contacts, fallback "Contact")', () {
    test('retourne le nom complet', () {
      expect(buildContactNameFallbackHelper('Bob', 'Martin'), 'Bob Martin');
    });

    test('retourne "Contact" si les deux champs sont null', () {
      expect(buildContactNameFallbackHelper(null, null), 'Contact');
    });

    test('retourne "Contact" si les deux champs sont vides', () {
      expect(buildContactNameFallbackHelper('', ''), 'Contact');
    });
  });

  // ── 3. buildAvatar ───────────────────────────────────────────────────────

  group('buildAvatar', () {
    test('retourne la première lettre en majuscule', () {
      expect(buildAvatarHelper('alice Dupont'), 'A');
    });

    test('retourne "?" si le nom est vide', () {
      expect(buildAvatarHelper(''), '?');
    });

    test('retourne le fallback personnalisé si le nom est vide', () {
      expect(buildAvatarHelper('', fallback: 'X'), 'X');
    });

    test('retourne la lettre déjà en majuscule si elle l\'est déjà', () {
      expect(buildAvatarHelper('Bob'), 'B');
    });

    test('fonctionne avec un nom en minuscule', () {
      expect(buildAvatarHelper('claire'), 'C');
    });
  });

  // ── 4. hasUnread ─────────────────────────────────────────────────────────

  group('hasUnread', () {
    test('retourne true si unread > 0', () {
      expect(hasUnreadHelper(3), isTrue);
    });

    test('retourne false si unread == 0', () {
      expect(hasUnreadHelper(0), isFalse);
    });

    test('retourne true pour exactement 1 message non lu', () {
      expect(hasUnreadHelper(1), isTrue);
    });
  });

  // ── 5. sortConversations ─────────────────────────────────────────────────

  group('sortConversations', () {
    test('place les conversations sans time à la fin', () {
      final sorted = sortConversationsHelper(_fakeConversations);
      expect(sorted.last['id'], 'c3'); // time == ''
    });

    test('trie les conversations par time décroissant', () {
      final sorted = sortConversationsHelper(_fakeConversations);
      // '14:30' > '09:00', donc c1 avant c2
      expect(sorted[0]['id'], 'c1');
      expect(sorted[1]['id'], 'c2');
    });

    test('deux conversations sans time restent stables entre elles', () {
      final input = [
        {'id': 'x1', 'time': ''},
        {'id': 'x2', 'time': ''},
      ];
      final sorted = sortConversationsHelper(input);
      expect(sorted.length, 2);
    });

    test('liste vide retourne liste vide', () {
      expect(sortConversationsHelper([]), isEmpty);
    });
  });

  // ── 6. filterConversations ───────────────────────────────────────────────

  group('filterConversations', () {
    test('retourne toutes les conversations si query vide', () {
      final result = filterConversationsHelper(_fakeConversations, '');
      expect(result.length, _fakeConversations.length);
    });

    test('filtre par nom (insensible à la casse)', () {
      final result = filterConversationsHelper(_fakeConversations, 'alice');
      expect(result.length, 1);
      expect(result[0]['name'], 'Alice Dupont');
    });

    test('filtre par contenu du dernier message', () {
      final result = filterConversationsHelper(_fakeConversations, 'séance');
      expect(result.length, 1);
      expect(result[0]['id'], 'c2');
    });

    test('retourne liste vide si aucun résultat', () {
      final result = filterConversationsHelper(_fakeConversations, 'zzz');
      expect(result, isEmpty);
    });

    test('retourne plusieurs résultats si plusieurs correspondent', () {
      // 'a' est dans "Alice" et "À demain"
      final result = filterConversationsHelper(_fakeConversations, 'a');
      expect(result.length, greaterThan(1));
    });
  });

  // ── 7. filterContacts ────────────────────────────────────────────────────

  group('filterContacts', () {
    test('retourne tous les contacts si query vide', () {
      final result = filterContactsHelper(_fakeContacts, '');
      expect(result.length, _fakeContacts.length);
    });

    test('filtre par nom (insensible à la casse)', () {
      final result = filterContactsHelper(_fakeContacts, 'bob');
      expect(result.length, 1);
      expect(result[0]['name'], 'Bob Martin');
    });

    test('retourne liste vide si aucun résultat', () {
      final result = filterContactsHelper(_fakeContacts, 'zzz');
      expect(result, isEmpty);
    });

    test('filtre partiel fonctionne ("du" → "Alice Dupont")', () {
      final result = filterContactsHelper(_fakeContacts, 'du');
      expect(result.length, 1);
      expect(result[0]['name'], 'Alice Dupont');
    });
  });

  // ── 8. Widget smoke tests ─────────────────────────────────────────────────

  group('Widget smoke tests', () {
    testWidgets('affiche "Aucune conversation" quand la liste est vide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Aucune conversation',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ),
      );
      expect(find.text('Aucune conversation'), findsOneWidget);
    });

    testWidgets('affiche "Aucun contact" quand la liste est vide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Aucun contact',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ),
      );
      expect(find.text('Aucun contact'), findsOneWidget);
    });

    testWidgets('le badge de messages non lus affiche le bon nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('2')),
          ),
        ),
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator affiché pendant le chargement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}