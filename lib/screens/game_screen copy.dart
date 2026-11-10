import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tricky_treats/models/cartela_model.dart';
import 'package:tricky_treats/widgets/dot_widget.dart';

// Enum para controlar a fase atual do jogo
enum GamePhase {
  player1Selecting,
  player1Confirm,
  player2Selecting,
  player2Confirm,
  playing,
  gameOver,
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<DotModel> _dots = [];
  final int _numberOfDots = 20; // Reduzi um pouco para caberem melhor na tela
  final double _dotSize = 50.0; // Tamanho único para os doces

  // Variável que controla o estado atual do jogo
  GamePhase _currentPhase = GamePhase.player1Selecting;
  String _gameOverMessage = ''; // Guarda a mensagem de fim de jogo

  @override
  void initState() {
    super.initState();
    // --- MUDANÇA IMPORTANTE AQUI ---
    // Pedimos para o Flutter chamar a nossa função DEPOIS que a primeira "pintura" da tela for concluída.
    // O `(_) ` é um placeholder para um argumento que não vamos usar.
    // Nesse momento, o 'context' já está totalmente disponível e pode ser usado por _generateDots.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateDots();
    });
  }

  void _generateDots() {
    // --- Define a área segura da tela ---
    final paddingTop = MediaQuery.of(context).padding.top + kToolbarHeight;
    final paddingBottom = 150.0; // Espaço para o Floating Action Button
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final random = Random();
    List<DotModel> newDots = [];
    
    for (int i = 0; i < _numberOfDots; i++) {
      Offset position;
      bool isOverlapping;
      int tries = 0; // Contador para evitar loops infinitos

      do {
        // Gera uma posição dentro da área segura
        position = Offset(
          random.nextDouble() * (screenWidth - _dotSize),
          paddingTop + random.nextDouble() * (screenHeight - paddingTop - paddingBottom - _dotSize),
        );

        isOverlapping = false;
        // Verifica se a nova posição colide com algum doce já existente
        for (var dot in newDots) {
          final distance = (position - dot.position).distance;
          if (distance < _dotSize) { // Se a distância é menor que o diâmetro, há colisão
            isOverlapping = true;
            break;
          }
        }
        tries++;
      } while (isOverlapping && tries < 100); // Tenta até 100 vezes encontrar um lugar

      if (!isOverlapping) {
        final color = Colors.primaries[random.nextInt(Colors.primaries.length)];
        newDots.add(DotModel(
          id: 'dot_$i',
          color: color,
          position: position,
        ));
      }
    }
    setState(() {
      _dots = newDots;
    });
  }

  void _resetGame() {
    setState(() {
      _dots = [];
      _currentPhase = GamePhase.player1Selecting;
      _gameOverMessage = '';
      _generateDots();
    });
  }

    // Função chamada ao clicar em um doce
  void _onDotTapped(String tappedDotId) {
  // Lógica de seleção (continua a mesma)
  if (_currentPhase == GamePhase.player1Selecting || _currentPhase == GamePhase.player2Selecting) {
    setState(() {
      final tappedDot = _dots.firstWhere((dot) => dot.id == tappedDotId);
      if (_currentPhase == GamePhase.player1Selecting) {
        // ignore: avoid_function_literals_in_foreach_calls
        _dots.forEach((dot) { if (dot.trickedBy == TrickedBy.player1) dot.trickedBy = TrickedBy.none; });
        tappedDot.trickedBy = TrickedBy.player1;
      } else if (_currentPhase == GamePhase.player2Selecting) {
        // ignore: avoid_function_literals_in_foreach_calls
        _dots.forEach((dot) {
          if (dot.trickedBy == TrickedBy.player2) {
            dot.trickedBy = TrickedBy.none;
          } else if (dot.trickedBy == TrickedBy.both) {
            dot.trickedBy = TrickedBy.player1;
          }
        });
        if (tappedDot.trickedBy == TrickedBy.player1) {
          tappedDot.trickedBy = TrickedBy.both;
        } else {
          tappedDot.trickedBy = TrickedBy.player2;
        }
      }
    });
    return;
  }

  // Lógica da Fase de Jogo (COM A CORREÇÃO)
  if (_currentPhase == GamePhase.playing) {
    final tappedDot = _dots.firstWhere((dot) => dot.id == tappedDotId);
    
    // Verifica se o doce estava marcado
    if (tappedDot.trickedBy != TrickedBy.none) {
      // Se estava marcado, termina o jogo
      setState(() {
        _currentPhase = GamePhase.gameOver;
        if (tappedDot.trickedBy == TrickedBy.both) {
          _gameOverMessage = 'Armadilha dupla! Ambos marcaram este doce!';
        } else {
          final player = tappedDot.trickedBy == TrickedBy.player1 ? '1' : '2';
          _gameOverMessage = 'Você foi enganado pelo Jogador $player!';
        }
      });
    } else { 
      // ---> ESTE É O BLOCO QUE FALTAVA <---
      // Se o doce era seguro, simplesmente o removemos da lista
      setState(() {
        _dots.removeWhere((dot) => dot.id == tappedDotId);
      });
    }
  }
}
  
  // Função para avançar para a próxima fase do jogo
  void _advanceGamePhase() {
    setState(() {
      switch (_currentPhase) {
        case GamePhase.player1Selecting:
          _currentPhase = GamePhase.player1Confirm;
          break;
        case GamePhase.player1Confirm:
          _currentPhase = GamePhase.player2Selecting;
          break;
        case GamePhase.player2Selecting:
          _currentPhase = GamePhase.player2Confirm;
          break;
        case GamePhase.player2Confirm:
          _currentPhase = GamePhase.playing;
          break;
        default:
          break;
      }
    });
  }

  bool _isSelectionMadeInCurrentTurn() {
    if (_currentPhase == GamePhase.player1Selecting) {
      return _dots.any((dot) => dot.trickedBy == TrickedBy.player1);
    }
    if (_currentPhase == GamePhase.player2Selecting) {
      return _dots.any((dot) => dot.trickedBy == TrickedBy.player2 || dot.trickedBy == TrickedBy.both);
    }
    return false;
  }
  
  // --- Funções de Texto e Widgets Auxiliares ---
  String _getAppBarTitle() {
    switch (_currentPhase) {
      case GamePhase.player1Selecting:
        return 'Vez do Jogador 1';
      case GamePhase.player2Selecting:
        return 'Vez do Jogador 2';
      case GamePhase.playing:
        return 'O Jogo Começou!';
      default:
        return 'Tricky Treats';
    }
  }

  Widget _buildTransitionScreen(String message, String buttonText) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _advanceGamePhase,
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }

  // Widget para a tela de Game Over
  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.red.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fim de Jogo!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(_gameOverMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text('Jogar Novamente'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Stack(
      children: _dots.map((dot) {
        // LÓGICA CORRIGIDA AQUI
final bool shouldShowThisSelection = 
    (_currentPhase == GamePhase.player1Selecting && dot.trickedBy == TrickedBy.player1) ||
    (_currentPhase == GamePhase.player2Selecting && (dot.trickedBy == TrickedBy.player2 || dot.trickedBy == TrickedBy.both));

        return Positioned(
          left: dot.position.dx,
          top: dot.position.dy,
          child: DotWidget(
            size: _dotSize,
            color: dot.color,
            trickedBy: dot.trickedBy,
            showSelection: shouldShowThisSelection, // Usa a nova lógica
            onTap: () => _onDotTapped(dot.id),
          ),
        );
      }).toList(),
    );
  }

  void _showSettingsPopup() {
    print("Botão de Configurações clicado!");
  }

  void _showTutorialPopup() {
    print("Botão de Tutorial clicado!");
  }

  void _navigateToNewGameScreen() {
    print("Floating Action Button clicado! Navegando para Novo Jogo.");
  }
  
  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    // Define o corpo da tela com base na fase do jogo
switch (_currentPhase) {
      case GamePhase.player1Confirm:
        currentBody = _buildTransitionScreen("Seleção feita!\nPasse o celular para o Jogador 2.", "Estou Pronto!");
        break;
      case GamePhase.player2Confirm:
        currentBody = _buildTransitionScreen("Tudo pronto!\nDevolva para o Jogador 1 para começar.", "Jogar!");
        break;
      // NOVO CASO: Tela de Fim de Jogo
      case GamePhase.gameOver:
        currentBody = _buildGameOverScreen();
        break;
      default:
        currentBody = _buildGameArea();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tricky Treats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTutorialPopup,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsPopup,
          ),
        ],
      ),
      body: currentBody,
      floatingActionButton: (_currentPhase == GamePhase.player1Selecting || _currentPhase == GamePhase.player2Selecting)
        ? FloatingActionButton.extended(
            onPressed: _isSelectionMadeInCurrentTurn() ? _advanceGamePhase : null,
            backgroundColor: _isSelectionMadeInCurrentTurn()
              ? (_currentPhase == GamePhase.player1Selecting ? Colors.cyan : Colors.orange)
              : Colors.grey,
            icon: const Icon(Icons.check, color: Colors.white,),
            label: const Text("Pronto", style: TextStyle(
              color: Colors.white
            ),),
          )
        : null,
    );
  }
}