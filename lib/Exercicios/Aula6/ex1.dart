import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:topografia/Codigos/drawPoligono.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Contants/constantes.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/excel.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class A6EX1 extends StatefulWidget {
  A6EX1();

  @override
  _A6EX1 createState() => _A6EX1();
}

class _A6EX1 extends State<A6EX1> {
  _A6EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  int currentPage = 0;
  int currentPageBar = 0;
  int page_init = 0;
  int page_fim = 3;

  List<String> certos = [];

  List<String> pontos = [];

  List<ItemTabelaValues> dadosValues = [];
  int dadosValuesLenAns = 0;
  bool iniciou = false;

  Random? rdn;

  String questao = "Primeiro Levantamento Topográfico";

  double azmab = gmsToDoube("222°15'25\"");
  double decliMag = gmsToDoube("-22°15'25\"");

  Timer? t;

  Map<String, dynamic> respostas = {
    "numVertices": 0,
    "classe": "IP",
    "errAngMaxTolerado": 0.0,
    "sumAngExterno": 0.0,
    "anguloCorrecao": <double>[],
    "azimutes": <String, double>{},
    "drs": <String, double>{},
    "coordRel": <String, Offset>{},
    "errosDeFechamento": <String, double>{
      "x": 0.0,
      "y": 0.0,
    },
    "errosLinMax": 0.0,
    "coefCorrecaoLin": <String, double>{
      "x": 0.0,
      "y": 0.0,
    },
    "coordRelCorrigida": <String, Offset>{},
    "coordAbs": <String, Offset>{},
  };
  Map<String, dynamic> respostasAns = {};

  //TODO: Zerar tudo no fim
  /*respostas = {
      "numVertices": 3,
      "classe": "IIP",
      "errAngMaxTolerado": 0.007217,
      "sumAngExterno": 900.0,
      "anguloCorrecao": <double>[0.0, gmsToDoube("0°0'4\""), 0.0, 0.0, gmsToDoube("0°0'4\""), 0.0, gmsToDoube("0°0'5\""), 0.0],
      "azimutes": <String, double>{
        "AB": 200.0,
        "AA1": 207.51972222222224,
        "BC": 328.0308333333333,
        "CA": 29.014444444444443,
        "CC1": 200.97694444444446,
      },
      "drs": <String, double>{
        "AC": 236.75,
        "AB": 262.73,
        "AA1": 229.13,
        "BA": 262.73,
        "BC": 46.99,
        "CB": 47.18,
        "CA": 236.55,
        "CC1": 74.79,
      },
      "coordRel": <String, Offset>{
        "AB": Offset(-89.86, -246.89),
        "AA1": Offset(-105.87, -203.20),
        "BC": Offset(-24.93, 39.95),
        "CA": Offset(114.78, 206.95),
        "CC1": Offset(-26.77, -69.83),
      },
      "errosDeFechamento": <String, double>{
        "x": -0.01,
        "y": 0.01,
      },
      "errosLinMax": 7.01300934,
      "coefCorrecaoLin": <String, double>{
        "x": -0.000018299,
        "y": 0.000018299,
      },
      "coordRelCorrigida": <String, Offset>{
        "AB": Offset(-89.86, -246.89),
        "BC": Offset(-24.93, 39.95),
        "CA": Offset(114.79, 206.94),
      },
      "coordAbs": <String, Offset>{
        "AB": Offset(410.14, 253.11),
        "AA1": Offset(394.13, 296.80),
        "BC": Offset(385.21, 293.06),
        "CA": Offset(500, 500),
        "CC1": Offset(358.44, 223.23),
      },
    };*/
  /*dadosValues = [
        ItemTabelaValues(
          re: "C",
          estacao: "A",
          vante: "",
          descricao: "Piquete",
          alturaInst: 1.5,
          angHorizontal: 0,
          angZenital: 89.13,
          fioSup: 2.534,
          fioMed: 1.350,
          fioInf: 0.166,
        ),
        ItemTabelaValues(
          re: "C",
          estacao: "A",
          vante: "B",
          alturaInst: 1.5,
          fioInf: 0.136,
          fioSup: 2.764,
          fioMed: 1.450,
          angHorizontal: 350.984222,
          angZenital: 89.0766667,
          descricao: "Piquete",
        ),
        ItemTabelaValues(
          re: "C",
          estacao: "A",
          vante: "A1",
          alturaInst: 1.5,
          fioInf: 0.154,
          fioSup: 2.446,
          fioMed: 1.300,
          angHorizontal: 358.5052778,
          angZenital: 88.964444444,
          descricao: "Cerca",
        ),
        ItemTabelaValues(
          re: "A",
          estacao: "B",
          vante: "",
          alturaInst: 1.51,
          fioInf: 0.266,
          fioSup: 2.894,
          fioMed: 1.580,
          angHorizontal: 0,
          angZenital: 90.9186111,
          descricao: "Piquete",
        ),
        ItemTabelaValues(
          re: "A",
          estacao: "B",
          vante: "C",
          alturaInst: 1.51,
          fioInf: 0.765,
          fioSup: 1.235,
          fioMed: 1.000,
          angHorizontal: 308.03,
          angZenital: 90.9925,
          descricao: "Piquete",
        ),
        ItemTabelaValues(
          re: "B",
          estacao: "C",
          vante: "",
          alturaInst: 1.254,
          fioInf: 1.164,
          fioSup: 1.636,
          fioMed: 1.400,
          angHorizontal: 0,
          angZenital: 88.94194444,
          descricao: "Piquete",
        ),
        ItemTabelaValues(
          re: "B",
          estacao: "C",
          vante: "A",
          alturaInst: 1.254,
          fioInf: 0.317,
          fioSup: 2.686,
          fioMed: 1.500,
          angHorizontal: 240.9823,
          angZenital: 90.86888889,
          descricao: "Piquete",
        ),
        ItemTabelaValues(
          re: "B",
          estacao: "C",
          vante: "C1",
          alturaInst: 1.254,
          fioInf: 1.126,
          fioSup: 1.874,
          fioMed: 1.500,
          angHorizontal: 52.94611,
          angZenital: 89.4342,
          descricao: "Piquete",
        ),
      ]; */

  @override
  void initState() {
    super.initState();
    rdn = Random(DateTime.now().microsecondsSinceEpoch);

    iniciar();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void iniciar() async {
    if (!kIsWeb) {
      Future.delayed(
        Duration(milliseconds: 2),
        () async {
          if (user == null) {
            iniciar();
            return;
          }
          try {
            Directory tempDir = await getTemporaryDirectory();
            String dataSave = tempDir.path + "/dadosA6E1.json";
            String tableSave = tempDir.path + "/TableA6E1.json";

            dadosValues = getTableSave(tableSave);

            File dados = File(dataSave);

            String content = await dados.readAsString();
            respostas = jsonDecode(content);

            Map<String, Offset> dadosMudados = {};
            respostas['coordRel'].forEach((key, value) {
              dadosMudados[key] = Offset(value[0], value[1]);
            });
            respostas['coordRel'] = dadosMudados;

            dadosMudados = {};
            respostas['coordRelCorrigida'].forEach((key, value) {
              dadosMudados[key] = Offset(value[0], value[1]);
            });
            respostas['coordRelCorrigida'] = dadosMudados;

            dadosMudados = {};
            respostas['coordAbs'].forEach((key, value) {
              dadosMudados[key] = Offset(value[0], value[1]);
            });
            respostas['coordAbs'] = dadosMudados;
          } catch (e) {
            dadosValues = [];
            respostas = {
              "numVertices": 0,
              "classe": "IP",
              "errAngMaxTolerado": 0.0,
              "sumAngExterno": 0.0,
              "anguloCorrecao": <double>[],
              "azimutes": <String, double>{},
              "drs": <String, double>{},
              "coordRel": <String, Offset>{},
              "errosDeFechamento": <String, double>{
                "x": 0.0,
                "y": 0.0,
              },
              "errosLinMax": 0.0,
              "coefCorrecaoLin": <String, double>{
                "x": 0.0,
                "y": 0.0,
              },
              "coordRelCorrigida": <String, Offset>{},
              "coordAbs": <String, Offset>{},
            };
          }
          iniciou = true;
          dadosValuesLenAns = dadosValues.length;
          setState(() {});
        },
      );
    } else {
      iniciou = true;
      setState(() {});
    }
  }

  void save() async {
    if (!kIsWeb) {
      try {
        Directory tempDir = await getTemporaryDirectory();
        String tableSave = tempDir.path + "/TableA6E1.json";
        String dataSave = tempDir.path + "/dadosA6E1.json";

        if (dadosValues.length != dadosValuesLenAns) {
          dadosValuesLenAns = dadosValues.length;

          respostas = {
            "numVertices": respostas["numVertices"],
            "classe": respostas["classe"],
            "errAngMaxTolerado": 0.0,
            "sumAngExterno": 0.0,
            "anguloCorrecao": <double>[],
            "azimutes": <String, double>{},
            "drs": <String, double>{},
            "coordRel": <String, Offset>{},
            "errosDeFechamento": <String, double>{
              "x": 0.0,
              "y": 0.0,
            },
            "errosLinMax": 0.0,
            "coefCorrecaoLin": <String, double>{
              "x": 0.0,
              "y": 0.0,
            },
            "coordRelCorrigida": <String, Offset>{},
            "coordAbs": <String, Offset>{},
          };
        }

        setTableSave(tableSave, dadosValues);

        File arq = File(dataSave);

        Map dadosMudados = {};
        respostas['coordRel'].forEach((key, value) {
          dadosMudados[key] = [value.dx, value.dy];
        });
        respostas['coordRel'] = dadosMudados;

        dadosMudados = {};
        respostas['coordRelCorrigida'].forEach((key, value) {
          dadosMudados[key] = [value.dx, value.dy];
        });
        respostas['coordRelCorrigida'] = dadosMudados;

        dadosMudados = {};
        respostas['coordAbs'].forEach((key, value) {
          dadosMudados[key] = [value.dx, value.dy];
        });
        respostas['coordAbs'] = dadosMudados;

        //Salva os dados
        String content = await jsonEncode(respostas);
        arq.writeAsString(content);

        //Retorna ao normal
        dadosMudados = {};
        respostas['coordRel'].forEach((key, value) {
          dadosMudados[key] = Offset(value[0], value[1]);
        });
        respostas['coordRel'] = dadosMudados;

        dadosMudados = {};
        respostas['coordRelCorrigida'].forEach((key, value) {
          dadosMudados[key] = Offset(value[0], value[1]);
        });
        respostas['coordRelCorrigida'] = dadosMudados;

        dadosMudados = {};
        respostas['coordAbs'].forEach((key, value) {
          dadosMudados[key] = Offset(value[0], value[1]);
        });
        respostas['coordAbs'] = dadosMudados;
      } catch (e) {
        print(e);
      }
    }
  }

  void finalizarTentativa() async {
    /*int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    respostas['numVertices'] = dadosValues.length;

    double erroAngularMax = 0;
    if (respostas['classe'] == "IP") {
      erroAngularMax = 0.001666667 * sqrt(respostas["numVertices"]);
    } else if (respostas['classe'] == "IIP") {
      erroAngularMax = 0.004166666667 * sqrt(respostas["numVertices"]);
    } else if (respostas['classe'] == "IIIP") {
      erroAngularMax = 0.005555555 * sqrt(respostas["numVertices"]);
    } else if (respostas['classe'] == "IVP") {
      erroAngularMax = 0.0111111111 * sqrt(respostas["numVertices"]);
    } else if (respostas['classe'] == "VP") {
      erroAngularMax = 0.05 * sqrt(respostas["numVertices"]);
    }

    double somaAngExt = 180.0 * (respostas["numVertices"] + 2);
    double erroAngular = somaAngExt - getSumAng(respostas['anguloCorrecao'], dadosValues);
    bool acertouAngHor = true;
    if (erroAngular > erroAngularMax) {
      acertouAngHor = false;
    }

    List<double> drs = [];
    bool acertouDr = true;

    for (int i = 0; i < dadosValues.length; i++) {
      double m = dadosValues[i].fioSup! - dadosValues[i].fioInf!;

      double dr = m * constAparelho * pow(sin(pi * dadosValues[i].angHorizontal! / 180), 2);

      drs.add(dr);

      double drCalc = respostas['distReduzida'][i];

      bool usou_tolerancia = (sqrt(pow(drCalc - dr, 2)) <= 0.5);

      if (!((drCalc == dr) || usou_tolerancia)) {
        acertouDr = false;
      }
    }

    certos.add(acertouDr && acertouAngHor ? "acertou" : "errou");
    Map dados = {
      "acertou": acertouDr && acertouAngHor,
      "acertouDr": acertouDr,
      "acertouAngHor": acertouAngHor,
    };

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set(
      {
        'dados': dados,
      },
    );

    setState(() {});*/
  }

  Widget exercicio(int index) {
    try {
      if (index == 0) {
        return enunciadoTabela(
          (dados) {
            dadosValues = mapTabelaToListTabela(dados[1]);

            int vertices = 0;

            for (int i = 0; i < dadosValues.length; i++) {
              if (isAngHorizontal(i, dadosValues)) {
                vertices += 1;
              }
            }
            respostas["numVertices"] = vertices;
            save();
          },
          dadosValues,
        );
      } else if (index == 1) {
        if (respostas["numVertices"] < 3) {
          return Center(
            child: Text(
              "A poligonal fechada precisa ter no mínimo 3 vértices, confira sua tabela!",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        return tolAngular(
          respostas["numVertices"],
          (classe, erroMax) {
            respostas["classe"] = classe;
            respostas["errAngMaxTolerado"] = erroMax;
            save();
          },
          respostas["classe"],
          respostas["errAngMaxTolerado"],
        );
      } else if (index == 2) {
        double erroMaxCalc = classesLevantamneto[respostas["classe"]]!(respostas["numVertices"]);
        if (respostas["classe"] == "" || respostas["errAngMaxTolerado"] == 0) {
          return Center(
            child: Text(
              "Você deve definir a classe do projeto e calcular o erro angular máximo no item Tol. Angular!",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        if ((erroMaxCalc - respostas["errAngMaxTolerado"]).abs() > 0.00005) {
          return Center(
            child: Text(
              "O erro máximo para a classe ${respostas["classe"]} não é ${toGrauMinSec(respostas["errAngMaxTolerado"])}. Corrija no item Tol. Angular!",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        return erroAngular(
          respostas["classe"],
          respostas["errAngMaxTolerado"],
          respostas["numVertices"],
          respostas["sumAngExterno"],
          respostas["anguloCorrecao"],
          dadosValues,
          (sumAngExterno, anguloCorrecao) {
            respostas["sumAngExterno"] = sumAngExterno;
            respostas["anguloCorrecao"] = anguloCorrecao;
            save();
          },
        );
      } else if (index == 3) {
        if (respostas["anguloCorrecao"].length == 0) {
          return Center(
            child: Text(
              "O item Erro Angular ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }
        double angSum = getSumAng(respostas["anguloCorrecao"], dadosValues);

        if (toGrauMinSec(angSum) != toGrauMinSec(respostas['sumAngExterno'])) {
          return Center(
            child: Text(
              "O erro angular não foi corrigido da forma correta no item Erro angular, volte ao item e corrija da forma correta!",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        return azimute(
          respostas["anguloCorrecao"],
          dadosValues,
          respostas["azimutes"],
          (azimutes) {
            respostas["azimutes"] = azimutes;

            for (ItemTabelaValues item in dadosValues) {
              String estacao = item.estacao!;
              String vante = item.vante!;
              String key = estacao + vante;

              if (respostas["azimutes"].containsKey(key)) {
                item.azimute = respostas["azimutes"][key];
              }
            }

            save();
          },
        );
      } else if (index == 4) {
        if (respostas['azimutes'].length == 0) {
          return Center(
            child: Text(
              "O item Azimute ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }
        Map<String, double> azReais = getAzFromItemTabelaValue(200, dadosValues);

        if (azReais.containsKey("erro")) {
          return Center(
            child: Text(
              "Algum passo anterior não está correto, talvez algum dos angulos horizontais está como 0!",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        Map<String, bool> certos = {};
        bool errou = false;
        List<Widget> items = [];

        azReais.forEach((key, value) {
          bool tolerancia = (respostas["azimutes"][key] - value).abs() <= 0.5;
          certos[key] = tolerancia;
          if (!tolerancia) {
            errou = true;
            items.add(
              Text(
                "Azimute de $key: Errado = ${toGrauMinSec(respostas["azimutes"][key])} (${toGrauMinSec(value)})\n",
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            items.add(
              Text("Azimute de $key: Certo = ${toGrauMinSec(respostas["azimutes"][key])}\n"),
            );
          }
        });

        if (errou) {
          items.add(
            Divider(color: Cores.preto),
          );
          items.add(
            Text(
              "Alguns azimutes estão errados, volte ao passo Azimute e corrija os erros!",
              style: TextStyle(
                color: Cores.primaria,
                fontSize: 18,
              ),
            ),
          );
          return Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
          );
        }

        return dr(
          respostas['drs'],
          dadosValues,
          (drs) {
            respostas['drs'] = drs;
            save();
          },
        );
      } else if (index == 5) {
        if (respostas['drs'].length == 0) {
          return Center(
            child: Text(
              "O item Dr ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        bool errou = false;

        List<Widget> items = [];

        for (ItemTabelaValues item in dadosValues) {
          String drKey = "";
          if (item.vante == "") {
            drKey = item.estacao! + item.re!;
          } else {
            drKey = item.estacao! + item.vante!;
          }

          double dr = toFour(constAparelho * (item.fioSup! - item.fioInf!) * pow(sin(item.angZenital! * pi / 180), 2));

          if (!respostas['drs'].containsKey(drKey)) {
            return Center(
              child: Text(
                "Algum passo anterior não está correto, talvez algum dos angulos horizontais está como 0!",
                style: TextStyle(fontSize: 22),
              ),
            );
          }

          bool tolerancia = (respostas['drs'][drKey] - dr).abs() <= 0.5;

          if (!tolerancia) {
            errou = true;
            items.add(
              Text(
                "A distância reduzida entre $drKey está errada = ${toFour(respostas["drs"][drKey])} m (${toFour(dr)} m)\n",
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            items.add(
              Text("A distância reduzida entre $drKey está certa = ${toFour(respostas["drs"][drKey])} m\n"),
            );
          }
        }

        if (errou) {
          items.add(
            Divider(color: Cores.preto),
          );
          items.add(
            Text(
              "Algumas distâncias reduzidas estão erradas, volte ao passo Dr e corrija os erros!",
              style: TextStyle(
                color: Cores.primaria,
                fontSize: 18,
              ),
            ),
          );
          return Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
          );
        }

        return coords(
          respostas['drs'],
          respostas['azimutes'],
          respostas['coordRel'],
          dadosValues,
          (coordRel) {
            respostas['coordRel'] = coordRel;
            save();
          },
        );
      } else if (index == 6) {
        if (respostas['coordRel'].length == 0) {
          return Center(
            child: Text(
              "O item Coordenadas ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }
        List<String> pontos = [];

        for (ItemTabelaValues item in dadosValues) {
          if (!pontos.contains(item.estacao!)) {
            pontos.add(item.estacao!);
          }
        }

        List<Widget> items = [];
        bool errou = false;

        for (ItemTabelaValues item in dadosValues) {
          if (item.vante != "") {
            String keyRe = "";
            String keyVante = "";

            if (pontos.contains(item.vante!)) {
              keyVante = item.estacao! + item.vante!;
              keyRe = item.vante! + item.estacao!;
            } else {
              keyVante = item.estacao! + item.vante!;
              keyRe = item.estacao! + item.vante!;
            }

            if (!respostas['drs'].containsKey(keyVante) || !respostas['drs'].containsKey(keyRe)) {
              return Center(
                child: Text(
                  "Algum passo anterior não está correto, talvez algum dos angulos horizontais está como 0!",
                  style: TextStyle(fontSize: 22),
                ),
              );
            }

            double x = toTwo(((respostas['drs'][keyVante] + respostas['drs'][keyRe]) / 2) * sin(respostas['azimutes'][keyVante] * pi / 180));
            double y = toTwo(((respostas['drs'][keyVante] + respostas['drs'][keyRe]) / 2) * cos(respostas['azimutes'][keyVante] * pi / 180));

            double _x = toTwo(respostas['coordRel'][keyVante].dx);
            double _y = toTwo(respostas['coordRel'][keyVante].dy);

            String texto = "Em $keyVante: ";
            bool tolerancia = (x - _x).abs() <= 0.5;
            if (!tolerancia) {
              errou = true;
              texto += "X errado = $_x ($x) ";
            } else {
              texto += "X certo = $_x ";
            }

            tolerancia = (y - _y).abs() <= 0.5;
            if (!tolerancia) {
              errou = true;
              texto += "Y errado = $_y ($y)";
            } else {
              texto += "X certo = $_y";
            }
            items.add(
              Text(
                texto + "\n",
                style: texto.contains("errado") ? TextStyle(color: Colors.red) : null,
              ),
            );
          }
        }

        if (errou) {
          items.add(
            Divider(color: Cores.preto),
          );
          items.add(
            Text(
              "Algumas coordenadas estão erradas, vá em Coordenadas e as corrija!",
              style: TextStyle(
                color: Cores.primaria,
                fontSize: 18,
              ),
            ),
          );
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          );
        }

        return erroLinear(
          dadosValues,
          respostas['errosDeFechamento'],
          respostas["errosLinMax"],
          respostas["coefCorrecaoLin"],
          respostas['coordRel'],
          respostas['classe'],
          respostas["drs"],
          respostas['coordRelCorrigida'],
          (errFec, errLMax, coefiCorre, coordCor) {
            respostas['errosDeFechamento'] = errFec;
            respostas["errosLinMax"] = errLMax;
            respostas['coordRelCorrigida'] = coordCor;
            respostas['coefCorrecaoLin'] = coefiCorre;
            save();
          },
        );
      } else if (index == 7) {
        if (respostas['coordRelCorrigida'].length == 0) {
          return Center(
            child: Text(
              "O item Erro Linear ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }
        List<String> pontos = [];
        List<String> keysPontos = [];

        for (ItemTabelaValues item in dadosValues) {
          if (!pontos.contains(item.estacao!) && item.vante! != "") {
            pontos.add(item.estacao!);
            keysPontos.add(item.estacao! + item.vante!);
          }
        }

        double ex = 0;
        double ey = 0;
        double perimetro = 0;
        for (ItemTabelaValues item in dadosValues) {
          String vante = item.estacao! + item.vante!;
          String re = item.vante! + item.estacao!;

          if (pontos.contains(item.vante!)) {
            if (!respostas['coordRel'].containsKey(vante) || !respostas['drs'].containsKey(vante) || !respostas['drs'].containsKey(re)) {
              return Center(
                child: Text(
                  "Algum passo anterior não está correto, talvez algum dos angulos horizontais está como 0!",
                  style: TextStyle(fontSize: 22),
                ),
              );
            }

            ex += respostas['coordRel'][vante].dx;
            ey += respostas['coordRel'][vante].dy;
            perimetro += (respostas["drs"][vante] + respostas["drs"][re]) / 2;
          }
        }

        List<Widget> items = [];
        bool errou = false;

        bool tolerancia = (ex - (respostas['errosDeFechamento']['x'] ?? 0)).abs() <= 0.5;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "O erro linear de fechamento em x calculado está errado = ${respostas['errosDeFechamento']['x'] ?? 0} ($ex)",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          items.add(Text("O erro linear de fechamento em x calculado está certo = ${respostas['errosDeFechamento']['x'] ?? 0}"));
        }

        tolerancia = (ey - (respostas['errosDeFechamento']['y'] ?? 0)).abs() <= 0.5;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "O erro linear de fechamento em y calculado está errado = ${respostas['errosDeFechamento']['y'] ?? 0} ($ey)",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          items.add(Text("O erro linear de fechamento em y calculado está certo = ${respostas['errosDeFechamento']['y'] ?? 0}"));
        }

        double limMax = toSix(tolLinearMax[respostas['classe']]!(perimetro / 1000));
        tolerancia = (limMax - (respostas['errosLinMax'] ?? 0)).abs() <= 0.5;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "O limite máximo tolerado está errado = ${respostas['errosLinMax'] ?? 0} ($limMax)",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          items.add(Text("O limite máximo tolerado está certo = ${respostas['errosLinMax'] ?? 0}"));
        }

        double cx = toSix(ex / perimetro);
        tolerancia = (cx - (respostas['coefCorrecaoLin']['x'] ?? 0)).abs() <= 0.5;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "O coeficiente de correção em X está errado = ${respostas['coefCorrecaoLin']['x'] ?? 0} ($cx)",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          items.add(Text("O coeficiente de correção em X está certo = ${respostas['coefCorrecaoLin']['x'] ?? 0}"));
        }

        double cy = toSix(ey / perimetro);
        tolerancia = (cy - (respostas['coefCorrecaoLin']['y'] ?? 0)).abs() <= 0.5;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "O coeficiente de correção em Y está errado = ${respostas['coefCorrecaoLin']['y'] ?? 0} ($cy)",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          items.add(Text("O coeficiente de correção em Y está certo = ${respostas['coefCorrecaoLin']['y'] ?? 0}"));
        }

        double sumX = 0;
        double sumY = 0;

        respostas['coordRelCorrigida'].forEach((key, value) {
          if (keysPontos.contains(key)) {
            sumX += value.dx;
            sumY += value.dy;
          }
        });

        tolerancia = (sumX).abs() <= 0.0005;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "A correção das coordenadas em X esta errada",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        tolerancia = (sumY).abs() <= 0.0005;
        if (!tolerancia) {
          errou = true;
          items.add(
            Text(
              "A correção das coordenadas em Y esta errada",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (errou) {
          items.add(
            Divider(color: Cores.preto),
          );
          items.add(
            Text(
              "Algumas das correções estão erradas, volte ao item Erro Linear!",
              style: TextStyle(
                color: Cores.primaria,
                fontSize: 18,
              ),
            ),
          );
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          );
        }

        return coordAbsolutas(
          dadosValues,
          respostas['coordRel'],
          respostas['coordRelCorrigida'],
          respostas['coordAbs'],
          (coordAbs) {
            respostas['coordAbs'] = coordAbs;
            save();
          },
        );
      } else if (index == 8) {
        if (respostas['coordAbs'].length == 0) {
          return Center(
            child: Text(
              "O item Coordenadas Absolutas ainda não foi finalizado",
              style: TextStyle(fontSize: 22),
            ),
          );
        }
        List<String> pontos = [];

        for (ItemTabelaValues item in dadosValues) {
          if (!pontos.contains(item.estacao!)) {
            pontos.add(item.estacao!);
          }
        }

        double dif = 0;

        respostas['coordAbs'].forEach((key, value) {
          dif = max(value.dx, max(value.dy, dif));
        });

        bool errou = false;
        bool errou0 = false;

        for (ItemTabelaValues item in dadosValues) {
          if (pontos.contains(item.estacao!) && item.vante != "") {
            String key = item.estacao! + item.vante!;
            String keyAns = item.re! + item.estacao!;

            Offset rel = (respostas['coordRelCorrigida'][key] ?? respostas['coordRel'][key] ?? Offset.zero);
            Offset abs = (respostas['coordAbs'][key] ?? Offset.zero);
            Offset absAns = (respostas['coordAbs'][keyAns] ?? Offset.zero);

            Offset dif = abs - absAns;

            if (abs.dx < 0 || abs.dy < 0) {
              errou0 = true;
            }

            if ((dif.distance - rel.distance).abs() > 0.5) {
              errou = true;
            }
          }
        }

        List<Widget> items = [];
        if (errou) {
          items.add(
            Divider(color: Cores.preto),
          );
          items.add(
            Text(
              errou0 ? "Algum ponto continua menor que 0" : "As coordenadas absolutas não estão corretas",
              style: TextStyle(
                color: Cores.primaria,
                fontSize: 18,
              ),
            ),
          );
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          );
        }

        return toTable(
          dadosValues,
          respostas,
          user!,
          () {
            save();
          },
        );
      } else {
        return Container();
      }
    } catch (e) {
      return Center(
        child: Text(
          "Ocorreu um erro gerando o index ($e)",
          style: TextStyle(fontSize: 22),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //currentPage = 0;
    //currentPageBar = 0;
    //page_init = 0;
    //page_fim = 3;

    /*respostas = {
      "numVertices": 3,
      "classe": "IIP",
      "errAngMaxTolerado": 0.007217,
      "sumAngExterno": 900.0,
      "anguloCorrecao": <double>[0.0, gmsToDoube("0°0'4\""), 0.0, 0.0, gmsToDoube("0°0'4\""), 0.0, gmsToDoube("0°0'5\""), 0.0],
      "azimutes": <String, double>{
        "AB": 200.0,
        "AA1": 207.51972222222224,
        "BC": 328.0308333333333,
        "CA": 29.014444444444443,
        "CC1": 200.97694444444446,
      },
      "drs": <String, double>{
        "AC": 236.75,
        "AB": 262.73,
        "AA1": 229.13,
        "BA": 262.73,
        "BC": 46.99,
        "CB": 47.18,
        "CA": 236.55,
        "CC1": 74.79,
      },
      "coordRel": <String, Offset>{
        "AB": Offset(-89.86, -246.89),
        "AA1": Offset(-105.87, -203.20),
        "BC": Offset(-24.93, 39.95),
        "CA": Offset(114.78, 206.95),
        "CC1": Offset(-26.77, -69.83),
      },
      "errosDeFechamento": <String, double>{
        "x": -0.01,
        "y": 0.01,
      },
      "errosLinMax": 7.01300934,
      "coefCorrecaoLin": <String, double>{
        "x": -0.000018299,
        "y": 0.000018299,
      },
      "coordRelCorrigida": <String, Offset>{
        "AB": Offset(-89.86, -246.89),
        "BC": Offset(-24.93, 39.95),
        "CA": Offset(114.79, 206.94),
      },
      "coordAbs": <String, Offset>{
        "AB": Offset(410.14, 253.11),
        "AA1": Offset(394.13, 296.80),
        "BC": Offset(385.21, 293.06),
        "CA": Offset(500, 500),
        "CC1": Offset(358.44, 223.23),
      },
    };
    dadosValues = [
      ItemTabelaValues(
        re: "C",
        estacao: "A",
        vante: "",
        descricao: "Piquete",
        alturaInst: 1.5,
        angHorizontal: 0,
        angZenital: 89.13,
        fioSup: 2.534,
        fioMed: 1.350,
        fioInf: 0.166,
      ),
      ItemTabelaValues(
        re: "C",
        estacao: "A",
        vante: "B",
        alturaInst: 1.5,
        fioInf: 0.136,
        fioSup: 2.764,
        fioMed: 1.450,
        angHorizontal: 350.984222,
        angZenital: 89.0766667,
        descricao: "Piquete",
      ),
      ItemTabelaValues(
        re: "C",
        estacao: "A",
        vante: "A1",
        alturaInst: 1.5,
        fioInf: 0.154,
        fioSup: 2.446,
        fioMed: 1.300,
        angHorizontal: 358.5052778,
        angZenital: 88.964444444,
        descricao: "Cerca",
      ),
      ItemTabelaValues(
        re: "A",
        estacao: "B",
        vante: "",
        alturaInst: 1.51,
        fioInf: 0.266,
        fioSup: 2.894,
        fioMed: 1.580,
        angHorizontal: 0,
        angZenital: 90.9186111,
        descricao: "Piquete",
      ),
      ItemTabelaValues(
        re: "A",
        estacao: "B",
        vante: "C",
        alturaInst: 1.51,
        fioInf: 0.765,
        fioSup: 1.235,
        fioMed: 1.000,
        angHorizontal: 308.03,
        angZenital: 90.9925,
        descricao: "Piquete",
      ),
      ItemTabelaValues(
        re: "B",
        estacao: "C",
        vante: "",
        alturaInst: 1.254,
        fioInf: 1.164,
        fioSup: 1.636,
        fioMed: 1.400,
        angHorizontal: 0,
        angZenital: 88.94194444,
        descricao: "Piquete",
      ),
      ItemTabelaValues(
        re: "B",
        estacao: "C",
        vante: "A",
        alturaInst: 1.254,
        fioInf: 0.317,
        fioSup: 2.686,
        fioMed: 1.500,
        angHorizontal: 240.9823,
        angZenital: 90.86888889,
        descricao: "Piquete",
      ),
      ItemTabelaValues(
        re: "B",
        estacao: "C",
        vante: "C1",
        alturaInst: 1.254,
        fioInf: 1.126,
        fioSup: 1.874,
        fioMed: 1.500,
        angHorizontal: 52.94611,
        angZenital: 89.4342,
        descricao: "Piquete",
      ),
    ];*/

    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.table_chart_outlined),
        label: "Tabela",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.incomplete_circle),
        label: "Tol. Ângular",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.architecture),
        label: "Erro Ângular",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.north),
        label: "Azimute",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.straighten_outlined),
        label: "Dr",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.my_location_sharp),
        label: "Coordenadas",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.filter_list_off_rounded),
        label: "Erro Linear",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.grain),
        label: "Coordenadas\n  Absolutas",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.format_shapes),
        label: "Planilha",
      ),
    ];

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

    if (iniciou) {
      save();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores.primaria,
        title: Text("Exercício 1"),
        elevation: 0,
      ),
      bottomNavigationBar: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 3,
          child: BottomNavigationBar(
            onTap: (index) {
              currentPage += index - currentPageBar;

              currentPage = min(max(0, currentPage), items.length - 1);

              page_init = currentPage - 1;

              if (page_init < 0) {
                page_init = 0;
                currentPageBar = 0;
              } else if (page_init == items.length - 2) {
                currentPageBar = 2;
                page_init -= 1;
              } else {
                currentPageBar = 1;
              }

              page_fim = page_init + 3;

              setState(() {});
            },
            backgroundColor: Cores.primaria,
            currentIndex: currentPageBar,
            selectedItemColor: Cores.secundaria,
            items: items.getRange(page_init, page_fim).toList(),
          ),
        ),
      ),
      body: iniciou
          ? Container(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: exercicio(currentPage),
              ),
            )
          : Container(),
    );
  }
}

double getSumAng(List angCorrecao, List<ItemTabelaValues> dados) {
  double sum = 0;

  for (int i = 0; i < angCorrecao.length; i++) {
    if (isAngHorizontal(i, dados)) {
      sum += angCorrecao[i] + dados[i].angHorizontal!;
    }
  }

  return sum;
}

bool isAngHorizontal(int index, List<ItemTabelaValues> dados) {
  if (index < dados.length) {
    if (dados[index].vante == "") {
      return false;
    }

    String vante = dados[index].vante!;

    for (ItemTabelaValues item in dados) {
      if (vante == item.re) {
        return true;
      }
    }
  }
  return false;
}

Widget enunciadoTabela(Function on_finish, List<ItemTabelaValues> dados) {
  Map<String, Map> dadosToDados = listTabelaToMapTabela(dados);

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: Column(
          children: [
            Text(
              """Em campo realize um levantamento topográfico com o teodolito e preenha a tabela a baixo.

  Para este exercício considere:
    - Finalidade: Apoio topográfico para projetos básicos e obras de engenharia;
    - AZm(AB) 222°15'25\";
    - Declinação magnética -22°15'25\";
    - Xa = 500,00 e Ya = 500,00.""",
            ),
            SizedBox(height: 10),
            Expanded(
              //height: MediaQuery.of(ctx).size.height * 0.5,
              child: TabelaCampo(
                dadosValues: dadosToDados,
                celulaHeight: 30,
                celulaWidth: 76,
                tabelaEstatica: false,
                onDataChange: (val) {
                  on_finish(val);
                },
                titulos: {
                  "estacao": Text(
                    "Estação",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "re": Text(
                    "Ré",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "vante": Text(
                    "Vante",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "descricao": Text(
                    "Descrição",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "alturaInst": Text(
                    "Alt. Instrumento",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "angHorizontal": Text(
                    "Ang. Horizontal",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "angZenital": Text(
                    "Ang. Zenital",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "fioInf": Text(
                    "Fio Inferior",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "fioMed": Text(
                    "Fio Médio",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  "fioSup": Text(
                    "Fio Superior",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
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
                  "fioInf",
                  "fioMed",
                  "fioSup",
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget tolAngular(int ladosPoligonal, Function on_finish, String _classe, double _erroMax) {
  String classe = _classe == "" ? "IP" : _classe;
  double erroMax = _erroMax;

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: Column(
          children: [
            Text(
              """Determine o erro angular para a poligonal formada pela tabela do item anterior:

  Sua poligonal ficou com $ladosPoligonal vertices.""",
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Classe do levantamento:"),
                SizedBox(width: 10),
                DropdownButton(
                  value: classe,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: classesLevantamneto.entries.map(
                    (e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.key),
                      );
                    },
                  ).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      classe = newValue!;
                      on_finish(classe, erroMax);
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
            Spacer(flex: 1),
            Row(
              children: [
                Text(
                  "Digite o erro ângular\nmáximo permitido: ",
                ),
                Spacer(),
                TextGMSField(
                  width: 160,
                  height: 56,
                  angleInit: erroMax,
                  decimalDigits: true,
                  onChange: (val) {
                    erroMax = val;

                    on_finish(classe, erroMax);
                    setState(() {});
                  },
                ),
                Spacer(),
              ],
            ),
            Spacer(flex: 10),
          ],
        ),
      );
    },
  );
}

Widget erroAngular(String _classe, double _erroMax, int _tableVertices, double _sumAngExterno, List _anguloCorrecao, List<ItemTabelaValues> _dadosValues, Function on_finish) {
  double erroMaxCalc = classesLevantamneto[_classe]!(_tableVertices);

  String classe = _classe;
  double sumAngExterno = _sumAngExterno;
  List anguloCorrecao = _anguloCorrecao;
  List<ItemTabelaValues> dadosValues = _dadosValues;

  while (anguloCorrecao.length != dadosValues.length) {
    if (anguloCorrecao.length < dadosValues.length) {
      anguloCorrecao.add(0.0);
    } else if (anguloCorrecao.length > dadosValues.length) {
      anguloCorrecao.removeLast();
    }
  }

  return StatefulBuilder(
    builder: (ctx, setState) {
      List<Widget> items = [];

      for (ItemTabelaValues item in dadosValues) {
        int index = dadosValues.indexOf(item);
        if (isAngHorizontal(index, dadosValues)) {
          items.add(
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              decoration: BoxDecoration(
                color: items.length % 2 == 0 ? Cores.primaria : Cores.terciaria,
                border: Border.all(color: Cores.preto),
              ),
              width: MediaQuery.of(ctx).size.width - 20,
              child: Row(
                children: [
                  Container(
                    width: 1,
                    height: 46,
                    color: Cores.preto,
                  ),
                  Spacer(),
                  FittedBox(
                    child: Text(
                      item.re! + "-" + item.estacao! + "-" + item.vante!,
                      textAlign: TextAlign.center,
                      //style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 1,
                    height: 46,
                    color: Cores.preto,
                  ),
                  SizedBox(
                    height: 46,
                    width: 120,
                    child: TextGMSField(
                      angleInit: anguloCorrecao[index],
                      isNegative: true,
                      onChange: (value) {
                        anguloCorrecao[index] = value;
                        on_finish(sumAngExterno, anguloCorrecao);
                        setState(() {});
                      },
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 1,
                    height: 46,
                    color: Cores.preto,
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      toGrauMinSec((item.angHorizontal! + anguloCorrecao[index])),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(ctx).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                """Determine a soma dos ângulos externos da poligonal e após isso distribua o erro angular nos vértices do poligono.""",
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Soma dos ângulos externos\nda poligonal (n = $_tableVertices):",
                  ),
                  Spacer(),
                  TextGMSField(
                    width: 160,
                    height: 56,
                    angleInit: sumAngExterno,
                    maxValue: 180 * (_tableVertices + 3),
                    decimalDigits: true,
                    onChange: (val) {
                      sumAngExterno = val;
                      on_finish(sumAngExterno, anguloCorrecao);
                      setState(() {});
                    },
                  ),
                  Spacer(),
                ],
              ),
              Text(
                """A tabela a baixo representa as leituras realizadas, na ordem Ré-Estação-Vante:\n""",
              ),
              SizedBox(
                width: MediaQuery.of(ctx).size.width - 20,
                height: MediaQuery.of(ctx).size.height * 0.4,
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    if (index == items.length) {
                      return Column(
                        children: [
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                """Ângulo total: ${toGrauMinSec(getSumAng(anguloCorrecao, dadosValues))}""",
                                textAlign: TextAlign.end,
                              ),
                            ],
                          )
                        ],
                      );
                    }
                    return items[index];
                  },
                  itemCount: items.length + 1,
                ),
              ),
              Text(
                "Erro: ${toGrauMinSec(sumAngExterno)} - ${toGrauMinSec(getSumAng(List.generate(anguloCorrecao.length, (index) => 0.0).toList(), dadosValues))} = ${toGrauMinSec(sumAngExterno - getSumAng(List.generate(dadosValues.length, (index) => 0.0), dadosValues))}",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: (erroMaxCalc.abs() <
                          (sumAngExterno -
                                  getSumAng(
                                    List.generate(dadosValues.length, (index) => 0.0),
                                    dadosValues,
                                  ))
                              .abs())
                      ? Colors.red
                      : Cores.preto,
                ),
              ),
              SizedBox(height: 15),
              Text(
                (erroMaxCalc.abs() <
                        (sumAngExterno -
                                getSumAng(
                                  List.generate(dadosValues.length, (index) => 0.0),
                                  dadosValues,
                                ))
                            .abs())
                    ? "O erro está muito alto para a classe $classe, o levantamento deve ser refeito!"
                    : "",
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget azimute(List angCorrecao, List<ItemTabelaValues> dadosValues, Map azimutes, Function on_finish) {
  int index = 0;
  int azimuteAB = 0;

  return StatefulBuilder(
    builder: (ctx, setState) {
      try {
        List<ItemTabelaValues> dadosAzimutes = List.generate(dadosValues.length, (index) {
          double dr = constAparelho * (dadosValues[index].fioSup! - dadosValues[index].fioInf!) * pow(sin(dadosValues[index].angZenital! * pi / 180), 2);
          return ItemTabelaValues(
            re: dadosValues[index].re,
            estacao: dadosValues[index].estacao,
            vante: dadosValues[index].vante,
            angHorizontal: dadosValues[index].angHorizontal,
            azimute: azimutes[dadosValues[index].estacao! + dadosValues[index].vante!],
            distRed: dr,
          );
        });

        List<List<Offset>> points = gerarPoligonoByTableValues(dadosValues: dadosAzimutes);

        List<ItemTabela> dadosExibir = [];

        for (ItemTabelaValues item in dadosValues) {
          int index = dadosValues.indexOf(item);
          if (dadosValues[index].vante == "") {
            continue;
          }

          String pontoKey = item.estacao! + item.vante!;

          if (pontoKey == "AB") {
            azimuteAB = index;
          }

          if (index == azimuteAB) {
            dadosExibir.add(
              ItemTabela(
                estacao: Text(dadosValues[index].estacao!),
                vante: Text(dadosValues[index].vante!),
                azimute: Text(toGrauMinSec(azimutes[pontoKey] ?? 0)),
                angHorizontal: Text(toGrauMinSec(dadosValues[index].angHorizontal!)),
              ),
            );
            continue;
          }

          dadosExibir.add(
            ItemTabela(
              estacao: Text(dadosValues[index].estacao!),
              vante: Text(dadosValues[index].vante!),
              azimute: TextGMSField(
                angleInit: azimutes[pontoKey] ?? 0,
                onChange: (val) {
                  azimutes[pontoKey] = val;
                  on_finish(azimutes);
                  setState(() {});
                },
              ),
              angHorizontal: Text(toGrauMinSec(dadosValues[index].angHorizontal!)),
            ),
          );
        }

        Column tabela = Column(
          children: <Widget>[
                Row(
                  children: [
                    Spacer(),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.primaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: Text("Estação")),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.primaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: Text("Vante")),
                    ),
                    Container(
                      width: 96,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.primaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: Text("Ang. Horizontal", textAlign: TextAlign.center)),
                    ),
                    Container(
                      width: 96,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.primaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: Text("Azimute")),
                    ),
                    Spacer(),
                  ],
                ),
              ] +
              List.generate(
                dadosExibir.length,
                (index) => Row(
                  children: [
                    Spacer(),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: dadosExibir[index].estacao),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: dadosExibir[index].vante),
                    ),
                    Container(
                      width: 96,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: dadosExibir[index].angHorizontal),
                    ),
                    Container(
                      width: 96,
                      height: 56,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                        border: Border.all(color: Cores.preto),
                      ),
                      child: Center(child: dadosExibir[index].azimute),
                    ),
                    Spacer(),
                  ],
                ),
              ),
        );

        return Container(
          height: MediaQuery.of(ctx).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  """Determine o Azimute verdadeiro de AB, sabendo que:
  A declinação magnética para o local consultado é de -22°15'25\";
  O Azimute entre o norte magnético e o trecho AB determinado em campo é de 222°15'25\"""",
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Azimue verdadeiro AB: "),
                    Spacer(),
                    SizedBox(
                      height: 66,
                      width: 116,
                      child: TextGMSField(
                        angleInit: azimutes["AB"] ?? 0,
                        onChange: (val) {
                          azimutes["AB"] = val;
                          on_finish(azimutes);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Draw polygon
                Card(
                  elevation: 3,
                  child: Container(
                    color: Cores.secundaria,
                    height: MediaQuery.of(ctx).size.height * 0.5,
                    width: MediaQuery.of(ctx).size.width,
                    padding: EdgeInsets.all(10),
                    child: DrawPoligon(
                      points: points,
                      drawAzimute: true,
                      drawTrueNorth: true,
                      drawPoints: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //Tabela
                tabela,
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      } catch (e) {
        return Center(
          child: Text("Ocorreu algum erro aqui ($e), pode ser que o passo anterior não tenha sido feito de maneira correta!"),
        );
      }
    },
  );
}

Widget dr(Map drs, List<ItemTabelaValues> dadosValues, Function on_finish) {
  List<TextEditingController> controllers = [];
  for (ItemTabelaValues item in dadosValues) {
    String key = item.estacao! + (item.vante == "" ? item.re! : item.vante!);
    if (!drs.containsKey(key)) {
      drs[key] = 0.0;
    }
  }
  if (drs.length > 0) {
    controllers = List.generate(
      drs.length,
      (index) {
        String key = drs.keys.toList()[index];
        return TextEditingController(
          text: (drs[key] ?? 0.0).toString().replaceAll(".", ",") + " m",
        );
      },
    );
  }

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              """Determine as distâncias reduzidas para os pontos que seguem:""",
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 16 / 6,
                ),
                itemCount: drs.length,
                itemBuilder: (ctx, index) {
                  String keyDR = dadosValues[index].vante == "" ? dadosValues[index].estacao! + dadosValues[index].re! : dadosValues[index].estacao! + dadosValues[index].vante!;

                  return Row(
                    children: [
                      SizedBox(
                        height: 56,
                        width: 56,
                        child: Center(
                          child: Text(
                            "Dr $keyDR:",
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 56,
                        width: 96,
                        child: TextField(
                          controller: controllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            drs[keyDR] = double.tryParse(text.replaceAll("m", "").replaceAll(" ", "").replaceAll(",", '.')) ?? (drs[keyDR] ?? 0);
                            on_finish(drs);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget coords(Map drs, Map azimutes, Map coordsRel, List<ItemTabelaValues> dadosValues, Function on_finish) {
  List<String> pontos = [];

  for (ItemTabelaValues item in dadosValues) {
    if (!pontos.contains(item.estacao!)) {
      pontos.add(item.estacao!);
    }
  }

  List<List<TextEditingController>> controllers = [];
  List<String> pontosPlot = [];
  for (ItemTabelaValues item in dadosValues) {
    if (item.vante != "") {
      pontosPlot.add(item.estacao! + item.vante!);
      controllers.add(
        [
          TextEditingController(text: (coordsRel[item.estacao! + item.vante!] ?? Offset.zero).dx.toString().replaceAll(".", ",")),
          TextEditingController(text: (coordsRel[item.estacao! + item.vante!] ?? Offset.zero).dy.toString().replaceAll(".", ",")),
        ],
      );
    }
  }

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                """As coordenadas relativas são calculdas com a média entre as distâncias reduzidas da estação a vante e da estação a ré, para os pontos que compõem a poligonal (pontos que não são irradiações)
  
  Sabendo disto preencha as abscissas e ordenadas relativas da tabela que segue:""",
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 7 * 100,
                  height: MediaQuery.of(ctx).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 4 / 2,
                    ),
                    itemCount: (pontosPlot.length + 1) * 7,
                    itemBuilder: (ctx, index) {
                      int indexReal = index ~/ 7;
                      index = index - indexReal * 7;

                      if (indexReal == 0) {
                        if (index == 0) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Ré")),
                          );
                        }
                        if (index == 1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Estação")),
                          );
                        }
                        if (index == 2) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Vante")),
                          );
                        }
                        if (index == 3) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Azimute")),
                          );
                        }
                        if (index == 4) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Dist. Reduzida")),
                          );
                        }
                        if (index == 5) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Absc. Rel. X")),
                          );
                        }
                        if (index == 6) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(child: Text("Abs. Rel. Y")),
                          );
                        }
                      }

                      indexReal--;

                      int indexValue = 0;

                      for (ItemTabelaValues item in dadosValues) {
                        if (item.estacao! + item.vante! == pontosPlot[indexReal]) {
                          indexValue = dadosValues.indexOf(item);
                          break;
                        }
                      }

                      Widget child = Text("");
                      if (index == 0) {
                        child = Text(dadosValues[indexValue].re!);
                      }
                      if (index == 1) {
                        child = Text(dadosValues[indexValue].estacao!);
                      }
                      if (index == 2) {
                        child = Text(dadosValues[indexValue].vante!);
                      }
                      if (index == 3) {
                        child = Text(toGrauMinSec(azimutes[dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!]!));
                      }

                      String keyRe = "";
                      String keyVante = "";

                      if (pontos.contains(dadosValues[indexValue].vante!)) {
                        keyVante = dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!;
                        keyRe = dadosValues[indexValue].vante! + dadosValues[indexValue].estacao!;
                      } else {
                        keyVante = dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!;
                        keyRe = dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!;
                      }

                      if (index == 4) {
                        child = Text(
                          toTwo((drs[keyRe]! + drs[keyVante]!) / 2).toString() + " m",
                        );
                      }

                      Offset absc = coordsRel[keyVante] ?? Offset.zero;

                      if (index == 5) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: controllers[indexReal][0],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordsRel[keyVante] = Offset(
                                double.tryParse(text.replaceAll("m", "").replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dx,
                                absc.dy,
                              );
                              on_finish(coordsRel);
                            },
                          ),
                        );
                      }
                      if (index == 6) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: controllers[indexReal][1],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordsRel[keyVante] = Offset(
                                absc.dx,
                                double.tryParse(text.replaceAll("m", "").replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dy,
                              );
                              on_finish(coordsRel);
                            },
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: indexReal % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                          border: Border.all(
                            color: Cores.preto,
                          ),
                        ),
                        child: Center(child: child),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget erroLinear(List<ItemTabelaValues> dadosValues, Map errFechamento, double erroLinMax, Map coefiCorre, Map coordsRel, String classe, Map drs, Map coordsRelCorr, Function on_finish) {
  TextEditingController editingX = TextEditingController(text: (toFour(errFechamento["x"] ?? 0)).toStringAsExponential().replaceAll(".", ","));
  TextEditingController editingY = TextEditingController(text: (toFour(errFechamento["y"] ?? 0)).toStringAsExponential().replaceAll(".", ","));
  TextEditingController editingL = TextEditingController(text: (toFour(erroLinMax)).toStringAsExponential().replaceAll(".", ","));
  TextEditingController editingCX = TextEditingController(text: (toSix(coefiCorre["x"] ?? 0)).toStringAsExponential().replaceAll(".", ","));
  TextEditingController editingCY = TextEditingController(text: (toSix(coefiCorre["y"] ?? 0)).toStringAsExponential().replaceAll(".", ","));

  List<String> pontos = [];
  for (ItemTabelaValues item in dadosValues) {
    if (!pontos.contains(item.estacao!)) {
      pontos.add(item.estacao!);
    }
  }

  List<String> pontosPlot = [];
  for (ItemTabelaValues item in dadosValues) {
    if (item.vante != "") {
      pontosPlot.add(item.estacao! + item.vante!);
    }
  }

  double somaAbcX = 0;
  double somaAbcY = 0;
  double somaAbcXcor = 0;
  double somaAbcYcor = 0;

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                """Para prosseguir determine o erro linear de fechamento para o seu projeto:""",
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Spacer(flex: 1),
                  Text("Erro em X: "),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: editingX,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        errFechamento["x"] = double.tryParse(text.replaceAll(" ", "").replaceAll(",", ".")) ?? 0;
                        on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                  Text("Erro em Y: "),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: editingY,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        errFechamento["y"] = double.tryParse(text.replaceAll(" ", "").replaceAll(",", ".")) ?? 0;
                        on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
              SizedBox(height: 10),
              Text(
                """Para a classe $classe determine o limite máximo tolerado para o erro linear:""",
              ),
              Row(
                children: [
                  Spacer(flex: 1),
                  Text("Erro planimétrico:"),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: editingL,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onSubmitted: (text) {
                        erroLinMax = double.tryParse(text.replaceAll(" ", "").replaceAll(",", ".")) ?? 0;
                        on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
              SizedBox(height: 10),
              Text(
                """Observe se o erro ângular no item Erro Ângular e o erro linear deste item se enquadram em uma classe mais baixa do que a especificada neste projeto, e com isso pode ser que o projeto se enquadre em uma classe de maior precisão.
  
  Determine os coeficientes para a correção linear:""",
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Spacer(flex: 1),
                  Text("Cx: "),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: editingCX,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        coefiCorre["x"] = double.tryParse(text.replaceAll(" ", "").replaceAll(",", ".")) ?? 0;
                        on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                  Text("Cy: "),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: editingCY,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        coefiCorre["y"] = double.tryParse(text.replaceAll(" ", "").replaceAll(",", ".")) ?? 0;
                        on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 6 * 100,
                  height: MediaQuery.of(ctx).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 4 / 2,
                    ),
                    itemCount: (coordsRel.length + 2) * 6,
                    itemBuilder: (ctx, index) {
                      int indexReal = index ~/ 6;
                      index = index - indexReal * 6;

                      if (indexReal == 0) {
                        if (index == 0) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Ré-Estação-Vante",
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Distância Reduzida",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 2) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                                child: Text(
                              "Absc. Rel. X",
                              textAlign: TextAlign.center,
                            )),
                          );
                        }
                        if (index == 3) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Absc. Rel X Corrigida",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 4) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Orde. Rel Y",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 5) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Orde. Rel. Y Corrigida",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                      }

                      Widget child = Text("");

                      if (indexReal == coordsRel.length + 1) {
                        if (index == 1) {
                          child = Text("Erro:");
                        }
                        if (index == 2) {
                          child = Text(toTwo(somaAbcX).toStringAsExponential().replaceAll(".", ","));
                        }
                        if (index == 3) {
                          child = Text(toTwo(somaAbcXcor).toStringAsExponential().replaceAll(".", ","));
                        }
                        if (index == 4) {
                          child = Text(toTwo(somaAbcY).toStringAsExponential().replaceAll(".", ","));
                        }
                        if (index == 5) {
                          child = Text(toTwo(somaAbcYcor).toStringAsExponential().replaceAll(".", ","));
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Cores.branco,
                            border: Border.all(
                              color: Cores.preto,
                            ),
                          ),
                          child: Center(child: child),
                        );
                      }

                      indexReal--;

                      int indexValue = 0;

                      for (ItemTabelaValues item in dadosValues) {
                        if (item.estacao! + item.vante! == pontosPlot[indexReal]) {
                          indexValue = dadosValues.indexOf(item);
                          break;
                        }
                      }

                      String keyVante = dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!;

                      Offset absc = coordsRelCorr[keyVante] ?? Offset.zero;

                      if (index == 0) {
                        child = Text(dadosValues[indexValue].re! + "-" + dadosValues[indexValue].estacao! + "-" + dadosValues[indexValue].vante!);
                      }
                      if (index == 1) {
                        child = Text(toTwo(drs[keyVante] ?? 0).toString());
                      }
                      if (index == 2) {
                        child = Text(toTwo(coordsRel[keyVante]!.dx).toString().replaceAll(".", ','));
                        if (pontos.contains(dadosValues[indexValue].vante!)) {
                          somaAbcX += coordsRel[keyVante]!.dx;
                        }
                      }
                      if (index == 3) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: TextEditingController(text: absc.dx.toString().replaceAll(".", ",")),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordsRelCorr[keyVante] = Offset(
                                double.tryParse(text.replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dx,
                                absc.dy,
                              );
                              on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                            },
                          ),
                        );
                        if (pontos.contains(dadosValues[indexValue].vante!)) {
                          somaAbcXcor += absc.dx;
                        }
                      }
                      if (index == 4) {
                        child = Text(toTwo(coordsRel[keyVante]!.dy).toString().replaceAll(".", ','));
                        if (pontos.contains(dadosValues[indexValue].vante!)) {
                          somaAbcY += coordsRel[keyVante]!.dy;
                        }
                      }
                      if (index == 5) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: TextEditingController(text: absc.dy.toString().replaceAll(".", ",")),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordsRelCorr[keyVante] = Offset(
                                absc.dx,
                                double.tryParse(text.replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dy,
                              );
                              on_finish(errFechamento, erroLinMax, coefiCorre, coordsRelCorr);
                            },
                          ),
                        );
                        if (pontos.contains(dadosValues[indexValue].vante!)) {
                          somaAbcYcor += absc.dy;
                        }
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: indexReal % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                          border: Border.all(
                            color: Cores.preto,
                          ),
                        ),
                        child: Center(child: child),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget coordAbsolutas(List<ItemTabelaValues> dadosValues, Map coordRel, Map coordRelCor, Map coordAbs, Function on_finish) {
  List<String> pontos = [];
  for (ItemTabelaValues item in dadosValues) {
    if (!pontos.contains(item.estacao!)) {
      pontos.add(item.estacao!);
    }
  }

  double coordInit = 0;

  List<String> pontosPlot = [];
  for (ItemTabelaValues item in dadosValues) {
    if (item.vante != "") {
      pontosPlot.add(item.estacao! + item.vante!);
      if (coordAbs.containsKey(item.estacao! + item.vante!) && coordRel.containsKey(item.estacao! + item.vante!) && coordInit == 0) {
        coordInit = (coordAbs[item.estacao! + item.vante!] ?? Offset.zero).dx - (coordRel[item.estacao! + item.vante!] ?? Offset.zero).dx;
      }
    }
  }

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        height: MediaQuery.of(ctx).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                """Para finalizar, deve ser definida uma coordenada em X e em Y de modo que todos os pontos fiquem maiores que 0, escolha também em qual pontos será iniciada a contagem:""",
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 5 * 70,
                  height: MediaQuery.of(ctx).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 4 / 2,
                    ),
                    itemCount: (coordRel.length + 1) * 5,
                    itemBuilder: (ctx, index) {
                      int indexReal = index ~/ 5;
                      index = index - indexReal * 5;

                      if (indexReal == 0) {
                        if (index == 0) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Ré-Estação-Vante",
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Absc. Relativa X",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (index == 2) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                                child: Text(
                              "Absc. Absoluta X",
                              textAlign: TextAlign.center,
                            )),
                          );
                        }
                        if (index == 3) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                                child: Text(
                              "Orde. Relativa Y",
                              textAlign: TextAlign.center,
                            )),
                          );
                        }
                        if (index == 4) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Cores.primaria,
                              border: Border.all(
                                color: Cores.preto,
                              ),
                            ),
                            child: Center(
                                child: Text(
                              "Orde. Absoluta Y",
                              textAlign: TextAlign.center,
                            )),
                          );
                        }
                      }

                      Widget child = Text("");

                      indexReal--;

                      int indexValue = 0;

                      for (ItemTabelaValues item in dadosValues) {
                        if (item.estacao! + item.vante! == pontosPlot[indexReal]) {
                          indexValue = dadosValues.indexOf(item);
                          break;
                        }
                      }

                      String keyVante = dadosValues[indexValue].estacao! + dadosValues[indexValue].vante!;

                      Offset absc = coordAbs[keyVante] ?? Offset.zero;

                      if (index == 0) {
                        child = Text(dadosValues[indexValue].re! + "-" + dadosValues[indexValue].estacao! + "-" + dadosValues[indexValue].vante!);
                      }
                      if (index == 1) {
                        if (coordRelCor.containsKey(keyVante)) {
                          child = Text((coordRelCor[keyVante] ?? Offset.zero).dx.toString());
                        } else {
                          child = Text((coordRel[keyVante] ?? Offset.zero).dx.toString());
                        }
                      }
                      if (index == 2) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: TextEditingController(text: absc.dx.toString().replaceAll(".", ",")),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordAbs[keyVante] = Offset(
                                double.tryParse(text.replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dx,
                                absc.dy,
                              );
                              on_finish(coordAbs);
                            },
                          ),
                        );
                      }
                      if (index == 3) {
                        if (coordRelCor.containsKey(keyVante)) {
                          child = Text((coordRelCor[keyVante] ?? Offset.zero).dy.toString());
                        } else {
                          child = Text((coordRel[keyVante] ?? Offset.zero).dy.toString());
                        }
                      }
                      if (index == 4) {
                        child = Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: TextEditingController(text: absc.dy.toString().replaceAll(".", ",")),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              coordAbs[keyVante] = Offset(
                                absc.dx,
                                double.tryParse(text.replaceAll(" ", "").replaceAll(",", '.')) ?? absc.dy,
                              );
                              on_finish(coordAbs);
                            },
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: indexReal % 2 == 0 ? Cores.secundaria : Cores.terciaria,
                          border: Border.all(
                            color: Cores.preto,
                          ),
                        ),
                        child: Center(child: child),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget toTable(List<ItemTabelaValues> dadosValues, Map resp, Usuario user, Function on_finish) {
  List<ItemTabelaValues> newValues = [];

  List<List> dadosToExcel = [];

  dadosToExcel.add(
    [
      "Classe do projeto",
      resp['classe'],
    ],
  );

  dadosToExcel.add(
    [
      "Erro Angular Máximo Tolerado",
      resp['errAngMaxTolerado'],
    ],
  );

  dadosToExcel.add(
    [
      "Soma dos Ângulos Externos",
      resp['sumAngExterno'],
    ],
  );

  dadosToExcel.add(
    [
      "Erro de fechamento (X, Y)",
      resp['errosDeFechamento'][0],
      resp['errosDeFechamento'][1],
    ],
  );

  dadosToExcel.add(
    [
      "Erro linear Máximo",
      resp['errosLinMax'],
    ],
  );

  dadosToExcel.add(
    [
      "Coeficientes de correção linear (X, Y)",
      resp['coefCorrecaoLin'][0],
      resp['coefCorrecaoLin'][1],
    ],
  );

  dadosToExcel.add(
    [],
  );

  dadosToExcel.add(
    [],
  );

  dadosToExcel.add(
    [
      "Ré",
      "Estação",
      "Vante",
      "Descrição",
      "Altura do Instrumento",
      "Ângulo Horizontal",
      "Ângulo de Correção",
      "Ângulo Horizontal Final",
      "Azimute",
      "Ângulo Zenital",
      "Fio Inferior",
      "Fio Médio",
      "Fio Superior",
      "Distância Reduzida",
      "Abscissa Relativa",
      "Ordenada Relativa",
      "Abscissa Relativa Corrigida",
      "Ordenada Relativa Corrigida",
      "Abscissa Absoluta",
      "Ordenada Absoluta",
    ],
  );

  for (ItemTabelaValues item in dadosValues) {
    String estaVante = item.estacao! + ((item.vante ?? "") == "" ? item.re! : item.vante!);
    //String reEsta = item.re! + item.estacao!;
    int index = dadosValues.indexOf(item);

    dadosToExcel.add(
      [
        item.re ?? "-",
        item.estacao ?? "-",
        item.vante ?? "-",
        item.descricao ?? "-",
        item.alturaInst ?? "-",
        toGrauMinSec(item.angHorizontal ?? 0),
        toGrauMinSec(resp['anguloCorrecao'][index] ?? 0),
        toGrauMinSec((item.angHorizontal ?? 0.0) + (resp['anguloCorrecao'][index] ?? 0)),
        toGrauMinSec(resp['azimutes'][estaVante] ?? 0),
        toGrauMinSec(item.angZenital ?? 0),
        item.fioInf ?? "-",
        item.fioMed ?? "-",
        item.fioSup ?? "-",
        resp['drs'][estaVante] ?? "-",
        (resp['coordRel'][estaVante] ?? Offset.zero).dx,
        (resp['coordRel'][estaVante] ?? Offset.zero).dy,
        (resp['coordRelCorrigida'][estaVante] ?? Offset.zero).dx,
        (resp['coordRelCorrigida'][estaVante] ?? Offset.zero).dy,
        (resp['coordAbs'][estaVante] ?? Offset.zero).dx,
        (resp['coordAbs'][estaVante] ?? Offset.zero).dy,
      ],
    );

    newValues.add(
      ItemTabelaValues(
        re: item.re,
        vante: item.vante,
        estacao: item.estacao,
        descricao: item.descricao,
        alturaInst: item.alturaInst,
        angHorizontal: item.angHorizontal! + resp['anguloCorrecao'][index],
        angZenital: item.angZenital,
        azimute: resp['azimutes'][estaVante] ?? 0.0,
        distRed: resp['drs'][estaVante] ?? 0.0,
        fioInf: item.fioInf!,
        fioMed: item.fioMed!,
        fioSup: item.fioSup!,
        abcRelX: (resp['coordRelCorrigida'][estaVante] ?? resp['coordRel'][estaVante] ?? Offset.zero).dx,
        abcRelY: (resp['coordRelCorrigida'][estaVante] ?? resp['coordRel'][estaVante] ?? Offset.zero).dy,
        abcAbsX: (resp['coordAbs'][estaVante] ?? Offset.zero).dx,
        abcAbsY: (resp['coordAbs'][estaVante] ?? Offset.zero).dy,
      ),
    );
  }

  List<List<Offset>> dadosPlot = gerarPoligonoByTableValues(dadosValues: newValues);
  return StatefulBuilder(
    builder: (ctx, setState) {
      return Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("""Estes são os resultados do levantamento que você realizou, você pode compartilhar a planilha exibida na tabela a baixo com seu professor ou da forma que preferir.

A classe do projeto foi a classe ${resp['classe']}.
"""),
              SizedBox(
                width: MediaQuery.of(ctx).size.width - 10,
                height: MediaQuery.of(ctx).size.height * 0.5,
                child: TabelaCampo(
                  celulaHeight: 40,
                  celulaWidth: 76,
                  tabelaEstatica: true,
                  dadosValues: listTabelaToMapTabela(newValues),
                  titulos: {
                    "vante": Text(
                      "Vante",
                      textAlign: TextAlign.center,
                    ),
                    "re": Text(
                      "Ré",
                      textAlign: TextAlign.center,
                    ),
                    "estacao": Text(
                      "Estação",
                      textAlign: TextAlign.center,
                    ),
                    "descricao": Text(
                      "Descrição",
                      textAlign: TextAlign.center,
                    ),
                    "alturaInst": Text(
                      "Alt. Instrumen.",
                      textAlign: TextAlign.center,
                    ),
                    "angHorizontal": Text(
                      "Ang. Horizontal",
                      textAlign: TextAlign.center,
                    ),
                    "angZenital": Text(
                      "Ang. Zenital",
                      textAlign: TextAlign.center,
                    ),
                    "azimute": Text(
                      "Azimute",
                      textAlign: TextAlign.center,
                    ),
                    "distRed": Text(
                      "Dist. Reduzida",
                      textAlign: TextAlign.center,
                    ),
                    "fioInf": Text(
                      "Fio Inferior",
                      textAlign: TextAlign.center,
                    ),
                    "fioMed": Text(
                      "Fio Médio",
                      textAlign: TextAlign.center,
                    ),
                    "fioSup": Text(
                      "Fio Superior",
                      textAlign: TextAlign.center,
                    ),
                    "abcRelX": Text(
                      "Absc. Rel. (X)",
                      textAlign: TextAlign.center,
                    ),
                    "abcRelY": Text(
                      "Ored. Rel. (Y)",
                      textAlign: TextAlign.center,
                    ),
                    "abcAbsX": Text(
                      "Absc. Abs. (X)",
                      textAlign: TextAlign.center,
                    ),
                    "abcAbsY": Text(
                      "Orde. Abs. (Y)",
                      textAlign: TextAlign.center,
                    ),
                  },
                  ordem: [
                    "estacao",
                    "re",
                    "vante",
                    "descricao",
                    "alturaInst",
                    "angHorizontal",
                    "azimute",
                    "angZenital",
                    "distRed",
                    "fioInf",
                    "fioMed",
                    "fioSup",
                    "abcRelX",
                    "abcRelY",
                    "abcAbsX",
                    "abcAbsY",
                  ],
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 3,
                child: Container(
                  color: Cores.secundaria,
                  height: MediaQuery.of(ctx).size.height * 0.5,
                  width: MediaQuery.of(ctx).size.width,
                  padding: EdgeInsets.all(10),
                  child: DrawPoligon(
                    points: dadosPlot,
                    drawAzimute: true,
                    drawTrueNorth: true,
                    drawPoints: true,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  String path = await save_excel(dadosToExcel, user);
                  if (!kIsWeb) {
                    Share.shareFiles([path], text: "Compartilhar resultados");
                  }
                  on_finish();
                },
                child: Text(
                  "Finalizar",
                  style: TextStyle(
                    color: Cores.preto,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
