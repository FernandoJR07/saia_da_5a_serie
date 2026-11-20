import 'package:flutter/material.dart';

import 'cores.dart';
import 'detalhes_page.dart';
import 'pesquisa_page.dart';
import 'receita.dart';
import 'receita_service.dart';
import 'widgets.dart';

// Aba Explorar (tela principal)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ReceitaService _service = ReceitaService();

  String? _mensagemErro; // erro de digitação (campo vazio)
  List<Receita> _receitas = [];
  bool _carregando = true; // começa carregando
  String? _erroCarregar; // erro de rede/servidor

  @override
  void initState() {
    super.initState();
    // Busca UMA vez ao abrir (não a cada redesenho da tela)
    _buscarReceitas();
  }

  Future<void> _buscarReceitas() async {
    try {
      final lista = await _service.buscarTodas();
      if (!mounted) return;
      setState(() {
        _receitas = lista;
        _carregando = false;
      });
    } on ErroApi catch (erro) {
      if (!mounted) return;
      setState(() {
        _erroCarregar = erro.mensagem;
        _carregando = false;
      });
    }
  }

  void _tentarNovamente() {
    if (_carregando) return; // evita cliques repetidos
    setState(() {
      _carregando = true;
      _erroCarregar = null;
    });
    _buscarReceitas();
  }

  // Valida o termo e abre a tela de pesquisa
  void _pesquisar() {
    final termo = _controller.text.trim();

    if (termo.isEmpty) {
      setState(() {
        _mensagemErro =
        'Digite o nome de uma receita para pesquisar (ex.: pizza).';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _mensagemErro = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PesquisaPage(termoInicial: termo)),
    );
  }

  void _aoDigitar(String texto) {
    if (_mensagemErro != null) {
      setState(() {
        _mensagemErro = null;
      });
    }
  }

  void _abrirDetalhes(Receita receita) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesPage(receita: receita)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraSuperior(),
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
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _pesquisar(),
                  onChanged: _aoDigitar,
                  decoration: decoracaoCampoBusca(erro: _mensagemErro),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pesquisar,
                  style: estiloBotaoPrincipal(),
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Buscar receitas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                const BannerApp(),
                const SizedBox(height: 24),
                const TituloSecao(
                  titulo: 'Receitas disponíveis',
                  subtitulo: 'Selecione uma receita para ver o preparo.',
                ),
                const SizedBox(height: 12),
                _conteudoLista(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Decide o que mostrar na área da lista
  Widget _conteudoLista() {
    final erro = _erroCarregar;

    if (_carregando) {
      return const EstadoCarregando();
    }

    if (erro != null) {
      return EstadoMensagem(
        icone: Icons.wifi_off,
        titulo: 'Não foi possível carregar as receitas.',
        mensagem: erro,
        textoBotao: 'Tentar novamente',
        aoTocarBotao: _tentarNovamente,
      );
    }

    if (_receitas.isEmpty) {
      return EstadoMensagem(
        icone: Icons.no_meals,
        titulo: 'Nenhuma receita disponível',
        mensagem: 'O servidor não retornou receitas agora.',
        textoBotao: 'Tentar novamente',
        aoTocarBotao: _tentarNovamente,
      );
    }

    return Column(
      children: _receitas
          .map(
            (receita) => CartaoReceita(
          receita: receita,
          aoTocar: () => _abrirDetalhes(receita),
        ),
      )
          .toList(),
    );
  }
}