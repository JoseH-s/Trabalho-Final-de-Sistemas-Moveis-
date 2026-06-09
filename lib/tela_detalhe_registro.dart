import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:pomodoro/pomodoro_provider.dart";
import "package:pomodoro/registro.dart";
import "package:pomodoro/utils.dart";

class TelaDetalheRegistro extends StatelessWidget {
  final Registro registro;

  const TelaDetalheRegistro({super.key, required this.registro});

  String _formatarDataCompleta(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String dois(int n) => n.toString().padLeft(2, "0");
    return "${dois(d.day)}/${dois(d.month)}/${d.year} às "
        "${dois(d.hour)}:${dois(d.minute)}:${dois(d.second)}";
  }

  Widget _linha(IconData icone, Color cor, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cor.withValues(alpha: 0.15),
            child: Icon(icone, color: cor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final provider = context.read<PomodoroProvider>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir registro"),
        content: const Text(
            "Tem certeza que deseja excluir esta sessão? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await provider.excluirRegistro(registro);
      if (context.mounted) {
        Navigator.pop(context); // volta para o histórico
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro excluído.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trabalho = registro.segundosTrabalho;
    final descanso = registro.segundosDescanso;
    final total = trabalho + descanso;

    String perc(int parte) =>
        total == 0 ? "0%" : "${(parte / total * 100).toStringAsFixed(1)}%";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da sessão"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linha(Icons.event, Colors.deepPurple, "Data e hora",
                        _formatarDataCompleta(registro.dataHora)),
                    const Divider(),
                    _linha(
                        Icons.work,
                        Colors.red,
                        "Tempo de trabalho",
                        "${formatarDuracao(trabalho)}  (${perc(trabalho)})"),
                    const Divider(),
                    _linha(
                        Icons.coffee,
                        Colors.blue,
                        "Tempo de descanso",
                        "${formatarDuracao(descanso)}  (${perc(descanso)})"),
                    const Divider(),
                    _linha(Icons.timelapse, Colors.green, "Tempo total",
                        formatarDuracao(total)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _confirmarExclusao(context),
                icon: const Icon(Icons.delete),
                label: const Text("Excluir registro"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
