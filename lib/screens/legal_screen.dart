import 'package:flutter/material.dart';

import '../ui.dart';

// ponytail: e-mail e data fixos no app; publicar o mesmo texto numa URL (a Play Store exige link web).
const supportEmail = 'privacidade@funcfit.app';
const _updated = '05/10/2026';

enum LegalDoc {
  terms('Termos de Uso', [
    ('1. Aceitação', 'Ao criar uma conta ou usar o FuncFit, você concorda com estes Termos e com a Política de Privacidade.'),
    ('2. O serviço', 'O FuncFit oferece treinos, cronogramas, cronômetro e acompanhamento de progresso. O conteúdo pode mudar ou ser atualizado a qualquer momento.'),
    ('3. Saúde e responsabilidade', 'Os treinos têm caráter informativo e não substituem orientação médica ou de um profissional de educação física. Consulte um médico antes de iniciar atividade física e interrompa o exercício se sentir dor, tontura ou falta de ar. Você treina por sua conta e risco.'),
    ('4. Sua conta', 'Você é responsável pelas informações cadastradas e por manter sua senha em sigilo. É preciso ter 18 anos ou mais, ou autorização dos responsáveis.'),
    ('5. Uso permitido', 'É proibido copiar, revender ou distribuir o conteúdo do app, ou tentar acessar dados de outros usuários.'),
    ('6. Encerramento', 'Você pode excluir sua conta a qualquer momento em Meu perfil > Excluir conta. Podemos suspender contas que violem estes Termos.'),
    ('7. Alterações', 'Podemos atualizar estes Termos. Mudanças relevantes serão avisadas no app.'),
    ('8. Contato e foro', 'Dúvidas: $supportEmail. Estes Termos seguem a legislação brasileira.'),
  ]),
  privacy('Política de Privacidade', [
    ('1. Quem somos', 'Esta política explica como o FuncFit trata seus dados pessoais, conforme a Lei Geral de Proteção de Dados (Lei 13.709/2018 – LGPD).'),
    ('2. Dados que coletamos', 'Cadastro: nome, e-mail, senha (armazenada de forma criptografada) e nível de condicionamento.\nPerfil: objetivo, altura, peso e meta de peso.\nUso: cronograma, treinos concluídos, duração e horário do lembrete.'),
    ('3. Para que usamos', 'Para criar sua conta, montar e lembrar seus treinos, mostrar seu histórico e progresso. Base legal: execução do contrato (art. 7º, V) e, para peso e altura, seu consentimento (art. 11, I), que você dá ao informá-los e pode retirar apagando os registros.'),
    ('4. Compartilhamento', 'Não vendemos seus dados. Eles são guardados em provedores de infraestrutura contratados para operar o app, sob obrigação de sigilo.'),
    ('5. Por quanto tempo', 'Enquanto sua conta existir. Ao excluir a conta, seus dados são apagados, salvo o que a lei obrigar a manter.'),
    ('6. Seus direitos', 'Você pode confirmar, acessar, corrigir, exportar ou excluir seus dados e revogar o consentimento. Edite seus dados em Meu perfil, exclua tudo em Meu perfil > Excluir conta, ou escreva para $supportEmail.'),
    ('7. Segurança', 'Usamos conexão criptografada e controle de acesso para proteger seus dados.'),
    ('8. Notificações', 'Os lembretes de treino são gerados no próprio aparelho e só são ativados se você permitir.'),
    ('9. Alterações', 'Avisaremos no app quando esta política mudar.'),
  ]);

  const LegalDoc(this.title, this.sections);
  final String title;
  final List<(String, String)> sections;
}

class LegalScreen extends StatelessWidget {
  const LegalScreen(this.doc, {super.key});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SquareIconButton(Icons.arrow_back, tooltip: 'Voltar', onTap: () => Navigator.pop(context)),
            ),
            const SizedBox(height: 20),
            Text(doc.title, style: grotesk(32, spacing: -0.6)),
            const SizedBox(height: 6),
            const Text('Atualizado em $_updated', style: TextStyle(color: textLow, fontSize: 13)),
            for (final (title, body) in doc.sections) ...[
              const SizedBox(height: 24),
              Text(title, style: grotesk(18, weight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(body, style: const TextStyle(fontSize: 15, height: 1.6)),
            ],
          ]),
        ),
      );
}

/// "Termos de Uso · Política de Privacidade" clicáveis.
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) => Wrap(alignment: WrapAlignment.center, children: [
        for (final doc in LegalDoc.values)
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LegalScreen(doc))),
            child: Text(doc.title, style: grotesk(13, weight: FontWeight.w600, color: lime)),
          ),
      ]);
}
