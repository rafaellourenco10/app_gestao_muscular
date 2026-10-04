import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'exercises_screen.dart';
import 'weekly_plan_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.userName});
  final String userName;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final picked = categories.where((c) => _selected.contains(c.id)).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList.list(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Logo(),
                CircleAvatar(radius: 22, backgroundColor: lime, child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(imgAvatar))),
              ]),
              const SizedBox(height: 28),
              Text('Olá, ${widget.userName}', style: grotesk(30, spacing: -0.6)),
              const SizedBox(height: 4),
              const Text('O que vamos treinar hoje?', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              _WeeklyPlanCard(onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()));
                setState(() {}); // atualiza o resumo de hoje
              }),
              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Categorias de Foco', style: grotesk(22, weight: FontWeight.w600)),
                Text('SELECIONE 1 OU MAIS', style: caps(textLow)),
              ]),
              const SizedBox(height: 16),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
              children: [
                for (final c in categories)
                  _CategoryCard(
                    category: c,
                    selected: _selected.contains(c.id),
                    onTap: () => setState(() => _selected.contains(c.id) ? _selected.remove(c.id) : _selected.add(c.id)),
                  ),
              ],
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: surface1, border: Border(top: BorderSide(color: border))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            picked.isEmpty
                ? 'NENHUMA CATEGORIA SELECIONADA'
                : '${picked.length} SELECIONADA${picked.length > 1 ? 'S' : ''}: ${picked.map((c) => c.name).join(', ').toUpperCase()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: caps(picked.isEmpty ? textLow : textMed),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              'Ver exercícios',
              onPressed: picked.isEmpty
                  ? null
                  : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExercisesScreen(categories: picked))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final i = DateTime.now().weekday - 1;
    final today = weeklyPlan[i];

    return Material(
      color: surface1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: lime.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_month_outlined, color: lime),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MEU CRONOGRAMA', style: caps(textMed)),
                const SizedBox(height: 4),
                Text(
                  doneToday
                      ? 'Treino de hoje concluído ✓'
                      : today.isEmpty
                          ? 'Monte seu treino da semana'
                          : 'Hoje (${weekdays[i]}): ${today.length} exercícios • ~${planMinutes(today)} min',
                  style: const TextStyle(color: textHigh),
                ),
              ]),
            ),
            const Icon(Icons.chevron_right, color: textLow),
          ]),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.selected, required this.onTap});
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: category.name,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? lime : border, width: selected ? 2 : 1),
              boxShadow: selected ? limeGlow : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(fit: StackFit.expand, children: [
                NetImage(category.image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x220F0F12), Color(0xF20F0F12)],
                      stops: [0.3, 0.95],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: selected ? lime : Colors.black45,
                    child: Icon(selected ? Icons.check : Icons.add, size: 20, color: selected ? bg : textHigh),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(category.tag.toUpperCase(), style: caps(selected ? lime : textMed)),
                    const SizedBox(height: 4),
                    Text(category.name, style: grotesk(20, color: selected ? lime : textHigh)),
                    const SizedBox(height: 4),
                    Text('${exerciseCount(category.id)} exercícios', style: const TextStyle(color: textLow, fontSize: 13)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}
