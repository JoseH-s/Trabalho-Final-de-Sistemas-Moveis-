class Registro {
  int id;
  String dataHora; // data/hora da sessão em formato ISO 8601
  int segundosTrabalho;
  int segundosDescanso;

  Registro({
    required this.id,
    required this.dataHora,
    required this.segundosTrabalho,
    required this.segundosDescanso,
  });

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map["id"],
      dataHora: map["data_hora"],
      segundosTrabalho: map["segundos_trabalho"],
      segundosDescanso: map["segundos_descanso"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "data_hora": dataHora,
      "segundos_trabalho": segundosTrabalho,
      "segundos_descanso": segundosDescanso,
    };
  }
}
