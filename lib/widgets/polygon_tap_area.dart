import 'package:flutter/material.dart';
import 'dart:ui';

class PolygonTapArea extends StatelessWidget {
  final List<List<double>> points;
  final VoidCallback onTap;
  final double svgWidth;
  final double svgHeight;

  const PolygonTapArea({
    required this.points,
    required this.onTap,
    required this.svgWidth,
    required this.svgHeight,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // SVG 좌표를 Flutter Canvas 좌표로 변환
          final transformedPoints = _transformSvgToCanvasCoordinates(
            points, constraints.biggest);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              final local = details.localPosition;
              if (_pointInPolygon(local, transformedPoints)) {
                onTap();
              }
            },
            child: CustomPaint(
              painter: _DebugPolygonPainter(transformedPoints), // Debug: Show polygon outline
            ),
          );
        },
      ),
    );
  }

  // SVG 좌표를 Flutter Canvas 좌표로 변환
  List<List<double>> _transformSvgToCanvasCoordinates(
      List<List<double>> svgPoints, Size canvasSize) {
    // BoxFit.contain을 고려한 실제 표시 크기와 오프셋 계산
    final double svgAspectRatio = svgWidth / svgHeight;
    final double canvasAspectRatio = canvasSize.width / canvasSize.height;

    double actualWidth, actualHeight;
    double offsetX = 0, offsetY = 0;

    if (svgAspectRatio > canvasAspectRatio) {
      // SVG가 더 넓음 - 너비에 맞춤
      actualWidth = canvasSize.width;
      actualHeight = canvasSize.width / svgAspectRatio;
      offsetY = (canvasSize.height - actualHeight) / 2;
    } else {
      // SVG가 더 높음 - 높이에 맞춤
      actualHeight = canvasSize.height;
      actualWidth = canvasSize.height * svgAspectRatio;
      offsetX = (canvasSize.width - actualWidth) / 2;
    }

    // SVG 좌표를 Canvas 좌표로 변환
    return svgPoints.map((point) {
      final double relativeX = point[0] / svgWidth;
      final double relativeY = point[1] / svgHeight;
      final double canvasX = offsetX + (relativeX * actualWidth);
      final double canvasY = offsetY + (relativeY * actualHeight);
      return [canvasX, canvasY];
    }).toList();
  }

  // Ray-casting algorithm for point-in-polygon
  bool _pointInPolygon(Offset point, List<List<double>> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;
    for (i = 0; i < polygon.length; i++) {
      double xi = polygon[i][0], yi = polygon[i][1];
      double xj = polygon[j][0], yj = polygon[j][1];
      if ((yi < point.dy && yj >= point.dy || yj < point.dy && yi >= point.dy) &&
          (xi <= point.dx || xj <= point.dx)) {
        if (xi + (point.dy - yi) / (yj - yi) * (xj - xi) < point.dx) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }
    return oddNodes;
  }
}

// Debug: Draw polygon outline to verify coordinates
class _DebugPolygonPainter extends CustomPainter {
  final List<List<double>> points;
  _DebugPolygonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Draw polygon outline in red
    final outlinePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()..moveTo(points[0][0], points[0][1]);
    for (var p in points.skip(1)) {
      path.lineTo(p[0], p[1]);
    }
    path.close();
    canvas.drawPath(path, outlinePaint);

    // Draw corner points as small circles
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(
        Offset(point[0], point[1]),
        3.0,
        pointPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
