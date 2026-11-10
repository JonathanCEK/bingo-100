// Importa o pacote principal do Flutter para usar os widgets do Material Design.
import 'package:flutter/material.dart';

// 1. Importe o pacote de serviços do Flutter
import 'package:flutter/services.dart';

import 'package:tricky_treats/screens/game_screen.dart';

// 2. Transforme a função main em 'async'
Future<void> main() async {
  // 3. Garanta que os bindings do Flutter foram inicializados
  // Esta linha é necessária antes de chamar configurações do sistema.
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Defina as orientações preferidas
  // Esta linha é a que efetivamente trava a tela.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Rode o seu aplicativo como antes
  runApp(const MyApp());
}

// MyApp é o widget raiz do seu aplicativo.
class MyApp extends StatelessWidget {
  // O construtor `const` melhora a performance.
  const MyApp({super.key});

  // O método build é responsável por descrever a parte do aplicativo que este widget representa.
  @override
  Widget build(BuildContext context) {
    // MaterialApp é um widget que envolve vários outros widgets que são comumente
    // necessários para aplicativos Material Design.
    return MaterialApp(
      // Título do seu aplicativo (usado pelo sistema operacional).
      title: 'Tricky Treats',

      // Remove a faixa de "Debug" no canto superior direito da tela.
      debugShowCheckedModeBanner: false,

      // Define o tema visual do aplicativo.
      theme: ThemeData(
        // Define a cor primária do aplicativo (afeta a cor da AppBar, etc.).
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),

      // Define a tela inicial do aplicativo. Aqui estamos chamando a nossa GameScreen.
      home: const GameScreen(),
    );
  }
}