import 'package:flutter/foundation.dart';

import 'receita.dart';

// Guarda os favoritos durante a sessão e avisa as telas quando muda
class Favoritos extends ChangeNotifier {
  final List<Receita> _itens = [];

  // Lista só para leitura (ninguém de fora altera sem passar por aqui)
  List<Receita> get itens => List.unmodifiable(_itens);

  // Já está nos favoritos? (compara pelo id, assim não duplica)
  bool contem(int id) => _itens.any((r) => r.id == id);

  // Adiciona se não tiver, remove se já tiver
  void alternar(Receita receita) {
    if (contem(receita.id)) {
      _itens.removeWhere((r) => r.id == receita.id);
    } else {
      _itens.add(receita);
    }
    notifyListeners(); // avisa todas as telas
  }
}

// Instância única usada por todas as telas (fonte única de verdade)
final favoritos = Favoritos();