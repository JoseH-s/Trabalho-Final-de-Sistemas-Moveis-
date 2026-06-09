import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:pomodoro/pomodoro_provider.dart";
import "package:pomodoro/utils.dart";

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  Widget _legenda(Color cor, String texto, String percentual) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: cor),
        const SizedBox(width: 8),
        Text("$texto  ($percentual)", style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PomodoroProvider>();
    final trabalho = provider.totalTrabalho;
    final descanso = provider.totalDescanso;
    final total = trabalho + descanso;

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Sem dados para exibir.\nRegistre uma sessão na tela do cronômetro para ver seu gráfico.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final percTrabalho = trabalho / total * 100;
    final percDescanso = descanso / total * 100;

    String fmt(double v) => "${v.toStringAsFixed(1)}%";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 8),
            const Text(
              "Meu Perfil",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "${provider.registros.length} sessão(ões) registrada(s)",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "Trabalho x Descanso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: trabalho.toDouble(),
                      color: Colors.red,
                      title: fmt(percTrabalho),
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: descanso.toDouble(),
                      color: Colors.blue,
                      title: fmt(percDescanso),
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _legenda(Colors.red, "Trabalho", fmt(percTrabalho)),
            const SizedBox(height: 8),
            _legenda(Colors.blue, "Descanso", fmt(percDescanso)),
            const SizedBox(height: 24),
            Text(
              "Tempo total: ${formatarDuracao(total)}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
