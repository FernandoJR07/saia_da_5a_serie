import 'package:flutter/material.dart';

import 'cores.dart';
import 'favoritos.dart';
import 'receita.dart';
import 'widgets.dart';

// Tela de detalhes. Reaproveita o objeto completo que já veio na lista
// (a resposta da API já traz ingredientes e instruções).
class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key, required this.receita});

  final Receita receita;

  // Ex.: "Italian • Fácil • 4,6 / 5 • Dinner"
  String _linhaInfo() {
    final partes = <String>[];
    final culinaria = receita.culinaria;
    if (culinaria != null) partes.add(culinaria);
    partes.add(traduzirDificuldade(receita.dificuldade));
    final nota = receita.avaliacao;
    if (nota != null) partes.add('${formatarNota(nota)} / 5');
    if (receita.tiposRefeicao.isNotEmpty) {
      partes.add(receita.tiposRefeicao.join(', '));
    }
    return partes.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final total = receita.tempoTotal;
    final porcoes = receita.porcoes;

    return Scaffold(
      appBar: barraSuperior(titulo: const Text('Receita')),
      // ListView permite rolar e ler o conteúdo longo
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ImagemReceita(
            url: receita.imagem,
            largura: double.infinity,
            altura: 220,
            raio: 20,
          ),
          const SizedBox(height: 16),
          Text(
            receita.nome,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Cores.textoPrincipal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _linhaInfo(),
            style: const TextStyle(fontSize: 15, color: Cores.textoSecundario),
          ),
          const SizedBox(height: 16),

          // Caixinhas: tempo, porções e favorito
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Caixinha(
                  icone: Icons.schedule,
                  valor: total == null ? 'Não informado' : '$total min',
                  legenda: 'tempo total',
                ),
              ),
              // Porções só aparecem se forem informadas
              if (porcoes != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _Caixinha(
                    icone: Icons.people_outline,
                    valor: '$porcoes',
                    legenda: 'porções',
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: ListenableBuilder(
                  listenable: favoritos,
                  builder: (context, _) {
                    final ehFavorita = favoritos.contem(receita.id);
                    return _Caixinha(
                      icone:
                      ehFavorita ? Icons.favorite : Icons.favorite_border,
                      valor: ehFavorita ? 'Salva' : 'Salvar',
                      legenda: 'nos favoritos',
                      aoTocar: () => favoritos.alternar(receita),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Ingredientes
          TituloSecao(
            titulo: 'Ingredientes',
            subtitulo: '${receita.ingredientes.length} itens',
          ),
          const SizedBox(height: 8),
          if (receita.ingredientes.isEmpty)
            const Text(
              'Ingredientes não informados.',
              style: TextStyle(color: Cores.textoSecundario),
            )
          else
            ...receita.ingredientes.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(Icons.circle, size: 8, color: Cores.vermelho),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),

          // Modo de preparo (mantém a ordem dos passos)
          const TituloSecao(
            titulo: 'Modo de preparo',
            subtitulo: 'Siga os passos na ordem.',
          ),
          const SizedBox(height: 8),
          if (receita.instrucoes.isEmpty)
            const Text(
              'Modo de preparo não informado.',
              style: TextStyle(color: Cores.textoSecundario),
            )
          else
            for (var i = 0; i < receita.instrucoes.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Cores.vermelho,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Cores.branco,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        receita.instrucoes[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Caixinha branca com ícone, valor e legenda
class _Caixinha extends StatelessWidget {
  const _Caixinha({
    required this.icone,
    required this.valor,
    required this.legenda,
    this.aoTocar,
  });

  final IconData icone;
  final String valor;
  final String legenda;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Cores.branco,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: Cores.vermelho),
              const SizedBox(height: 6),
              Text(
                valor,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Cores.textoPrincipal,
                ),
              ),
              Text(
                legenda,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Cores.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}