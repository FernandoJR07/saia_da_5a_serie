import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra do topo com o nome do app
      appBar: AppBar(
        title: const Text(
          'Saborê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      // Corpo da tela (ListView permite rolar)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título da seção de pesquisa
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

          // Campo de busca
          const TextField(
            decoration: InputDecoration(
              labelText: 'Buscar pelo nome',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Botão de buscar
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Buscar receitas', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 32),

          // Título da seção de receitas
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

          // Cartão de uma receita (exemplo fixo por enquanto)
          Card(
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
          ),
        ],
      ),

      // Barra de navegação de baixo
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
}