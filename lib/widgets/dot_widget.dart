import 'package:flutter/material.dart';
// Precisamos importar o arquivo do modelo para que o widget saiba o que é 'TrickedBy'
import 'package:tricky_treats/models/cartela_model.dart'; 

class DotWidget extends StatelessWidget {
  final double size;
  final Color color;
  
  // --- ADIÇÃO 1: DECLARAR AS NOVAS PROPRIEDADES ---
  // Propriedade para saber QUEM marcou o doce.
  final TrickedBy trickedBy;
  // Propriedade para saber se a seleção deve ser MOSTRADA.
  final bool showSelection;

  final VoidCallback? onTap;

  // --- ADIÇÃO 2: ATUALIZAR O CONSTRUTOR ---
  // Adicionamos as novas propriedades aqui para que o widget possa recebê-las.
  const DotWidget({
    super.key,
    this.size = 50.0,
    required this.color,
    this.trickedBy = TrickedBy.none, // Valor padrão
    this.showSelection = false,     // Valor padrão
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define a cor da borda baseada em quem marcou
    Color borderColor;
    switch (trickedBy) {
      case TrickedBy.player1:
        borderColor = Colors.cyan;
        break;
      case TrickedBy.player2:
      case TrickedBy.both:
        borderColor = Colors.orange;
        break;
      case TrickedBy.none:
        borderColor = Colors.transparent;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // A lógica da borda agora funciona, pois 'showSelection' e 'trickedBy' existem.
          border: showSelection && trickedBy != TrickedBy.none
              ? Border.all(color: borderColor, width: 4.0, strokeAlign: BorderSide.strokeAlignOutside)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0.5,
              blurRadius: 3,
              offset: const Offset(0.5, 1.5),
            )
          ]
        ),
      ),
    );
  }
}