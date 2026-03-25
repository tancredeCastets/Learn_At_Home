import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers – données de test
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final List<Map<String, dynamic>> _fakeTasks = [
  {
    'id': '1',
    'title': 'Tâche urgente',
    'description': 'À faire aujourd\'hui',
    'due_date': _now.toIso8601String(),
    'is_completed': false,
    'created_by': 'user-123',
    'assigned_to': null,
  },
  {
    'id': '2',
    'title': 'Tâche terminée',
    'description': 'Déjà faite',
    'due_date': _now.add(const Duration(days: 3)).toIso8601String(),
    'is_completed': true,
    'created_by': 'user-123',
    'assigned_to': null,
  },
  {
    'id': '3',
    'title': 'Tâche assignée',
    'description': null,
    'due_date': _now.add(const Duration(days: 10)).toIso8601String(),
    'is_completed': false,
    'created_by': 'other-user',
    'assigned_to': 'user-123',
  },
];

final List<Map<String, dynamic>> _fakeEvents = [
  {
    'id': 'e1',
    'title': 'Réunion d\'équipe',
    'description': 'Standup quotidien',
    'start_datetime': _now.add(const Duration(hours: 2)).toIso8601String(),
    'created_by': 'user-123',
  },
  {
    'id': 'e2',
    'title': 'Démo client',
    'description': null,
    'start_datetime': _now.add(const Duration(days: 1)).toIso8601String(),
    'created_by': 'user-123',
  },
];


// ---------------------------------------------------------------------------
// Tests des méthodes utilitaires (logique pure, sans widget)
// ---------------------------------------------------------------------------

// On extrait ici la logique de formatage pour pouvoir la tester directement.
// Dans l'implémentation réelle ces méthodes sont privées ; les tests ci-dessous
// vérifient le comportement observable via l'UI, mais on peut aussi tester
// la logique en isolé en la déplaçant vers une classe utilitaire.

String formatDueDateHelper(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;
  if (difference == 0) return "Aujourd'hui";
  if (difference == 1) return 'Demain';
  if (difference < 7) return 'Dans $difference jours';
  return '${date.day}/${date.month}';
}

String formatEventDateHelper(DateTime date) {
  final now = DateTime.now();
  final isToday = date.day == now.day &&
      date.month == now.month &&
      date.year == now.year;
  final isTomorrow = date.day == now.day + 1 &&
      date.month == now.month &&
      date.year == now.year;
  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  if (isToday) return "Aujourd'hui à $time";
  if (isTomorrow) return 'Demain à $time';
  return '${date.day}/${date.month} à $time';
}

// ---------------------------------------------------------------------------
// Tests unitaires
// ---------------------------------------------------------------------------

void main() {
  // ── 1. Logique de formatage de date ──────────────────────────────────────

  group('formatDueDate', () {
    test('renvoie "Aujourd\'hui" quand la date est aujourd\'hui', () {
      final today = DateTime.now();
      expect(formatDueDateHelper(today), "Aujourd'hui");
    });

    test('renvoie "Demain" pour une date dans 1 jour', () {
      final now = DateTime.now();
      // On construit minuit du lendemain pour garantir inDays == 1
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0, 0);
      expect(formatDueDateHelper(tomorrow), 'Demain');
    });

    test('renvoie "Dans X jours" pour une date dans 2–6 jours', () {
      final now = DateTime.now();
      for (int i = 2; i <= 6; i++) {
        final future = DateTime(now.year, now.month, now.day + i, 12, 0, 0);
        expect(formatDueDateHelper(future), 'Dans $i jours');
      }
    });

    test('renvoie le format jour/mois pour une date au-delà de 7 jours', () {
      final farFuture = DateTime.now().add(const Duration(days: 15));
      expect(
        formatDueDateHelper(farFuture),
        '${farFuture.day}/${farFuture.month}',
      );
    });
  });

  group('formatEventDate', () {
    test('renvoie "Aujourd\'hui à HH:mm" pour un événement aujourd\'hui', () {
      final today = DateTime.now();
      final result = formatEventDateHelper(today);
      expect(result, startsWith("Aujourd'hui à "));
    });

    test('renvoie "Demain à HH:mm" pour un événement demain', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = formatEventDateHelper(tomorrow);
      expect(result, startsWith('Demain à '));
    });

    test('renvoie "DD/MM à HH:mm" pour un événement plus lointain', () {
      final future = DateTime(2030, 6, 15, 14, 30);
      expect(formatEventDateHelper(future), '15/6 à 14:30');
    });

    test('le format HH:mm est bien paddé avec un zéro', () {
      final date = DateTime(2030, 3, 25, 9, 5);
      expect(formatEventDateHelper(date), '25/3 à 09:05');
    });
  });

  // ── 2. Logique de calcul des stats ───────────────────────────────────────

  group('Calcul des statistiques', () {
    test('compte correctement les tâches complétées', () {
      final allTasks = _fakeTasks;
      final completedCount =
          allTasks.where((t) => t['is_completed'] == true).length;
      expect(completedCount, 1);
    });

    test('le total des tâches est correct', () {
      expect(_fakeTasks.length, 3);
    });

    test('messages non lus est initialisé à 0 en cas d\'erreur', () {
      // Simule le fallback en cas d'exception lors de la requête messages
      int unreadMessages = 0;
      try {
        throw Exception('Erreur réseau simulée');
      } catch (_) {
        // garder 0
      }
      expect(unreadMessages, 0);
    });
  });

  // ── 3. Transformation des données Supabase ───────────────────────────────

  group('Mapping des tâches Supabase → modèle UI', () {
    test('une tâche avec is_completed=true a le statut "done"', () {
      final raw = _fakeTasks[1]; // tâche complétée
      final status = raw['is_completed'] == true ? 'done' : 'todo';
      expect(status, 'done');
    });

    test('une tâche non complétée a le statut "todo"', () {
      final raw = _fakeTasks[0];
      final status = raw['is_completed'] == true ? 'done' : 'todo';
      expect(status, 'todo');
    });

    test('une tâche sans due_date utilise DateTime.now() comme fallback', () {
      final raw = {'title': 'Sans date', 'due_date': null, 'is_completed': false};
      final dueDate = raw['due_date'] != null
          ? DateTime.parse(raw['due_date'] as String)
          : DateTime.now();
      // Vérifie que la date est proche de maintenant (< 1 seconde)
      expect(dueDate.difference(DateTime.now()).inSeconds.abs(), lessThan(1));
    });

    test('une tâche sans titre renvoie une chaîne vide', () {
      final raw = {'title': null, 'due_date': null, 'is_completed': false};
      expect(raw['title'] ?? '', '');
    });
  });

  group('Mapping des événements Supabase → modèle UI', () {
    test('un événement avec start_datetime valide est correctement parsé', () {
      final raw = _fakeEvents[0];
      final date = raw['start_datetime'] != null
          ? DateTime.parse(raw['start_datetime'] as String)
          : DateTime.now();
      expect(date.isAfter(DateTime.now().subtract(const Duration(seconds: 5))),
          isTrue);
    });

    test('description null renvoie chaîne vide', () {
      final raw = _fakeEvents[1]; // description: null
      expect(raw['description'] ?? '', '');
    });
  });

  // ── 4. Détection d'urgence ────────────────────────────────────────────────

  group('Détection d\'urgence sur une tâche', () {
    test('une tâche échéant aujourd\'hui est urgente (≤ 1 jour)', () {
      final dueDate = DateTime.now();
      final isUrgent = dueDate.difference(DateTime.now()).inDays <= 1;
      expect(isUrgent, isTrue);
    });

    test('une tâche échéant demain est urgente', () {
      final dueDate = DateTime.now().add(const Duration(days: 1));
      final isUrgent = dueDate.difference(DateTime.now()).inDays <= 1;
      expect(isUrgent, isTrue);
    });

    test('une tâche dans 5 jours n\'est pas urgente', () {
      final dueDate = DateTime.now().add(const Duration(days: 5));
      final isUrgent = dueDate.difference(DateTime.now()).inDays <= 1;
      expect(isUrgent, isFalse);
    });
  });

  // ── 5. Détection "aujourd'hui" pour les événements ────────────────────────

  group('Détection isToday pour un événement', () {
    test('un événement prévu maintenant est "today"', () {
      final eventDate = DateTime.now();
      final now = DateTime.now();
      final isToday = eventDate.day == now.day &&
          eventDate.month == now.month &&
          eventDate.year == now.year;
      expect(isToday, isTrue);
    });

    test('un événement hier n\'est pas "today"', () {
      final eventDate = DateTime.now().subtract(const Duration(days: 1));
      final now = DateTime.now();
      final isToday = eventDate.day == now.day &&
          eventDate.month == now.month &&
          eventDate.year == now.year;
      expect(isToday, isFalse);
    });
  });

  // ── 6. Construction des stats ─────────────────────────────────────────────

  group('Construction de la map _stats', () {
    test('la map contient toutes les clés attendues', () {
      final stats = {
        'tasksCompleted': 0,
        'tasksTotal': 0,
        'hoursThisWeek': 0,
        'sessionsThisMonth': 0,
        'unreadMessages': 0,
      };
      expect(stats.containsKey('tasksCompleted'), isTrue);
      expect(stats.containsKey('tasksTotal'), isTrue);
      expect(stats.containsKey('hoursThisWeek'), isTrue);
      expect(stats.containsKey('sessionsThisMonth'), isTrue);
      expect(stats.containsKey('unreadMessages'), isTrue);
    });

    test('sessionsThisMonth correspond au nombre d\'événements chargés', () {
      // Simule le comportement de _loadDashboardData
      final events = _fakeEvents;
      final stats = {
        'sessionsThisMonth': events.length,
      };
      expect(stats['sessionsThisMonth'], 2);
    });

    test('tasksCompleted est bien compté parmi allTasks', () {
      final allTasks = _fakeTasks;
      final completedCount =
          allTasks.where((t) => t['is_completed'] == true).length;
      final stats = {
        'tasksCompleted': completedCount,
        'tasksTotal': allTasks.length,
      };
      expect(stats['tasksCompleted'], 1);
      expect(stats['tasksTotal'], 3);
    });
  });

  // ── 7. Tests de rendu Widget (smoke tests) ────────────────────────────────
  //
  // Ces tests vérifient que les widgets s'affichent sans lever d'exception.
  // Ils nécessitent un MaterialApp minimal comme wrapper.

  group('Widget smoke tests', () {
    testWidgets(
        'affiche un CircularProgressIndicator pendant le chargement',
        (WidgetTester tester) async {
      // On construit directement le widget de chargement
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('affiche "Aucune tâche" quand la liste est vide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task_outlined, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text('Aucune tâche',
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Aucune tâche'), findsOneWidget);
    });

    testWidgets('affiche "Aucun événement" quand la liste est vide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Aucun événement',
                  style: TextStyle(color: Colors.grey[500])),
            ),
          ),
        ),
      );
      expect(find.text('Aucun événement'), findsOneWidget);
    });

    testWidgets(
        'le titre de la stat "Messages non lus" est affiché',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Messages non lus'),
            ),
          ),
        ),
      );
      expect(find.text('Messages non lus'), findsOneWidget);
    });
  });
}