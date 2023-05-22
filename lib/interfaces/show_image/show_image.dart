import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ShowImage extends StatelessWidget {
  const ShowImage({
    super.key,
    this.imageUI,
    this.faces,
    required this.width,
  });
  final Image? imageUI;
  final List<Face>? faces;
  final double width;
  @override
  Widget build(BuildContext context) {
    return imageUI != null
        ? Center(
            child: FittedBox(
              child: SizedBox(
                width: imageUI!.width.toDouble(),
                height: imageUI!.height.toDouble(),
                child: CustomPaint(
                  painter: FacePainter(
                    imageUI: imageUI!,
                    faces: faces,
                  ),
                ),
              ),
            ),
          )
        : Icon(
            Icons.image,
            size: width,
          );
  }
}

class FacePainter extends CustomPainter {
  const FacePainter({required this.imageUI, this.faces});
  final List<Face>? faces;
  final Image imageUI;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(imageUI, Offset.zero, Paint());
    if (faces != null) {
      final Paint faceRectangleBoxPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final Paint faceContourPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final Paint faceLandmarkPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (final Face face in faces!) {
        canvas.drawRect(face.boundingBox, faceRectangleBoxPaint);
      }
      for (final Face face in faces!) {
        final Map<FaceContourType, FaceContour?> faceContours = face.contours;
        final List<Offset> offsetPoints = <Offset>[];
        faceContours.forEach(
          (facecontourtypes, facecontours) {
            if (facecontours != null) {
              final List<Point<int>> contourPoints = facecontours.points;
              for (final Point point in contourPoints) {
                final Offset offsetPoint =
                    Offset(point.x.toDouble(), point.y.toDouble());
                offsetPoints.add(offsetPoint);
              }
            }
          },
        );
        canvas.drawPoints(PointMode.points, offsetPoints, faceContourPaint);
        final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
        if (leftEar != null) {
          final Point<int> leftEarPoint = leftEar.position;
          canvas.drawRect(
            Rect.fromLTWH(
              leftEarPoint.x.toDouble() - 15,
              leftEarPoint.y.toDouble() - 10,
              20,
              20,
            ),
            faceLandmarkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) =>
      oldDelegate.imageUI != imageUI;
}
