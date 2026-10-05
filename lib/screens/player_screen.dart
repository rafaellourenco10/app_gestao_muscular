import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data.dart';
import '../reminders.dart';
import '../ui.dart';
import 'exercises_screen.dart' show LevelBadge;
import 'workout_summary_screen.dart';

enum _Phase { work, rest, done }

/// Relógio do player; os testes trocam para simular o tempo passando em segundo plano.
@visibleForTesting
DateTime Function() playerClock = DateTime.now;

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
  // Cópia: trocar um exercício vale só para este treino. Os itens são os mesmos do
  // cronograma, então o "ajustar carga" continua valendo para os próximos treinos.
  late final _items = [...widget.items];
  late int _i = widget.index;
  int _set = 1;
  _Phase _phase = _Phase.work;
  late int _left = _item.time; // segundos restantes da rodada (funcional) ou do descanso
  // Fim da fase pelo relógio real: em segundo plano os ticks param ou atrasam,
  // então o tempo restante é sempre recalculado a partir daqui.
  DateTime? _endsAt;
  Timer? _timer;
  final _clock = Stopwatch()..start(); // tempo real do treino, para o resumo
  int _setsDone = 0;
  bool _background = false;
  bool _askedPermission = false;
  late final AppLifecycleListener _lifecycle;

  PlanItem get _item => _items[_i];
  bool get _running => _endsAt != null;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {}); // tela não apaga durante o treino
    _lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    clearWorkoutNotifications();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  /// [from]: quando a fase começou. Na troca automática de fase é o fim da anterior,
  /// assim o tempo passado em segundo plano não se perde.
  void _start([DateTime? from]) {
    if (!_askedPermission) {
      _askedPermission = true; // para o cronômetro aparecer na notificação
      requestReminderPermission().catchError((_) => false);
    }
    setState(() {
      _endsAt = (from ?? playerClock()).add(Duration(seconds: _left));
      _timer ??= Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    });
  }

  void _pause() => setState(() {
        _timer?.cancel();
        _timer = null;
        _endsAt = null;
      });

  void _tick() {
    // laço: ao voltar do segundo plano pode ter passado mais de uma fase
    while (_endsAt != null) {
      final end = _endsAt!;
      final left = (end.difference(playerClock()).inMilliseconds / 1000).ceil();
      if (left > 0) {
        if (left != _left) {
          setState(() => _left = left);
          if (_phase == _Phase.rest && left <= 3) HapticFeedback.selectionClick(); // 3, 2, 1
        }
        return;
      }
      if (_phase == _Phase.rest) {
        _alert();
        _beginWork(end);
      } else {
        _completeSet(end);
      }
    }
  }

  // ponytail: vibração curta do sistema; pacote `vibration` se precisar de padrão mais longo
  void _alert() => HapticFeedback.vibrate();

  /// Fim de uma série/rodada: vai para a próxima série, o próximo exercício ou encerra.
  void _completeSet([DateTime? at]) {
    _setsDone++;
    final lastSet = _set >= _item.sets;
    if (lastSet && _i == _items.length - 1) {
      _pause();
      _alert();
      setState(() => _phase = _Phase.done);
      _notifyBackground();
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
      _start(at);
      _notifyBackground();
    } else {
      _beginWork(at);
    }
  }

  /// Funcional segue contando sozinho; hipertrofia espera o "Série feita".
  void _beginWork([DateTime? at]) {
    setState(() {
      _phase = _Phase.work;
      _left = _item.time;
    });
    _item.isTime ? _start(at) : _pause();
    _notifyBackground();
  }

  /// Ajuste na hora: ±5s por rodada (funcional) ou ±1 repetição (hipertrofia).
  /// O item é o mesmo do cronograma, então o ajuste vale para os próximos treinos.
  void _adjust(int step) => setState(() {
        final item = _item;
        if (item.isTime) {
          final old = item.time;
          item.time = (old + step * 5).clamp(5, 300);
          // rodada em andamento ganha/perde o mesmo tempo
          if (_phase == _Phase.work) {
            _left = (_left + item.time - old).clamp(1, item.time);
            if (_running) _endsAt = playerClock().add(Duration(seconds: _left));
          }
        } else {
          item.reps = (item.reps + step).clamp(1, 100);
        }
      });

  void _goTo(int i) {
    _pause();
    setState(() {
      _i = i;
      _set = 1;
      _phase = _Phase.work;
      _left = _item.time;
    });
  }

  /// Aparelho ocupado: troca por outro da mesma categoria, mantendo séries/tempo/reps.
  Future<void> _swap() async {
    final current = _item.exercise;
    final options = exercises.where((e) => e.categoryId == current.categoryId && e != current).toList();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há outro exercício nesta categoria.')));
      return;
    }
    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: surface1,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Text('Trocar ${current.title}', style: grotesk(20)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text('Só neste treino. O cronograma não muda.', style: TextStyle(color: textLow, fontSize: 13)),
          ),
          for (final e in options)
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.square(dimension: 48, child: NetImage(e.image)),
              ),
              title: Text(e.title, style: grotesk(16, weight: FontWeight.w600)),
              subtitle: Text('${e.equipment} · ${e.level}', style: const TextStyle(color: textLow, fontSize: 13)),
              onTap: () => Navigator.pop(sheet, e),
            ),
        ]),
      ),
    );
    if (picked == null || !mounted) return;
    final old = _item;
    _items[_i] = PlanItem(picked, type: old.type, sets: old.sets, time: old.time, reps: old.reps);
    _goTo(_i);
  }

  // --- Segundo plano ---

  void _onHide() {
    _background = true;
    if (_phase == _Phase.done || (!_running && _item.isTime)) return; // pausado: nada a avisar
    final (title, body) = _backgroundText();
    showWorkoutProgress(title, body, endsAt: _endsAt);
    if (_endsAt case final end?) {
      final rest = _phase == _Phase.rest;
      final label = _item.type.setLabel;
      alertWorkout(
        rest ? 'Fim do descanso' : '$label concluída',
        rest ? 'Bora para a próxima ${label.toLowerCase()}!' : 'Volte ao app para seguir o treino.',
        at: end,
      );
    }
  }

  void _onShow() {
    _background = false;
    clearWorkoutNotifications();
    _tick(); // recupera o tempo que passou fora
  }

  /// Troca de fase com o app em segundo plano (o Android segue contando): avisa com
  /// som e atualiza o cronômetro da notificação.
  void _notifyBackground() {
    if (!_background) return;
    final (title, body) = _backgroundText();
    if (_phase == _Phase.done) {
      clearWorkoutNotifications().then((_) => alertWorkout(title, body));
    } else {
      alertWorkout(title, body);
      showWorkoutProgress(title, body, endsAt: _endsAt);
    }
  }

  (String, String) _backgroundText() {
    final item = _item, e = item.exercise;
    final set = '${item.type.setLabel} $_set de ${item.sets}';
    return switch (_phase) {
      _Phase.done => ('Treino completo! 💪', 'Toque para concluir e salvar no histórico.'),
      _Phase.rest => ('Descanso', 'A seguir: ${e.title} · $set'),
      _ when item.isTime => (set, e.title),
      _ => ('$set · ${item.reps} reps', '${e.title} · toque para marcar a série'),
    };
  }

  void _finish() {
    _clock.stop();
    final minutes = (_clock.elapsed.inSeconds / 60).ceil().clamp(1, 999);
    history.add(WorkoutLog(DateTime.now(), widget.title, _items.length, minutes));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          title: widget.title,
          duration: _clock.elapsed,
          exercises: _items.length,
          setsDone: _setsDone,
          type: _items.first.type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final e = item.exercise;
    final category = categories.firstWhere((c) => c.id == e.categoryId);
    final isLast = _i == _items.length - 1;

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
              Text('Exercício ${_i + 1} / ${_items.length}', style: grotesk(16, color: textLow)),
            ]),
          ),
          // TODO(videos): trocar a imagem por VideoPlayer (pacote video_player) com e.videoUrl
          AspectRatio(aspectRatio: 16 / 9, child: NetImage(e.image)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Hud(phase: _phase, item: item, set: _set, left: _left, restSec: widget.restSec),
              if (_phase != _Phase.done) ...[
                const SizedBox(height: 10),
                Row(children: [
                  _AdjustButton(item.isTime ? '−5s' : '−1 rep', () => _adjust(-1)),
                  Expanded(
                    child: Text(
                      _phase == _Phase.rest ? 'Ajustar próxima' : 'Ajustar carga',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: textLow, fontSize: 13),
                    ),
                  ),
                  _AdjustButton(item.isTime ? '+5s' : '+1 rep', () => _adjust(1)),
                ]),
              ],
              const SizedBox(height: 24),
              Text(category.name.toUpperCase(), style: caps(textLow)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(e.title, style: grotesk(26, spacing: -0.5))),
                if (_phase != _Phase.done)
                  TextButton.icon(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: const Text('Trocar'),
                    style: TextButton.styleFrom(foregroundColor: lime, textStyle: grotesk(15, weight: FontWeight.w600)),
                  ),
              ]),
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
                Expanded(child: Text('Dicas de execução', style: grotesk(22, weight: FontWeight.w600))),
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
          SquareIconButton(Icons.skip_previous, size: 56, tooltip: 'Exercício anterior', onTap: _i == 0 ? null : () => _goTo(_i - 1)),
          const SizedBox(width: 10),
          Expanded(child: PrimaryButton(label, icon: icon, onPressed: onPressed)),
          const SizedBox(width: 10),
          SquareIconButton(Icons.skip_next, size: 56, tooltip: 'Próximo exercício', onTap: isLast ? null : () => _goTo(_i + 1)),
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

class _AdjustButton extends StatelessWidget {
  const _AdjustButton(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: surface2,
            foregroundColor: textHigh,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: grotesk(15, weight: FontWeight.w600),
          ),
          child: Text(label),
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
