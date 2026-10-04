import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'categories_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    // TODO(supabase): auth.signInWithPassword e buscar o nome em profiles
    profile.email = _email.text.trim();
    if (profile.name.isEmpty) profile.name = profile.email.split('@').first; // sem banco, não sabemos o nome
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
              ),
              const Center(child: Logo()),
              const SizedBox(height: 20),
              const Center(child: DotPill('Functional athletics')),
              const SizedBox(height: 16),
              Text('Bem-vindo de volta', textAlign: TextAlign.center, style: grotesk(32, spacing: -0.6)),
              const SizedBox(height: 8),
              const Text('Acesse sua conta para continuar seus treinos', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              const FieldLabel('E-mail'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: textHigh),
                validator: validateEmail,
                decoration: const InputDecoration(hintText: 'seu.email@funcfit.com', prefixIcon: Icon(Icons.mail_outline)),
              ),
              const FieldLabel('Senha'),
              PasswordField(controller: _password, hint: 'Digite sua senha'),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  // TODO(supabase): auth.resetPasswordForEmail
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Recuperação de senha chega com o backend.'))),
                  child: Text('Esqueci minha senha', style: grotesk(15, weight: FontWeight.w600, color: lime)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton('ENTRAR', onPressed: _submit),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Não tem uma conta?'),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: Text('Cadastre-se ›', style: grotesk(16, color: lime)),
                ),
              ]),
            ]),
          ),
        ),
      );
}
