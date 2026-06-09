import 'package:flutter/material.dart';
import 'stroke.dart';

class PuniPuniAnimationPage extends StatefulWidget {
  const PuniPuniAnimationPage({super.key, required this.lines});

  final List<DrawnLine> lines;

  @override
  State<PuniPuniAnimationPage> createState() => _PuniPuniAnimationPageState();
}

class _PuniPuniAnimationPageState extends State<PuniPuniAnimationPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("保存機能は後で実装するよ！")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCCE5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveVideo,
          ),
        ],
      ),
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: CustomPaint(
            painter: _PuniPainter(lines: widget.lines),
            child: const SizedBox(width: 300, height: 300),
          ),
        ),
      ),
    );
  }
}

class _PuniPainter extends CustomPainter {
  _PuniPainter({required this.lines});
  final List<DrawnLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PuniPainter oldDelegate) => true;
}
