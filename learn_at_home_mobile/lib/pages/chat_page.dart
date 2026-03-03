import 'package:flutter/material.dart';
import 'chat_conversation_page.dart';
import '../widgets/bottom_nav_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  // Données simulées des conversations
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Marie Dupont',
      'avatar': 'M',
      'lastMessage': 'D\'accord, on se voit demain pour le cours de maths !',
      'time': '14:30',
      'unread': 2,
    },
    {
      'id': '2',
      'name': 'Pierre Martin',
      'avatar': 'P',
      'lastMessage': 'As-tu compris l\'exercice 3 ?',
      'time': '12:15',
      'unread': 0,
    },
    {
      'id': '3',
      'name': 'Sophie Bernard',
      'avatar': 'S',
      'lastMessage': 'Merci pour ton aide !',
      'time': 'Hier',
      'unread': 0,
    },
    {
      'id': '4',
      'name': 'Lucas Petit',
      'avatar': 'L',
      'lastMessage': 'Je t\'envoie les documents ce soir.',
      'time': 'Hier',
      'unread': 1,
    },
    {
      'id': '5',
      'name': 'Emma Leroy',
      'avatar': 'E',
      'lastMessage': 'À quelle heure le prochain cours ?',
      'time': 'Lun',
      'unread': 0,
    },
  ];

  // Données simulées des contacts
  List<Map<String, dynamic>> _contacts = [
    {'name': 'Marie Dupont', 'avatar': 'M'},
    {'name': 'Pierre Martin', 'avatar': 'P'},
    {'name': 'Sophie Bernard', 'avatar': 'S'},
    {'name': 'Lucas Petit', 'avatar': 'L'},
    {'name': 'Emma Leroy', 'avatar': 'E'},
    {'name': 'Thomas Moreau', 'avatar': 'T'},
    {'name': 'Julie Garcia', 'avatar': 'J'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsList(),
          _buildContactsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tabController.index == 0 ? _showNewConversationDialog : _showAddContactDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: Icon(
          _tabController.index == 0 ? Icons.chat_bubble_outline : Icons.person_add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                filled: false,
              ),
              onChanged: (value) => setState(() {}),
            )
          : const Text(
              'Messages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: const Color(0xFF4A90A4),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF4A90A4)),
          onPressed: _showOptionsMenu,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF4A90A4),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF4A90A4),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Conversations'),
          Tab(text: 'Contacts'),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    final filteredConversations = _conversations.where((conv) {
      if (_searchController.text.isEmpty) return true;
      return conv['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          conv['lastMessage'].toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    if (filteredConversations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Aucune conversation',
        subtitle: 'Commencez une nouvelle conversation',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final hasUnread = conversation['unread'] > 0;

    return Dismissible(
      key: Key(conversation['id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeleteConversation(conversation['name']),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF4A90A4).withOpacity(0.2),
                child: Text(
                  conversation['avatar'],
                  style: const TextStyle(
                    color: Color(0xFF4A90A4),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conversation['name'],
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              Text(
                conversation['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: hasUnread ? const Color(0xFF4A90A4) : Colors.grey,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  conversation['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasUnread ? const Color(0xFF2D3748) : Colors.grey[600],
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (hasUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90A4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${conversation['unread']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => _openConversation(conversation),
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    final filteredContacts = _contacts.where((contact) {
      if (_searchController.text.isEmpty) return true;
      return contact['name'].toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    if (filteredContacts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'Aucun contact',
        subtitle: 'Ajoutez des contacts pour commencer',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return _buildContactTile(contact);
      },
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF4A90A4).withOpacity(0.2),
          child: Text(
            contact['avatar'],
            style: const TextStyle(
              color: Color(0xFF4A90A4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4A90A4)),
              onPressed: () => _startConversationWithContact(contact),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showContactOptions(contact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90A4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF4A90A4)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _openConversation(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(
          contactName: conversation['name'],
          contactAvatar: conversation['avatar'],
        ),
      ),
    );
  }

  void _startConversationWithContact(Map<String, dynamic> contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(
          contactName: contact['name'],
          contactAvatar: contact['avatar'],
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteConversation(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la conversation'),
            content: Text('Voulez-vous vraiment supprimer la conversation avec $name ?'),
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

  void _showNewConversationDialog() {
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
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nouvelle conversation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4A90A4).withOpacity(0.2),
                      child: Text(
                        contact['avatar'],
                        style: const TextStyle(
                          color: Color(0xFF4A90A4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(contact['name']),
                    onTap: () {
                      Navigator.pop(context);
                      _startConversationWithContact(contact);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
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
              leading: const Icon(Icons.mark_chat_read, color: Color(0xFF4A90A4)),
              title: const Text('Tout marquer comme lu'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les conversations marquées comme lues')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Color(0xFF4A90A4)),
              title: const Text('Conversations archivées'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4A90A4)),
              title: const Text('Paramètres de chat'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(Map<String, dynamic> contact) {
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
              leading: const Icon(Icons.person, color: Color(0xFF4A90A4)),
              title: const Text('Voir le profil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Bloquer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer le contact'),
              onTap: () {
                Navigator.pop(context);
                _deleteContact(contact);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteContact(Map<String, dynamic> contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contact'),
        content: Text('Voulez-vous vraiment supprimer ${contact['name']} de vos contacts ?'),
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
    );

    if (confirm == true) {
      setState(() {
        _contacts.removeWhere((c) => c['name'] == contact['name']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contact['name']} supprimé de vos contacts')),
        );
      }
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();

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
                'Ajouter un contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du contact',
                  hintText: 'Ex: Jean Martin',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      _addContact(nameController.text);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90A4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _addContact(String name) {
    setState(() {
      _contacts.add({
        'name': name,
        'avatar': name.isNotEmpty ? name[0].toUpperCase() : '?',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name ajouté à vos contacts')),
    );
  }
}
