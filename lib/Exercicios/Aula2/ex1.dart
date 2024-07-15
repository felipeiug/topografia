import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topografia/Codigos/drawPoligono.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';

class A2EX1 extends StatefulWidget {
  A2EX1();

  @override
  _A2EX1 createState() => _A2EX1();
}

class _A2EX1 extends State<A2EX1> {
  _A2EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};
  List<String> certos = [];

  List<TextEditingController> respostasAbs = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  List<TextEditingController> respostasRel = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int distanciaMax = 300; //Distancia máxima para distribuir os pontos.

  Random? rdn;

  List<List<Offset>>? pontos;
  Widget? drawPoints;
  List dataEx = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    rdn = Random(DateTime.now().microsecondsSinceEpoch);

    gerarEx();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  //Dados pra pegar no servidor
  //Quantidade de exercícios que serão gerados
  //Texto da questão

  String questao = "Com os dados fornecidos calcule as coordenadas relativas (Xr, Yr) e as coordenadas absolutas dos vértices A, B, C e D:";

  void finalizarTentativa(List<TextEditingController> respostas, BuildContext context) async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    List dados = [];
    respostas.forEach(
      (e) {
        int i = respostas.indexOf(e);
        double resp = 0;

        //Rersposta real
        double res = 0;
        if (i == 0) {
          res = dataEx[3]['dr'] * sin(dataEx[3]['az'] * pi / 180);
        } else if (i == 1) {
          res = dataEx[3]['dr'] * cos(dataEx[3]['az'] * pi / 180);
        } else if (i == 2) {
          res = dataEx[0]['dr'] * sin(dataEx[0]['az'] * pi / 180);
        } else if (i == 3) {
          res = dataEx[0]['dr'] * cos(dataEx[0]['az'] * pi / 180);
        } else if (i == 4) {
          res = dataEx[1]['dr'] * sin(dataEx[1]['az'] * pi / 180);
        } else if (i == 5) {
          res = dataEx[1]['dr'] * cos(dataEx[1]['az'] * pi / 180);
        } else if (i == 6) {
          res = dataEx[2]['dr'] * sin(dataEx[2]['az'] * pi / 180);
        } else if (i == 7) {
          res = dataEx[2]['dr'] * cos(dataEx[2]['az'] * pi / 180);
        }

        e.text = e.text.replaceAll(",", ".");

        if (e.text != "") {
          resp = double.parse(e.text);
        }

        bool usou_tolerancia = (sqrt(pow(resp - res, 2)) <= 0.5);

        bool acertou = (resp == res) || usou_tolerancia;

        while (certos.length < i + 1) {
          certos.add("errou");
        }

        certos[i] = acertou ? "acertou" : "errou";

        //if (!acertou) {
        //  e.text += " (${toTwo(res)})";
        //}

        dados.add(
          {
            "usou_tolerancia": usou_tolerancia,
            "acertou": acertou,
            "resposta": resp,
            "resultado": res,
          },
        );
      },
    );

    List _pontos = [];

    pontos!.forEach((e) {
      _pontos.add([e[0].dx, e[0].dy]);
    });

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set({
      'pontos': _pontos,
      'dados': dados,
    });

    setState(() {});
  }

  void gerarEx() {
    pontos = gerarPoligono(4, distanciaMax, rdn!);

    drawPoints = DrawPoligon(
      points: pontos,
      drawTrueNorth: true,
      //drawAzimute: true,
      drawPoints: true,
    );

    dataEx = [];

    double drAns = 0;

    for (int i = 0; i < pontos!.length; i++) {
      Offset p1 = pontos![i][0];
      Offset p2;

      if (i == pontos!.length - 1) {
        p2 = pontos![0][0];
      } else {
        p2 = pontos![i + 1][0];
      }

      double h = p1.dy - p2.dy;
      double d = p1.dx - p2.dx;

      double angleP1P2 = atan(h / d);

      double angle = 0.0;
      double dr = sqrt(pow(h, 2) + pow(d, 2));

      if (d >= 0) {
        angle = (pi + pi / 2 - angleP1P2) * 180 / pi;
      } else {
        angle = (pi / 2 - angleP1P2) * 180 / pi;
      }
      dataEx.add(
        {
          "az": toSix(angle),
          "dr": toTwo(drAns),
          "gms": toGrauMinSec(angle),
        },
      );
      drAns = dr;
    }

    dataEx[0]['dr'] = toTwo(drAns);
  }

  Widget itemsDeTexto() {
    bool justRead = false;

    if (certos.contains("acertou") || certos.contains("errou")) {
      justRead = true;
    }

    List<Widget> dados = [
      //Títulos
      Text(
        'Ré',
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        'Estacão',
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        'Vante',
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        "Azimute\nCalculado",
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        "Distância\nReduzida",
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Text(
        "Abscissa\nRelativa (x)",
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        "Ordenada\nRelativa (y)",
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        "Abscissa\nAbsoluta (x)",
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      Text(
        "Ordenada\nAbsoluta (y)",
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      //Dados 1
      Text("D"),
      Text("A"),
      Text("B"),
      Text(dataEx[0]["gms"].toString()),
      Text(dataEx[0]["dr"].toString()),
      TextField(
        controller: respostasRel[1],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasRel[2],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[0],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[1],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      //Dados 2
      Text("A"),
      Text("B"),
      Text("C"),
      Text(dataEx[1]["gms"].toString()),
      Text(dataEx[1]["dr"].toString()),
      TextField(
        controller: respostasRel[3],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasRel[4],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[1],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[2],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      //Dados 3
      Text("B"),
      Text("C"),
      Text("D"),
      Text(dataEx[2]["gms"].toString()),
      Text(dataEx[2]["dr"].toString()),
      TextField(
        controller: respostasRel[5],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasRel[6],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[3],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasAbs[4],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      //Dados 4
      Text("C"),
      Text("D"),
      Text("A"),
      Text(dataEx[3]["gms"].toString()),
      Text(dataEx[3]["dr"].toString()),
      TextField(
        controller: respostasRel[5],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      TextField(
        controller: respostasRel[6],
        keyboardType: TextInputType.number,
        readOnly: justRead,
      ),
      Text("1000.00"),
      Text("1000.00"),
    ];

    return SizedBox(
      width: kIsWeb ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
      height: 50 * 5,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 9,
        childAspectRatio: 16 / 9,
        children: dados.map((e) {
          return Container(
            decoration: BoxDecoration(
              color: dados.indexOf(e) < 9 ? Cores.primaria : Cores.branco,
              border: Border.all(
                color: Cores.preto,
              ),
            ),
            child: Center(
              child: e,
            ),
          );
        }).toList(),
      ),
    );
  }

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

    //bool justRead = false;
    String textoFinalizar = "Finalizar Tentativa";

    if (certos.contains("acertou") || certos.contains("errou")) {
      textoFinalizar = "Sair";
      //justRead = true;
    }

    //gerarEx();

    return Scaffold(
      appBar: AppBar(
        title: Text("Coordenadas Relativas e Absolutas"),
        backgroundColor: Cores.primaria,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                questao,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5 - 50,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Card(
                elevation: 9,
                child: Container(
                  color: Color.lerp(Colors.black, Colors.transparent, 0.7),
                  padding: EdgeInsets.fromLTRB(15, 10, 25, 20),
                  child: drawPoints,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text("Na topografia utilizam-se tabelas para facilitar a organização dos dados. Para se familiarizar com as nomenclaturas utilizadas na topografia preencha a Tabela com os dados calculados"),
            SizedBox(
              height: 15,
            ),
            itemsDeTexto(),
            Builder(
              builder: (ctx) {
                if (certos.contains("acertou") || certos.contains("errou")) {
                  return Text(!certos.contains("errou") ? "Você acertou" : "Você errou!");
                }
                return SizedBox();
              },
            ),
            Row(
              children: [
                    Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        finalizarTentativa(respostasAbs, context);
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
    );
  }
}
