import "dart:async";
import "package:flutter/material.dart";
import "package:pomodoro/data_access_object.dart";
import "package:pomodoro/registro.dart";

enum EstadoPomodoro { parado, trabalhando, emPausa }

class PomodoroProvider extends ChangeNotifier {
  EstadoPomodoro _estado = EstadoPomodoro.parado;
  int _segundosTrabalho = 0;
  int _segundosDescanso = 0;
  Timer? _timer;

  List<Registro> _registros = [];

  // estado do cronômetro (sessão atual)
  EstadoPomodoro get estado => _estado;
  int get segundosTrabalho => _segundosTrabalho;
  int get segundosDescanso => _segundosDescanso;
  bool get sessaoEmAndamento =>
      _estado != EstadoPomodoro.parado ||
      _segundosTrabalho > 0 ||
      _segundosDescanso > 0;

  // histórico
  List<Registro> get registros => _registros;
  int get totalTrabalho =>
      _registros.fold(0, (soma, r) => soma + r.segundosTrabalho);
  int get totalDescanso =>
      _registros.fold(0, (soma, r) => soma + r.segundosDescanso);

  // garante um único Timer ativo que incrementa o contador do estado atual
  void _garantirTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_estado == EstadoPomodoro.trabalhando) {
        _segundosTrabalho++;
        notifyListeners();
      } else if (_estado == EstadoPomodoro.emPausa) {
        _segundosDescanso++;
        notifyListeners();
      }
    });
  }

  // Iniciar / Retomar: começa (ou volta) a contar o tempo de trabalho.
  void iniciar() {
    _estado = EstadoPomodoro.trabalhando;
    _garantirTimer();
    notifyListeners();
  }

  // Pausar: congela o trabalho e passa a contabilizar o descanso.
  void pausar() {
    _estado = EstadoPomodoro.emPausa;
    _garantirTimer();
    notifyListeners();
  }

  // Fim: salva a sessão atual no banco e zera os contadores.
  Future<void> finalizar() async {
    _timer?.cancel();
    _timer = null;

    if (_segundosTrabalho > 0 || _segundosDescanso > 0) {
      final registro = Registro(
        id: 0,
        dataHora: DateTime.now().toIso8601String(),
        segundosTrabalho: _segundosTrabalho,
        segundosDescanso: _segundosDescanso,
      );
      await DataAccessObject.incluirRegistro(registro);
      await carregarRegistros();
    }

    _estado = EstadoPomodoro.parado;
    _segundosTrabalho = 0;
    _segundosDescanso = 0;
    notifyListeners();
  }

  Future<void> carregarRegistros() async {
    _registros = await DataAccessObject.obterRegistros();
    notifyListeners();
  }

  Future<void> excluirRegistro(Registro registro) async {
    await DataAccessObject.excluirRegistro(registro);
    await carregarRegistros();
  }

  Future<void> limparHistorico() async {
    await DataAccessObject.limparHistorico();
    await carregarRegistros();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
