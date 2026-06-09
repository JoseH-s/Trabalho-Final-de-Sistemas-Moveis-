import "package:flutter/material.dart";
import "package:pomodoro/registro.dart";
import "package:sqflite/sqflite.dart" as sql;

class DataAccessObject {
  static Future<void> criarTabelas(sql.Database database) async {
    await database.execute("""
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        data_hora TEXT NOT NULL,
        segundos_trabalho INTEGER NOT NULL,
        segundos_descanso INTEGER NOT NULL
      );
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "pomodoro.db",
      version: 1,
      onCreate: (sql.Database database, int versao) async {
        await criarTabelas(database);
      },
    );
  }

  static Future<int> incluirRegistro(Registro registro) async {
    final db = await DataAccessObject.db();
    final idIncluido = await db.insert("registros", registro.toMap());
    return idIncluido;
  }

  static Future<List<Registro>> obterRegistros() async {
    final db = await DataAccessObject.db();
    final mapas = await db.query("registros", orderBy: "data_hora DESC");
    return mapas.map((map) => Registro.fromMap(map)).toList();
  }

  static Future<bool> excluirRegistro(Registro registro) async {
    final db = await DataAccessObject.db();
    try {
      await db.delete("registros", where: "id = ?", whereArgs: [registro.id]);
      return true;
    } catch (erro) {
      debugPrint("Falha ao excluir registro: $erro");
      return false;
    }
  }

  static Future<bool> limparHistorico() async {
    final db = await DataAccessObject.db();
    try {
      await db.delete("registros");
      return true;
    } catch (erro) {
      debugPrint("Falha ao limpar histórico: $erro");
      return false;
    }
  }
}
