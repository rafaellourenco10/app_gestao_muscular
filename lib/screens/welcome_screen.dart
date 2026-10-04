import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void go(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NetImage(imgHero),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x990F0F12), Color(0xCC0F0F12), bg],
                stops: [0, 0.45, 0.8],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                // Spacer empurra o conteúdo para baixo e tudo cabe sem rolar;
                // a rolagem só entra em telas muito baixas.
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Logo()),
                        const Spacer(),
                        const SizedBox(height: 24),
                        const DotPill('Treino funcional inteligente'),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            style: grotesk(40, spacing: -1.2).copyWith(height: 1.1),
                            children: const [
                              TextSpan(text: 'Treine do seu jeito,\nem qualquer '),
                              TextSpan(
                                text: 'lugar',
                                style: TextStyle(color: lime),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Treinos funcionais adaptados ao seu ritmo, com foco em força, mobilidade e resistência real.',
                          style: TextStyle(fontSize: 16, height: 1.5, color: textMed),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(color: surface1.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16)),
                          child: const Row(
                            children: [_Stat('+180', 'CIRCUITOS'), _Stat('100%', 'ADAPTÁVEL', highlight: true), _Stat('HIIT', '& FORÇA')],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton('Entrar', onPressed: () => go(const LoginScreen())),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Novo por aqui?', style: TextStyle(color: textMed)),
                            TextButton(
                              onPressed: () => go(const SignupScreen()),
                              child: Text('Criar conta', style: grotesk(16, color: lime)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, {this.highlight = false});
  final String value, label;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: grotesk(26, color: highlight ? lime : textHigh)),
        const SizedBox(height: 4),
        Text(label, style: caps(textMed)),
      ],
    ),
  );
}
