import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A3EX4 extends StatefulWidget {
  A3EX4();

  @override
  _A3EX4 createState() => _A3EX4();
}

class _A3EX4 extends State<A3EX4> {
  _A3EX4();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};

  List<String> certos = [];

  Random? rdn;
  bool rumoToAz = false;
  bool rumoToAzAns = true;
  double grauAz = 0;
  double grauRu = 0;
  String quad = "NE";

  double _resposta = 0;
  String _quadResp = "NE";

  @override
  void initState() {
    super.initState();

    rdn = Random(DateTime.now().microsecondsSinceEpoch);
    gerarEx();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String questao = "Calculadora de Rumos ⇆ Azimutes";

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    double res = toFour(_resposta);
    double resp = grauAz;
    String quadResp = "NE";

    if (rumoToAz) {
      if (quad == "NE") {
        resp = grauRu;
      } else if (quad == "SE") {
        resp = 180 - grauRu;
      } else if (quad == "SW") {
        resp = 180 + grauRu;
      } else if (quad == "NW") {
        resp = 360 - grauRu;
      }
    } else {
      if (grauAz <= 90) {
        resp = grauAz;
        quadResp = "NE";
      } else if (grauAz <= 180) {
        resp = 180 - grauAz;
        quadResp = "SE";
      } else if (grauAz <= 270) {
        resp = grauAz - 180;
        quadResp = "SW";
      } else {
        resp = 360 - grauAz;
        quadResp = "NW";
      }
    }

    bool usou_tolerancia = (sqrt(pow(resp - res, 2)) <= 0.5);
    bool acertou = ((resp == res) || usou_tolerancia) &&
        (rumoToAz || quadResp == _quadResp);

    certos.add(acertou ? "acertou" : "errou");

    user!.dbOn
        .child(
            "users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario")
        .set(
      {
        'dados': {
          "usou_tolerancia": usou_tolerancia,
          "acertou": acertou,
          "valores": {
            "rumoToAz": rumoToAz,
            "quadrante": rumoToAz ? "-" : _quadResp, //Qaundrante da Resposta
            "resp": _resposta, //Resposta
          }
        },
      },
    );

    setState(() {});
  }

  void gerarEx() {
    rdn = Random(DateTime.now().microsecondsSinceEpoch);

    grauAz = min(toFour(rdn!.nextInt(360) + rdn!.nextDouble()), 360);
    grauRu = min(toFour(rdn!.nextInt(90) + rdn!.nextDouble()), 90);
    quad = ["NE", "SE", "SW", "NW"][rdn!.nextInt(4)];
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map && args.containsKey("user")) {
      user = args['user'];
    }

    if (args != null && args is Map && args.containsKey("indexAula")) {
      indexAula = args['indexAula'];
    }

    if (args != null && args is Map && args.containsKey("indexTexto")) {
      indexTexto = args['indexTexto'];
    }

    String textoFinalizar = "Finalizar Tentativa";

    if (certos.contains("acertou") || certos.contains("errou")) {
      textoFinalizar = "Sair";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercício 4"),
        backgroundColor: Cores.primaria,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 90,
          child: Column(
            children: [
              //Enunciado do exercício
              Padding(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Text(
                    questao,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              //Eixos cartezianos
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.35,
                //color: Cores.primaria,
                child: CustomPaint(
                  painter: EixosCartesianos(
                    angle: (rumoToAz ? grauRu : grauAz),
                    rumoToAz: rumoToAz,
                    quad: quad,
                    showAng2: (certos.contains("acertou") ||
                        certos.contains("errou")),
                    angle2: _resposta,
                    quadAng2: _quadResp,
                    usouTolerancia: certos.contains("acertou"),
                  ),
                ),
              ),
              //Botao de azimute pra rumo e vice-e-versa
              OutlinedButton(
                onPressed: () {
                  if (!(certos.contains("acertou") ||
                      certos.contains("errou"))) {
                    rumoToAz = !rumoToAz;

                    _resposta = 0;

                    setState(() {});
                  }
                },
                child: Text(
                  !rumoToAz ? "Azimute para Rumo" : "Rumo para Azimute",
                  style: TextStyle(
                    color: Cores.preto,
                  ),
                ),
              ),
              //Textos e items de ação
              Padding(
                padding: EdgeInsets.all(15),
                child: Builder(
                  builder: (ctx) {
                    if (!rumoToAz) {
                      return Row(
                        children: [
                          Text(
                            "Tranforme o azimute em\nrumo: ${toGrauMinSec(grauAz)}",
                            style: TextStyle(
                              color: Cores.preto,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextGMSField(
                              angleInit: _resposta,
                              quad: _quadResp,
                              onChange: (val) {
                                _resposta = val[0];
                                _quadResp = val[1];
                                setState(() {});
                              },
                              isRumo: !rumoToAz,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Text(
                            "Tranforme o rumo em\nazimute: ${toGrauMinSec(grauRu)} $quad",
                            style: TextStyle(
                              color: Cores.preto,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextGMSField(
                              angleInit: _resposta,
                              onChange: (val) {
                                _resposta = val;
                                setState(() {});
                              },
                              isRumo: !rumoToAz,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              //Espaçador
              Spacer(),
              //Botão para finalizar a tentativa
              Row(
                children: [
                      Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          finalizarTentativa();
                        },
                        child: Text(
                          textoFinalizar,
                          style: TextStyle(
                            color: Cores.preto,
                          ),
                        ),
                      )
                    ] +
                    ((certos.contains("acertou") || certos.contains("errou"))
                        ? [
                            IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                certos = [];
                                gerarEx();
                                setState(() {});
                              },
                            ),
                          ]
                        : []) +
                    [
                      Spacer(),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EixosCartesianos extends CustomPainter {
  EixosCartesianos({
    this.rumoToAz,
    this.angle,
    this.quad,
    this.angle2,
    this.showAng2,
    this.quadAng2,
    this.usouTolerancia,
  });

  final bool? rumoToAz;
  final double? angle;
  final String? quad;

  final bool? showAng2;
  final double? angle2;
  final String? quadAng2;
  final bool? usouTolerancia;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;

    //Text style for indicators
    final style = TextStyle(
      color: Cores.primaria,
      fontSize: 16,
    );

    double tamanho = min(
      size.height - (size.height * 0.2),
      size.width - (size.width * 0.2),
    );

    Offset p1 = Offset(
      (size.width / 2),
      (size.height - tamanho) / 2,
    );
    Offset p2 = Offset(
      ((size.width - tamanho) / 2) + tamanho,
      (size.height / 2),
    );
    Offset p3 = Offset(
      (size.width / 2),
      ((size.height - tamanho) / 2) + tamanho,
    );
    Offset p4 = Offset(
      (size.width - tamanho) / 2,
      (size.height / 2),
    );

    canvas.drawLine(
      p1,
      p3,
      paint,
    );

    canvas.drawLine(
      p4,
      p2,
      paint,
    );

    //Draw arrows
    //N
    canvas.drawLine(
      p1,
      p1 + Offset(-5, 10),
      paint,
    );
    canvas.drawLine(
      p1 + Offset(5, 10),
      p1,
      paint,
    );

    //Draw N

    TextSpan textSpan = TextSpan(
      text: 'N',
      style: style,
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(canvas, p1 + Offset(0, -18));

    //E
    canvas.drawLine(
      p2,
      p2 - Offset(10, 5),
      paint,
    );
    canvas.drawLine(
      p2 - Offset(10, -5),
      p2,
      paint,
    );

    //Draw E
    textSpan = TextSpan(
      text: 'E',
      style: style,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(canvas, p2 + Offset(3, -7));

    //S
    canvas.drawLine(
      p3,
      p3 - Offset(-5, 10),
      paint,
    );
    canvas.drawLine(
      p3 - Offset(5, 10),
      p3,
      paint,
    );

    //Draw S
    textSpan = TextSpan(
      text: 'S',
      style: style,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(canvas, p3);

    //W
    canvas.drawLine(
      p4,
      p4 + Offset(10, 5),
      paint,
    );
    canvas.drawLine(
      p4 + Offset(10, -5),
      p4,
      paint,
    );

    //Draw W
    textSpan = TextSpan(
      text: 'W',
      style: style,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(canvas, p4 + Offset(-16, -7));

    ///////////////////////////////////////
    ///Show ang
    void showAng(double ang, bool resp) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = resp ? Colors.green : Cores.primaria;

      double angInit = 0; //3 * pi / 2;
      double angFim = ang * pi / 180;

      if (!(rumoToAz ?? true)) {
        if (resp) {
          if ((quadAng2 ?? "NE") == "NE") {
            angInit = 3 * pi / 2;
          } else if ((quadAng2 ?? "NE") == "NW") {
            angInit = 3 * pi / 2;
            angFim = -angFim;
          } else if ((quadAng2 ?? "NE") == "SE") {
            angInit = pi / 2;
            angFim = -angFim;
          } else if ((quadAng2 ?? "NE") == "SW") {
            angInit = pi / 2;
          }
        } else {
          if ((quad ?? "NE") == "NE") {
            angInit = -pi / 2;
          } else if ((quad ?? "NE") == "NW") {
            angInit = -pi / 2;
            //angFim = -angFim;
          } else if ((quad ?? "NE") == "SE") {
            angInit = -pi / 2;
            //angFim = -angFim;
          } else if ((quad ?? "NE") == "SW") {
            angInit = -pi / 2;
          }
        }
      } else {
        if (!resp) {
          if ((quad ?? "NE") == "NE") {
            angInit = 3 * pi / 2;
          } else if ((quad ?? "NE") == "NW") {
            angInit = 3 * pi / 2;
            angFim = -angFim;
          } else if ((quad ?? "NE") == "SE") {
            angInit = pi / 2;
            angFim = -angFim;
          } else if ((quad ?? "NE") == "SW") {
            angInit = pi / 2;
          }
        } else {
          angInit = -pi / 2;
        }
      }

      canvas.drawArc(
        Rect.fromCenter(
          center: (p1 + p3) / 2,
          width: tamanho * 0.7,
          height: tamanho * 0.7,
        ),
        angInit,
        angFim,
        false,
        paint,
      );

      double angTotal = angInit + angFim;

      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = !(resp)
            ? Colors.blue
            : (angle != null &&
                    angle2 != null &&
                    (angle == angle2 || (usouTolerancia ?? false)))
                ? Colors.green
                : Colors.red;

      canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(
          //Ponto final da reta inclinada
          size.width / 2 + (tamanho * 0.8 / 2) * cos(angTotal),
          size.height / 2 + (tamanho * 0.8 / 2) * sin(angTotal),
        ),
        paint,
      );
    }

    showAng(angle ?? 0, false);

    if (showAng2 ?? false) {
      showAng(angle2 ?? 0, true);
    }
  }

  @override
  bool shouldRepaint(EixosCartesianos oldDelegate) => false;
}
