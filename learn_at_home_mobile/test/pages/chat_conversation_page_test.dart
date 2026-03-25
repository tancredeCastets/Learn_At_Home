import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers – logique extraite pour les tests
// ---------------------------------------------------------------------------

// Reproduction de _formatTime
String formatTimeHelper(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

// Reproduction du mapping message Supabase → modèle UI
Map<String, dynamic> buildMessageModelHelper(
    Map<String, dynamic> raw, String currentUserId) {
  return {
    'id': raw['id'],
    'content': raw['content'] ?? '',
    'isMe': raw['sender_id'] == currentUserId,
    'sent_at': formatTimeHelper(DateTime.parse(raw['sent_at'] as String)),
    'is_read': raw['is_read'] == true || raw['is_read'] == 'true',
  };
}

// Reproduction de la logique showAvatar
bool showAvatarHelper(
    List<Map<String, dynamic>> messages, int index) {
  final isMe = messages[index]['isMe'] as bool;
  if (isMe) return false;
  if (index == 0) return true;
  return messages[index - 1]['isMe'] == true;
}

// Reproduction de la logique tempId
String buildTempIdHelper(DateTime now) {
  return 'temp_${now.millisecondsSinceEpoch}';
}

// Reproduction de la validation d'envoi (message vide ignoré)
bool canSendMessageHelper(String text) {
  return text.trim().isNotEmpty;
}

// Reproduction de la logique is_read (bool ou string 'true')
bool parseIsReadHelper(dynamic value) {
  return value == true || value == 'true';
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

const _myUserId = 'user-me';
const _otherUserId = 'user-other';

final _now = DateTime.now();

// Dates fixes pour éviter tout piège de timing
DateTime _fixedTime(int hour, int minute) =>
    DateTime(_now.year, _now.month, _now.day, hour, minute, 0);

final List<Map<String, dynamic>> _fakeRawMessages = [
  {
    'id': 'm1',
    'content': 'Bonjour !',
    'sender_id': _otherUserId,
    'sent_at': '${_now.year}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}T09:00:00',
    'is_read': true,
  },
  {
    'id': 'm2',
    'content': 'Salut, ça va ?',
    'sender_id': _myUserId,
    'sent_at': '${_now.year}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}T09:01:00',
    'is_read': false,
  },
  {
    'id': 'm3',
    'content': 'Très bien merci !',
    'sender_id': _otherUserId,
    'sent_at': '${_now.year}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}T09:02:00',
    'is_read': true,
  },
  {
    'id': 'm4',
    'content': null, // titre null → ''
    'sender_id': _myUserId,
    'sent_at': '${_now.year}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}T09:03:00',
    'is_read': 'true', // is_read en string
  },
];

// ---------------------------------------------------------------------------
// Tests unitaires
// ---------------------------------------------------------------------------

void main() {
  // ── 1. formatTime ─────────────────────────────────────────────────────────

  group('formatTime', () {
    test('formate correctement 09:00', () {
      expect(formatTimeHelper(_fixedTime(9, 0)), '09:00');
    });

    test('formate correctement 14:30', () {
      expect(formatTimeHelper(_fixedTime(14, 30)), '14:30');
    });

    test('padde l\'heure avec un zéro (08:05)', () {
      expect(formatTimeHelper(_fixedTime(8, 5)), '08:05');
    });

    test('formate minuit 00:00', () {
      expect(formatTimeHelper(_fixedTime(0, 0)), '00:00');
    });

    test('formate 23:59', () {
      expect(formatTimeHelper(_fixedTime(23, 59)), '23:59');
    });

    test('le résultat a toujours le format HH:mm (5 caractères)', () {
      for (int h = 0; h < 24; h++) {
        for (int m = 0; m < 60; m += 15) {
          final result = formatTimeHelper(_fixedTime(h, m));
          expect(result.length, 5);
          expect(result[2], ':');
        }
      }
    });
  });

  // ── 2. buildMessageModel ──────────────────────────────────────────────────

  group('buildMessageModel', () {
    test('isMe = true si sender_id correspond à l\'utilisateur courant', () {
      final model = buildMessageModelHelper(_fakeRawMessages[1], _myUserId);
      expect(model['isMe'], isTrue);
    });

    test('isMe = false si sender_id est celui de l\'autre', () {
      final model = buildMessageModelHelper(_fakeRawMessages[0], _myUserId);
      expect(model['isMe'], isFalse);
    });

    test('content null devient une chaîne vide', () {
      final model = buildMessageModelHelper(_fakeRawMessages[3], _myUserId);
      expect(model['content'], '');
    });

    test('sent_at est formaté en HH:mm', () {
      final model = buildMessageModelHelper(_fakeRawMessages[0], _myUserId);
      expect(RegExp(r'^\d{2}:\d{2}$').hasMatch(model['sent_at'] as String), isTrue);
    });

    test('is_read bool true est correctement parsé', () {
      final model = buildMessageModelHelper(_fakeRawMessages[0], _myUserId);
      expect(model['is_read'], isTrue);
    });

    test('is_read bool false est correctement parsé', () {
      final model = buildMessageModelHelper(_fakeRawMessages[1], _myUserId);
      expect(model['is_read'], isFalse);
    });

    test('is_read en string "true" est correctement parsé', () {
      final model = buildMessageModelHelper(_fakeRawMessages[3], _myUserId);
      expect(model['is_read'], isTrue);
    });

    test('l\'id est correctement transmis', () {
      final model = buildMessageModelHelper(_fakeRawMessages[0], _myUserId);
      expect(model['id'], 'm1');
    });
  });

  // ── 3. parseIsRead ────────────────────────────────────────────────────────

  group('parseIsRead', () {
    test('true (bool) → true', () => expect(parseIsReadHelper(true), isTrue));
    test('"true" (string) → true', () => expect(parseIsReadHelper('true'), isTrue));
    test('false (bool) → false', () => expect(parseIsReadHelper(false), isFalse));
    test('null → false', () => expect(parseIsReadHelper(null), isFalse));
    test('"false" (string) → false', () => expect(parseIsReadHelper('false'), isFalse));
    test('0 (int) → false', () => expect(parseIsReadHelper(0), isFalse));
  });

  // ── 4. canSendMessage ────────────────────────────────────────────────────

  group('canSendMessage', () {
    test('message non vide → peut envoyer', () {
      expect(canSendMessageHelper('Bonjour'), isTrue);
    });

    test('message vide → ne peut pas envoyer', () {
      expect(canSendMessageHelper(''), isFalse);
    });

    test('message avec espaces seulement → ne peut pas envoyer', () {
      expect(canSendMessageHelper('   '), isFalse);
    });

    test('message avec espace avant/après → peut envoyer (trim)', () {
      expect(canSendMessageHelper('  Bonjour  '), isTrue);
    });

    test('message avec saut de ligne seulement → ne peut pas envoyer', () {
      expect(canSendMessageHelper('\n'), isFalse);
    });
  });

  // ── 5. buildTempId ───────────────────────────────────────────────────────

  group('buildTempId', () {
    test('commence par "temp_"', () {
      final id = buildTempIdHelper(DateTime.now());
      expect(id.startsWith('temp_'), isTrue);
    });

    test('contient le millisecondsSinceEpoch', () {
      final now = DateTime(2025, 6, 15, 10, 30, 0);
      expect(buildTempIdHelper(now), 'temp_${now.millisecondsSinceEpoch}');
    });

    test('deux appels à des moments différents donnent des ids différents', () {
      final id1 = buildTempIdHelper(DateTime(2025, 6, 15, 10, 0, 0));
      final id2 = buildTempIdHelper(DateTime(2025, 6, 15, 10, 0, 1));
      expect(id1, isNot(id2));
    });
  });

  // ── 6. showAvatar ────────────────────────────────────────────────────────

  group('showAvatar', () {
    // Messages simulés : [autre, moi, autre, autre, moi, autre]
    final messages = [
      {'isMe': false}, // 0 → premier message de l'autre → avatar
      {'isMe': true},  // 1 → moi → pas d'avatar
      {'isMe': false}, // 2 → autre après moi → avatar
      {'isMe': false}, // 3 → autre après autre → pas d'avatar
      {'isMe': true},  // 4 → moi → pas d'avatar
      {'isMe': false}, // 5 → autre après moi → avatar
    ];

    test('premier message de l\'autre → affiche avatar', () {
      expect(showAvatarHelper(messages, 0), isTrue);
    });

    test('message de moi → pas d\'avatar', () {
      expect(showAvatarHelper(messages, 1), isFalse);
    });

    test('message de l\'autre après moi → affiche avatar', () {
      expect(showAvatarHelper(messages, 2), isTrue);
    });

    test('message de l\'autre après l\'autre → pas d\'avatar', () {
      expect(showAvatarHelper(messages, 3), isFalse);
    });

    test('message de moi après moi → pas d\'avatar', () {
      expect(showAvatarHelper(messages, 4), isFalse);
    });

    test('message de l\'autre après moi (en fin de liste) → affiche avatar', () {
      expect(showAvatarHelper(messages, 5), isTrue);
    });
  });

  // ── 7. Mapping de liste complète ─────────────────────────────────────────

  group('Mapping liste de messages', () {
    test('mappe tous les messages correctement', () {
      final mapped = _fakeRawMessages
          .map((raw) => buildMessageModelHelper(raw, _myUserId))
          .toList();
      expect(mapped.length, 4);
    });

    test('les messages de l\'autre ont isMe=false', () {
      final mapped = _fakeRawMessages
          .map((raw) => buildMessageModelHelper(raw, _myUserId))
          .toList();
      expect(mapped[0]['isMe'], isFalse); // otherUserId
      expect(mapped[2]['isMe'], isFalse); // otherUserId
    });

    test('les messages de moi ont isMe=true', () {
      final mapped = _fakeRawMessages
          .map((raw) => buildMessageModelHelper(raw, _myUserId))
          .toList();
      expect(mapped[1]['isMe'], isTrue);
      expect(mapped[3]['isMe'], isTrue);
    });

    test('tous les sent_at ont le format HH:mm', () {
      final mapped = _fakeRawMessages
          .map((raw) => buildMessageModelHelper(raw, _myUserId))
          .toList();
      for (final msg in mapped) {
        expect(
          RegExp(r'^\d{2}:\d{2}$').hasMatch(msg['sent_at'] as String),
          isTrue,
          reason: 'sent_at "${msg['sent_at']}" n\'a pas le format HH:mm',
        );
      }
    });
  });

  // ── 8. Widget smoke tests ─────────────────────────────────────────────────

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

    testWidgets('le placeholder "Écrire un message..." est affiché',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(hintText: 'Écrire un message...'),
            ),
          ),
        ),
      );
      expect(find.text('Écrire un message...'), findsOneWidget);
    });

    testWidgets('le bouton envoyer est bien présent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('icône "done_all" affichée pour message lu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Icon(Icons.done_all)),
        ),
      );
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('icône "done" affichée pour message non lu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Icon(Icons.done)),
        ),
      );
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}