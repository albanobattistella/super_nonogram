import 'package:flutter/material.dart';
import 'package:super_nonogram/board/tile_state.dart';

class TilePreview extends StatelessWidget {
  const TilePreview({super.key, required this.tileState});

  final TileState tileState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    const tileSize = 48.0;
    return SizedBox.square(
      dimension: tileSize,
      child: CustomPaint(
        painter: TilePainter(tileState: tileState, colorScheme: colorScheme),
      ),
    );
  }
}

class TilePainter extends CustomPainter {
  TilePainter({required this.tileState, required ColorScheme colorScheme})
    : _tileColor = getTileColor(colorScheme),
      _crossColor = getCrossColor(colorScheme);

  final TileState tileState;
  final Color _tileColor;
  final Color _crossColor;

  @override
  void paint(Canvas canvas, Size size) {
    paintTile(
      tileState,
      canvas: canvas,
      tileRect: Offset.zero & size,
      tileColor: _tileColor,
      crossColor: _crossColor,
    );
  }

  @override
  bool shouldRepaint(covariant TilePainter oldDelegate) {
    return oldDelegate.tileState != tileState;
  }

  static Color getTileColor(ColorScheme colorScheme) => colorScheme.primary;
  static Color getCrossColor(ColorScheme colorScheme) =>
      Color.lerp(colorScheme.surface, colorScheme.onSurface, 0.7)!;

  static void paintTile(
    TileState tileState, {
    required Canvas canvas,
    required Rect tileRect,
    required Color tileColor,
    required Color crossColor,
  }) {
    final tileRRect = RRect.fromRectXY(
      tileRect,
      tileRect.width * 0.2,
      tileRect.height * 0.2,
    );
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = switch (tileState) {
        .selected => tileColor,
        .crossed => tileColor.withValues(alpha: 0.05),
        .empty => tileColor.withValues(alpha: 0.3),
      };
    canvas.drawRRect(tileRRect, paint);

    // Draw cross if crossed
    if (tileState == TileState.crossed) {
      final crossPaint = Paint()
        ..color = crossColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = tileRect.width * 0.04;
      final t = 0.25;
      canvas.drawLine(
        Alignment(-t, -t).withinRect(tileRect),
        Alignment(t, t).withinRect(tileRect),
        crossPaint,
      );
      canvas.drawLine(
        Alignment(-t, t).withinRect(tileRect),
        Alignment(t, -t).withinRect(tileRect),
        crossPaint,
      );
    }
  }
}
