import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Codigos/drawPoligono.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';

class A2EX2 extends StatefulWidget {
  A2EX2();

  @override
  _A2EX2 createState() => _A2EX2();
}

class _A2EX2 extends State<A2EX2> {
  _A2EX2();

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

    rdn = Random(DateTime.now().microsecondsSinceEpoch);

    gerarEx();
  }

  //Dados pra pegar no servidor
  //Quantidade de exercícios que serão gerados
  //Texto da questão

  String questao =
      "Determine as coordenadas absolutas (x, y) dos vértices A, B, C e D, partindo de Xa = 1000,00 e Xb = 1000,00";

  void finalizarTentativa(
      List<TextEditingController> respostas, BuildContext context) async {
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

    user!.dbOn
        .child(
            "users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario")
        .set({
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
      drawAzimute: true,
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
          "dr": toFour(drAns),
          "gms": toGrauMinSec(angle),
        },
      );
      drAns = dr;
    }

    dataEx[0]['dr'] = toFour(drAns);
  }

  Widget itemsDeTexto() {
    bool justRead = false;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height / 2,
      child: TabelaCampo(
        dados: [
          ItemTabela(
            re: Text("D"),
            estacao: Text("A"),
            vante: Text("B"),
            azimute: Text(dataEx[0]["gms"].toString()),
            distRed: Text(dataEx[0]["dr"].toString()),
            abcRelX: TextField(
              controller: respostasRel[0],
              keyboardType: TextInputType.number,
              readOnly: justRead,
            ),
            abcRelY: Text("1000.00"),
          ),
          ItemTabela(
            re: Text("A"),
            estacao: Text("B"),
            vante: Text("C"),
            azimute: Text(dataEx[1]["gms"].toString()),
            distRed: Text(dataEx[1]["dr"].toString()),
            abcRelX: Text("1000.00"),
            abcRelY: Text("1000.00"),
          ),
          ItemTabela(
            re: Text("B"),
            estacao: Text("C"),
            vante: Text("D"),
            azimute: Text(dataEx[2]["gms"].toString()),
            distRed: Text(dataEx[2]["dr"].toString()),
          ),
          ItemTabela(
            re: Text("C"),
            estacao: Text("D"),
            vante: Text("A"),
            azimute: Text(dataEx[3]["gms"].toString()),
            distRed: Text(dataEx[3]["dr"].toString()),
          ),
        ],
        
        tabelaEstatica: true,
        titulos: {
          "re": Text(
            'Ré',
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "estacao": Text(
            'Estacão',
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "vante": Text(
            'Vante',
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "azimute": Text(
            "Azimute",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "distRed": Text(
            "Dr",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "abcRelX": Text(
            "Abscissa\nRel (x)",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          "abcRelY": Text(
            "Abscissa\nRel (y)",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        },
        ordem: [
          "estacao",
          "re",
          "vante",
          "azimute",
          "distRed",
          "abcRelX",
          "abcRelY",
        ],
        celulaHeight: 30,
        celulaWidth: 70,
      ),
    );

    /*List<RenderObjectWidget> items = [];

    bool justRead = false;

    List<String> textos = [
      "XA = ",
      "YA = ",
      "XB = ",
      "YB = ",
      "XC = ",
      "YC = ",
      "XD = ",
      "YD = ",
    ];

    if (certos.contains("acertou") || certos.contains("errou")) {
      justRead = true;
    }

    textos.forEach((element) {
      int i = textos.indexOf(element);

      if (justRead) {
        String respostaTexto = respostas[i].text;
        if (certos[i] == "acertou") {
          respostas[i] = TextEditingController(text: respostas[i].text);
        } else {
          //Rersposta real
          double res = 0;
          if (i == 0) {
            res = 1000.00; //dataEx[3]['dr'] * sin(dataEx[3]['az'] * pi / 180);
          } else if (i == 1) {
            res = 1000.00; //dataEx[3]['dr'] * cos(dataEx[3]['az'] * pi / 180);
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
          respostas[i] = TextEditingController(
              text: respostas[i].text + " (${toSix(res)})");
        }
      }

      items.add(
        Row(
          children: [
            Spacer(flex: 1),
            Text(element),
            Expanded(
              flex: 10,
              child: TextField(
                controller: respostas[i],
                keyboardType: TextInputType.number,
                readOnly: justRead || i == 0 || i == 1,
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      );
    });

    return Column(children: items);*/
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercício 2"),
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
              width: MediaQuery.of(context).size.width - 50,
              height: 350,
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
            Row(
              children: [
                Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  child: Text(
                      "AZ A^B: ${dataEx[0]["gms"]}\n\nAZ B^C: ${dataEx[1]["gms"]}\n\nAZ C^D: ${dataEx[2]["gms"]}\n\nAZ D^A: ${dataEx[3]["gms"]}"),
                ),
                Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  child: Text(
                      "Dr A: ${dataEx[0]["dr"]}m\n\nDr B: ${dataEx[1]["dr"]}m\n\nDr C: ${dataEx[2]["dr"]}m\n\nDr D: ${dataEx[3]["dr"]}m"),
                ),
                Spacer(),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            itemsDeTexto(),
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
            ),
          ],
        ),
      ),
    );
  }
}
