// Dados de exemplo. Os campos espelham as tabelas planejadas (categories / exercises);
// na integração com o Supabase, só a origem das listas muda.
// ponytail: imagens são URLs temporárias geradas pelo Stitch, trocar pelas do Storage.

const _img = 'https://lh3.googleusercontent.com/aida-public/';
const imgHero = '${_img}AB6AXuDSPUNps0VsbkMhE1nuRy7WzbRL09tGPMYglVeT2tCM6-vsAtlHjk6Hfd7N-qBOg4b9ovQaIVY0lGzK5UWVcNRWQ3gW4ZlYg_QWroU2u1m8l6OL_cgESyHf6zsQA1JxxO90iZN33asOdrBs5748e7PMSTfoFVGDTbTPP19y3KmGMN6jotd6mr_itDgqm_wubiRyGBCTHQDQKPFgUMju1i6mZE7xUbci2--L02WPOs9svmmnL8YKxumcCw';
const imgAvatar = '${_img}AB6AXuCyYq8wRCB7gmjol7FDtp6YgwWuYRKTBWTnXiku52Xx9ps8iMCs0_6-ygS7IM_YbV8LPG4spmKavgZmwjgtp91oWCUBat3cROQZdKRPzQGFei6VIyygJ4fy2SjefQeatWUyOHdYUDo78F2OlTbPQPhfsrtNPDv70Vc_cE3p2yRlxkIYGB2BCFuFlsjzPwhiv4OohTTpD78PXh0541j-s3xcHL1m8QNWTrv7z8KXEhWwSVp28b-LfHQMiQ';
const _kettlebellMan = '${_img}AB6AXuDzbr0y8gVWgUv6rBIL6QxbRpCJ8p3PMAoSpBtaQzCViXEFmpjq8HJpTDJr0_MMNbj_jYmtJ4LXUJJPHez4AkVl-KLuF01M6cGANeDa2KPPLvU03UDfOfNLcmh-NWpuM4fwg4HYm9h6JJL6sVD4geOaYzT8aXCCyLW-xWItkiaE7pOz_nhtzUIyUl0TmtFv1Dyige6i1K5ihet-SJ_Ng-bDMh-25uuKHFGyTYoeYfrySCHnHkOl5E7jxw';
const _lunge = '${_img}AB6AXuDx0Gz89ivY-KKjpTAzhjqD86yo4iX82oZ3tLWQ0Edcd8lhmiS7PXahXakqbCH1ip4HGcKxv6L2gHuWFpjIozHwkGU6RP4_ioBhBLe0ibqOlxOeMSghTT5rUxtXnpszrkgMfIngZtX0H3HuAPtacUcYUh-t1VP5rSYhRRhEOf0Y0_7IJs9A1VgAItkMvdtUwHwQJhsaKrKSE0gOEuiC6c9nLVx0bArXiFtJaAsOXD9UzVAMH97xEwtK2A';
const _core = '${_img}AB6AXuCx19huPBqMoqy7ngkQOZYiN-jCqVW6P7kSbUG_3yZv5lpy8CiGNsKF2sGvtS2QB-lXnyKnYWozxU_Bl8kxinHFmZI4UhihSUF0bFryKwl7xbeTz3SXytFsBWZPRt-FED3_zaiOq2E2ayYvmHZo9prD4KSBnDCtPLCp0uLghuTdI2Z-Q8_cj_IrEvm8hn6PWASSkij57-dQNAOFCvBtMS1IlTCCJ7xOuj6UxgGOglFMiU9sQ--Np5wTfQ';
const _press = '${_img}AB6AXuA_bEHfwMeEhjc_Dyjkpq_gggHSqKpYkTk1CsjCurvMkqKeyVN2GnIqns-mIlJd55uSxAxTnIJBMGVY4gCEUSwkB2Xr4-bBytpTE48TFu8K8NTshvrycSmFcpjZhFnA89LpKoMYpjC95IvQrfxDHWFxO6Tw4rLXF74yKVto9PtL7FAhaFfjMh1Nvb-6pmWYXd9MvNwfr--BC75kEVsXKfnGHpuIHxhLTM3t9JPQefkngFlXdfrf-ICX_g';
const _jump = '${_img}AB6AXuAON0KpiGaCMgZIvZs2_mg0-LvJkN4xYQYVqgygshbj1Cehgm9xjwbYGEo2IulHVv18q0X9ZbGejA7vSQSEWD77uL843ff80dZyQL1agLc6EM8x_bi3h0NjeIww9zNYVpoi7LKJG2VWaWEKkL1AXU6_q6rEQ0QAjODT6qvI4eRQqEIspyTCNAiH3BAeIDEsNpK11yDNNZvKiDo2NSfilPUnIMGxXczxv2a9Eig7NObp57Rdp3PoBbqC2g';
const _mobility = '${_img}AB6AXuBQ_bRVBmn_dS1-rbp0EEAdmFkJJK29ehTCG-rg03OEi4J7WN2NYq8t0LBXmctgvp4uZJTtOfjfFaWkWjgfYfIUSdIKgWxq5y7owBSZOOcrRZokwoet1-ziqCSkpMfvgABvRrxoCwuotokSjeKvMb_VzMw_iINrhy2Q-7bkti2H_h5TAt-n5pigsUy_5MDiJIkDPUAcB0mw7SuXrTsRj6DAKPGX87eeX1ASjo_Xg0FfNCqHCJUgdQCnAA';
const _wallSit = '${_img}AB6AXuCUlopTe_Ne-r5v2f0MejC2Ji3Hv8Q19FPQxBdd09kCIasSkc8FdkAz-oJQWJBnY8ooSG3t2w0bR_OUIp6zI2sc-NUqcZOfYMDEJ5lFRO-o8dwYFNQXjpAS93R3JRewbvFUApeahDBjQhUQqZDJ6q5g8P3tLu4RMicLV6BJXFJ-4i0myO6euebLdgUWecxw3ynQmP119mrXdCwAr1iv_vX5mO0d7SkPsmUxdbUPOmHk9DJMgcIwZpupqw';
const _forwardLunge = '${_img}AB6AXuAWGvCosd7ODmX6r7F0kucbroWZpP4hYYpfuDnF0rauZbIhIhUVfq-w9avUQI-Uzo-Jtdta3Ix0YJQL6VTgBXY2Td_eMJKYgwurd0WfclAZW3j4EBrnvxuDkBDXgEDaX9_o4MCieE8ewUghsZlXV0xWFbJHCaL0QiQit3jrcFl9t0Me9-Mlbgy4gerbb21CsndOjIYo7H32Fy_uaQ71Q7DDaoPuoME7OUDn_q20uT4HsoLlq6_0DGka2g';

const levels = ['Iniciante', 'Intermediário', 'Avançado'];

class Category {
  const Category(this.id, this.tag, this.name, this.image);
  final int id;
  final String tag, name, image;
}

class Exercise {
  const Exercise({
    required this.categoryId,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.durationSec,
    required this.image,
    this.description = 'Mantenha o core ativado e execute o movimento com controle, priorizando a amplitude e a postura antes da velocidade.',
    this.tips = const [
      ('Postura da coluna', 'Mantenha o peito aberto e o core ativado durante todo o movimento.'),
      ('Respiração', 'Expire na fase de esforço e inspire no retorno.'),
      ('Controle', 'Evite trancos: qualidade antes de quantidade.'),
    ],
  });
  final int categoryId;
  final String title, subtitle, level, image, description;
  final int durationSec;
  final List<(String, String)> tips;
}

const categories = [
  Category(1, 'Funcional', 'Corpo inteiro', _kettlebellMan),
  Category(2, 'Força inferior', 'Pernas e glúteos', _lunge),
  Category(3, 'Estabilidade', 'Core / Abdômen', _core),
  Category(4, 'Força & empurre', 'Membros sup.', _press),
  Category(5, 'Alta intensidade', 'Cardio / HIIT', _jump),
  Category(6, 'Recuperação', 'Mobilidade', _mobility),
];

const exercises = [
  Exercise(
    categoryId: 2, title: 'Agachamento com salto', subtitle: 'Foco em potência de quadríceps', level: 'Intermediário', durationSec: 45, image: _jump,
    description: 'Mantenha os pés afastados na largura dos ombros, desça flexionando os joelhos e exploda para cima com potência total na ponta dos pés, aterrissando suavemente.',
    tips: [
      ('Postura da coluna', 'Mantenha o peito aberto e o core ativado durante toda a fase de descida.'),
      ('Aterrissagem suave', 'Amorteça o impacto flexionando os joelhos imediatamente ao tocar o chão.'),
      ('Impulsão com os braços', 'Use o balanço coordenado dos braços para ganhar altura e estabilidade.'),
    ],
  ),
  Exercise(categoryId: 2, title: 'Afundo búlgaro com halteres', subtitle: 'Ativação profunda de glúteos', level: 'Avançado', durationSec: 50, image: _lunge),
  Exercise(categoryId: 2, title: 'Kettlebell Swing unilateral', subtitle: 'Cadeia posterior, extensão de quadril', level: 'Intermediário', durationSec: 40, image: _kettlebellMan),
  Exercise(categoryId: 2, title: 'Isometria na parede', subtitle: 'Resistência estática de quadríceps', level: 'Iniciante', durationSec: 60, image: _wallSit),
  Exercise(categoryId: 2, title: 'Passada com elevação de joelho', subtitle: 'Equilíbrio dinâmico, flexores do quadril', level: 'Intermediário', durationSec: 45, image: _forwardLunge),
  Exercise(categoryId: 1, title: 'Burpee', subtitle: 'Condicionamento total', level: 'Intermediário', durationSec: 40, image: _jump),
  Exercise(categoryId: 1, title: 'Kettlebell Swing', subtitle: 'Potência de quadril', level: 'Iniciante', durationSec: 45, image: _kettlebellMan),
  Exercise(categoryId: 3, title: 'Elevação de pernas na barra', subtitle: 'Abdômen inferior', level: 'Avançado', durationSec: 40, image: _core),
  Exercise(categoryId: 3, title: 'Prancha frontal', subtitle: 'Estabilidade do core', level: 'Iniciante', durationSec: 60, image: _wallSit),
  Exercise(categoryId: 4, title: 'Push press com kettlebell', subtitle: 'Ombros e tríceps', level: 'Intermediário', durationSec: 45, image: _press),
  Exercise(categoryId: 4, title: 'Flexão de braço', subtitle: 'Peitoral e tríceps', level: 'Iniciante', durationSec: 40, image: _forwardLunge),
  Exercise(categoryId: 5, title: 'Polichinelo', subtitle: 'Aquecimento cardiovascular', level: 'Iniciante', durationSec: 60, image: _jump),
  Exercise(categoryId: 5, title: 'Mountain climber', subtitle: 'Cardio e core', level: 'Intermediário', durationSec: 40, image: _core),
  Exercise(categoryId: 6, title: 'Rotação torácica', subtitle: 'Mobilidade da coluna', level: 'Iniciante', durationSec: 60, image: _mobility),
  Exercise(categoryId: 6, title: 'Alongamento de quadril', subtitle: 'Flexores e glúteos', level: 'Iniciante', durationSec: 60, image: _mobility),
];

int exerciseCount(int categoryId) => exercises.where((e) => e.categoryId == categoryId).length;

int totalMinutes(List<Exercise> list) => (list.fold(0, (s, e) => s + e.durationSec) / 60).ceil();

const weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

/// Funcional = rodadas x tempo (3 x 50s). Hipertrofia = séries x repetições (3 x 12).
enum WorkoutType {
  funcional('Funcional', 'Rodadas', 'Tempo por rodada'),
  hipertrofia('Hipertrofia', 'Séries', 'Repetições');

  const WorkoutType(this.label, this.setsLabel, this.amountLabel);
  final String label, setsLabel, amountLabel;
}

/// Exercício com a prescrição do usuário. Guarda tempo e repetições separados,
/// assim trocar o tipo do dia não perde o que foi ajustado.
class PlanItem {
  PlanItem(this.exercise, {this.type = WorkoutType.funcional, this.sets = 3, int? time, this.reps = 12})
      : time = time ?? exercise.durationSec;
  final Exercise exercise;
  WorkoutType type;
  int sets;
  int time; // segundos por rodada (funcional)
  int reps; // repetições por série (hipertrofia)

  bool get isTime => type == WorkoutType.funcional;

  String get label => sets == 1
      ? (isTime ? '$time seg' : '$reps reps')
      : isTime
          ? '$sets x ${time}s'
          : '$sets x $reps';

  // ponytail: estimativa de 3s por repetição, sem contar descanso
  int get seconds => sets * (isTime ? time : reps * 3);
}

int planMinutes(List<PlanItem> items) => (items.fold(0, (s, i) => s + i.seconds) / 60).ceil();

// Treino montado pelo usuário: índice 0 = segunda ... 6 = domingo.
// ponytail: só em memória (some ao fechar o app); vira as tabelas plan_days / plan_items no Supabase.
final weeklyPlan = List.generate(7, (_) => <PlanItem>[]);
final dayType = List.filled(7, WorkoutType.funcional);

class WorkoutLog {
  const WorkoutLog(this.date, this.title, this.exercises, this.minutes);
  final DateTime date;
  final String title;
  final int exercises, minutes;
}

// ponytail: só em memória; vira a tabela workout_logs no Supabase.
final history = <WorkoutLog>[];

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

bool get doneToday => history.any((l) => isSameDay(l.date, DateTime.now()));
