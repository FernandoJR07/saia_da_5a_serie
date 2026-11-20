import 'package:flutter/material.dart';

import 'cores.dart';
import 'favoritos_page.dart';
import 'home_page.dart';

// Moldura do app: barra de baixo + as duas abas
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _abaAtual = 0; // 0 = Explorar, 1 = Favoritos

  void _irParaAba(int aba) {
    setState(() {
      _abaAtual = aba;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém as duas abas "vivas" e só troca a visível
      body: IndexedStack(
        index: _abaAtual,
        children: [
          const HomePage(),
          FavoritosPage(aoExplorar: () => _irParaAba(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Cores.branco,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Cores.begeEscuro,
        selectedIndex: _abaAtual,
        onDestinationSelected: _irParaAba,
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
}