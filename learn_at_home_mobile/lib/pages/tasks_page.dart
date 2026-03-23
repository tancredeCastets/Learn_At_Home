import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_header.dart';

enum TaskRole { eleve, tuteur }

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskRole _currentRole = TaskRole.tuteur; // Simuler le rôle actuel
  bool _isLoading = true;

  // Élèves du tuteur (simulés)
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Pierre Martin', 'avatar': 'P'},
    {'id': '2', 'name': 'Emma Leroy', 'avatar': 'E'},
    {'id': '3', 'name': 'Lucas Petit', 'avatar': 'L'},
  ];

  // Tâches depuis Supabase
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('tasks')
          .select()
          .or('created_by.eq.$userId,assigned_to.eq.$userId')
          .order('due_date', ascending: true);

      setState(() {
        _tasks = List<Map<String, dynamic>>.from(response).map((task) {
          // Convertir le format Supabase vers le format local
          return {
            'id': task['id'],
            'title': task['title'] ?? '',
            'description': task['description'] ?? '',
            'dueDate': task['due_date'] != null 
                ? DateTime.parse(task['due_date']) 
                : DateTime.now(),
            'status': task['is_completed'] == true ? 'termine' : 'a_faire',
            'assignedTo': 'Moi',
            'assignedBy': 'Moi',
          };
        }).toList();
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getTasksByStatus(String status) {
    if (status == 'all') {
      return _tasks;
    }
    return _tasks.where((task) => task['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppHeader(
        title: 'Gestion des Tâches',
        onRefresh: _loadTasks,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            onPressed: _toggleRole,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRoleIndicator(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('all'),
                _buildTaskList('a_faire'),
                _buildTaskList('termine'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  // ignore: unused_element
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Gestion des Tâches',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF4A90A4)),
          onPressed: _showFilterOptions,
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: Color(0xFF4A90A4)),
          onPressed: _toggleRole,
        ),
      ],
    );
  }

  Widget _buildRoleIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _currentRole == TaskRole.tuteur
            ? const Color(0xFF4A90A4).withOpacity(0.1)
            : const Color(0xFF9C27B0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _currentRole == TaskRole.tuteur
              ? const Color(0xFF4A90A4)
              : const Color(0xFF9C27B0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _currentRole == TaskRole.tuteur
                ? Icons.volunteer_activism
                : Icons.school,
            color: _currentRole == TaskRole.tuteur
                ? const Color(0xFF4A90A4)
                : const Color(0xFF9C27B0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentRole == TaskRole.tuteur
                      ? 'Mode Tuteur'
                      : 'Mode Élève',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentRole == TaskRole.tuteur
                        ? const Color(0xFF4A90A4)
                        : const Color(0xFF9C27B0),
                  ),
                ),
                Text(
                  _currentRole == TaskRole.tuteur
                      ? 'Vous pouvez créer et assigner des tâches'
                      : 'Vous pouvez créer des tâches pour vous-même',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (_currentRole == TaskRole.tuteur)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_students.length} élèves',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: const Color(0xFF4A90A4),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Toutes'),
                const SizedBox(width: 4),
                _buildBadge(_getTasksByStatus('all').length),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('À faire'),
                const SizedBox(width: 4),
                _buildBadge(_getTasksByStatus('a_faire').length),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Terminé'),
                const SizedBox(width: 4),
                _buildBadge(_getTasksByStatus('termine').length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    if (count == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90A4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskList(String status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final tasks = _getTasksByStatus(status);

    if (tasks.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(tasks[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'all':
        message = 'Aucune tâche';
        icon = Icons.task_outlined;
        break;
      case 'a_faire':
        message = 'Aucune tâche à faire';
        icon = Icons.hourglass_empty;
        break;
      case 'termine':
        message = 'Aucune tâche terminée';
        icon = Icons.done_all;
        break;
      default:
        message = 'Aucune tâche';
        icon = Icons.task;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (_currentRole == TaskRole.tuteur) ...[
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer une tâche',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final isOverdue = task['dueDate'].isBefore(DateTime.now()) && task['status'] != 'termine';

    return Dismissible(
      key: Key(task['id']),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _updateTaskStatus(task, _getNextStatus(task['status']));
          return false;
        } else {
          return await _confirmDelete(task['title']);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          setState(() {
            _tasks.removeWhere((t) => t['id'] == task['id']);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${task['title']}" supprimée')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isOverdue ? Border.all(color: Colors.red, width: 1) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showTaskDetails(task),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90A4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF2D3748),
                              decoration: task['status'] == 'termine'
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),

                        ],
                      ),
                    ),
                    _buildStatusChip(task['status']),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task['assignedTo'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task['dueDate']),
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusConfig = {
      'all': {'label': 'Toutes', 'color': Colors.grey},
      'a_faire': {'label': 'À faire', 'color': Colors.blue},
      'termine': {'label': 'Terminé', 'color': Colors.green},
    };

    final config = statusConfig[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          fontSize: 11,
          color: config['color'] as Color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return "Aujourd'hui";
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference == -1) {
      return 'Hier';
    } else if (difference < -1) {
      return 'Il y a ${-difference} jours';
    } else {
      return 'Dans $difference jours';
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'a_faire':
        return 'termine';
      default:
        return 'a_faire';
    }
  }

  Future<void> _updateTaskStatus(Map<String, dynamic> task, String newStatus) async {
    try {
      final supabase = Supabase.instance.client;
      final isCompleted = newStatus == 'termine';
      
      await supabase.from('tasks').update({
        'is_completed': isCompleted,
      }).eq('id', task['id']);

      setState(() {
        task['status'] = newStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tâche mise à jour : ${_getStatusLabel(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'a_faire':
        return 'À faire';
      case 'termine':
        return 'Terminé';
      default:
        return status;
    }
  }

  Future<bool> _confirmDelete(String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la tâche'),
            content: Text('Voulez-vous vraiment supprimer "$title" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toggleRole() {
    setState(() {
      _currentRole = _currentRole == TaskRole.tuteur ? TaskRole.eleve : TaskRole.tuteur;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentRole == TaskRole.tuteur
              ? 'Mode Tuteur activé'
              : 'Mode Élève activé',
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filtrer par',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('Priorité haute'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text('Priorité moyenne'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.green),
              title: const Text('Priorité basse'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('En retard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Color(0xFF4A90A4)),
              title: const Text('Effacer les filtres'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'Assigné à', task['assignedTo']),
              _buildDetailRow(Icons.person_outline, 'Assigné par', task['assignedBy']),
              _buildDetailRow(Icons.calendar_today, 'Échéance', _formatDate(task['dueDate'])),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditTaskDialog(task);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateTaskStatus(task, _getNextStatus(task['status']));
                      },
                      icon: const Icon(Icons.check),
                      label: Text(
                        task['status'] == 'a_faire'
                            ? 'Terminer'
                            : 'Rouvrir',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A90A4)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedStudent;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle tâche',
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
                    hintText: 'Ex: Exercices de maths',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Détails de la tâche...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentRole == TaskRole.tuteur)
                  DropdownButtonFormField<String>(
                    value: selectedStudent,
                    decoration: InputDecoration(
                      labelText: 'Assigner à',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _students
                        .map((s) => DropdownMenuItem(
                              value: s['name'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedStudent = value);
                    },
                  ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF4A90A4)),
                  title: const Text('Date d\'échéance'),
                  subtitle: Text(_formatFullDate(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final assignee = _currentRole == TaskRole.tuteur 
                            ? (selectedStudent ?? 'Non assigné')
                            : 'Moi-même';
                        _addTask(
                          titleController.text,
                          descriptionController.text,
                          assignee,
                          selectedDate,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Créer la tâche'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _addTask(
    String title,
    String description,
    String assignedTo,
    DateTime dueDate,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('tasks').insert({
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String().split('T')[0],
        'is_completed': false,
        'created_by': userId,
        'assigned_to': userId,
      });

      // Recharger les tâches depuis Supabase
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâche créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    final descriptionController = TextEditingController(text: task['description']);
    String selectedStudent = task['assignedTo'];
    DateTime selectedDate = task['dueDate'];

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modifier la tâche',
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
                    hintText: 'Ex: Exercices de maths',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Détails de la tâche...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentRole == TaskRole.tuteur)
                  DropdownButtonFormField<String>(
                    value: _students.any((s) => s['name'] == selectedStudent) ? selectedStudent : null,
                    decoration: InputDecoration(
                      labelText: 'Assigner à',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _students
                        .map((s) => DropdownMenuItem(
                              value: s['name'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedStudent = value!);
                    },
                  ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF4A90A4)),
                  title: const Text('Date d\'échéance'),
                  subtitle: Text(_formatFullDate(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        _updateTask(
                          task,
                          titleController.text,
                          descriptionController.text,
                          selectedStudent,
                          selectedDate,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateTask(
    Map<String, dynamic> task,
    String title,
    String description,
    String assignedTo,
    DateTime dueDate,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('tasks').update({
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String().split('T')[0],
      }).eq('id', task['id']);

      setState(() {
        task['title'] = title;
        task['description'] = description;
        task['assignedTo'] = assignedTo;
        task['dueDate'] = dueDate;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâche modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
