import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A5EX1 extends StatefulWidget {
  A5EX1();

  @override
  _A5EX1 createState() => _A5EX1();
}

class _A5EX1 extends State<A5EX1> {
  _A5EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  List<String> certos = [];

  Random? rdn;

  List<List> dadosEx = [];
  List<List> respostas = [];
  bool justRead = false;

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

  String questao = "Exercício em desenvolvimento";

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou") || true) {
      Navigator.of(context).pop();
      return;
    }

    /*for (List item in respostas) {
      int index = respostas.indexOf(item);
      double drRes =
          toFour(double.tryParse(item[1].text.replaceAll(",", ".")) ?? 0);
      double dnRes =
          toFour(double.tryParse(item[3].text.replaceAll(",", ".")) ?? 0);

      double m = dadosEx[index][7] - dadosEx[index][9];
      double angZenital = gmsToDoube(dadosEx[index][6]) * pi / 180;

      double drCalc = toFour(m * constAparelho * pow(sin(angZenital), 2));

      double dnCalc = toFour((m * constAparelho * sin(2 * angZenital)) / 2 +
          dadosEx[index][4] -
          dadosEx[index][8]);

      bool usou_tolerancia = (sqrt(pow(drCalc - drRes, 2)) <= 0.5) &&
          (sqrt(pow(dnCalc - dnRes, 2)) <= 0.5);

      bool acertou = ((drCalc == drRes && dnCalc == dnRes) || usou_tolerancia);

      if (acertou == false) {
        item[1].text = drRes.toString().padRight(5, "0") +
            " (" +
            drCalc.toString().padRight(5, "0") +
            ")";

        item[3].text = dnRes.toString().padRight(5, "0") +
            " (" +
            dnCalc.toString().padRight(5, "0") +
            ")";
      }

      certos.add(acertou ? "acertou" : "errou");
      String key = dadosEx[index][1] + "-" + dadosEx[index][2];
      dados[key] = {
        "usou_tolerancia": usou_tolerancia,
        "acertou": acertou,
        "valores": {
          "drCalc": drCalc,
          "dnCalc": dnCalc,
          "drRes": drRes,
          "dnRes": dnRes,
        }
      };
    }
    justRead = true;

    user!.dbOn
        .child(
            "users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario")
        .set(
      {
        'dados': dados,
      },
    );

    setState(() {});*/
  }

  void gerarEx() {}

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
        title: Text("Exercício 1"),
        backgroundColor: Cores.primaria,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
