import 'package:flutter/material.dart';

import 'cores.dart';
import 'favoritos.dart';
import 'receita.dart';

// ================= Funções de texto =================

// A API manda a dificuldade em inglês: traduzimos só essa
String traduzirDificuldade(String? dificuldade) {
  switch (dificuldade) {
    case 'Easy':
      return 'Fácil';
    case 'Medium':
      return 'Média';
    case 'Hard':
      return 'Difícil';
    default:
      return dificuldade ?? 'Dificuldade não informada';
  }
}

// 4.6 -> "4,6"
String formatarNota(double nota) =>
    nota.toStringAsFixed(1).replaceAll('.', ',');

// Tempo total, ou aviso se a API não informou
String textoTempo(Receita receita) {
  final total = receita.tempoTotal;
  return total == null ? 'Tempo não informado' : '$total min';
}

// ================= Estilos =================

// Botão vermelho arredondado
ButtonStyle estiloBotaoPrincipal() {
  return ElevatedButton.styleFrom(
    backgroundColor: Cores.vermelho,
    foregroundColor: Cores.branco,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}

// Visual do campo de busca (usado na Explorar e na Pesquisa)
InputDecoration decoracaoCampoBusca({String? erro}) {
  final borda = BorderRadius.circular(30);
  return InputDecoration(
    labelText: 'Nome da receita',
    hintText: 'Ex.: pizza, chicken, cake...',
    helperText: 'Busque pelo nome em inglês, inteiro ou só uma parte.',
    errorText: erro, // aparece em vermelho se houver erro
    prefixIcon: const Icon(Icons.search, color: Cores.vermelho),
    filled: true,
    fillColor: Cores.bege,
    border: OutlineInputBorder(
      borderRadius: borda,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borda,
      borderSide: const BorderSide(color: Cores.vermelho, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borda,
      borderSide: const BorderSide(color: Cores.vermelhoEscuro),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borda,
      borderSide: const BorderSide(color: Cores.vermelhoEscuro, width: 2),
    ),
  );
}

// Barra do topo padrão (branca, com detalhes em vermelho)
PreferredSizeWidget barraSuperior({Widget? titulo}) {
  return AppBar(
    backgroundColor: Cores.branco,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Cores.vermelho, // cor da seta de voltar e do título
    elevation: 0,
    title: titulo ?? const LogoApp(),
  );
}

// ================= Peças visuais =================

// Logo: ícone + nome do app
class LogoApp extends StatelessWidget {
  const LogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_menu, color: Cores.vermelho),
        SizedBox(width: 8),
        Text(
          'LondonFood',
          style: TextStyle(
            color: Cores.vermelho,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// Banner vermelho de boas-vindas
class BannerApp extends StatelessWidget {
  const BannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Cores.vermelho, Cores.vermelhoEscuro],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receitas do mundo todo',
                  style: TextStyle(
                    color: Cores.branco,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Escolha, aprenda e cozinhe em casa.',
                  style: TextStyle(color: Cores.branco, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.ramen_dining, color: Cores.branco, size: 56),
        ],
      ),
    );
  }
}

// Título + subtítulo de uma seção
class TituloSecao extends StatelessWidget {
  const TituloSecao({super.key, required this.titulo, this.subtitulo});

  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final sub = subtitulo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Cores.textoPrincipal,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 15, color: Cores.textoSecundario),
          ),
        ],
      ],
    );
  }
}

// Imagem da receita, com ícone no lugar se faltar ou falhar
class ImagemReceita extends StatelessWidget {
  const ImagemReceita({
    super.key,
    required this.url,
    required this.altura,
    this.largura,
    this.raio = 12,
  });

  final String? url;
  final double altura;
  final double? largura;
  final double raio;

  @override
  Widget build(BuildContext context) {
    // Alternativa visual (sem foto)
    final reserva = Container(
      width: largura,
      height: altura,
      color: Cores.bege,
      child: const Icon(Icons.restaurant, color: Cores.vermelho, size: 32),
    );

    final endereco = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: endereco == null
          ? reserva
          : Image.network(
        endereco,
        width: largura,
        height: altura,
        fit: BoxFit.cover,
        // Se a imagem falhar, mostra o ícone
        errorBuilder: (context, erro, pilha) => reserva,
        // Enquanto carrega, mostra o ícone
        loadingBuilder: (context, imagem, progresso) =>
        progresso == null ? imagem : reserva,
      ),
    );
  }
}

// "Pílula" com a estrela e a nota
class PilulaNota extends StatelessWidget {
  const PilulaNota({super.key, required this.nota});

  final double nota;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Cores.bege,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            formatarNota(nota),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Cores.textoPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

// Cartão de uma receita (usado em todas as listas)
class CartaoReceita extends StatelessWidget {
  const CartaoReceita({
    super.key,
    required this.receita,
    required this.aoTocar,
  });

  final Receita receita;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final nota = receita.avaliacao;

    return Card(
      color: Cores.branco,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ImagemReceita(url: receita.imagem, largura: 72, altura: 72),
              const SizedBox(width: 12),

              // Nome, tempo e dificuldade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Cores.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 16, color: Cores.textoSecundario),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${textoTempo(receita)} • '
                                '${traduzirDificuldade(receita.dificuldade)}',
                            overflow: TextOverflow.ellipsis,
                            style:
                            const TextStyle(color: Cores.textoSecundario),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (nota != null) ...[
                const SizedBox(width: 8),
                PilulaNota(nota: nota),
              ],

              // Coração: atualiza sozinho quando os favoritos mudam
              ListenableBuilder(
                listenable: favoritos,
                builder: (context, _) {
                  final ehFavorita = favoritos.contem(receita.id);
                  return IconButton(
                    onPressed: () => favoritos.alternar(receita),
                    tooltip: ehFavorita
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    icon: Icon(
                      ehFavorita ? Icons.favorite : Icons.favorite_border,
                      color: Cores.vermelho,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Estado "carregando"
class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key, this.mensagem = 'Carregando receitas…'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Cores.vermelho),
          const SizedBox(height: 16),
          Text(
            mensagem,
            style: const TextStyle(fontSize: 16, color: Cores.textoSecundario),
          ),
        ],
      ),
    );
  }
}

// Estado com ícone, título, mensagem e até 2 botões
// (usado para erro, nenhum resultado, favoritos vazios...)
class EstadoMensagem extends StatelessWidget {
  const EstadoMensagem({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.textoBotao,
    this.aoTocarBotao,
    this.textoBotaoSecundario,
    this.aoTocarBotaoSecundario,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? textoBotao;
  final VoidCallback? aoTocarBotao;
  final String? textoBotaoSecundario;
  final VoidCallback? aoTocarBotaoSecundario;

  @override
  Widget build(BuildContext context) {
    final botao = textoBotao;
    final botaoSecundario = textoBotaoSecundario;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Cores.begeEscuro,
            child: Icon(icone, color: Cores.vermelho, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Cores.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Cores.textoSecundario),
          ),
          if (botao != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: aoTocarBotao,
              style: estiloBotaoPrincipal(),
              child: Text(botao),
            ),
          ],
          if (botaoSecundario != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: aoTocarBotaoSecundario,
              style: TextButton.styleFrom(foregroundColor: Cores.vermelho),
              child: Text(botaoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}