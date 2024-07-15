import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A1EX3 extends StatefulWidget {
  A1EX3();

  @override
  _A1EX3 createState() => _A1EX3();
}

class _A1EX3 extends State<A1EX3> {
  _A1EX3();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  List items = [];
  List<String> certos = [];
  List<TextEditingController> respostas = [];

  @override
  void initState() {
    super.initState();
    gerarEx();
  }

  //Dados pra pegar no servidor
  //Quantidade de exercícios que serão gerados
  int qtEx = 7;
  //Texto da questão
  String questao = "Faça o que se pede (As respostas devem ter ao menos 6 casas decimais):";

  void finalizarTentativa(
    List<TextEditingController> respostas,
    BuildContext context,
  ) async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certos.contains("acertou") || certos.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    respostas.forEach(
      (e) {
        int i = respostas.indexOf(e);
        double resp = 0;
        double res = items[i]['resp'];

        e.text = e.text.replaceAll(",", ".");

        if (e.text.contains("°") || e.text.contains("º")) {
          resp = gmsToDoube(e.text);
        } else if (e.text != "") {
          resp = double.parse(e.text);
        }

        bool usou_tolerancia = (sqrt(pow(resp - res, 2)) <= 0.0005);

        bool acertou = (resp == res) || usou_tolerancia;

        certos[i] = acertou ? "acertou" : "errou";

        user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario/$i").set(
          {
            "usou_tolerancia": usou_tolerancia,
            "acertou": acertou,
            "resposta": resp,
            "resultado": res,
          },
        );
      },
    );

    setState(() {});
  }

  void gerarEx() {
    Random rdn = Random(DateTime.now().microsecondsSinceEpoch);

    List exs = [];

    for (int i = 0; i < qtEx; i++) {
      int grau = rdn.nextInt(360); //Valor em graus
      int min = rdn.nextInt(60); //Valor em minutos
      int seg = rdn.nextInt(60); //Valor em segundos

      double resp = grau + min / 60 + seg / 3600;

      Map dados = {};

      if (i == 0) {
        //Faz nada
        dados['tipo'] = "normal";

        dados['grau'] = grau;
        dados['min'] = min;
        dados['seg'] = seg;
        dados['resp'] = toSix(resp);
      } else if (i == 1) {
        //Soma
        dados['tipo'] = "soma";

        int grau1 = rdn.nextInt(360); //Valor em graus
        int min1 = rdn.nextInt(60); //Valor em minutos
        int seg1 = rdn.nextInt(60); //Valor em segundos

        dados['grau'] = grau;
        dados['min'] = min;
        dados['seg'] = seg;
        dados['grau1'] = grau1;
        dados['min1'] = min1;
        dados['seg1'] = seg1;

        resp = resp + grau1 + min1 / 60 + seg1 / 3600;
        dados['resp'] = toSix(resp);
      } else if (i == 2) {
        //Subtração
        dados['tipo'] = "sub";

        int grau1 = rdn.nextInt(360); //Valor em graus
        int min1 = rdn.nextInt(60); //Valor em minutos
        int seg1 = rdn.nextInt(60); //Valor em segundos

        dados['grau'] = grau;
        dados['min'] = min;
        dados['seg'] = seg;
        dados['grau1'] = grau1;
        dados['min1'] = min1;
        dados['seg1'] = seg1;

        resp = resp - (grau1 + min1 / 60 + seg1 / 3600);
        dados['resp'] = toSix(resp);
      } else {
        //Subtração
        if (i == 3) {
          dados['tipo'] = "sen";
          resp = sin((resp * pi) / 180);
        }
        if (i == 4) {
          dados['tipo'] = "cos";
          resp = cos((resp * pi) / 180);
        }
        if (i == 5) {
          dados['tipo'] = "sen2";
          resp = pow(sin((resp * pi) / 180), 2).toDouble();
        }
        if (i == 6) {
          dados['tipo'] = "sen2x";
          resp = sin(((resp * pi) / 180) * 2);
        }

        dados['grau'] = grau;
        dados['min'] = min;
        dados['seg'] = seg;
        dados['resp'] = toSix(resp);
      }

      exs.add(dados);
    }

    items = exs;

    for (int i = 0; i < qtEx; i++) {
      respostas.add(
        TextEditingController(),
      );
      certos.add("none");
    }
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

    bool justRead = false;
    String textoFinalizar = "Finalizar Tentativa";

    if (certos.contains("acertou") || certos.contains("errou")) {
      textoFinalizar = "Sair";
      justRead = true;

      for (int i = 0; i < certos.length; i++) {
        if (certos[i] == "errou") {
          if (i == 1 || i == 2) {
            respostas[i].text = respostas[i].text + " (" + toGrauMinSec(items[i]['resp']) + ")";
          } else {
            respostas[i].text = respostas[i].text + " (" + items[i]['resp'].toString() + ")";
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercício 3"),
        backgroundColor: Cores.primaria,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              questao,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                Map ex = items[index];

                //dados['tipo'] = "normal";
                //dados['tipo'] = "soma";
                //dados['tipo'] = "sub";
                //dados['tipo'] = "sen";
                //dados['tipo'] = "cos";
                //dados['tipo'] = "sen2;"
                //dados['tipo'] = "sen2x";

                String quest = "";

                if (ex['tipo'] == "normal") {
                  quest = "Transforme para graus decimais:   \n" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '" = ';
                } else if (ex['tipo'] == "soma") {
                  quest = "Resolva a Soma:\n" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '" + ' + ex['grau1'].toString() + "°" + ex['min1'].toString() + "'" + ex['seg1'].toString() + '" =';
                } else if (ex['tipo'] == "sub") {
                  quest = "Resolva a Subtração:\n" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '" - ' + ex['grau1'].toString() + "°" + ex['min1'].toString() + "'" + ex['seg1'].toString() + '" =';
                } else if (ex['tipo'] == "sen") {
                  quest = "Resolva:\nsen(" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '") =';
                } else if (ex['tipo'] == "cos") {
                  quest = "Resolva:\ncos(" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '") =';
                } else if (ex['tipo'] == "sen2") {
                  quest = "Resolva:\nsen²(" + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '") =';
                } else if (ex['tipo'] == "sen2x") {
                  quest = "Resolva:\nsen(2 * " + ex['grau'].toString() + "°" + ex['min'].toString() + "'" + ex['seg'].toString() + '") =';
                }

                return Card(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    color: Color.lerp(Cores.terciaria, Colors.transparent, 0.8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                quest,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                width: 150,
                                height: 30,
                                child: TextFormField(
                                  controller: respostas[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Resposta",
                                    icon: certos[index] == "none"
                                        ? null
                                        : Icon(
                                            certos[index] == "acertou" ? Icons.done_all : Icons.block,
                                          ),
                                  ),
                                  readOnly: justRead,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: qtEx,
            ),
          ),
          Row(
            children: [
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      finalizarTentativa(respostas, context);
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
                            respostas = [];
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
