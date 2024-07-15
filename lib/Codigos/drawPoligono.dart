import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Paleta/cores.dart';

class DrawPoligon extends StatefulWidget {
  DrawPoligon({
    this.points,
    this.drawCoords,
    this.drawDist,
    this.drawPoints,
    this.drawAngles,
    this.drawAzimute,
    this.drawTrueNorth,
    this.drawMagneticNorth,
    this.strokeWidth,
  });

  final List<List<Offset>>? points;
  final bool? drawCoords;
  final bool? drawPoints;
  final bool? drawDist;
  final bool? drawAngles;
  final bool? drawAzimute;
  final bool? drawTrueNorth;
  final bool? drawMagneticNorth;
  final double? strokeWidth;

  @override
  _DrawPoligon createState() => _DrawPoligon();
}

class _DrawPoligon extends State<DrawPoligon> {
  _DrawPoligon();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      child: new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        /*double width = constraints.maxWidth;
        double height = constraints.maxHeight;*/

        return CustomPaint(
          painter: Poligono(
            points: widget.points,
            drawCoords: widget.drawCoords,
            drawDist: widget.drawDist,
            drawPoints: widget.drawPoints,
            drawAngles: widget.drawAngles,
            drawAzimute: widget.drawAzimute,
            drawTrueNorth: widget.drawTrueNorth,
            drawMagneticNorth: widget.drawMagneticNorth,
            strokeWidth: widget.strokeWidth,
          ),
        );
      }),
    );
  }
}

class Poligono extends CustomPainter {
  Poligono({
    this.points,
    this.drawCoords,
    this.drawDist,
    this.drawPoints,
    this.drawAngles,
    this.drawAzimute,
    this.drawLineName,
    this.drawTrueNorth,
    this.drawMagneticNorth,
    this.strokeWidth,
  });

  final List<List<Offset>>? points;
  final bool? drawCoords;
  final bool? drawPoints;
  final bool? drawDist;
  final bool? drawAngles;
  final bool? drawAzimute;
  final bool? drawTrueNorth;
  final bool? drawMagneticNorth;
  final bool? drawLineName;
  final double? strokeWidth;

  void _drawTruthNort(Offset point, double scale, Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2
      ..color = Cores.primaria;

    //Draw line of arrow
    Offset finalPoint = point + Offset(0, -0.8 * scale);

    canvas.drawLine(point, finalPoint, paint);

    List<double> arrowPoints = [];

    //Draw arrow
    arrowPoints.add(finalPoint.dx - 0.1 * scale); // \
    arrowPoints.add(finalPoint.dy + 0.15 * scale); //

    arrowPoints.add(finalPoint.dx); //
    arrowPoints.add(finalPoint.dy); // .

    arrowPoints.add(finalPoint.dx + 0.1 * scale); //
    arrowPoints.add(finalPoint.dy + 0.15 * scale); // /

    canvas.drawRawPoints(
      PointMode.polygon,
      Float32List.fromList(arrowPoints),
      paint,
    );

    //Draw text
    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 0.2 * scale,
    );
    final textSpan = TextSpan(
      text: 'NV',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    Offset center = Offset(
      finalPoint.dx - textPainter.width / 2,
      finalPoint.dy - textPainter.height,
    );

    textPainter.paint(canvas, center);
  }

  void _drawAz(List<Offset> points, double scale, Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2
      ..color = Colors.pink;

    for (int i = 0; i < points.length; i++) {
      Offset p1 = points[i];
      Offset p2;

      if (i == points.length - 1) {
        p2 = points[0];
      } else {
        p2 = points[i + 1];
      }

      double h = p1.dy - p2.dy;
      double d = p1.dx - p2.dx;

      double angleP1P2 = atan(h / d);

      double angleNort = 0.0;

      if (d >= 0) {
        angleNort = pi + pi / 2 + angleP1P2;
      } else {
        angleNort = pi / 2 + angleP1P2;
      }

      canvas.drawArc(
        Rect.fromCenter(center: p1, width: 0.8 * scale, height: 0.8 * scale),
        0 - pi / 2,
        angleNort,
        false,
        paint,
      );
    }
  }

  void _drawPoint(List<Offset> points, double scale, Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      Offset p1 = points[i];

      //Draw text
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 0.25 * scale,
      );
      final textSpan = TextSpan(
        text: '${intToText(i + 1)}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      Offset center = Offset(
        p1.dx - textPainter.width / 2,
        p1.dy - textPainter.height + 0.4 * scale,
      );

      textPainter.paint(canvas, center);
    }
  }

  void _drawLinesName(List<List<Offset>> points, double scale, Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      Offset p1 = points[i][0];
      for (int j = 1; j < points[i].length; j++) {
        /*int i2 = 0;
        if (i == 0) {
          i2 = points.length - 1;
        } else {
          i2 = i - 1;
        }*/

        String letra = intToText(i + 1);

        Offset p2 = points[i][j];

        //Draw text
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: 0.25 * scale,
        );
        final textSpan = TextSpan(
          text: '$letra$j',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );

        Offset center = Offset(
          ((p1.dx + p2.dx) / 2) - textPainter.width / 2,
          ((p1.dy + p2.dy) / 2) - textPainter.height + 0.4 * scale,
        );

        textPainter.paint(canvas, center);
      }

      //Texto da linha principal/////////////////////
      int i2 = 0;
      if (i == 0) {
        i2 = points.length - 1;
      } else {
        i2 = i - 1;
      }
      String letra = intToText(i + 1);
      Offset p2 = points[i2][0];
      //Draw text
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 0.25 * scale,
      );
      final textSpan = TextSpan(
        text: '$letra',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      Offset center = Offset(
        ((p1.dx + p2.dx) / 2) - textPainter.width / 2,
        ((p1.dy + p2.dy) / 2) - textPainter.height + 0.4 * scale,
      );
      textPainter.paint(canvas, center);
      ////////////
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double escaleComponents = 50 * 4 / (log(points!.length / 4) + 4);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2
      ..color = Colors.black;

    if (points == null) return;

    double escala = 0;

    double minX = 1;
    double maxX = 0;
    double minY = 1;
    double maxY = 0;

    for (int i = 0; i < points!.length; i++) {
      for (int j = 0; j < points![i].length; j++) {
        if (points![i][j].dx < minX) {
          minX = points![i][j].dx;
        }
        if (points![i][j].dx > maxX) {
          maxX = points![i][j].dx;
        }
        if (points![i][j].dy < minY) {
          minY = points![i][j].dy;
        }
        if (points![i][j].dy > maxY) {
          maxY = points![i][j].dy;
        }
      }
    }

    double somaX = minX < 0 ? -minX : 0;
    double somaY = minY < 0 ? -minY : 0;

    if (size.width >= (size.height - escaleComponents)) {
      //Maior para os lados que para cima e baixo ou iguais.

      escala = size.width / (maxX - minX);

      if ((maxY + somaY) * escala > (size.height - escaleComponents)) {
        escala = (size.height - escaleComponents) / (maxY - minY);
      }
    } else {
      //Maior de cima a baixo que pros lados.

      escala = (size.height - escaleComponents) / (maxY - minY);

      if ((maxX + somaX) * escala > size.width) {
        escala = size.width / (maxX - minX);
      }
    }

    double distX = size.width / 2 - ((maxX - minX) * escala) / 2;
    double distY = (size.height - escaleComponents) / 2 - ((maxY - minY) * escala) / 2;

    List<List<Offset>> pointsScale = [];

    for (int i = 0; i < points!.length; i++) {
      List<Offset> _add = [];
      for (int j = 0; j < points![i].length; j++) {
        _add.add(
          Offset(
            (points![i][j].dx + somaX) * escala + distX,
            size.height - distY - (points![i][j].dy + somaY) * escala,
          ),
        );
      }
      pointsScale.add(_add);
    }

    List<double> poligonal = [];

    //TODO: Checar se é somente para o primeiro ponto aqui, ou se está desenhando para todos.
    pointsScale.forEach((point) {
      poligonal.add(point[0].dx);
      poligonal.add(point[0].dy);

      //Draw Truth Nort
      if (drawTrueNorth != null && drawTrueNorth == true) _drawTruthNort(point[0], escaleComponents, canvas, size);
    });

    //Draw Azimute
    if (drawAzimute != null && drawAzimute == true)
      _drawAz(
        pointsScale.map((e) => e[0]).toList(),
        escaleComponents,
        canvas,
        size,
      );

    //Draw number of point
    if (drawPoints != null && drawPoints == true)
      _drawPoint(
        pointsScale.map((e) => e[0]).toList(),
        escaleComponents,
        canvas,
        size,
      );

    //Draw name of line
    if ((drawPoints ?? false) && (drawLineName ?? false))
      _drawLinesName(
        pointsScale,
        escaleComponents,
        canvas,
        size,
      );

    poligonal.add(pointsScale[0][0].dx);
    poligonal.add(pointsScale[0][0].dy);

    //Draw Pligonal
    canvas.drawRawPoints(
      PointMode.polygon,
      Float32List.fromList(poligonal),
      paint,
    );

    //Draw irradiações
    paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2
      ..color = Cores.primaria;

    for (int i = 0; i < pointsScale.length; i++) {
      Offset p1 = pointsScale[i][0];
      for (int j = 1; j < pointsScale[i].length; j++) {
        Offset p2 = pointsScale[i][j];
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Poligono oldDelegate) => false;
}
