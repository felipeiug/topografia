import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A1EX5 extends StatefulWidget {
  A1EX5();

  @override
  _A1EX5 createState() => _A1EX5();
}

class _A1EX5 extends State<A1EX5> {
  _A1EX5();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};

  //TODO: Arrumar para quando tiver o norte verdadeiro dos locais.
  List<String> certos = [
    "Acertou",
  ];

  Random? rdn;

  @override
  void initState() {
    super.initState();
    rdn = Random(DateTime.now().microsecondsSinceEpoch);
    gerarEx();
  }

  String questao = "Exercício em Desenvolvimento.";

  void finalizarTentativa() async {
    /*int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    dist = double.tryParse(_dist.text.replaceAll(",", ".")) ?? 0;
    angAlfa = toFour(gmsToDoube(_ang.text));
    double res = double.tryParse(_distArc.text.replaceAll(",", ".")) ?? 0;

    double resp = (pi * angAlfa * earthRadius) / 180;

    bool usou_tolerancia = (sqrt(pow(resp - res, 2)) <= 0.5);

    bool acertou = (resp == res) || usou_tolerancia;

    certos.add(acertou ? "acertou" : "errou");

    _distArc.text = _distArc.text + " [${toFour(resp)}]";

    user!.dbOn
        .child(
            "users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario")
        .set(
      {
        'dados': {
          "usou_tolerancia": usou_tolerancia,
          "acertou": acertou,
          "resposta": resp,
          "resultado": res,
          "valores": {
            "ang": angAlfa, //Angulo alfa
            "dist": dist, //Distancia no plano topográfico
          }
        },
      },
    );

    setState(() {});*/
  }

  void gerarEx() {}

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
      body: Column(
        children: [
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
        ],
      ),
    );
  }
}
