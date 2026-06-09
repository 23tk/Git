import 'package:flutter/material.dart';
import 'stroke.dart';
import 'sound_manager.dart';
import 'puni_animation.dart';

class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  final List<DrawnLine> _lines = [];
  Color _currentColor = const Color(0xFFFFAACC);
  final double _strokeWidth = 8.0;

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      _lines.add(
        DrawnLine(
          points: [point],
          color: _currentColor,
          strokeWidth: _strokeWidth,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      _lines.last.points.add(point);
    });
  }

  void _clearCanvas() {
    setState(() {
      _lines.clear();
    });
    SoundManager.clear();
  }

  void _changeColor(Color color) {
    setState(() {
      _currentColor = color;
    });
    SoundManager.tap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCCE5),
        elevation: 0,
        title: const Text('ぷにぷにおえかき'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PuniPuniAnimationPage(lines: _lines),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              child: CustomPaint(
                painter: _OekakiPainter(lines: _lines),
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildColorBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildColorBar() {
    final colors = [
      const Color(0xFFFFAACC),
      const Color(0xFFFFDDAA),
      const Color(0xFFFFFFAA),
      const Color(0xFFAAFFCC),
      const Color(0xFFAAEEFF),
      const Color(0xFFCCAAFF),
      const Color(0xFFCC9966),
      const Color(0xFFFFFFFF),
      const Color(0xFF000000),
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: colors.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color == _currentColor;

          return GestureDetector(
            onTap: () => _changeColor(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: isSelected ? 46 : 40,
              height: isSelected ? 46 : 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withAlpha(153),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OekakiPainter extends CustomPainter {
  _OekakiPainter({required this.lines});
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
  bool shouldRepaint(covariant _OekakiPainter oldDelegate) => true;
}
