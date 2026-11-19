import 'package:flutter/material.dart';
import 'cores.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controle ligado ao campo de texto (para ler o que foi digitado)
  final TextEditingController _controller = TextEditingController();

  // Memória da tela
  String? _mensagemErro; // mensagem de erro (null = sem erro)
  String? _termoPesquisado; // último termo válido (null = nenhuma pesquisa)

  // Chamada quando a pessoa pede para pesquisar (botão ou Enter)
  void _pesquisar() {
    // Remove os espaços do começo e do fim
    final termo = _controller.text.trim();

    // Consulta vazia ou só com espaços: mostra erro e NÃO pesquisa
    if (termo.isEmpty) {
      setState(() {
        _mensagemErro =
        'Digite o nome de uma receita para pesquisar (ex.: pizza).';
      });
      return;
    }

    // Fecha o teclado (no celular)
    FocusScope.of(context).unfocus();

    // Consulta válida: apaga o erro e guarda o termo
    setState(() {
      _mensagemErro = null;
      _termoPesquisado = termo;
    });
  }

  // Limpa o campo e volta ao início, permitindo nova consulta
  void _limparPesquisa() {
    _controller.clear();
    setState(() {
      _mensagemErro = null;
      _termoPesquisado = null;
    });
  }

  // Quando a pessoa volta a digitar, some a mensagem de erro
  void _aoDigitar(String texto) {
    if (_mensagemErro != null) {
      setState(() {
        _mensagemErro = null;
      });
    }
  }

  // Libera o controller quando a tela for fechada
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cópia local do termo (facilita usar dentro do layout)
    final termo = _termoPesquisado;

    return Scaffold(
      backgroundColor: Cores.bege,

      // Topo branco com o nome do app em vermelho
      appBar: AppBar(
        backgroundColor: Cores.branco,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
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
        ),
      ),

      // Corpo da tela (ListView permite rolar)
      body: ListView(
        children: [
          // ===== Bloco branco de pesquisa =====
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: Cores.branco,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'O que vamos cozinhar hoje?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Cores.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pesquise uma receita pelo nome.',
                  style: TextStyle(fontSize: 15, color: Cores.textoSecundario),
                ),
                const SizedBox(height: 16),

                // Campo de busca (rotulado)
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _pesquisar(), // Enter também pesquisa
                  onChanged: _aoDigitar,
                  decoration: InputDecoration(
                    labelText: 'Nome da receita',
                    hintText: 'Ex.: pizza, frango, bolo...',
                    helperText:
                    'Você pode buscar por parte do nome da receita.',
                    errorText: _mensagemErro, // vermelho se houver erro
                    prefixIcon: const Icon(Icons.search, color: Cores.vermelho),
                    filled: true,
                    fillColor: Cores.bege,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                      const BorderSide(color: Cores.vermelho, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Cores.vermelhoEscuro),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Cores.vermelhoEscuro,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botão de pesquisar (ação explícita)
                ElevatedButton.icon(
                  onPressed: _pesquisar,
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Pesquisar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Cores.vermelho,
                    foregroundColor: Cores.branco,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Conteúdo sobre o fundo bege =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner de boas-vindas (identidade do app)
                _banner(),
                const SizedBox(height: 24),

                // Se ninguém pesquisou ainda: mostra a listagem
                if (termo == null) ...[
                  _tituloSecao(
                    'Receitas disponíveis',
                    'Selecione uma receita para ver o preparo.',
                  ),
                  const SizedBox(height: 12),
                  _cartaoReceita(),
                ]
                // Se pesquisou: mostra o termo recebido e o resultado provisório
                else ...[
                  _tituloSecao(
                    'Resultados para “$termo”',
                    'Toque na receita para ver o preparo.',
                  ),
                  const SizedBox(height: 12),
                  _cartaoReceita(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _limparPesquisa,
                    icon: const Icon(Icons.close),
                    label: const Text('Limpar pesquisa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Cores.vermelho,
                      side: const BorderSide(color: Cores.vermelho),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      // Barra de navegação de baixo
      bottomNavigationBar: NavigationBar(
        backgroundColor: Cores.branco,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Cores.begeEscuro,
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: Cores.vermelho),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Cores.vermelho),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  // Banner vermelho de boas-vindas
  Widget _banner() {
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

  // Título + subtítulo de uma seção
  Widget _tituloSecao(String titulo, String subtitulo) {
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
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: const TextStyle(fontSize: 15, color: Cores.textoSecundario),
        ),
      ],
    );
  }

  // Cartão de uma receita (exemplo fixo por enquanto)
  Widget _cartaoReceita() {
    return Card(
      color: Cores.branco,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // "Foto" provisória (ícone no lugar da imagem)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Cores.bege,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_pizza,
                  color: Cores.vermelho,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),

              // Nome e informações
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classic Margherita Pizza',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Cores.textoPrincipal,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 16, color: Cores.textoSecundario),
                        SizedBox(width: 4),
                        Text(
                          '35 min • Fácil',
                          style: TextStyle(color: Cores.textoSecundario),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Nota em formato de "pílula"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Cores.bege,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '4,6',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Cores.textoPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}