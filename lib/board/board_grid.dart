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
          final size = MediaQuery.sizeOf(context);
          final maxPossibleTileSize = min(
            size.width / width,
            // subtract 300 for header and footer
            max((size.height - 300), 300) / height,
          );
          final labelFontSize = min(24.0, maxPossibleTileSize * 0.7);

          return _LabelledBoardGridRenderObjectWidget(
            answer: answer,
            currentAnswers: currentAnswers,
            textDirection: Directionality.of(context),
            textStyle: TextTheme.of(context).bodyLarge!.copyWith(
              fontSize: labelFontSize,
              letterSpacing: labelFontSize * -0.1,
            ),
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (overlay != null) IgnorePointer(child: overlay!),
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
  }

  BoardLabels get currentAnswers => _currentAnswers;
  BoardLabels _currentAnswers;
  set currentAnswers(BoardLabels currentAnswers) {
    if (_currentAnswers == currentAnswers) return;
    _currentAnswers = currentAnswers;
    _updateTextPainters(); // Updates color based on correctness
  }

  TextStyle get textStyle => _textStyle;
  TextStyle _textStyle;
  set textStyle(TextStyle textStyle) {
    if (_textStyle == textStyle) return;
    final sizeChanged = _textStyle.fontSize != textStyle.fontSize;
    _textStyle = textStyle;
    _updateTextPainters();
    if (sizeChanged) markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection = TextDirection.ltr;
  set textDirection(TextDirection textDirection) {
    if (_textDirection == textDirection) return;
    _textDirection = textDirection;
    _updateTextPainters();
  }

  List<TextPainter> _columnLabelPainters = const [];
  List<TextPainter> _rowLabelPainters = const [];
  late double _colLabelHeight;
  late double _rowLabelWidth;
  late double _tileSize;
  late double _rowLabelSpacing;

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
    // Font sizes are already as big as possible to fit within the tile size.
    // We use [TextScaler.noScaling] to not scale further.
    _columnLabelPainters = List.generate(
      boardWidth,
      (_) => TextPainter(textAlign: .center, textScaler: .noScaling),
      growable: false,
    );
    _rowLabelPainters = List.generate(
      boardHeight,
      (_) => TextPainter(textAlign: .end, textScaler: .noScaling),
      growable: false,
    );
    _updateTextPainters();
  }

  /// Updates the text and style of all text painters.
  /// Internally calls [markNeedsLayout] if needed, otherwise [markNeedsPaint].
  void _updateTextPainters() {
    var changedText = false;

    for (var x = 0; x < boardWidth; x++) {
      final painter = _columnLabelPainters[x];
      final newLabel = answer.labelColumn(x);
      changedText |= (painter.text as TextSpan?)?.text != newLabel;
      _updateTextPainterExplicitly(
        painter,
        newLabel,
        BoardLabels.statusOfCol(x, answer, currentAnswers),
      );
    }
    for (var y = 0; y < boardHeight; y++) {
      final painter = _rowLabelPainters[y];
      final newLabel = answer.labelRow(y);
      changedText |= (painter.text as TextSpan?)?.text != newLabel;
      _updateTextPainterExplicitly(
        painter,
        newLabel,
        BoardLabels.statusOfRow(y, answer, currentAnswers),
      );
    }

    if (changedText) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  /// Updates a single text painter's style.
  /// Call [_updateTextPainters] instead of using this method directly.
  void _updateTextPainterExplicitly(
    TextPainter painter,
    String label,
    BoardLabelStatus status,
  ) {
    painter.text = TextSpan(
      text: label,
      style: textStyle.copyWith(
        height: 1.1,
        color: switch (status) {
          .correct => Colors.transparent,
          .incorrect => Colors.red,
          .incomplete => null,
        },
      ),
    );
    painter.textDirection = textDirection;
  }

  @override
  void performLayout() {
    _rowLabelSpacing = _textStyle.fontSize! * 0.2;

    // Find the max width of the row labels
    double maxRowLabelsWidth = 0;
    for (var y = 0; y < _rowLabelPainters.length; y++) {
      final painter = _rowLabelPainters[y];
      painter.layout(maxWidth: constraints.maxWidth * 0.5);
      maxRowLabelsWidth = max(maxRowLabelsWidth, painter.width);
    }
    maxRowLabelsWidth += _rowLabelSpacing;
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
          offset.dx + (_rowLabelWidth - _rowLabelSpacing - painter.width),
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
      onOffSwitchLabels: MediaQuery.onOffSwitchLabelsOf(context),
      highContrast: MediaQuery.highContrastOf(context),
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
      ..colorScheme = ColorScheme.of(context)
      ..onOffSwitchLabels = MediaQuery.onOffSwitchLabelsOf(context)
      ..highContrast = MediaQuery.highContrastOf(context);
  }
}

class UnlabelledBoardGridRenderObject extends RenderBox {
  UnlabelledBoardGridRenderObject({
    required int width,
    required int height,
    required BoardState board,
    required ColorScheme colorScheme,
    required bool onOffSwitchLabels,
    required bool highContrast,
  }) : _width = width,
       _height = height,
       _board = board,
       _colorScheme = colorScheme,
       _onOffSwitchLabels = onOffSwitchLabels,
       _highContrast = highContrast {
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

  bool get onOffSwitchLabels => _onOffSwitchLabels;
  bool _onOffSwitchLabels;
  set onOffSwitchLabels(bool onOffSwitchLabels) {
    if (_onOffSwitchLabels == onOffSwitchLabels) return;
    _onOffSwitchLabels = onOffSwitchLabels;
    markNeedsPaint();
  }

  bool get highContrast => _highContrast;
  bool _highContrast;
  set highContrast(bool highContrast) {
    if (_highContrast == highContrast) return;
    _highContrast = highContrast;
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
          colorScheme: colorScheme,
          onOffSwitchLabels: onOffSwitchLabels,
          highContrast: highContrast,
          inCenterOfBoard: _isInCenter(x, width) || _isInCenter(y, height),
        );
      }
    }
  }

  @override
  void dispose() {
    _tilesListener?.removeListener(markNeedsPaint);
    super.dispose();
  }

  bool _isInCenter(int index, int total) {
    final middle = total ~/ 2;
    if (total.isOdd) {
      return index == middle;
    } else {
      return index == middle || index == middle - 1;
    }
  }
}
