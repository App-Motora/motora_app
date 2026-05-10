import 'package:flutter/material.dart';
import 'package:motora_app/components/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E9),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bem-vindo ao Motora!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      floatingLabelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined)
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe seu e-mail'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      floatingLabelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Senha deve ter no mínimo 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Entrar',
                    icon: Icons.login,
                    color: const Color(0xFF4FA8FF), 
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = 'E-mail ou senha incorretos';
                          if (e.code == 'user-not-found') {
                            message = 'Usuário não encontrado';
                          } else if (e.code == 'wrong-password') {
                            message = 'Senha incorreta';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/registro'),
                    child: const Text(
                      'Não possui conta? Cadastre-se aqui',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
