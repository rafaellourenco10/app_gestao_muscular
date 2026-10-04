import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'exercises_screen.dart' show LevelBadge;

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.title, required this.items, required this.index});
  final String title; // vai para o histórico ao concluir
  final List<PlanItem> items;
  final int index;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late int _i = widget.index;

  void _finish() {
    history.add(WorkoutLog(DateTime.now(), widget.title, widget.items.length, planMinutes(widget.items)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Treino concluído! ${widget.items.length} exercícios • ${planMinutes(widget.items)} min')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_i];
    final e = item.exercise;
    final isFirst = _i == 0, isLast = _i == widget.items.length - 1;
    final category = categories.firstWhere((c) => c.id == e.categoryId);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: EdgeInsets.zero, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(children: [
              SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const Spacer(),
              Text('${_i + 1} / ${widget.items.length}', style: grotesk(16, color: textLow)),
            ]),
          ),
          // TODO(videos): trocar a imagem por VideoPlayer (pacote video_player) com e.videoUrl
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              NetImage(e.image),
              const ColoredBox(color: Color(0x330F0F12)),
              Center(
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: limeGlow),
                  child: IconButton.filled(
                    iconSize: 40,
                    tooltip: 'Reproduzir',
                    style: IconButton.styleFrom(backgroundColor: lime, foregroundColor: bg, fixedSize: const Size(80, 80)),
                    icon: const Icon(Icons.play_arrow_rounded),
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Os vídeos entram na próxima etapa.'))),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(category.name.toUpperCase(), style: caps(textLow)),
              const SizedBox(height: 6),
              Text(e.title, style: grotesk(26, spacing: -0.5)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                LevelBadge(e.level),
                _Tag(item.isTime ? Icons.timer_outlined : Icons.repeat, item.label),
              ]),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Como executar', style: grotesk(22, weight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(e.description, style: const TextStyle(fontSize: 16, height: 1.6)),
                ]),
              ),
              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Dicas de execução', style: grotesk(22, weight: FontWeight.w600)),
                Text('${e.tips.length} FUNDAMENTAIS', style: caps(textLow)),
              ]),
              const SizedBox(height: 12),
              for (final (n, (title, body)) in e.tips.indexed)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
                      child: Text('${n + 1}', style: grotesk(16)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: grotesk(17, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(body, style: const TextStyle(color: textLow, height: 1.4)),
                      ]),
                    ),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
        child: Row(children: [
          SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              onPressed: isFirst ? null : () => setState(() => _i--),
              tooltip: 'Exercício anterior',
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: surface2,
                disabledBackgroundColor: surface1,
                foregroundColor: textHigh,
                side: const BorderSide(color: border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              isLast ? 'Concluir treino' : 'Próximo exercício',
              icon: isLast ? Icons.check : Icons.arrow_forward,
              onPressed: isLast ? _finish : () => setState(() => _i++),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: lime),
          const SizedBox(width: 4),
          Text(text, style: grotesk(12, weight: FontWeight.w600, color: lime)),
        ]),
      );
}
