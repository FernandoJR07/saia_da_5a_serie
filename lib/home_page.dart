import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  String? _mensagemErro;
  String? _termoPesquisado;

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
      _termoPesquisado = termo;
    });
  }

  void _limparPesquisa() {
    _controller.clear();
    setState(() {
      _mensagemErro = null;
      _termoPesquisado = null;
    });
  }

  void _aoDigitar(String texto) {
    if (_mensagemErro != null) {
      setState(() {
        _mensagemErro = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _termoPesquisado;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saborê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Receitas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pesquise uma receita pelo nome.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _pesquisar(), // Enter também pesquisa
            onChanged: _aoDigitar,
            decoration: InputDecoration(
              labelText: 'Nome da receita',
              hintText: 'Buscar pelo nome',
              helperText: 'Você pode buscar por parte do nome da receita.',
              errorText: _mensagemErro, // aparece em vermelho se houver erro
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _pesquisar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Pesquisar', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 32),

          if (termo == null) ...[
            const Text(
              'Receitas disponíveis',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione uma receita para ver o preparo.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _cartaoReceita(),
          ]
          else ...[
            Text(
              'Resultados para “$termo”',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque na receita para ver o preparo.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _cartaoReceita(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _limparPesquisa,
              icon: const Icon(Icons.close),
              label: const Text('Limpar pesquisa'),
            ),
          ],
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _cartaoReceita() {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: Colors.deepOrange),
        ),
        title: const Text(
          'Classic Margherita Pizza',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('35 min • Fácil'),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 18),
            SizedBox(width: 4),
            Text('4,6 / 5'),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}