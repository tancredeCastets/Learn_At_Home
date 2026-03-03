import 'package:flutter/material.dart';
import 'login_page.dart';

enum UserRole { eleve, benevole }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  UserRole _selectedRole = UserRole.eleve;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter les conditions d\'utilisation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simuler une inscription
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // En-tête
              _buildHeader(),
              const SizedBox(height: 24),
              // Sélecteur de rôle
              _buildRoleSelector(),
              const SizedBox(height: 24),
              // Formulaire d'inscription
              _buildRegisterForm(),
              const SizedBox(height: 16),
              // Conditions d'utilisation
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              // Bouton d'inscription
              _buildRegisterButton(),
              const SizedBox(height: 24),
              // Lien vers connexion
              _buildLoginLink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez Learn At Home et commencez à apprendre',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Je suis',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                role: UserRole.eleve,
                icon: Icons.school_outlined,
                label: 'Élève',
                description: 'Je cherche de l\'aide',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleOption(
                role: UserRole.benevole,
                icon: Icons.volunteer_activism_outlined,
                label: 'Bénévole',
                description: 'Je veux aider',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90A4).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90A4) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4A90A4) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF4A90A4) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ prénom
          const Text(
            'Prénom',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Entrez votre prénom',
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4A90A4)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              if (value.length < 2) {
                return 'Le prénom doit contenir au moins 2 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Champ nom
          const Text(
            'Nom',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Entrez votre nom de famille',
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4A90A4)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              if (value.length < 2) {
                return 'Le nom doit contenir au moins 2 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Champ email
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Entrez votre email',
              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4A90A4)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Champ mot de passe
          const Text(
            'Mot de passe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Créez un mot de passe',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A90A4)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Champ confirmation mot de passe
          const Text(
            'Confirmer le mot de passe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Confirmez votre mot de passe',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A90A4)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _toggleConfirmPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF4A90A4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                children: const [
                  TextSpan(text: "J'accepte les "),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      color: Color(0xFF4A90A4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(
                      color: Color(0xFF4A90A4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('S\'inscrire'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Se connecter',
            style: TextStyle(
              color: Color(0xFF4A90A4),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
