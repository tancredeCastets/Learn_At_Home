import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  int _unreadMessages = 0;
  
  List<Map<String, dynamic>> _upcomingTasks = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  Map<String, dynamic> _stats = {
    'tasksCompleted': 0,
    'tasksTotal': 0,
    'hoursThisWeek': 0,
    'sessionsThisMonth': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Charger les tâches
      final tasksResponse = await supabase
          .from('tasks')
          .select()
          .or('created_by.eq.$userId,assigned_to.eq.$userId')
          .order('due_date', ascending: true)
          .limit(5);

      // Charger les événements
      final eventsResponse = await supabase
          .from('events')
          .select()
          .eq('created_by', userId)
          .gte('start_datetime', DateTime.now().toIso8601String())
          .order('start_datetime', ascending: true)
          .limit(5);

      // Calculer les stats
      final allTasksResponse = await supabase
          .from('tasks')
          .select()
          .or('created_by.eq.$userId,assigned_to.eq.$userId');

      final allTasks = List<Map<String, dynamic>>.from(allTasksResponse);
      final completedTasks = allTasks.where((t) => t['is_completed'] == true).length;

      setState(() {
        _upcomingTasks = List<Map<String, dynamic>>.from(tasksResponse).map((task) {
          return {
            'title': task['title'] ?? '',
            'description': task['description'] ?? '',
            'dueDate': task['due_date'] != null 
                ? DateTime.parse(task['due_date']) 
                : DateTime.now(),
            'status': task['is_completed'] == true ? 'done' : 'todo',
          };
        }).toList();

        _upcomingEvents = List<Map<String, dynamic>>.from(eventsResponse).map((event) {
          return {
            'title': event['title'] ?? '',
            'description': event['description'] ?? '',
            'date': event['start_datetime'] != null 
                ? DateTime.parse(event['start_datetime']) 
                : DateTime.now(),
          };
        }).toList();

        _stats = {
          'tasksCompleted': completedTasks,
          'tasksTotal': allTasks.length,
          'hoursThisWeek': 0,
          'sessionsThisMonth': _upcomingEvents.length,
        };

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A90A4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadDashboardData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données actualisées')),
              );
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte de bienvenue avec messages non lus
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    
                    // Statistiques rapides
            _buildStatsRow(),
            const SizedBox(height: 24),
            
            // To-do list résumée
            _buildSectionTitle('Mes tâches à venir', Icons.task_alt),
            const SizedBox(height: 12),
            _buildTasksList(),
            const SizedBox(height: 24),
            
            // Prochains événements
            _buildSectionTitle('Prochains événements', Icons.event),
            const SizedBox(height: 12),
            _buildEventsList(),
            const SizedBox(height: 24),
            
            // Progression
            _buildSectionTitle('Ma progression', Icons.trending_up),
            const SizedBox(height: 12),
            _buildProgressCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90A4), Color(0xFF357A8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90A4).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour ! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous avez $_unreadMessages messages non lus',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Voir les messages'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4A90A4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.mail,
                  size: 40,
                  color: Colors.white,
                ),
                if (_unreadMessages > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_unreadMessages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tâches',
            '${_stats['tasksCompleted']}/${_stats['tasksTotal']}',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Heures/sem',
            '${_stats['hoursThisWeek']}h',
            Icons.access_time,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sessions',
            '${_stats['sessionsThisMonth']}',
            Icons.calendar_today,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A90A4), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    if (_upcomingTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.task_outlined, size: 40, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('Aucune tâche', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _upcomingTasks.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final task = _upcomingTasks[index];
          return _buildTaskItem(task);
        },
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final statusIcons = {
      'todo': Icons.radio_button_unchecked,
      'in_progress': Icons.pending,
      'done': Icons.check_circle,
    };

    final dueDate = task['dueDate'] as DateTime;
    final isUrgent = dueDate.difference(DateTime.now()).inDays <= 1;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF4A90A4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Row(
        children: [
          Icon(
            statusIcons[task['status']],
            size: 18,
            color: task['status'] == 'done' ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task['title'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 26, top: 4),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 12,
              color: isUrgent ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDueDate(dueDate),
              style: TextStyle(
                fontSize: 11,
                color: isUrgent ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navigation vers les détails de la tâche
      },
    );
  }

  Widget _buildEventsList() {
    if (_upcomingEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_outlined, size: 40, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('Aucun événement', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _upcomingEvents.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final event = _upcomingEvents[index];
          return _buildEventItem(event);
        },
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    final eventDate = event['date'] as DateTime;
    final isToday = eventDate.day == DateTime.now().day &&
        eventDate.month == DateTime.now().month &&
        eventDate.year == DateTime.now().year;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4A90A4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.event,
          color: Color(0xFF4A90A4),
        ),
      ),
      title: Text(
        event['title'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (event['description'] != null && event['description'].isNotEmpty)
            Text(
              event['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: isToday ? Colors.green : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatEventDate(eventDate),
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? Colors.green : Colors.grey[600],
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navigation vers les détails de l'événement
      },
    );
  }

  Widget _buildProgressCard() {
    final completionRate = _stats['tasksCompleted'] / _stats['tasksTotal'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tâches complétées',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90A4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90A4)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('À faire', _stats['tasksTotal'] - _stats['tasksCompleted'], Colors.orange),
              _buildProgressStat('Terminées', _stats['tasksCompleted'], Colors.green),
              _buildProgressStat('Total', _stats['tasksTotal'], const Color(0xFF4A90A4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return "Aujourd'hui";
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference < 7) {
      return 'Dans $difference jours';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
    final isTomorrow = date.day == now.day + 1 && date.month == now.month && date.year == now.year;
    
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    if (isToday) {
      return "Aujourd'hui à $time";
    } else if (isTomorrow) {
      return 'Demain à $time';
    } else {
      return '${date.day}/${date.month} à $time';
    }
  }
}
