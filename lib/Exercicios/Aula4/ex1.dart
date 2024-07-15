import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Contants/constantes.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';

class A4EX1 extends StatefulWidget {
  A4EX1();

  @override
  _A4EX1 createState() => _A4EX1();
}

class _A4EX1 extends State<A4EX1> {
  _A4EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  Map items = {};

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

  String questao = "Determine as distâncias reduzidas e diferença de nível para os dados apresentados na Tabela";

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    Map dados = {};

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    for (List item in respostas) {
      int index = respostas.indexOf(item);
      double drRes = toTwo(double.tryParse(item[1].text.replaceAll(",", ".")) ?? 0);
      double dnRes = toTwo(double.tryParse(item[3].text.replaceAll(",", ".")) ?? 0);

      double m = dadosEx[index][7] - dadosEx[index][9];
      double angZenital = gmsToDoube(dadosEx[index][6]) * pi / 180;

      double drCalc = toTwo(m * constAparelho * pow(sin(angZenital), 2));

      double dnCalc = toTwo((m * constAparelho * sin(2 * angZenital)) / 2 + dadosEx[index][4] - dadosEx[index][8]);

      bool usou_tolerancia = (sqrt(pow(drCalc - drRes, 2)) <= 0.5) && (sqrt(pow(dnCalc - dnRes, 2)) <= 0.5);

      bool acertou = ((drCalc == drRes && dnCalc == dnRes) || usou_tolerancia);

      if (acertou == false) {
        item[1].text = drRes.toString().padRight(5, "0") + " (" + drCalc.toString().padRight(5, "0") + ")";

        item[3].text = dnRes.toString().padRight(5, "0") + " (" + dnCalc.toString().padRight(5, "0") + ")";
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

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set(
      {
        'dados': dados,
      },
    );

    setState(() {});
  }

  void gerarEx() {
    dadosEx = [
      [
        "C",
        "A",
        "B",
        "Piquete",
        1.5,
        "350°59'" + '08"',
        "89°04'" + '36"',
        2.764,
        1.450,
        0.136,
      ],
      [
        "C",
        "A",
        "A1",
        "Cerca",
        1.500,
        "358°30'" + '19"',
        "88°57'" + '52"',
        2.446,
        1.300,
        0.154,
      ],
      [
        "A",
        "B",
        "C",
        "Piquete",
        1.510,
        "308°01'" + '51"',
        "90°59'" + '33"',
        1.235,
        1.000,
        0.765,
      ],
      [
        "B",
        "C",
        "A",
        "Piquete",
        1.254,
        "240°59'" + '01"',
        "90°52'" + '08"',
        2.683,
        1.500,
        0.317,
      ],
      [
        "B",
        "C",
        "C1",
        "Meio-fio",
        1.254,
        "52°56'" + '46"',
        "89°26'" + '03"',
        1.874,
        1.500,
        1.126,
      ],
    ];
    respostas = [
      [
        "Dr - AB:",
        TextEditingController(),
        "Dn - AB:",
        TextEditingController(),
      ],
      [
        "Dr - AA1:",
        TextEditingController(),
        "Dn - AA1:",
        TextEditingController(),
      ],
      [
        "Dr - BC:",
        TextEditingController(),
        "Dn - BC:",
        TextEditingController(),
      ],
      [
        "Dr - CA:",
        TextEditingController(),
        "Dn - CA:",
        TextEditingController(),
      ],
      [
        "Dr - CC1:",
        TextEditingController(),
        "Dn - CC1:",
        TextEditingController(),
      ],
    ];
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
                  //Tabela com os dados
                  TabelaCampo(
                    dados: dadosEx
                        .map(
                          (e) => ItemTabela(
                            re: Text(
                              e[0].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            estacao: Text(
                              e[1].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            vante: Text(
                              e[2].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            descricao: Text(
                              e[3].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            alturaInst: Text(
                              e[4].toString().padRight(5, "0").replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            angHorizontal: Text(
                              e[5].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            angZenital: Text(
                              e[6].toString().replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            fioSup: Text(
                              e[7].toString().padRight(5, "0").replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            fioMed: Text(
                              e[8].toString().padRight(5, "0").replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                            fioInf: Text(
                              e[9].toString().padRight(5, "0").replaceAll(".", ","),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    celulaHeight: 25,
                    celulaWidth: 55,
                    tabelaEstatica: true,
                    titulos: {
                      "re": Text(
                        'Ré',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "estacao": Text(
                        'Estacão',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "vante": Text(
                        'Vante',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "descricao": Text(
                        'Descrição',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "alturaInst": Text(
                        'Altura do\nInstrumento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "angHorizontal": Text(
                        'Ang.\nHorizontal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "angZenital": Text(
                        "Ang.\nZenital",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "fioSup": Text(
                        "Fio\nSuperior",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "fioMed": Text(
                        "Fio\nMédio",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                      "fioInf": Text(
                        "Fio\nInferior",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 9,
                        ),
                      ),
                    },
                    ordem: [
                      "estacao",
                      "re",
                      "vante",
                      "descricao",
                      "alturaInst",
                      "angHorizontal",
                      "angZenital",
                      "fioSup",
                      "fioMed",
                      "fioInf",
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ] +
                respostas
                    .map(
                      (e) => SizedBox(
                        width: kIsWeb ? MediaQuery.of(context).size.width / 3 : null,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                          child: Row(
                            children: [
                              Text(e[0]),
                              Spacer(),
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: TextField(
                                  controller: e[1],
                                  keyboardType: TextInputType.number,
                                  readOnly: justRead,
                                ),
                              ),
                              Spacer(),
                              Text(e[2]),
                              Spacer(),
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: TextField(
                                  controller: e[3],
                                  keyboardType: TextInputType.number,
                                  readOnly: justRead,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList() +
                [
                  //Espaçador
                  Spacer(),
                  //Continuação
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        "Desenhe no AutoCad todos os pontos apresentados na tabela do exercício anterior (A, B, C, A1 e C1). Ligue os pontos A, B e C e represente os ângulos horários. Ligue os pontos A – A1 e C – C1 e represente os seus ângulos horários. Utilize os ângulos horários e as distâncias para desenhar no AutoCad. Utilize o azimute verdadeiro de AB de 15º25'" +
                            '35" e as coordenadas absolutas de A seu número de matrícula.',
                        style: TextStyle(fontSize: 14),
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
                        ] /* +
                        ((certos.contains("acertou") ||
                                certos.contains("errou"))
                            ? [
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    certos = [];
                                    textoFinalizar = "";
                                    gerarEx();
                                    setState(() {});
                                  },
                                ),
                              ]
                            : []) */
                        +
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
