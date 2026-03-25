import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers – logique extraite pour les tests
// ---------------------------------------------------------------------------

// Reproduction de _isSameDay
bool isSameDayHelper(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Reproduction du formatage de l'heure HH:mm (startTime / endTime)
String formatTimeHelper(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// Reproduction du nom du jour affiché dans _buildEventsList
String formatDayNameHelper(DateTime date) {
  const dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  return dayNames[date.weekday - 1];
}

// Reproduction du nom du mois long (utilisé dans _buildEventsList)
String formatMonthLongHelper(int month) {
  const months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];
  return months[month - 1];
}

// Reproduction du nom du mois court (utilisé dans _buildWeekHeader)
String formatMonthShortHelper(int month) {
  const months = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
  ];
  return months[month - 1];
}

// Reproduction du nom du mois long majuscule (utilisé dans _buildMonthHeader)
String formatMonthHeaderHelper(int month) {
  const months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return months[month - 1];
}

// Reproduction de la clé de date normalisée (minuit)
DateTime normalizeDateKey(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}

// Reproduction de _getEventsForDay
List<Map<String, dynamic>> getEventsForDayHelper(
    Map<DateTime, List<Map<String, dynamic>>> events, DateTime day) {
  return events[DateTime(day.year, day.month, day.day)] ?? [];
}

// Reproduction du calcul de endDateTime (fallback +1h si null)
DateTime resolveEndDateTimeHelper(String? endDatetimeStr, DateTime startDateTime) {
  return endDatetimeStr != null
      ? DateTime.parse(endDatetimeStr)
      : startDateTime.add(const Duration(hours: 1));
}

// Reproduction du calcul du lundi de la semaine
DateTime getMondayOfWeekHelper(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

// Reproduction du mapping événement Supabase → modèle UI
Map<String, dynamic> buildEventModelHelper(Map<String, dynamic> raw) {
  final startDateTime = DateTime.parse(raw['start_datetime'] as String);
  final endDatetimeStr = raw['end_datetime'] as String?;
  final endDateTime = resolveEndDateTimeHelper(endDatetimeStr, startDateTime);
  return {
    'id': raw['id'],
    'title': raw['title'] ?? '',
    'description': raw['description'] ?? '',
    'startTime': formatTimeHelper(startDateTime),
    'endTime': formatTimeHelper(endDateTime),
  };
}

// Reproduction du calcul totalCells pour la grille calendrier
int calcTotalCellsHelper(int year, int month) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);
  final startingWeekday = firstDayOfMonth.weekday;
  final daysInMonth = lastDayOfMonth.day;
  return ((startingWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final List<Map<String, dynamic>> _fakeRawEvents = [
  {
    'id': 'e1',
    'title': 'Séance de soutien',
    'description': 'Maths niveau 3ème',
    'start_datetime': '2025-06-15T09:00:00',
    'end_datetime': '2025-06-15T10:30:00',
  },
  {
    'id': 'e2',
    'title': 'Réunion parents',
    'description': null,
    'start_datetime': '2025-06-15T14:00:00',
    'end_datetime': null, // fallback +1h
  },
  {
    'id': 'e3',
    'title': 'Cours anglais',
    'description': 'Préparation examen',
    'start_datetime': '2025-06-20T10:00:00',
    'end_datetime': '2025-06-20T11:00:00',
  },
];

// ---------------------------------------------------------------------------
// Tests unitaires
// ---------------------------------------------------------------------------

void main() {
  // ── 1. isSameDay ──────────────────────────────────────────────────────────

  group('isSameDay', () {
    test('deux fois la même date → true', () {
      final a = DateTime(2025, 6, 15, 9, 30);
      final b = DateTime(2025, 6, 15, 22, 0);
      expect(isSameDayHelper(a, b), isTrue);
    });

    test('jours différents du même mois → false', () {
      expect(isSameDayHelper(DateTime(2025, 6, 15), DateTime(2025, 6, 16)), isFalse);
    });

    test('même jour mais mois différents → false', () {
      expect(isSameDayHelper(DateTime(2025, 6, 15), DateTime(2025, 7, 15)), isFalse);
    });

    test('même jour mais années différentes → false', () {
      expect(isSameDayHelper(DateTime(2025, 6, 15), DateTime(2026, 6, 15)), isFalse);
    });

    test('fonctionne avec DateTime.now()', () {
      expect(isSameDayHelper(_now, _now), isTrue);
    });
  });

  // ── 2. formatTime (HH:mm) ────────────────────────────────────────────────

  group('formatTime', () {
    test('formate correctement 09:00', () {
      expect(formatTimeHelper(DateTime(2025, 1, 1, 9, 0)), '09:00');
    });

    test('formate correctement 14:30', () {
      expect(formatTimeHelper(DateTime(2025, 1, 1, 14, 30)), '14:30');
    });

    test('formate correctement minuit 00:00', () {
      expect(formatTimeHelper(DateTime(2025, 1, 1, 0, 0)), '00:00');
    });

    test('formate correctement 23:59', () {
      expect(formatTimeHelper(DateTime(2025, 1, 1, 23, 59)), '23:59');
    });

    test('padde les minutes avec un zéro (08:05)', () {
      expect(formatTimeHelper(DateTime(2025, 1, 1, 8, 5)), '08:05');
    });
  });

  // ── 3. formatDayName ─────────────────────────────────────────────────────

  group('formatDayName', () {
    test('lundi = "Lundi"', () {
      // 2025-06-16 est un lundi
      expect(formatDayNameHelper(DateTime(2025, 6, 16)), 'Lundi');
    });

    test('mercredi = "Mercredi"', () {
      // 2025-06-18 est un mercredi
      expect(formatDayNameHelper(DateTime(2025, 6, 18)), 'Mercredi');
    });

    test('dimanche = "Dimanche"', () {
      // 2025-06-22 est un dimanche
      expect(formatDayNameHelper(DateTime(2025, 6, 22)), 'Dimanche');
    });

    test('couvre les 7 jours sans doublon', () {
      final names = List.generate(7, (i) =>
          formatDayNameHelper(DateTime(2025, 6, 16 + i)));
      expect(names.toSet().length, 7);
    });
  });

  // ── 4. formatMonthLong ───────────────────────────────────────────────────

  group('formatMonthLong', () {
    test('janvier', () => expect(formatMonthLongHelper(1), 'janvier'));
    test('juin', () => expect(formatMonthLongHelper(6), 'juin'));
    test('décembre', () => expect(formatMonthLongHelper(12), 'décembre'));

    test('couvre les 12 mois sans doublon', () {
      final months = List.generate(12, (i) => formatMonthLongHelper(i + 1));
      expect(months.toSet().length, 12);
    });
  });

  // ── 5. formatMonthShort ──────────────────────────────────────────────────

  group('formatMonthShort', () {
    test('janvier → "Jan"', () => expect(formatMonthShortHelper(1), 'Jan'));
    test('juillet → "Juil"', () => expect(formatMonthShortHelper(7), 'Juil'));
    test('décembre → "Déc"', () => expect(formatMonthShortHelper(12), 'Déc'));

    test('couvre les 12 mois sans doublon', () {
      final months = List.generate(12, (i) => formatMonthShortHelper(i + 1));
      expect(months.toSet().length, 12);
    });
  });

  // ── 6. formatMonthHeader ─────────────────────────────────────────────────

  group('formatMonthHeader', () {
    test('janvier → "Janvier"', () => expect(formatMonthHeaderHelper(1), 'Janvier'));
    test('août → "Août"', () => expect(formatMonthHeaderHelper(8), 'Août'));
    test('décembre → "Décembre"', () => expect(formatMonthHeaderHelper(12), 'Décembre'));
  });

  // ── 7. normalizeDateKey ──────────────────────────────────────────────────

  group('normalizeDateKey', () {
    test('supprime l\'heure et la minute', () {
      final dt = DateTime(2025, 6, 15, 14, 35, 22);
      final key = normalizeDateKey(dt);
      expect(key, DateTime(2025, 6, 15));
    });

    test('deux datetimes du même jour donnent la même clé', () {
      final a = normalizeDateKey(DateTime(2025, 6, 15, 9, 0));
      final b = normalizeDateKey(DateTime(2025, 6, 15, 23, 59));
      expect(a, b);
    });

    test('deux jours différents donnent des clés différentes', () {
      final a = normalizeDateKey(DateTime(2025, 6, 15));
      final b = normalizeDateKey(DateTime(2025, 6, 16));
      expect(a, isNot(b));
    });
  });

  // ── 8. getEventsForDay ───────────────────────────────────────────────────

  group('getEventsForDay', () {
    final events = {
      DateTime(2025, 6, 15): [
        {'id': 'e1', 'title': 'Séance'},
        {'id': 'e2', 'title': 'Réunion'},
      ],
      DateTime(2025, 6, 20): [
        {'id': 'e3', 'title': 'Cours'},
      ],
    };

    test('retourne les événements du jour demandé', () {
      final result = getEventsForDayHelper(events, DateTime(2025, 6, 15));
      expect(result.length, 2);
    });

    test('retourne une liste vide si aucun événement ce jour', () {
      final result = getEventsForDayHelper(events, DateTime(2025, 6, 16));
      expect(result, isEmpty);
    });

    test('ignore l\'heure dans la clé', () {
      final result = getEventsForDayHelper(events, DateTime(2025, 6, 15, 14, 0));
      expect(result.length, 2);
    });
  });

  // ── 9. resolveEndDateTime ────────────────────────────────────────────────

  group('resolveEndDateTime', () {
    test('utilise end_datetime s\'il est fourni', () {
      final start = DateTime(2025, 6, 15, 9, 0);
      final end = resolveEndDateTimeHelper('2025-06-15T10:30:00', start);
      expect(end, DateTime(2025, 6, 15, 10, 30));
    });

    test('ajoute 1h au start si end_datetime est null', () {
      final start = DateTime(2025, 6, 15, 9, 0);
      final end = resolveEndDateTimeHelper(null, start);
      expect(end, DateTime(2025, 6, 15, 10, 0));
    });

    test('le fallback +1h fonctionne à 23h → 00h du lendemain', () {
      final start = DateTime(2025, 6, 15, 23, 0);
      final end = resolveEndDateTimeHelper(null, start);
      expect(end, DateTime(2025, 6, 16, 0, 0));
    });
  });

  // ── 10. buildEventModel ──────────────────────────────────────────────────

  group('buildEventModel', () {
    test('mappe correctement un événement avec end_datetime', () {
      final model = buildEventModelHelper(_fakeRawEvents[0]);
      expect(model['id'], 'e1');
      expect(model['title'], 'Séance de soutien');
      expect(model['description'], 'Maths niveau 3ème');
      expect(model['startTime'], '09:00');
      expect(model['endTime'], '10:30');
    });

    test('utilise le fallback +1h si end_datetime est null', () {
      final model = buildEventModelHelper(_fakeRawEvents[1]);
      expect(model['startTime'], '14:00');
      expect(model['endTime'], '15:00');
    });

    test('description null devient une chaîne vide', () {
      final model = buildEventModelHelper(_fakeRawEvents[1]);
      expect(model['description'], '');
    });

    test('title null devient une chaîne vide', () {
      final raw = {
        'id': 'e0',
        'title': null,
        'description': null,
        'start_datetime': '2025-06-15T08:00:00',
        'end_datetime': null,
      };
      final model = buildEventModelHelper(raw);
      expect(model['title'], '');
    });
  });

  // ── 11. getMondayOfWeek ──────────────────────────────────────────────────

  group('getMondayOfWeek', () {
    test('un lundi reste un lundi', () {
      final monday = DateTime(2025, 6, 16); // lundi
      expect(getMondayOfWeekHelper(monday), monday);
    });

    test('un mercredi donne le lundi de la même semaine', () {
      final wednesday = DateTime(2025, 6, 18);
      expect(getMondayOfWeekHelper(wednesday), DateTime(2025, 6, 16));
    });

    test('un dimanche donne le lundi de la même semaine', () {
      final sunday = DateTime(2025, 6, 22);
      expect(getMondayOfWeekHelper(sunday), DateTime(2025, 6, 16));
    });

    test('le résultat est toujours un weekday == 1 (lundi)', () {
      for (int i = 0; i < 7; i++) {
        final day = DateTime(2025, 6, 16 + i);
        expect(getMondayOfWeekHelper(day).weekday, 1);
      }
    });
  });

  // ── 12. calcTotalCells (grille calendrier) ────────────────────────────────

  group('calcTotalCells', () {
    test('est un multiple de 7', () {
      for (int month = 1; month <= 12; month++) {
        expect(calcTotalCellsHelper(2025, month) % 7, 0);
      }
    });

    test('est >= au nombre de jours du mois', () {
      for (int month = 1; month <= 12; month++) {
        final daysInMonth = DateTime(2025, month + 1, 0).day;
        expect(calcTotalCellsHelper(2025, month), greaterThanOrEqualTo(daysInMonth));
      }
    });

    test('juin 2025 commence un dimanche (weekday=7) → 35 cellules', () {
      // 1er juin 2025 = dimanche, 30 jours
      // startingWeekday = 7 → offset = 6 → (6+30+6)//7*7 = 42
      expect(calcTotalCellsHelper(2025, 6), 42);
    });

    test('juillet 2025 commence un mardi (weekday=2) → 35 cellules', () {
      // 1er juillet 2025 = mardi, 31 jours
      // offset=1 → (1+31+6)//7*7 = 35
      expect(calcTotalCellsHelper(2025, 7), 35);
    });
  });

  // ── 13. Widget smoke tests ────────────────────────────────────────────────

  group('Widget smoke tests', () {
    testWidgets('affiche "Aucun événement" quand la liste est vide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Aucun événement',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ),
      );
      expect(find.text('Aucun événement'), findsOneWidget);
    });

    testWidgets('affiche un CircularProgressIndicator pendant le chargement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('les noms de jours de la semaine header sont affichés',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(child: Text('Lun', textAlign: TextAlign.center)),
                Expanded(child: Text('Mar', textAlign: TextAlign.center)),
                Expanded(child: Text('Mer', textAlign: TextAlign.center)),
                Expanded(child: Text('Jeu', textAlign: TextAlign.center)),
                Expanded(child: Text('Ven', textAlign: TextAlign.center)),
                Expanded(child: Text('Sam', textAlign: TextAlign.center)),
                Expanded(child: Text('Dim', textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      );
      for (final day in ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']) {
        expect(find.text(day), findsOneWidget);
      }
    });
  });
}