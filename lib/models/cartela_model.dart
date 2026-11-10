import 'package:flutter/material.dart';



class Cartela {
  List<List<int>> matrizNumeros;
  List<List<int>> matrizAcertos;
  int contadorAcertos;


  Cartela({
    required this.matrizNumeros,
    required this.matrizAcertos,
    this.contadorAcertos = 0,
  });
}