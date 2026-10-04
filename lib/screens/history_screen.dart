import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';

const _months = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', //
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selected; // dia tocado no calendário filtra a lista

  @override
  Widget build(BuildContext context) {
    final logs = [
      for (final l in history.reversed)
        if (_selected == null ? l.date.year == _month.year && l.date.month == _month.month : isSameDay(l.date, _selected!)) l,
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SEU PROGRESSO', style: caps(lime)),
                Text('Histórico', style: grotesk(24, spacing: -0.5)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
            child: Column(children: [
              Row(children: [
                IconButton(
                  tooltip: 'Mês anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                    _selected = null;
                  }),
                ),
                Expanded(
                  child: Text('${_months[_month.month - 1]} ${_month.year}', textAlign: TextAlign.center, style: grotesk(18)),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                    _selected = null;
                  }),
                ),
              ]),
              const SizedBox(height: 8),
              _MonthGrid(
                month: _month,
                selected: _selected,
                onTap: (d) => setState(() => _selected = _selected != null && isSameDay(_selected!, d) ? null : d),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Text(
                _selected == null ? 'Treinos do mês' : 'Treinos em ${_selected!.day}/${_selected!.month}',
                style: grotesk(20, weight: FontWeight.w600),
              ),
            ),
            Text('${logs.length}', style: grotesk(20, color: lime)),
          ]),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('Nenhum treino concluído aqui ainda.', textAlign: TextAlign.center, style: TextStyle(color: textLow)),
            ),
          for (final l in logs)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: lime.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Text('${l.date.day}', style: grotesk(20, color: lime)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: grotesk(16)),
                    const SizedBox(height: 2),
                    Text(
                      '${l.exercises} exercícios • ~${l.minutes} min • ${l.date.hour.toString().padLeft(2, '0')}:${l.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: textLow, fontSize: 13),
                    ),
                  ]),
                ),
                const Icon(Icons.check_circle, color: lime),
              ]),
            ),
        ]),
      ),
    );
  }
}

/// Grade do mês (segunda a domingo) com os dias treinados em verde.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.selected, required this.onTap});
  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final blanks = DateTime(month.year, month.month).weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final trained = {for (final l in history) if (l.date.year == month.year && l.date.month == month.month) l.date.day};
    final now = DateTime.now();

    return Column(children: [
      Row(children: [
        for (final w in ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'])
          Expanded(child: Text(w, textAlign: TextAlign.center, style: caps(textLow))),
      ]),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          for (var i = 0; i < blanks; i++) const SizedBox(),
          for (var d = 1; d <= days; d++)
            Builder(builder: (context) {
              final date = DateTime(month.year, month.month, d);
              final done = trained.contains(d);
              final isSelected = selected != null && isSameDay(selected!, date);
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onTap(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? lime : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected || isSameDay(date, now) ? Border.all(color: isSelected ? textHigh : lime, width: 1.5) : null,
                  ),
                  child: Text('$d', style: grotesk(14, weight: FontWeight.w600, color: done ? bg : textMed)),
                ),
              );
            }),
        ],
      ),
    ]);
  }
}
