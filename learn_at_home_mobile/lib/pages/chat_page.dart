import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_conversation_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_menu.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;

  // Conversations depuis Supabase
  List<Map<String, dynamic>> _conversations = [];

  // Contacts depuis Supabase
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadConversations(), _loadContacts()]);
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Charger les conversations où l'utilisateur est participant
      final response = await supabase
          .from('conversations')
          .select('id, last_message, last_message_at, participant_1, participant_2')
          .or('participant_1.eq.$userId,participant_2.eq.$userId')
          .order('last_message_at', ascending: false);

      // Charger les profils des autres participants
      final List<Map<String, dynamic>> conversations = [];
      
      for (final conv in response) {
        final isParticipant1 = conv['participant_1'] == userId;
        final otherUserId = isParticipant1 ? conv['participant_2'] : conv['participant_1'];
        
        String name = 'Utilisateur';
        
        if (otherUserId != null) {
          final profileResponse = await supabase
              .from('profiles')
              .select('first_name, last_name')
              .eq('id', otherUserId)
              .maybeSingle();
          
          if (profileResponse != null) {
            name = '${profileResponse['first_name'] ?? ''} ${profileResponse['last_name'] ?? ''}'.trim();
          }
        }
        
        conversations.add({
          'id': conv['id'],
          'name': name.isNotEmpty ? name : 'Utilisateur',
          'avatar': name.isNotEmpty ? name[0].toUpperCase() : '?',
          'lastMessage': conv['last_message'] ?? '',
          'time': _formatMessageTime(conv['last_message_at']),
          'unread': 0,
          'other_user_id': otherUserId,
        });
      }

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContacts() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Charger les contacts depuis la table contacts
      final response = await supabase
          .from('contacts')
          .select('id, contact_id')
          .eq('user_id', userId);

      final List<Map<String, dynamic>> contacts = [];
      
      for (final contact in response) {
        final contactId = contact['contact_id'];
        
        String name = 'Contact';
        String email = '';
        
        if (contactId != null) {
          final profileResponse = await supabase
              .from('profiles')
              .select('first_name, last_name, email')
              .eq('id', contactId)
              .maybeSingle();
          
          if (profileResponse != null) {
            name = '${profileResponse['first_name'] ?? ''} ${profileResponse['last_name'] ?? ''}'.trim();
            email = profileResponse['email'] ?? '';
          }
        }
        
        contacts.add({
          'id': contact['id'],
          'contact_id': contactId,
          'name': name.isNotEmpty ? name : 'Contact',
          'avatar': name.isNotEmpty ? name[0].toUpperCase() : '?',
          'email': email,
        });
      }

      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      // Silently fail for contacts
    }
  }

  String _formatMessageTime(String? dateStr) {
    if (dateStr == null) return '';
    
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      final jours = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
      return jours[date.weekday % 7];
    } else {
      return '${date.day}/${date.month}';
    }
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
        const ProfileMenu(),
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
          conversationId: conversation['id'],
          contactName: conversation['name'],
          contactAvatar: conversation['avatar'],
        ),
      ),
    );
  }

  Future<void> _startConversationWithContact(Map<String, dynamic> contact) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      final contactId = contact['contact_id'];

      // Vérifier si une conversation existe déjà
      final existing = await supabase
          .from('conversations')
          .select('id')
          .or('and(participant_1.eq.$userId,participant_2.eq.$contactId),and(participant_1.eq.$contactId,participant_2.eq.$userId)')
          .maybeSingle();

      String conversationId;

      if (existing != null) {
        conversationId = existing['id'];
      } else {
        // Créer une nouvelle conversation
        final response = await supabase.from('conversations').insert({
          'participant_1': userId,
          'participant_2': contactId,
        }).select('id').single();
        
        conversationId = response['id'];
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              conversationId: conversationId,
              contactName: contact['name'],
              contactAvatar: contact['avatar'],
            ),
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

  Future<void> _deleteContact(Map<String, dynamic> contact) async {
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
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('contacts').delete().eq('id', contact['id']);
        
        await _loadContacts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${contact['name']} supprimé de vos contacts'),
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

  void _showAddContactDialog() {
    final emailController = TextEditingController();

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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email du contact',
                  hintText: 'Ex: jean@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
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
                    if (emailController.text.isNotEmpty) {
                      _addContactByEmail(emailController.text);
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

  Future<void> _addContactByEmail(String email) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      // Trouver l'utilisateur par email
      final response = await supabase
          .from('profiles')
          .select('id, first_name, last_name')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun utilisateur trouvé avec cet email'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Ajouter le contact
      await supabase.from('contacts').insert({
        'user_id': userId,
        'contact_id': response['id'],
      });

      await _loadContacts();

      if (mounted) {
        final name = '${response['first_name'] ?? ''} ${response['last_name'] ?? ''}'.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name ajouté à vos contacts'),
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
