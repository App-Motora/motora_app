import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const Color _backgroundColor = AppColors.corFundo;
  static const Color _primaryYellow = AppColors.corPrincipal;
  static const Color _textColor = AppColors.corTexto;
  final Color _dividerColor = AppColors.corSombra;

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String _nome = 'Usuario';
  String _email = '';

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final user = _currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    String nome = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Usuario';
    String email = user.email ?? '';

    final doc = _userDoc;
    if (doc != null) {
      final snapshot = await doc.get();
      final data = snapshot.data();
      if (data != null) {
        final firestoreName = (data['nome'] ?? data['name'])?.toString();
        final firestoreEmail = data['email']?.toString();

        if (firestoreName != null && firestoreName.trim().isNotEmpty) {
          nome = firestoreName.trim();
        }
        if (firestoreEmail != null && firestoreEmail.trim().isNotEmpty) {
          email = firestoreEmail.trim();
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _nome = nome;
      _email = email;
      _nomeController.text = nome;
      _emailController.text = email;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _currentUser;
    final doc = _userDoc;
    if (user == null || doc == null) {
      _showMessage('Usuario nao encontrado.', AppColors.corErro);
      return;
    }

    final newName = _nomeController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _senhaController.text;
    final emailChanged = newEmail != (user.email ?? '');

    setState(() => _isSaving = true);

    try {
      await user.updateDisplayName(newName);

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      await doc.set({
        'nome': newName,
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();

      if (!mounted) return;
      setState(() {
        _nome = newName;
        _email = newEmail;
        _isEditing = false;
        _senhaController.clear();
        _confirmaSenhaController.clear();
      });

      _showMessage(
        emailChanged
            ? 'Dados salvos. Confira seu e-mail para confirmar a alteracao.'
            : 'Dados salvos com sucesso!',
        AppColors.corSucesso,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(_authErrorMessage(e), AppColors.corErro);
    } catch (e) {
      _showMessage('Erro ao salvar dados: $e', AppColors.corErro);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.corFundoMenu,
          surfaceTintColor: AppColors.corMaterial,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Saida',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Voce deseja realmente sair da sua conta?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.corTexto.withValues(alpha: 0.75)),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.corTexto),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: AppColors.corErro,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _authErrorMessage(FirebaseAuthException e) {
    if (e.code == 'requires-recent-login') {
      return 'Por seguranca, faca login novamente antes de alterar e-mail ou senha.';
    }
    if (e.code == 'email-already-in-use') {
      return 'Este e-mail ja esta em uso.';
    }
    if (e.code == 'invalid-email') {
      return 'Informe um e-mail valido.';
    }
    if (e.code == 'weak-password') {
      return 'A senha e muito fraca.';
    }
    return 'Erro ao salvar dados: ${e.message ?? e.code}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isEditing
                          ? _buildEditForm()
                          : _buildProfileOptions(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
      decoration: const BoxDecoration(
        color: _primaryYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: _textColor),
              ),
              const Expanded(
                child: Text(
                  'Meu perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.corFundoMenu,
            child: Icon(Icons.person, color: _primaryYellow, size: 58),
          ),
          const SizedBox(height: 16),
          Text(
            _nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        color: AppColors.corFundoMenu,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Meu Cadastro',
            onTap: () => setState(() => _isEditing = true),
          ),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'Sair',
            iconColor: AppColors.corErro,
            textColor: AppColors.corErro,
            onTap: _showLogoutConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = _textColor,
    Color textColor = _textColor,
  }) {
    return Column(
      children: [
        ListTile(
          minLeadingWidth: 32,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, color: iconColor, size: 25),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: title == 'Meu Cadastro'
              ? Icon(Icons.chevron_right, color: AppColors.corTexto.withValues(alpha: 0.75))
              : null,
          onTap: onTap,
        ),
        Divider(height: 1, color: _dividerColor),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      key: const ValueKey('edit-profile'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        color: AppColors.corFundoMenu,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => setState(() {
                            _isEditing = false;
                            _nomeController.text = _nome;
                            _emailController.text = _email;
                            _senhaController.clear();
                            _confirmaSenhaController.clear();
                          }),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Meu Cadastro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 22),
              _buildTextField(
                controller: _nomeController,
                label: 'Nome Completo',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe seu nome'
                    : null,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Informe um e-mail valido'
                    : null,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _senhaController,
                label: 'Nova senha',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (value.length < 6) return 'Minimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _confirmaSenhaController,
                label: 'Confirmar senha',
                icon: Icons.lock_reset,
                obscureText: true,
                validator: (value) {
                  if (_senhaController.text.isEmpty) return null;
                  if (value != _senhaController.text) {
                    return 'As senhas nao coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.corTexto,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar alteracoes'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.corTexto,
                  backgroundColor: _primaryYellow,
                  disabledBackgroundColor: AppColors.corBordaInputs,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: AppColors.corTexto),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.corTexto),
        ),
        filled: true,
        fillColor: _backgroundColor,
      ),
      validator: validator,
    );
  }
}
