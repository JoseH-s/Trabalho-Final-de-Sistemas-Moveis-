import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:pomodoro/pomodoro_provider.dart";
import "package:pomodoro/utils.dart";

class TelaCronometro extends StatelessWidget {
  const TelaCronometro({super.key});

  String _textoEstado(EstadoPomodoro estado) {
    switch (estado) {
      case EstadoPomodoro.trabalhando:
        return "Trabalhando";
      case EstadoPomodoro.emPausa:
        return "Em pausa";
      case EstadoPomodoro.parado:
        return "Parado";
    }
  }

  Color _corEstado(EstadoPomodoro estado) {
    switch (estado) {
      case EstadoPomodoro.trabalhando:
        return Colors.red;
      case EstadoPomodoro.emPausa:
        return Colors.blue;
      case EstadoPomodoro.parado:
        return Colors.grey;
    }
  }

  Widget _contador(
    BuildContext context,
    String titulo,
    int segundos,
    IconData icone,
    Color cor,
    bool ativo,
  ) {
    return Card(
      elevation: ativo ? 6 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ativo ? cor : Colors.transparent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 32),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              formatarDuracao(segundos),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PomodoroProvider>();
    final estado = provider.estado;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _corEstado(estado).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _textoEstado(estado),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _corEstado(estado),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _contador(
            context,
            "Trabalho",
            provider.segundosTrabalho,
            Icons.work,
            Colors.red,
            estado == EstadoPomodoro.trabalhando,
          ),
          const SizedBox(height: 16),
          _contador(
            context,
            "Descanso",
            provider.segundosDescanso,
            Icons.coffee,
            Colors.blue,
            estado == EstadoPomodoro.emPausa,
          ),
          const SizedBox(height: 32),
          _botoes(context, provider),
        ],
      ),
    );
  }

  Widget _botoes(BuildContext context, PomodoroProvider provider) {
    final estado = provider.estado;

    Widget botaoPrincipal;
    if (estado == EstadoPomodoro.trabalhando) {
      botaoPrincipal = FilledButton.icon(
        onPressed: provider.pausar,
        icon: const Icon(Icons.pause),
        label: const Text("Pausar"),
      );
    } else if (estado == EstadoPomodoro.emPausa) {
      botaoPrincipal = FilledButton.icon(
        onPressed: provider.iniciar,
        icon: const Icon(Icons.play_arrow),
        label: const Text("Retomar"),
      );
    } else {
      botaoPrincipal = FilledButton.icon(
        onPressed: provider.iniciar,
        icon: const Icon(Icons.play_arrow),
        label: const Text("Iniciar"),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 150, height: 50, child: botaoPrincipal),
        const SizedBox(width: 16),
        SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: provider.sessaoEmAndamento
                ? () async {
                    await provider.finalizar();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sessão salva no histórico!"),
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.stop),
            label: const Text("Fim"),
          ),
        ),
      ],
    );
  }
}
