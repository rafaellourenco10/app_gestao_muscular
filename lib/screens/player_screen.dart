import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../ui.dart';
import 'exercises_screen.dart' show LevelBadge;

enum _Phase { work, rest, done }

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.title, required this.items, required this.index, this.restSec = 0});
  final String title; // vai para o histórico ao concluir
  final List<PlanItem> items;
  final int index;
  final int restSec; // descanso entre séries/rodadas; 0 = sem descanso

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late int _i = widget.index;
  int _set = 1;
  _Phase _phase = _Phase.work;
  late int _left = _item.time; // segundos restantes da rodada (funcional) ou do descanso
  Timer? _timer;

  PlanItem get _item => widget.items[_i];
  bool get _running => _timer != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() => setState(() => _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick()));

  void _pause() => setState(() {
        _timer?.cancel();
        _timer = null;
      });

  void _tick() {
    setState(() => _left--);
    if (_phase == _Phase.rest && _left > 0 && _left <= 3) HapticFeedback.selectionClick(); // 3, 2, 1
    if (_left > 0) return;
    if (_phase == _Phase.rest) {
      _alert();
      _beginWork();
    } else {
      _completeSet();
    }
  }

  // ponytail: vibração curta do sistema; pacote `vibration` se precisar de padrão mais longo
  void _alert() => HapticFeedback.vibrate();

  /// Fim de uma série/rodada: vai para a próxima série, o próximo exercício ou encerra.
  void _completeSet() {
    final lastSet = _set >= _item.sets;
    if (lastSet && _i == widget.items.length - 1) {
      _pause();
      _alert();
      setState(() => _phase = _Phase.done);
      return;
    }
    setState(() {
      if (lastSet) {
        _i++;
        _set = 1;
      } else {
        _set++;
      }
    });
    if (widget.restSec > 0) {
      setState(() {
        _phase = _Phase.rest;
        _left = widget.restSec;
      });
      _start();
    } else {
      _beginWork();
    }
  }

  /// Funcional segue contando sozinho; hipertrofia espera o "Série feita".
  void _beginWork() {
    setState(() {
      _phase = _Phase.work;
      _left = _item.time;
    });
    _item.isTime ? _start() : _pause();
  }

  void _goTo(int i) {
    _pause();
    setState(() {
      _i = i;
      _set = 1;
      _phase = _Phase.work;
      _left = _item.time;
    });
  }

  void _finish() {
    history.add(WorkoutLog(DateTime.now(), widget.title, widget.items.length, planMinutes(widget.items)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Treino concluído! ${widget.items.length} exercícios • ${planMinutes(widget.items)} min')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final e = item.exercise;
    final category = categories.firstWhere((c) => c.id == e.categoryId);
    final isLast = _i == widget.items.length - 1;

    final (String label, IconData icon, VoidCallback onPressed) = switch (_phase) {
      _Phase.done => ('Concluir treino', Icons.check, _finish),
      _Phase.rest => ('Pular descanso', Icons.skip_next, () {
          _pause();
          _beginWork();
        }),
      _Phase.work when !item.isTime => ('Série feita', Icons.check, _completeSet),
      _Phase.work when _running => ('Pausar', Icons.pause, _pause),
      _Phase.work => (_left < item.time ? 'Continuar' : 'Iniciar', Icons.play_arrow, _start),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: EdgeInsets.zero, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(children: [
              SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const Spacer(),
              Text('Exercício ${_i + 1} / ${widget.items.length}', style: grotesk(16, color: textLow)),
            ]),
          ),
          // TODO(videos): trocar a imagem por VideoPlayer (pacote video_player) com e.videoUrl
          AspectRatio(aspectRatio: 16 / 9, child: NetImage(e.image)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Hud(phase: _phase, item: item, set: _set, left: _left, restSec: widget.restSec),
              const SizedBox(height: 24),
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
          _NavButton(Icons.skip_previous, 'Exercício anterior', _i == 0 ? null : () => _goTo(_i - 1)),
          const SizedBox(width: 10),
          Expanded(child: PrimaryButton(label, icon: icon, onPressed: onPressed)),
          const SizedBox(width: 10),
          _NavButton(Icons.skip_next, 'Próximo exercício', isLast ? null : () => _goTo(_i + 1)),
        ]),
      ),
    );
  }
}

/// Painel do cronômetro: rodada/série atual, tempo e barra de progresso.
class _Hud extends StatelessWidget {
  const _Hud({required this.phase, required this.item, required this.set, required this.left, required this.restSec});
  final _Phase phase;
  final PlanItem item;
  final int set, left, restSec;

  @override
  Widget build(BuildContext context) {
    final setText = '${item.type.setLabel} $set de ${item.sets}'; // "Série 2 de 3"
    final (String top, String big, double progress) = switch (phase) {
      _Phase.done => ('TREINO COMPLETO', 'Mandou bem!', 1),
      _Phase.rest => ('DESCANSO • A SEGUIR: ${setText.toUpperCase()}', _mmss(left), 1 - left / restSec),
      _Phase.work when item.isTime => (setText.toUpperCase(), _mmss(left), 1 - left / item.time),
      _Phase.work => (setText.toUpperCase(), '${item.reps} reps', (set - 1) / item.sets),
    };
    final rest = phase == _Phase.rest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rest ? border : lime.withValues(alpha: 0.4)),
        boxShadow: rest ? null : [BoxShadow(color: lime.withValues(alpha: 0.12), blurRadius: 24)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(top, style: caps(rest ? textLow : lime)),
        const SizedBox(height: 8),
        Text(
          big,
          style: grotesk(56, color: rest ? textMed : textHigh, spacing: -1)
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()], height: 1),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: surface2,
            color: rest ? textLow : lime,
          ),
        ),
      ]),
    );
  }
}

String _mmss(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

class _NavButton extends StatelessWidget {
  const _NavButton(this.icon, this.tooltip, this.onPressed);
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: surface2,
            disabledBackgroundColor: surface1,
            foregroundColor: textHigh,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
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
