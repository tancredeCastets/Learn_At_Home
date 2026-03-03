import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  bool _isMonthView = true; // true = mois, false = semaine

  // Événements simulés
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _initEvents();
  }

  void _initEvents() {
    final now = DateTime.now();
    
    // Ajouter des événements de test
    _events[DateTime(now.year, now.month, now.day)] = [
      {
        'title': 'Cours de Maths',
        'time': '14:00 - 15:30',
        'type': 'cours',
        'color': const Color(0xFF4CAF50),
        'with': 'Marie Dupont',
      },
      {
        'title': 'Révision Français',
        'time': '16:00 - 17:00',
        'type': 'revision',
        'color': const Color(0xFF2196F3),
        'with': 'Pierre Martin',
      },
    ];

    _events[DateTime(now.year, now.month, now.day + 1)] = [
      {
        'title': 'RDV Orientation',
        'time': '10:00 - 11:00',
        'type': 'rdv',
        'color': const Color(0xFFFF9800),
        'with': 'Sophie Bernard',
      },
    ];

    _events[DateTime(now.year, now.month, now.day + 3)] = [
      {
        'title': 'Cours de Physique',
        'time': '09:00 - 10:30',
        'type': 'cours',
        'color': const Color(0xFF4CAF50),
        'with': 'Lucas Petit',
      },
      {
        'title': 'Aide aux devoirs',
        'time': '14:00 - 15:00',
        'type': 'cours',
        'color': const Color(0xFF9C27B0),
        'with': 'Emma Leroy',
      },
    ];

    _events[DateTime(now.year, now.month, now.day + 5)] = [
      {
        'title': 'Examen Blanc',
        'time': '08:00 - 12:00',
        'type': 'examen',
        'color': const Color(0xFFF44336),
        'with': '',
      },
    ];
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildViewToggle(),
            _isMonthView ? _buildMonthView() : _buildWeekView(),
            const SizedBox(height: 8),
            _buildEventsList(),
            const SizedBox(height: 80), // Espace pour le FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Calendrier',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today, color: Color(0xFF4A90A4)),
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
              _focusedMonth = DateTime.now();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.sync, color: Color(0xFF4A90A4)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Synchronisation en cours...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMonthView = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isMonthView ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isMonthView
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Mois',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: _isMonthView ? FontWeight.bold : FontWeight.normal,
                    color: _isMonthView ? const Color(0xFF4A90A4) : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMonthView = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isMonthView ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isMonthView
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Semaine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: !_isMonthView ? FontWeight.bold : FontWeight.normal,
                    color: !_isMonthView ? const Color(0xFF4A90A4) : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 12),
          _buildWeekDaysHeader(),
          const SizedBox(height: 6),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF4A90A4)),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color(0xFF4A90A4)),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    // Ajuster pour commencer le lundi (1) au lieu du dimanche (7)
    int startingWeekday = firstDayOfMonth.weekday;
    
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((startingWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - (startingWeekday - 1);
        
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox();
        }

        final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset + 1);
        final isSelected = _isSameDay(day, _selectedDate);
        final isToday = _isSameDay(day, DateTime.now());
        final hasEvents = _getEventsForDay(day).isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF4A90A4)
                  : isToday
                      ? const Color(0xFF4A90A4).withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${dayOffset + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF4A90A4)
                            : const Color(0xFF2D3748),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF4A90A4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    // Trouver le lundi de la semaine sélectionnée
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeekHeader(monday),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (index) {
              final day = monday.add(Duration(days: index));
              final isSelected = _isSameDay(day, _selectedDate);
              final isToday = _isSameDay(day, DateTime.now());
              final hasEvents = _getEventsForDay(day).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90A4)
                          : isToday
                              ? const Color(0xFF4A90A4).withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          ['L', 'M', 'M', 'J', 'V', 'S', 'D'][index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF4A90A4)
                                    : const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasEvents)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : const Color(0xFF4A90A4),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF4A90A4)),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 7));
            });
          },
        ),
        Text(
          '${monday.day} ${months[monday.month - 1]} - ${sunday.day} ${months[sunday.month - 1]}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color(0xFF4A90A4)),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 7));
            });
          },
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDate);
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${dayNames[_selectedDate.weekday - 1]} ${_selectedDate.day} ${months[_selectedDate.month - 1]}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          events.isEmpty
              ? _buildEmptyEvents()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(events[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyEvents() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun événement',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour ajouter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: event['color'],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event['time'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (event['with'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event['with'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showEventOptions(event),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    String selectedType = 'cours';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nouvel événement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Ex: Cours de maths',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Type d\'événement', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildTypeChip('cours', 'Cours', Colors.green, selectedType, (type) {
                    setModalState(() => selectedType = type);
                  }),
                  _buildTypeChip('rdv', 'RDV', Colors.orange, selectedType, (type) {
                    setModalState(() => selectedType = type);
                  }),
                  _buildTypeChip('revision', 'Révision', Colors.blue, selectedType, (type) {
                    setModalState(() => selectedType = type);
                  }),
                  _buildTypeChip('examen', 'Examen', Colors.red, selectedType, (type) {
                    setModalState(() => selectedType = type);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Début'),
                      subtitle: Text('${startTime.format(context)}'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          setModalState(() => startTime = time);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fin'),
                      subtitle: Text('${endTime.format(context)}'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          setModalState(() => endTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      _addEvent(
                        titleController.text,
                        selectedType,
                        startTime,
                        endTime,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, Color color, String selected, Function(String) onSelect) {
    final isSelected = value == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _addEvent(String title, String type, TimeOfDay start, TimeOfDay end) {
    final colors = {
      'cours': const Color(0xFF4CAF50),
      'rdv': const Color(0xFFFF9800),
      'revision': const Color(0xFF2196F3),
      'examen': const Color(0xFFF44336),
    };

    final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final newEvent = {
      'title': title,
      'time': '${start.format(context)} - ${end.format(context)}',
      'type': type,
      'color': colors[type],
      'with': '',
    };

    setState(() {
      if (_events[key] == null) {
        _events[key] = [newEvent];
      } else {
        _events[key]!.add(newEvent);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Événement ajouté')),
    );
  }

  void _showEventOptions(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF4A90A4)),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la modification
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF4A90A4)),
              title: const Text('Ajouter un rappel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rappel ajouté')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(Map<String, dynamic> event) {
    final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    setState(() {
      _events[key]?.remove(event);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Événement supprimé')),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
