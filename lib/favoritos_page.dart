import 'package:flutter/material.dart';

import 'cores.dart';
import 'detalhes_page.dart';
import 'favoritos.dart';
import 'widgets.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key, required this.aoExplorar});

  // Troca para a aba Explorar (vem da TelaPrincipal)
  final VoidCallback aoExplorar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraSuperior(),
      // Redesenha sozinho quando os favoritos mudam
      body: ListenableBuilder(
        listenable: favoritos,
        builder: (context, _) {
          final itens = favoritos.itens;

          // Nenhum favorito ainda
          if (itens.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: EstadoMensagem(
                  icone: Icons.favorite_border,
                  titulo: 'Nenhum favorito',
                  mensagem:
                  'Marque uma receita como favorita para encontrá-la aqui.',
                  textoBotao: 'Explorar receitas',
                  aoTocarBotao: aoExplorar,
                ),
              ),
            );
          }

          // Lista de favoritos
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TituloSecao(
                titulo: 'Favoritos',
                subtitulo: 'Receitas salvas nesta sessão.',
              ),
              const SizedBox(height: 12),
              ...itens.map(
                    (receita) => CartaoReceita(
                  receita: receita,
                  aoTocar: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesPage(receita: receita),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toque no coração para remover.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Cores.textoSecundario),
              ),
            ],
          );
        },
      ),
    );
  }
}