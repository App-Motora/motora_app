import 'package:flutter/material.dart';
import 'package:motora_app/components/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motora_app/constants/app_colors.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.corFundo,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Crie sua conta para começar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),
                    
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            floatingLabelStyle: TextStyle(color: AppColors.corTexto),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Informe seu nome'
                              : null,
                        ),
                        const SizedBox(height: 20),
                    
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            floatingLabelStyle: TextStyle(color: AppColors.corTexto),
                            prefixIcon: const Icon(Icons.email_outlined)
                          ),
                          validator: (value) =>
                              (value == null || !value.contains('@'))
                              ? 'Informe um e-mail válido'
                              : null,
                        ),
                        const SizedBox(height: 20),
                    
                        TextFormField(
                          controller: _senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            floatingLabelStyle: TextStyle(color: AppColors.corTexto),
                            prefixIcon: const Icon(Icons.lock_outline)
                          ),
                          validator: (value) => (value == null || value.length < 6)
                              ? 'Mínimo 6 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 20),
                    
                        TextFormField(
                          controller: _confirmaSenhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            floatingLabelStyle: TextStyle(color: AppColors.corTexto),
                            prefixIcon: const Icon(Icons.lock_reset)
                          ),
                          validator: (value) {
                            if (value != _senhaController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                    
                        PrimaryButton(
                          label: 'Cadastrar',
                          icon: Icons.check_circle_outline,
                          color: AppColors.corSecundaria,
                          onPressed: () async { 
                            if (_formKey.currentState!.validate()) {
                              try {
                                final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _senhaController.text,
                                );
                                await credential.user?.updateDisplayName(
                                  _nomeController.text.trim(),
                                );
                                final uid = credential.user?.uid;
                                if (uid != null) {
                                  await FirebaseFirestore.instance
                                      .collection('usuarios')
                                      .doc(uid)
                                      .set({
                                        'nome': _nomeController.text.trim(),
                                        'email': _emailController.text.trim(),
                                        'createdAt': FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: AppColors.corSucesso),
                                  );
                                  Navigator.pop(context); 
                                }
                              } on FirebaseAuthException catch (e) {
                                String message = 'Ocorreu um erro ao cadastrar';
                                if (e.code == 'email-already-in-use') {
                                  message = 'Este e-mail já está em uso';
                                } else if (e.code == 'weak-password') {
                                  message = 'A senha é muito fraca';
                                }                         
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message), backgroundColor: AppColors.corErro),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao salvar cadastro: $e'),
                                    backgroundColor: AppColors.corErro,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Já possui conta? Faça login',
                            style: TextStyle(color: AppColors.corTexto),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          );
        }
      ),
    );
  }
}
