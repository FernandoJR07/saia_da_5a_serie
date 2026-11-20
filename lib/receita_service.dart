import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'receita.dart';

// Erro com mensagem amigável para mostrar na tela
class ErroApi implements Exception {
  final String mensagem;
  const ErroApi(this.mensagem);

  @override
  String toString() => mensagem;
}

// Responsável por buscar receitas na API DummyJSON
class ReceitaService {
  static const _enderecoBase = 'https://dummyjson.com/recipes';
  static const _tempoLimite = Duration(seconds: 10);

  // Lista de receitas (tela principal)
  Future<List<Receita>> buscarTodas() async {
    final dados = await _buscar(Uri.parse('$_enderecoBase?limit=50'));
    return _lerLista(dados);
  }

  // Pesquisa pelo nome (remota)
  Future<List<Receita>> buscarPorNome(String nome) async {
    final endereco = Uri.parse('$_enderecoBase/search').replace(
      queryParameters: {'q': nome.trim()},
    );
    final dados = await _buscar(endereco);
    return _lerLista(dados);
  }

  // Uma receita específica (tela de detalhes)
  Future<Receita> buscarPorId(int id) async {
    final dados = await _buscar(Uri.parse('$_enderecoBase/$id'));
    try {
      return Receita.fromJson(dados);
    } on FormatException {
      throw const ErroApi(
        'Os dados desta receita vieram incompletos. Tente novamente.',
      );
    }
  }

  // ---- Parte que realmente vai até a internet ----
  Future<Map<String, dynamic>> _buscar(Uri endereco) async {
    final http.Response resposta;

    // 1) Falha de rede ou demora demais
    try {
      resposta = await http.get(endereco).timeout(_tempoLimite);
    } on TimeoutException {
      throw const ErroApi(
        'O servidor demorou muito para responder. Tente novamente.',
      );
    } catch (_) {
      throw const ErroApi(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    }

    // 2) O servidor respondeu, mas com erro
    if (resposta.statusCode != 200) {
      throw ErroApi(
        'O servidor respondeu com erro (código ${resposta.statusCode}). '
            'Tente novamente.',
      );
    }

    // 3) A resposta não está no formato esperado
    final dynamic corpo;
    try {
      corpo = jsonDecode(resposta.body);
    } catch (_) {
      throw const ErroApi('Os dados recebidos vieram em um formato inesperado.');
    }

    if (corpo is! Map<String, dynamic>) {
      throw const ErroApi('Os dados recebidos vieram em um formato inesperado.');
    }

    return corpo;
  }

  // Lê a lista "recipes" da resposta e transforma cada item em Receita
  List<Receita> _lerLista(Map<String, dynamic> dados) {
    final lista = dados['recipes'];

    if (lista is! List) {
      throw const ErroApi('Os dados recebidos vieram em um formato inesperado.');
    }

    final receitas = <Receita>[];
    for (final item in lista) {
      if (item is Map<String, dynamic>) {
        try {
          receitas.add(Receita.fromJson(item));
        } on FormatException {
          // Receita com defeito (sem id): ignora só ela e segue com as outras
        }
      }
    }
    return receitas;
  }
}