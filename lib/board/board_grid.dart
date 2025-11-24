import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/tile.dart';

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.width,
    required this.height,
    required this.answer,
    required this.currentAnswers,
    required this.board,
    this.overlay,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final int width;
  final int height;
  final BoardLabels answer;
  final ValueNotifier<BoardLabels> currentAnswers;
  final BoardState board;
  final Widget? overlay;
  final void Function(Coordinate) onPanStart;
  final void Function(Coordinate) onPanUpdate;
  final void Function() onPanEnd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: currentAnswers,
        builder: (context, currentAnswers, child) {
          return _LabelledBoardGridRenderObjectWidget(
            answer: answer,
            currentAnswers: currentAnswers,
            textDirection: Directionality.of(context),
            textStyle: TextTheme.of(context).bodyLarge!,
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final gridSize = constraints.biggest;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (details) => onPanStart(
                    getCoordinateOfPosition(details.localFocalPoint, gridSize),
                  ),
                  onScaleUpdate: (details) => onPanUpdate(
                    getCoordinateOfPosition(details.localFocalPoint, gridSize),
                  ),
                  onScaleEnd: (_) => onPanEnd(),
                  child: _UnlabelledBoardGridRenderObjectWidget(
                    width: width,
                    height: height,
                    board: board,
                  ),
                );
              },
            ),
            if (overlay != null) IgnorePointer(child: overlay!),
          ],
        ),
      ),
    );
  }

  Coordinate getCoordinateOfPosition(Offset position, Size gridSize) {
    final tileSize = gridSize.width / answer.columns.length;
    final x = (position.dx / tileSize).floor();
    final y = (position.dy / tileSize).floor();
    return (x: x, y: y);
  }
}

class _LabelledBoardGridRenderObjectWidget
    extends SingleChildRenderObjectWidget {
  const _LabelledBoardGridRenderObjectWidget({
    required this.answer,
    required this.currentAnswers,
    required this.textDirection,
    required this.textStyle,
    super.child,
  });

  final BoardLabels answer;
  final BoardLabels currentAnswers;
  final TextDirection textDirection;
  final TextStyle textStyle;

  @override
  LabelledBoardGridRenderObject createRenderObject(BuildContext context) {
    return LabelledBoardGridRenderObject(
      answer: answer,
      currentAnswers: currentAnswers,
      textStyle: textStyle,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    LabelledBoardGridRenderObject renderObject,
  ) {
    renderObject
      ..answer = answer
      ..currentAnswers = currentAnswers
      ..textStyle = textStyle
      ..textDirection = textDirection;
  }
}

class LabelledBoardGridRenderObject extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  LabelledBoardGridRenderObject({
    required BoardLabels answer,
    required BoardLabels currentAnswers,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) : _answer = answer,
       _currentAnswers = currentAnswers,
       _textStyle = textStyle {
    _generateTextPainters();
  }

  BoardLabels get answer => _answer;
  BoardLabels _answer;
  set answer(BoardLabels answer) {
    if (_answer == answer) return;
    final changedSize =
        _answer.columns.length != answer.columns.length ||
        _answer.rows.length != answer.rows.length;
    _answer = answer;
    if (changedSize) {
      _generateTextPainters();
    } else {
      _updateTextPainters();
    }
    markNeedsLayout();
  }

  BoardLabels get currentAnswers => _currentAnswers;
  BoardLabels _currentAnswers;
  set currentAnswers(BoardLabels currentAnswers) {
    if (_currentAnswers == currentAnswers) return;
    _currentAnswers = currentAnswers;
    _updateTextPainters(); // Updates color based on correctness
    markNeedsPaint();
  }

  TextStyle get textStyle => _textStyle;
  TextStyle _textStyle;
  set textStyle(TextStyle textStyle) {
    if (_textStyle == textStyle) return;
    _textStyle = textStyle;
    _updateTextPainters();
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection = TextDirection.ltr;
  set textDirection(TextDirection textDirection) {
    if (_textDirection == textDirection) return;
    _textDirection = textDirection;
    _updateTextPainters();
    markNeedsLayout();
  }

  List<TextPainter> _columnLabelPainters = const [];
  List<TextPainter> _rowLabelPainters = const [];
  late double _colLabelHeight;
  late double _rowLabelWidth;
  late double _tileSize;

  int get boardWidth => currentAnswers.columns.length;
  int get boardHeight => currentAnswers.rows.length;

  @override
  void dispose() {
    for (final painter in _columnLabelPainters) {
      painter.dispose();
    }
    for (final painter in _rowLabelPainters) {
      painter.dispose();
    }
    super.dispose();
  }

  void _generateTextPainters() {
    _columnLabelPainters = [for (var x = 0; x < boardWidth; x++) TextPainter()];
    _rowLabelPainters = [for (var y = 0; y < boardHeight; y++) TextPainter()];
    _updateTextPainters();
  }

  void _updateTextPainters() {
    for (var x = 0; x < boardWidth; x++) {
      _columnLabelPainters[x]
        ..text = TextSpan(
          text: answer.labelColumn(x),
          style: textStyle.copyWith(
            height: 1.1,
            color: switch (BoardLabels.statusOfCol(x, answer, currentAnswers)) {
              .correct => Colors.transparent,
              .incorrect => Colors.red,
              .incomplete => null,
            },
          ),
        )
        ..textDirection = textDirection
        ..textAlign = TextAlign.center;
    }
    for (var y = 0; y < boardHeight; y++) {
      _rowLabelPainters[y]
        ..text = TextSpan(
          text: answer.labelRow(y),
          style: textStyle.copyWith(
            height: 1,
            color: switch (BoardLabels.statusOfRow(y, answer, currentAnswers)) {
              .correct => Colors.transparent,
              .incorrect => Colors.red,
              .incomplete => null,
            },
          ),
        )
        ..textDirection = textDirection
        ..textAlign = TextAlign.end;
    }
  }

  @override
  void performLayout() {
    // Find the max width of the row labels
    double maxRowLabelsWidth = 0;
    for (var y = 0; y < _rowLabelPainters.length; y++) {
      final painter = _rowLabelPainters[y];
      painter.layout(maxWidth: constraints.maxWidth * 0.5);
      maxRowLabelsWidth = max(maxRowLabelsWidth, painter.width);
    }
    _rowLabelWidth = maxRowLabelsWidth;

    // Find the max height of the column labels
    double maxColumnLabelsHeight = 0;
    for (var x = 0; x < _columnLabelPainters.length; x++) {
      final painter = _columnLabelPainters[x];
      painter.layout(
        maxWidth: (constraints.maxWidth - maxRowLabelsWidth) / boardWidth,
      );
      maxColumnLabelsHeight = max(maxColumnLabelsHeight, painter.height);
    }
    _colLabelHeight = maxColumnLabelsHeight;

    // Calculate tile size (must be square)
    final maxPossibleTileWidth =
        (constraints.maxWidth - maxRowLabelsWidth) / boardWidth;
    final maxPossibleTileHeight =
        (constraints.maxHeight - maxColumnLabelsHeight) / boardHeight;
    final tileSize = min(
      128.0, // Avoid excessively large tiles
      min(maxPossibleTileWidth, maxPossibleTileHeight),
    );
    _tileSize = tileSize;

    // Set the size of the render box
    size = constraints.constrain(
      Size(
        maxRowLabelsWidth + tileSize * boardWidth,
        maxColumnLabelsHeight + tileSize * boardHeight,
      ),
    );

    // Layout child
    if (child != null) {
      child!.layout(
        BoxConstraints.tight(
          Size(tileSize * boardWidth, tileSize * boardHeight),
        ),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var x = 0; x < _columnLabelPainters.length; x++) {
      final painter = _columnLabelPainters[x];
      painter.paint(
        context.canvas,
        Offset(
          offset.dx +
              _rowLabelWidth +
              x * _tileSize +
              (_tileSize - painter.width) / 2,
          offset.dy + (_colLabelHeight - painter.height),
        ),
      );
    }

    for (var y = 0; y < _rowLabelPainters.length; y++) {
      final painter = _rowLabelPainters[y];
      painter.paint(
        context.canvas,
        Offset(
          offset.dx + (_rowLabelWidth - painter.width),
          offset.dy +
              _colLabelHeight +
              y * _tileSize +
              (_tileSize - painter.height) / 2,
        ),
      );
    }

    if (child != null) {
      context.paintChild(
        child!,
        Offset(offset.dx + _rowLabelWidth, offset.dy + _colLabelHeight),
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final topLeft = Offset(_rowLabelWidth, _colLabelHeight);
    if (position.dx < topLeft.dx || position.dy < topLeft.dy) {
      return false;
    }
    return result.addWithPaintOffset(
      offset: topLeft,
      position: position,
      hitTest: (childHitTestResult, transformed) {
        return child!.hitTest(childHitTestResult, position: transformed);
      },
    );
  }
}

class _UnlabelledBoardGridRenderObjectWidget extends LeafRenderObjectWidget {
  const _UnlabelledBoardGridRenderObjectWidget({
    required this.width,
    required this.height,
    required this.board,
  });

  final int width;
  final int height;
  final BoardState board;

  @override
  UnlabelledBoardGridRenderObject createRenderObject(BuildContext context) {
    return UnlabelledBoardGridRenderObject(
      width: width,
      height: height,
      board: board,
      colorScheme: ColorScheme.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    UnlabelledBoardGridRenderObject renderObject,
  ) {
    renderObject
      ..width = width
      ..height = height
      ..board = board
      ..colorScheme = ColorScheme.of(context);
  }
}

class UnlabelledBoardGridRenderObject extends RenderBox {
  UnlabelledBoardGridRenderObject({
    required int width,
    required int height,
    required BoardState board,
    required ColorScheme colorScheme,
  }) : _width = width,
       _height = height,
       _board = board,
       _colorScheme = colorScheme {
    _listenToTiles();
  }

  int get width => _width;
  int _width;
  set width(int width) {
    if (_width == width) return;
    _width = width;
    markNeedsLayout();
  }

  int get height => _height;
  int _height;
  set height(int height) {
    if (_height == height) return;
    _height = height;
    markNeedsLayout();
  }

  BoardState get board => _board;
  BoardState _board;
  set board(BoardState board) {
    if (_board == board) return;
    _board = board;
    markNeedsPaint();
    _listenToTiles();
  }

  ColorScheme get colorScheme => _colorScheme;
  ColorScheme _colorScheme;
  set colorScheme(ColorScheme colorScheme) {
    if (_colorScheme == colorScheme) return;
    _colorScheme = colorScheme;
    markNeedsPaint();
  }

  late double _tileSize;
  Listenable? _tilesListener;

  void _listenToTiles() {
    _tilesListener?.removeListener(markNeedsPaint);
    _tilesListener = Listenable.merge([
      for (var row in board) ...[for (var tile in row) tile],
    ])..addListener(markNeedsPaint);
  }

  @override
  bool get sizedByParent => true;
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
  @override
  void performLayout() {
    final size = computeDryLayout(constraints);
    final tileWidth = size.width / width;
    final tileHeight = size.height / height;
    assert(
      (tileWidth / tileHeight - 1).abs() < 0.01,
      'Tiles must be square in UnlabelledBoardGridRenderObject',
    );
    _tileSize = tileWidth;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final spacing = _tileSize * 0.1;
    final crossColor = TilePainter.getCrossColor(colorScheme);
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final tileState = board[y][x].value;
        final tileOffset = Offset(
          offset.dx + x * _tileSize + spacing,
          offset.dy + y * _tileSize + spacing,
        );
        final tileRect =
            tileOffset & Size(_tileSize - spacing, _tileSize - spacing);
        TilePainter.paintTile(
          tileState,
          canvas: context.canvas,
          tileRect: tileRect,
          tileColor: TilePainter.getTileColor(colorScheme),
          crossColor: crossColor,
        );
      }
    }
  }

  @override
  void dispose() {
    _tilesListener?.removeListener(markNeedsPaint);
    super.dispose();
  }
}
