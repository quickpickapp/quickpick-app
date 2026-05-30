import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  DrawnLine copyWith({List<Offset>? points}) {
    return DrawnLine(
      points: points ?? this.points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

class TextOverlay {
  String text;
  Offset position;
  final Color color;
  double fontSize;

  TextOverlay({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
  });
}

enum EditMode { none, draw, text }

class PickPreviewPage extends StatefulWidget {
  final String imagePath;

  const PickPreviewPage({super.key, required this.imagePath});

  @override
  State<PickPreviewPage> createState() => _PickPreviewPageState();
}

class _PickPreviewPageState extends State<PickPreviewPage> {
  final GlobalKey _repaintKey = GlobalKey();

  EditMode _mode = EditMode.none;

  final List<DrawnLine> _lines = [];
  int _linesVersion = 0;
  DrawnLine? _currentLine;
  Color _activeColor = Colors.redAccent;
  double _strokeWidth = 4.0;

  final List<TextOverlay> _textOverlays = [];
  TextOverlay? _pendingText;
  double _fontSize = 22.0;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  // Unified history: each entry is either a DrawnLine or a TextOverlay
  final List<Object> _history = [];
  final List<Object> _redoStack = [];

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureImage() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> _onSend() async {
    _commitPendingText();
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _setMode(EditMode m) {
    _commitPendingText();
    setState(() {
      _mode = _mode == m ? EditMode.none : m;
    });
  }

  void _onPanStart(DragStartDetails d) {
    if (_mode == EditMode.draw) {
      setState(() {
        _currentLine = DrawnLine(
          points: [d.localPosition],
          color: _activeColor,
          strokeWidth: _strokeWidth,
        );
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_mode == EditMode.draw && _currentLine != null) {
      setState(() {
        _currentLine = _currentLine!.copyWith(
          points: [..._currentLine!.points, d.localPosition],
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails _) {
    if (_currentLine != null) {
      setState(() {
        _lines.add(_currentLine!);
        _history.add(_currentLine!);
        _redoStack.clear();
        _linesVersion++;
        _currentLine = null;
      });
    }
  }

  void _onTapCanvas(TapUpDetails d) {
    if (_mode != EditMode.text) {
      return;
    }
    _commitPendingText();

    final overlay = TextOverlay(
      text: '',
      position: d.localPosition - const Offset(0, 20),
      color: _activeColor,
      fontSize: _fontSize,
    );
    _textController.text = '';
    setState(() {
      _pendingText = overlay;
    });
    Future.microtask(() => _textFocus.requestFocus());
  }

  void _commitPendingText() {
    if (_pendingText == null) return;
    final overlay = _pendingText!..text = _textController.text.trim();
    if (overlay.text.isNotEmpty) {
      setState(() {
        _textOverlays.add(overlay);
        _history.add(overlay);
        _redoStack.clear();
        _pendingText = null;
      });
    } else {
      setState(() {
        _pendingText = null;
      });
    }
    _textController.clear();
  }

  void _undo() {
    _commitPendingText();
    if (_history.isEmpty) return;
    setState(() {
      final last = _history.removeLast();
      _redoStack.add(last);
      if (last is DrawnLine) {
        _lines.remove(last);
        _linesVersion++;
      } else if (last is TextOverlay) {
        _textOverlays.remove(last);
      }
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      final item = _redoStack.removeLast();
      _history.add(item);
      if (item is DrawnLine) {
        _lines.add(item);
        _linesVersion++;
      } else if (item is TextOverlay) {
        _textOverlays.add(item);
      }
    });
  }

  bool get _canUndo => _history.isNotEmpty;
  bool get _canRedo => _redoStack.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTapUp: _onTapCanvas,
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  CustomPaint(
                    painter: _DrawingPainter(
                      lines: _lines,
                      currentLine: _currentLine,
                      version: _linesVersion,
                    ),
                  ),
                  for (int i = 0; i < _textOverlays.length; i++)
                    _DraggableText(
                      overlay: _textOverlays[i],
                      onMove: (pos) {
                        setState(() {
                          _textOverlays[i].position = pos;
                        });
                      },
                    ),
                  if (_pendingText != null)
                    Positioned(
                      left: _pendingText!.position.dx,
                      top: _pendingText!.position.dy,
                      child: _InlineTextInput(
                        controller: _textController,
                        focusNode: _textFocus,
                        color: _activeColor,
                        fontSize: _fontSize,
                        onSubmit: _commitPendingText,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      if (_canUndo || _canRedo)
                        Row(
                          children: [
                            if (_canUndo)
                              _GlassIconButton(
                                icon: Icons.undo_rounded,
                                onTap: _undo,
                              ),
                            if (_canRedo) ...[
                              const SizedBox(width: 8),
                              _GlassIconButton(
                                icon: Icons.redo_rounded,
                                onTap: _redo,
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _mode != EditMode.none
                          ? _OptionsRow(
                        key: const ValueKey('opts'),
                        selectedColor: _activeColor,
                        strokeWidth: _strokeWidth,
                        fontSize: _fontSize,
                        showStroke: _mode == EditMode.draw,
                        showFontSize: _mode == EditMode.text,
                        onColorChange: (c) {
                          setState(() => _activeColor = c);
                        },
                        onStrokeChange: (s) {
                          setState(() => _strokeWidth = s);
                        },
                        onFontSizeChange: (s) {
                          setState(() {
                            _fontSize = s;
                            _pendingText?.fontSize = s;
                          });
                        },
                      )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                    const SizedBox(height: 12),
                    _ToolRow(
                      mode: _mode,
                      onModeTap: _setMode,
                    ),
                    const SizedBox(height: 20),
                    _SendButton(onTap: _onSend),
                    const SizedBox(height: 36),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  final Color selectedColor;
  final double strokeWidth;
  final double fontSize;
  final bool showStroke;
  final bool showFontSize;
  final ValueChanged<Color> onColorChange;
  final ValueChanged<double> onStrokeChange;
  final ValueChanged<double> onFontSizeChange;

  static const List<Color> _colors = [
    Colors.white,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.cyanAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.black,
  ];

  const _OptionsRow({
    super.key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.fontSize,
    required this.showStroke,
    required this.showFontSize,
    required this.onColorChange,
    required this.onStrokeChange,
    required this.onFontSizeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _colors.map((c) {
                final selected = selectedColor == c;
                return GestureDetector(
                  onTap: () => onColorChange(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: selected ? 30 : 24,
                    height: selected ? 30 : 24,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.white30,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (showStroke) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.line_weight_rounded, color: Colors.white54, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: selectedColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: selectedColor,
                      overlayColor: selectedColor.withOpacity(0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: strokeWidth,
                      min: 2,
                      max: 20,
                      onChanged: onStrokeChange,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showFontSize) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_fields_rounded, color: Colors.white54, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: selectedColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: selectedColor,
                      overlayColor: selectedColor.withOpacity(0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: fontSize,
                      min: 10,
                      max: 72,
                      onChanged: onFontSizeChange,
                    ),
                  ),
                ),
                Text(
                  '${fontSize.round()}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final EditMode mode;
  final ValueChanged<EditMode> onModeTap;

  const _ToolRow({required this.mode, required this.onModeTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToolChip(
          icon: Icons.edit_rounded,
          label: 'Malen',
          active: mode == EditMode.draw,
          onTap: () => onModeTap(EditMode.draw),
        ),
        const SizedBox(width: 12),
        _ToolChip(
          icon: Icons.text_fields_rounded,
          label: 'Text',
          active: mode == EditMode.text,
          onTap: () => onModeTap(EditMode.text),
        ),
      ],
    );
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? Colors.white60 : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0072FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Senden',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InlineTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color color;
  final double fontSize;
  final VoidCallback onSubmit;

  const _InlineTextInput({
    required this.controller,
    required this.focusNode,
    required this.color,
    required this.fontSize,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 40, maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: EditableText(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          maxLines: null,
          cursorColor: color,
          backgroundCursorColor: Colors.transparent,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
          onSubmitted: (_) => onSubmit(),
        ),
      ),
    );
  }
}

class _DraggableText extends StatelessWidget {
  final TextOverlay overlay;
  final ValueChanged<Offset> onMove;

  const _DraggableText({required this.overlay, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => onMove(overlay.position + d.delta),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            overlay.text,
            style: TextStyle(
              color: overlay.color,
              fontSize: overlay.fontSize,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final int version;

  const _DrawingPainter({
    required this.lines,
    this.currentLine,
    required this.version,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allLines = [...lines, if (currentLine != null) currentLine!];
    for (final line in allLines) {
      if (line.points.isEmpty) {
        continue;
      }
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(line.points.first.dx, line.points.first.dy);
      for (int i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter old) {
    return old.version != version || old.currentLine != currentLine;
  }
}