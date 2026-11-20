import 'package:flutter/material.dart';

import 'detalhes_page.dart';
import 'receita.dart';
import 'receita_service.dart';
import 'widgets.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key, this.termoInicial});

  // Termo vindo da tela Explorar (pode não vir)
  final String? termoInicial;

  @override
  State<PesquisaPage> createState() => _PesquisaPageState();
}

class _PesquisaPageState extends State<PesquisaPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _foco = FocusNode(); // permite "clicar" no campo pelo código
  final ReceitaService _service = ReceitaService();

  String? _mensagemErro; // erro de digitação (campo vazio)
  String? _termoAtual; // último termo válido pesquisado
  List<Receita> _resultados = [];
  String? _erroBusca; // erro de rede/servidor
  bool _carregando = false;

  // Número da consulta: se chegar resposta de uma consulta antiga, ignoramos
  int _numeroConsulta = 0;

  @override
  void initState() {
    super.initState();
    final termo = widget.termoInicial;
    if (termo != null) {
      // Já chega pesquisando o termo digitado na tela Explorar
      _controller.text = termo;
      _termoAtual = termo;
      _carregando = true;
      _buscar(termo);
    }
  }

  // Validação + início da pesquisa
  void _pesquisar() {
    final termo = _controller.text.trim();

    // Consulta vazia ou só com espaços: NÃO pesquisa
    if (termo.isEmpty) {
      setState(() {
        _mensagemErro =
        'Digite o nome de uma receita para pesquisar (ex.: pizza).';
      });
      return;
    }

    // Evita cliques repetidos enquanto já está buscando
    if (_carregando) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _mensagemErro = null;
      _termoAtual = termo;
      _erroBusca = null;
      _carregando = true;
    });
    _buscar(termo);
  }

  // Vai até a API
  Future<void> _buscar(String termo) async {
    final numero = ++_numeroConsulta;
    try {
      final lista = await _service.buscarPorNome(termo);
      if (!mounted || numero != _numeroConsulta) return; // resposta antiga
      setState(() {
        _resultados = lista;
        _carregando = false;
      });
    } on ErroApi catch (erro) {
      if (!mounted || numero != _numeroConsulta) return;
      setState(() {
        _erroBusca = erro.mensagem;
        _carregando = false;
      });
    }
  }

  void _tentarNovamente() {
    final termo = _termoAtual;
    if (termo == null || _carregando) return;
    setState(() {
      _erroBusca = null;
      _carregando = true;
    });
    _buscar(termo);
  }

  // Apaga tudo e volta ao estado inicial
  void _limparPesquisa() {
    _numeroConsulta++; // descarta qualquer resposta pendente
    _controller.clear();
    setState(() {
      _mensagemErro = null;
      _termoAtual = null;
      _resultados = [];
      _erroBusca = null;
      _carregando = false;
    });
    _foco.requestFocus();
  }

  // Seleciona o texto do campo para a pessoa digitar outro
  void _alterarPesquisa() {
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _foco.requestFocus();
  }

  // Volta para a tela Explorar (lista completa)
  void _verTodas() {
    Navigator.pop(context);
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
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraSuperior(titulo: const Text('Pesquisar receitas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TituloSecao(titulo: 'Qual receita você procura?'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _foco,
            autofocus: widget.termoInicial == null,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _pesquisar(),
            onChanged: _aoDigitar,
            decoration: decoracaoCampoBusca(erro: _mensagemErro),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            // Desativado enquanto carrega (evita cliques repetidos)
            onPressed: _carregando ? null : _pesquisar,
            style: estiloBotaoPrincipal(),
            icon: const Icon(Icons.search),
            label: const Text(
              'Pesquisar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          _conteudo(),
        ],
      ),
    );
  }

  // Decide o que mostrar abaixo do botão
  Widget _conteudo() {
    final termo = _termoAtual;
    final erro = _erroBusca;

    // Ainda não pesquisou nada
    if (termo == null) {
      return const EstadoMensagem(
        icone: Icons.manage_search,
        titulo: 'Digite um nome para pesquisar.',
        mensagem: 'Você pode buscar por parte do nome da receita.',
      );
    }

    // Buscando
    if (_carregando) {
      return const EstadoCarregando(mensagem: 'Buscando receitas…');
    }

    // Falha de rede/servidor
    if (erro != null) {
      return EstadoMensagem(
        icone: Icons.wifi_off,
        titulo: 'Não foi possível pesquisar.',
        mensagem: erro,
        textoBotao: 'Tentar novamente',
        aoTocarBotao: _tentarNovamente,
      );
    }

    // Deu certo, mas não achou nada
    if (_resultados.isEmpty) {
      return EstadoMensagem(
        icone: Icons.search_off,
        titulo: 'Nenhum resultado',
        mensagem: 'Não encontramos receitas para “$termo”. Tente outro termo.',
        textoBotao: 'Alterar pesquisa',
        aoTocarBotao: _alterarPesquisa,
        textoBotaoSecundario: 'Ver todas as receitas',
        aoTocarBotaoSecundario: _verTodas,
      );
    }

    // Achou receitas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSecao(
          titulo: 'Resultados para “$termo”',
          subtitulo: 'Toque na receita para ver o preparo.',
        ),
        const SizedBox(height: 12),
        ..._resultados.map(
              (receita) => CartaoReceita(
            receita: receita,
            aoTocar: () => _abrirDetalhes(receita),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _limparPesquisa,
          icon: const Icon(Icons.close),
          label: const Text('Limpar pesquisa'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade700),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}