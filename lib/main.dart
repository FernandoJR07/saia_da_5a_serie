import 'package:flutter/material.dart';

import 'cores.dart';
import 'tela_principal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LondonFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Cores.vermelho,
          primary: Cores.vermelho,
          error: Cores.vermelhoEscuro,
          surface: Cores.branco,
        ),
        scaffoldBackgroundColor: Cores.bege,
      ),
      home: const TelaPrincipal(),
    );
  }
}