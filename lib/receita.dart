// Molde (modelo) de uma receita vinda da API DummyJSON
class Receita {
  final int id; // identidade única (usada nos favoritos)
  final String nome;
  final String? imagem; // pode não vir
  final List<String> ingredientes;
  final List<String> instrucoes;
  final int? tempoPreparo; // em minutos, pode não vir
  final int? tempoCozimento; // em minutos, pode não vir
  final int? porcoes;
  final double? avaliacao; // nota, ex.: 4.6
  final String? dificuldade;
  final String? culinaria;
  final List<String> tiposRefeicao; // ex.: ["Dinner", "Lunch"]

  const Receita({
    required this.id,
    required this.nome,
    required this.imagem,
    required this.ingredientes,
    required this.instrucoes,
    required this.tempoPreparo,
    required this.tempoCozimento,
    required this.porcoes,
    required this.avaliacao,
    required this.dificuldade,
    required this.culinaria,
    required this.tiposRefeicao,
  });

  // Tempo total: só calcula se os DOIS tempos vieram.
  // Se faltar algum, devolve null (a tela mostra "não informado"),
  // em vez de fingir que o tempo que faltou é zero.
  int? get tempoTotal {
    if (tempoPreparo == null || tempoCozimento == null) return null;
    return tempoPreparo! + tempoCozimento!;
  }

  // Transforma o JSON (texto da internet) em uma Receita
  factory Receita.fromJson(Map<String, dynamic> json) {
    final id = json['id'];

    // Sem id válido não dá para identificar a receita: recusa
    if (id is! int) {
      throw const FormatException('Receita sem id válido.');
    }

    final porcoes = _inteiro(json['servings']);

    return Receita(
      id: id,
      nome: _texto(json['name']) ?? 'Receita sem nome',
      imagem: _texto(json['image']),
      ingredientes: _listaDeTextos(json['ingredients']),
      instrucoes: _listaDeTextos(json['instructions']),
      tempoPreparo: _inteiro(json['prepTimeMinutes']),
      tempoCozimento: _inteiro(json['cookTimeMinutes']),
      // Porções só valem se forem maiores que zero
      porcoes: (porcoes != null && porcoes > 0) ? porcoes : null,
      // A nota pode vir como 4 (int) ou 4.6 (double): aceita os dois
      avaliacao: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : null,
      dificuldade: _texto(json['difficulty']),
      culinaria: _texto(json['cuisine']),
      // mealType é uma LISTA, não um texto único
      tiposRefeicao: _listaDeTextos(json['mealType']),
    );
  }

  // ---- Funções auxiliares que conferem o tipo de cada campo ----

  // Aceita só texto não vazio
  static String? _texto(dynamic valor) {
    if (valor is String && valor.trim().isNotEmpty) return valor.trim();
    return null;
  }

  // Aceita só número (converte para inteiro)
  static int? _inteiro(dynamic valor) {
    if (valor is num) return valor.toInt();
    return null;
  }

  // Aceita só lista, e dentro dela só os itens que são texto
  static List<String> _listaDeTextos(dynamic valor) {
    if (valor is List) {
      return valor.whereType<String>().toList();
    }
    return [];
  }
}