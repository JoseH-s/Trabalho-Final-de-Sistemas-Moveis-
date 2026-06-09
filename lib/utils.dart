// Formata uma quantidade de segundos em HH:MM:SS (ou MM:SS quando < 1h).
String formatarDuracao(int totalSegundos) {
  final horas = totalSegundos ~/ 3600;
  final minutos = (totalSegundos % 3600) ~/ 60;
  final segundos = totalSegundos % 60;

  String dois(int n) => n.toString().padLeft(2, "0");

  if (horas > 0) {
    return "${dois(horas)}:${dois(minutos)}:${dois(segundos)}";
  }
  return "${dois(minutos)}:${dois(segundos)}";
}
