// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Paints the entire app icon: rounded-rect gradient background + checkmark.
/// By painting everything in a single CustomPainter we guarantee a square
/// 1:1 output regardless of the test viewport dimensions.
class _AppIconPainter extends CustomPainter {
  final Color primaryColor;
  final Color tertiaryColor;

  _AppIconPainter({required this.primaryColor, required this.tertiaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // always square
    final radius = s * 0.22;

    // --- Rounded rectangle background with gradient ---
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(radius),
    );
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(s, s), [
        primaryColor,
        tertiaryColor,
      ]);
    canvas.drawRRect(rrect, bgPaint);

    // --- White checkmark (matches Icons.check_rounded proportions) ---
    // Less padding so the checkmark fills the icon like in the app
    final pad = s * 0.12;
    final cw = s - 2 * pad; // check area width
    final ch = s - 2 * pad; // check area height

    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = cw * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(pad + cw * 0.18, pad + ch * 0.52)
      ..lineTo(pad + cw * 0.40, pad + ch * 0.74)
      ..lineTo(pad + cw * 0.82, pad + ch * 0.26);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  testWidgets('Generate app icon PNG', (WidgetTester tester) async {
    // Use the exact same color scheme as the app
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.light,
    );

    const double iconSize = 1024;
    final key = GlobalKey();

    // Force the test surface to be large enough for our icon
    await tester.binding.setSurfaceSize(const Size(iconSize, iconSize));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CustomPaint(
                size: const Size(iconSize, iconSize),
                painter: _AppIconPainter(
                  primaryColor: colorScheme.primary,
                  tertiaryColor: colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final outputDir = Directory('assets');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    File('assets/app_icon.png').writeAsBytesSync(pngBytes);
    print('✅ Icon saved to assets/app_icon.png (${pngBytes.length} bytes)');
    print('Icon dimensions: ${image.width}x${image.height}');

    // Restore default surface size
    await tester.binding.setSurfaceSize(null);
  });
}
