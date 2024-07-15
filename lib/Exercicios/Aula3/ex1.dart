import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Contants/constantes.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A3EX1 extends StatefulWidget {
  A3EX1();

  @override
  _A3EX1 createState() => _A3EX1();
}

class _A3EX1 extends State<A3EX1> {
  _A3EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};
  List<String> certos = [];

  Random? rdn;
  double angAlfa = 0;
  double dist = 0;

  double raio_terra = 0;

  TextEditingController _dist = TextEditingController(text: "0");
  TextEditingController _ang = TextEditingController(text: "0");
  TextEditingController _distArc = TextEditingController();
  TextEditingController _eart_radius = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    rdn = Random(DateTime.now().microsecondsSinceEpoch);
    gerarEx();
  }

  String questao = "Determine D'";

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    dist = double.tryParse(_dist.text.replaceAll(",", ".")) ?? 0;
    angAlfa = toFour(gmsToDoube(_ang.text));
    double res = double.tryParse(_distArc.text.replaceAll(",", ".")) ?? 0;

    raio_terra = double.tryParse(_eart_radius.text.replaceAll(",", ".")) ?? 0;

    double resp = (pi * angAlfa * raio_terra) / 180;

    bool usou_tolerancia = (sqrt(pow(resp - res, 2)) <= 0.5);

    bool acertou = (resp == res) || usou_tolerancia;

    certos.add(acertou ? "acertou" : "errou");

    if (!acertou) {
      _distArc.text = _distArc.text + " (${toFour(resp)})";
    }

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set(
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

    setState(() {});
  }

  void gerarEx() {
    raio_terra = earthRadius;

    _eart_radius.text = raio_terra.toString().replaceAll(".", ",");

    dist = rdn!.nextDouble() * rdn!.nextInt(200000);

    angAlfa = atan(dist / earthRadius) * 180 / pi;
    angAlfa = toFour(angAlfa);
    dist = toFour(dist);

    _ang.text = toGrauMinSec(angAlfa);
    _dist.text = dist.toString();
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

    String textoFinalizar = "Finalizar Tentativa";

    if (certos.contains("acertou") || certos.contains("errou")) {
      textoFinalizar = "Sair";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercício 1"),
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
          SizedBox(
            child: Image.asset("assets/outros/esfericidade.png"),
            width: kIsWeb ? MediaQuery.of(context).size.width / 2 : null,
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 56 * 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Text(
                        "  Raio da Terra (m): ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Text(
                        "  Ângulo alfa: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Text(
                        "  e |D-D'|: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Text(
                        "  Plano Topográfico D: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Text(
                        "  Arco na superfície da terra D': ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 56 * 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _eart_radius,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          /*child: TextFormField(
                            controller: _ang,
                          ),*/
                          child: Center(child: Text(_ang.text)),
                        ),
                        Divider(color: Cores.preto, thickness: 1, height: 2),
                        Expanded(
                          /*child: TextFormField(
                            controller: _ang,
                          ),*/

                          child: Center(
                            child: Text(
                              _distArc.text != ""
                                  ? (double.parse(
                                            _dist.text.replaceAll(",", "."),
                                          ) -
                                          double.parse(
                                            _distArc.text.replaceAll(",", "."),
                                          ))
                                      .abs()
                                      .toString()
                                  : "-",
                            ),
                          ),
                        ),
                        Divider(color: Cores.preto, thickness: 1, height: 2),
                        Expanded(
                          /*child: TextFormField(
                            controller: _dist,
                            keyboardType: TextInputType.number,
                          ),*/
                          child: Center(child: Text(_dist.text)),
                        ),
                        Divider(color: Cores.preto, thickness: 1, height: 2),
                        Expanded(
                          child: TextFormField(
                            controller: _distArc,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          kIsWeb ? SizedBox() : Spacer(),
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
                            _distArc.text = "";
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
    );
  }
}
