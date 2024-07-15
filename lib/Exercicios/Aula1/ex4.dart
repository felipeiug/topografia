import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Contants/constantes.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A1EX4 extends StatefulWidget {
  A1EX4();

  @override
  _A1EX4 createState() => _A1EX4();
}

class _A1EX4 extends State<A1EX4> {
  _A1EX4();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};

  bool folha_up = true;
  String tipo_folha = "A4";
  double escala = 1 / 25;
  double largura = 0;
  double altura = 0;

  String texto_final = "";

  List<String> certos = [];

  Random? rdn;

  @override
  void initState() {
    super.initState();
    rdn = Random(DateTime.now().microsecondsSinceEpoch);
    gerarEx();
  }

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    String melhor_escala = "1:25";

    bool acertou = false;

    double escala_alt = altura / ((folha_up ? folhas[tipo_folha]![0] : folhas[tipo_folha]![1]) / 100);
    double escala_larg = largura / ((folha_up ? folhas[tipo_folha]![1] : folhas[tipo_folha]![0]) / 100);

    double _escala = 1 / max(escala_alt, escala_larg);

    num maior = 0;
    escalas.forEach((key, value) {
      if (value <= _escala) {
        if (value > maior) {
          melhor_escala = key;
          maior = value;
        }
      }
    });

    if (escala == escalas[melhor_escala]) {
      acertou = true;
    }

    certos.add(acertou ? "acertou" : "errou");

    if (acertou) {
      texto_final = "Você acertou a melhor escala: $melhor_escala";
    } else {
      texto_final = "Você errou, a melhor escala era a de $melhor_escala";
    }

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set(
      {
        'dados': {
          "acertou": acertou,
          "resposta": escala < 1 ? "1:${(1 ~/ escala)}" : "${escala.toInt()}:1",
          "resultado": melhor_escala,
          "valores": {
            "largura": largura,
            "altura": altura,
            "folha": tipo_folha,
            "folha_em_pe": folha_up,
          }
        },
      },
    );

    setState(() {});
  }

  void gerarEx() {
    altura = toTwo((rdn!.nextInt(65) * rdn!.nextDouble()) + 20);
    largura = toTwo((rdn!.nextInt(65) * rdn!.nextDouble()) + 20);
  }

  Widget build(BuildContext context) {
    String questao = "Determine a escala ideal para representar um retângulo de ${altura.toString().replaceAll(".", ",")}x${largura.toString().replaceAll(".", ",")}m (Altura x Largura) na folha escolhida (desconsidere as margens):";

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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  questao,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            Row(
              children: [
                Spacer(
                  flex: 10,
                ),
                Text("Tamanho da folha: "),
                PopupMenuButton<String>(
                  child: Card(
                    color: Cores.secundaria,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(tipo_folha + " (" + folhas[tipo_folha]![folha_up ? 0 : 1].toString().replaceAll(".", ",") + " x " + folhas[tipo_folha]![folha_up ? 1 : 0].toString().replaceAll(".", ",") + ")cm"),
                    ),
                  ),
                  initialValue: tipo_folha,
                  itemBuilder: (ctx) {
                    return folhas.keys.map((element) {
                      return PopupMenuItem<String>(
                        child: Text(element),
                        value: element,
                      );
                    }).toList();
                  },
                  onSelected: (folha) {
                    tipo_folha = folha;
                    setState(() {});
                  },
                ),
                Spacer(
                  flex: 100,
                ),
              ],
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: (kIsWeb ? (MediaQuery.of(context).size.width - 20) / 3 : (MediaQuery.of(context).size.width - 20)) * (folha_up ? (folhas[tipo_folha]![1] / folhas[tipo_folha]![0]) : 1),
              height: (kIsWeb ? (MediaQuery.of(context).size.width - 20) / 3 : (MediaQuery.of(context).size.width - 20)) * (folha_up ? 1 : (folhas[tipo_folha]![1] / folhas[tipo_folha]![0])),
              child: Card(
                child: Center(
                  child: Builder(
                    builder: (context) {
                      if (certos.contains("acertou") || certos.contains("errou")) {
                        double largura_folha = (MediaQuery.of(context).size.width - 20) * (folha_up ? (folhas[tipo_folha]![1] / folhas[tipo_folha]![0]) : 1);
                        double altura_folha = (MediaQuery.of(context).size.width - 20) * (folha_up ? 1 : (folhas[tipo_folha]![1] / folhas[tipo_folha]![0]));

                        bool ok1 = (escala * largura * 100) < (folha_up ? folhas[tipo_folha]![1] : folhas[tipo_folha]![0]);
                        bool ok2 = (escala * altura * 100) < (folha_up ? folhas[tipo_folha]![0] : folhas[tipo_folha]![1]);

                        bool ok = ok1 && ok2;

                        String text_escala = ok ? "1:${(1 ~/ escala).toString()}" : "Não cabe na Folha";
                        return Container(
                          width: (escala * largura * 100) * largura_folha / (folha_up ? folhas[tipo_folha]![1] : folhas[tipo_folha]![0]),
                          height: (escala * altura * 100) * altura_folha / (folha_up ? folhas[tipo_folha]![0] : folhas[tipo_folha]![1]),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                text_escala,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: ok ? Colors.transparent : Colors.red,
                            border: Border.all(color: Colors.blueAccent),
                          ),
                        );
                      } else {
                        return Center();
                      }
                    },
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                folha_up = !folha_up;
                setState(() {});
              },
              icon: Icon(Icons.crop_rotate),
            ),
            Row(
              children: [
                Spacer(
                  flex: 10,
                ),
                Text("Escala: "),
                PopupMenuButton<num>(
                  child: Card(
                    color: Cores.secundaria,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(escala < 1 ? "1:${(1 ~/ escala)}" : "${escala.toInt()}:1"),
                    ),
                  ),
                  initialValue: escalas[escala < 1 ? "1:${(1 ~/ escala)}" : "${escala.toInt()}:1"],
                  itemBuilder: (ctx) {
                    return escalas.keys.map((element) {
                      return PopupMenuItem<num>(
                        child: Text(element),
                        value: escalas[element],
                      );
                    }).toList();
                  },
                  onSelected: (esc) {
                    escala = esc.toDouble();
                    setState(() {});
                  },
                ),
                Spacer(
                  flex: 100,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(texto_final),
            ),
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
                              texto_final = "";
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
