import 'package:flutter/material.dart';
import 'drawing_canvas.dart';

void main() {
  runApp(const PuniPuniOekakiApp());
}

class PuniPuniOekakiApp extends StatelessWidget {
  const PuniPuniOekakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ぷにぷにおえかき',
      debugShowCheckedModeBanner: false,
      home: const DrawingCanvasPage(),
    );
  }
}
