# Pomodoro — Documentação do Projeto

Aplicativo de **Pomodoro** desenvolvido em **Flutter** para o Trabalho P2 de ADS B.
Permite cronometrar livremente o tempo de trabalho e de descanso, registrar cada
sessão em banco de dados, consultar o histórico (com detalhe e exclusão por
registro) e visualizar a proporção trabalho × descanso em um gráfico de pizza.

---

## 1. Visão geral

O app tem **3 telas**, acessadas por uma barra de navegação inferior
(`NavigationBar`):

| Aba | Tela | Função |
|-----|------|--------|
| Cronômetro | `TelaCronometro` | Controle livre do tempo de trabalho/descanso (iniciar, pausar, retomar, fim) |
| Histórico | `TelaHistorico` | Lista das sessões salvas, resumo agregado e botão de limpar |
| Perfil | `TelaPerfil` | Gráfico de pizza com o percentual de trabalho × descanso |

Ao tocar em um registro do histórico, abre-se a **tela de detalhe**
(`TelaDetalheRegistro`), que mostra mais informações da sessão e permite
**excluí-la**.

---

## 2. Requisitos atendidos

- **Gerenciamento de estado com Provider** — toda a lógica vive em
  `PomodoroProvider` (`ChangeNotifier`), exposto na árvore via
  `ChangeNotifierProvider` no `main.dart`.
- **Persistência em banco de dados** — `sqflite`, encapsulado em
  `DataAccessObject` (padrão DAO).
- **Gráfico de pizza** — biblioteca **`fl_chart`** (`PieChart`) na tela de Perfil.
- **Navegação** — `NavigationBar` (3 abas) + `Navigator.push` para a tela de
  detalhe.
- **3 telas** + tela de detalhe, conforme o enunciado.

---

## 3. Tecnologias e dependências

Definidas em `pubspec.yaml`:

```yaml
name: pomodoro
environment:
  sdk: ^3.11.0

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.2+1   # banco de dados local
  provider: ^6.1.2    # gerenciamento de estado
  fl_chart: ^0.69.2   # gráfico de pizza
```

---

## 4. Estrutura de pastas

A estrutura segue o padrão **model → DAO → provider → telas → app → main**, com
arquivos planos em `lib/`:

```
lib/
├── main.dart                   # ponto de entrada; injeta o Provider
├── pomodoro_app.dart           # MaterialApp + NavigationBar (shell das 3 telas)
├── pomodoro_provider.dart      # estado (ChangeNotifier): cronômetro + histórico
├── data_access_object.dart     # DAO sqflite (tabela "registros")
├── registro.dart               # model de uma sessão de pomodoro
├── utils.dart                  # função de formatação de duração
├── tela_cronometro.dart        # Tela 1
├── tela_historico.dart         # Tela 2
├── tela_detalhe_registro.dart  # detalhe/exclusão de um registro
└── tela_perfil.dart            # Tela 3 (gráfico de pizza)
```

---

## 5. Detalhamento dos arquivos

### 5.1 `main.dart`
Ponto de entrada. Envolve o app com `ChangeNotifierProvider`, criando o
`PomodoroProvider` e já carregando os registros do banco:

```dart
runApp(
  ChangeNotifierProvider(
    create: (_) => PomodoroProvider()..carregarRegistros(),
    child: const PomodoroApp(),
  ),
);
```

### 5.2 `pomodoro_app.dart`
- `PomodoroApp`: `MaterialApp` com tema (seed `Colors.red`, Material 3).
- `_Inicio` (`StatefulWidget`): mantém o índice da aba selecionada e troca o corpo
  entre `TelaCronometro`, `TelaHistorico` e `TelaPerfil` via `NavigationBar`.

### 5.3 `registro.dart` — Model
Representa uma sessão concluída:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | `int` | Chave primária (autoincremento) |
| `dataHora` | `String` | Data/hora em ISO 8601 |
| `segundosTrabalho` | `int` | Total de segundos trabalhados na sessão |
| `segundosDescanso` | `int` | Total de segundos em pausa na sessão |

Inclui `fromMap` (banco → objeto) e `toMap` (objeto → banco).

### 5.4 `data_access_object.dart` — DAO (sqflite)
Classe estática que isola o acesso ao banco `pomodoro.db`:

| Método | Operação | Descrição |
|--------|----------|-----------|
| `criarTabelas(db)` | — | Cria a tabela `registros` na 1ª execução |
| `db()` | — | Abre/cria o banco |
| `incluirRegistro(registro)` | Create | Insere uma sessão |
| `obterRegistros()` | Read | Lista todas (mais recentes primeiro) |
| `excluirRegistro(registro)` | Delete | Remove uma sessão pelo `id` |
| `limparHistorico()` | Delete | Apaga todos os registros |

### 5.5 `pomodoro_provider.dart` — Estado (ChangeNotifier)
Coração do app. Controla o cronômetro e o histórico.

**Estado do cronômetro:**
- `enum EstadoPomodoro { parado, trabalhando, emPausa }`
- `segundosTrabalho`, `segundosDescanso` — contadores da sessão atual.
- Um único `Timer.periodic(1s)` incrementa o contador correspondente ao estado
  atual e chama `notifyListeners()`.

**Métodos principais:**

| Método | Efeito |
|--------|--------|
| `iniciar()` | Estado → `trabalhando` (também usado para *retomar*) |
| `pausar()` | Estado → `emPausa` (passa a contar descanso) |
| `finalizar()` | Salva a sessão no banco, recarrega a lista e zera os contadores |
| `carregarRegistros()` | Lê os registros do banco |
| `excluirRegistro(r)` | Exclui um registro e recarrega |
| `limparHistorico()` | Apaga tudo e recarrega |

**Getters agregados:** `totalTrabalho` e `totalDescanso` somam todos os registros
(usados no resumo do histórico e no gráfico do perfil).

### 5.6 `utils.dart`
`formatarDuracao(int segundos)` → texto `MM:SS` (ou `HH:MM:SS` quando ≥ 1h).

### 5.7 `tela_cronometro.dart` — Tela 1
- Lê o provider com `context.watch`.
- Mostra o estado atual (chip colorido) e dois cartões: **Trabalho** e
  **Descanso**, com o tempo ao vivo em `MM:SS`; o cartão ativo fica destacado.
- Botões contextuais:
  - `parado` → **Iniciar**
  - `trabalhando` → **Pausar**
  - `emPausa` → **Retomar**
  - **Fim** (habilitado quando há sessão em andamento) → salva e mostra um
    `SnackBar`.

### 5.8 `tela_historico.dart` — Tela 2
- Resumo no topo: total de trabalho e total de descanso (cartão).
- `ListView` das sessões; cada item mostra data/hora e os tempos, com um `>`
  indicando que é clicável.
- **`onTap`** → `Navigator.push` para `TelaDetalheRegistro`.
- Botão **Limpar histórico** (com confirmação via `AlertDialog`), desabilitado se
  a lista estiver vazia.

### 5.9 `tela_detalhe_registro.dart` — Detalhe do registro
Recebe um `Registro` e exibe, em cartão:
- Data e hora completas (com segundos)
- Tempo de trabalho (com percentual da sessão)
- Tempo de descanso (com percentual)
- Tempo total

Botão **Excluir registro** (com confirmação). Ao confirmar, chama
`provider.excluirRegistro`, volta ao histórico e mostra um `SnackBar`.

### 5.10 `tela_perfil.dart` — Tela 3
- Usa os agregados `totalTrabalho` / `totalDescanso`.
- Renderiza um `PieChart` (`fl_chart`) com duas seções (trabalho em vermelho,
  descanso em azul) e os percentuais.
- Mostra legenda, quantidade de sessões e tempo total.
- Se não houver dados, exibe uma mensagem amigável.

---

## 6. Fluxo de uso

```
TelaCronometro
   Iniciar ─► conta TRABALHO (segundos)
   Pausar  ─► congela trabalho, conta DESCANSO
   Retomar ─► congela descanso, volta ao trabalho
   Fim     ─► salva {dataHora, segundosTrabalho, segundosDescanso} no banco
                 │
                 ▼
TelaHistorico  ◄── lista atualizada automaticamente (Provider)
   toca no item ─► TelaDetalheRegistro ─► Excluir ─► volta ao histórico
   Limpar histórico ─► apaga tudo
                 │
                 ▼
TelaPerfil     ─► gráfico de pizza com % trabalho × descanso
```

A lógica de "controle livre" pedida no enunciado é atendida porque o cronômetro
não tem tempo fixo: ele apenas contabiliza os segundos de trabalho enquanto roda e
os segundos de descanso enquanto está em pausa — o intervalo entre um início e
outro (a pausa) é exatamente o tempo acumulado no estado `emPausa`.

---

## 7. Banco de dados

Arquivo: `pomodoro.db` (criado automaticamente no primeiro uso).

```sql
CREATE TABLE registros (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  data_hora TEXT NOT NULL,
  segundos_trabalho INTEGER NOT NULL,
  segundos_descanso INTEGER NOT NULL
);
```

O histórico persiste entre execuções do app.

---

## 8. Como executar

```bash
# 1. Instalar as dependências
flutter pub get

# 2. Conferir que não há erros
flutter analyze

# 3. Rodar (emulador Android ou dispositivo físico)
flutter run
```

> **Observação (Windows desktop):** o projeto usa `sqflite` puro, que funciona em
> Android/iOS. Para rodar em **Windows desktop** (`flutter run -d windows`) seria
> necessário adicionar `sqflite_common_ffi` e inicializá-lo. Em emulador/dispositivo
> Android funciona diretamente.

---

## 9. Decisões de projeto

- **Provider** em vez de `setState` global: centraliza o estado do cronômetro e do
  histórico, permitindo que as 3 telas reajam às mudanças automaticamente.
- **DAO estático**: mantém o acesso ao banco isolado e reutilizável, seguindo o
  mesmo padrão do projeto-base.
- **Um único `Timer`**: simplifica a contagem — o mesmo timer incrementa trabalho
  ou descanso conforme o estado, evitando múltiplos timers concorrentes.
- **fl_chart**: biblioteca de gráficos mais popular e mantida do ecossistema
  Flutter, escolhida para o gráfico de pizza.
