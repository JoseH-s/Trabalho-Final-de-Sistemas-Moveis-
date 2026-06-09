import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:pomodoro/pomodoro_provider.dart";
import "package:pomodoro/registro.dart";
import "package:pomodoro/tela_detalhe_registro.dart";
import "package:pomodoro/utils.dart";

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  String _formatarData(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String dois(int n) => n.toString().padLeft(2, "0");
    return "${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}";
  }

  Future<void> _confirmarLimpeza(
      BuildContext context, PomodoroProvider provider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Limpar histórico"),
        content: const Text(
            "Tem certeza que deseja apagar todos os registros? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Limpar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await provider.limparHistorico();
    }
  }

  Widget _resumo(BuildContext context, PomodoroProvider provider) {
    Widget item(String titulo, int segundos, IconData icone, Color cor) {
      return Column(
        children: [
          Icon(icone, color: cor),
          const SizedBox(height: 4),
          Text(titulo, style: const TextStyle(fontSize: 14)),
          Text(
            formatarDuracao(segundos),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: cor),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            item("Total trabalho", provider.totalTrabalho, Icons.work,
                Colors.red),
            item("Total descanso", provider.totalDescanso, Icons.coffee,
                Colors.blue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PomodoroProvider>();
    final registros = provider.registros;

    return Column(
      children: [
        _resumo(context, provider),
        Expanded(
          child: registros.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma sessão registrada ainda.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final Registro r = registros[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.timer),
                      ),
                      title: Text(_formatarData(r.dataHora)),
                      subtitle: Row(
                        children: [
                          Icon(Icons.work, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(formatarDuracao(r.segundosTrabalho)),
                          const SizedBox(width: 16),
                          Icon(Icons.coffee, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(formatarDuracao(r.segundosDescanso)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaDetalheRegistro(registro: r),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: registros.isEmpty
                  ? null
                  : () => _confirmarLimpeza(context, provider),
              icon: const Icon(Icons.delete_outline),
              label: const Text("Limpar histórico"),
            ),
          ),
        ),
      ],
    );
  }
}
