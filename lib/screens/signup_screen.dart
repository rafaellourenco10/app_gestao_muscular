import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'categories_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _level = levels[0];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    // TODO(supabase): auth.signUp + insert em profiles (name, level)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => CategoriesScreen(userName: _name.text.trim().split(' ').first)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
                const DotPill('Passo 1 de 2', color: textMed),
              ]),
              const SizedBox(height: 28),
              Text('Criar conta', style: grotesk(40, spacing: -1)),
              const SizedBox(height: 8),
              const Text(
                'Comece sua jornada de evolução física hoje com treinos orientados a alta performance.',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              const FieldLabel('Nome completo'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: textHigh),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Informe seu nome' : null,
                decoration: const InputDecoration(hintText: 'Seu nome completo', prefixIcon: Icon(Icons.person_outline)),
              ),
              const FieldLabel('E-mail'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: textHigh),
                validator: validateEmail,
                decoration: const InputDecoration(hintText: 'exemplo@email.com', prefixIcon: Icon(Icons.mail_outline)),
              ),
              const FieldLabel('Senha'),
              PasswordField(controller: _password, hint: 'Mínimo 8 caracteres'),
              const FieldLabel('Nível de condicionamento'),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  for (final l in levels)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _level = l),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _level == l ? lime : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(l, style: grotesk(14, weight: FontWeight.w600, color: _level == l ? bg : textMed)),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 32),
              PrimaryButton('Cadastrar', onPressed: _submit),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Já tem conta?'),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text('Entrar', style: grotesk(16, color: lime)),
                ),
              ]),
              const Text(
                'Ao continuar, você concorda com nossos Termos de Uso e nossa Política de Privacidade.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textLow, fontSize: 13),
              ),
            ]),
          ),
        ),
      );
}
