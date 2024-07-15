import 'dart:math';
import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Contants/constantes.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A1EX1 extends StatefulWidget {
  A1EX1();

  @override
  _A1EX1 createState() => _A1EX1();
}

class _A1EX1 extends State<A1EX1> {
  _A1EX1();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;

  String certo = "";
  double dropDownValue1 = 1000.0;
  double dropDownValue2 = 100.0;
  TextEditingController resposta = TextEditingController();
  double resultado = 0;
  Random? aleatorio;
  double valor = 0;

  @override
  void initState() {
    super.initState();
    aleatorio = Random(DateTime.now().microsecondsSinceEpoch);
    gerarEx();
  }

  void gerarEx() {
    valor = toTwo(aleatorio!.nextDouble() * aleatorio!.nextInt(1000));
  }

  //Texto da questão
  String questao = "Transformação de unidades planas:";

  void finalizarTentativa() async {
    int horario = DateTime.now().microsecondsSinceEpoch;

    if (certo.contains("acertou") || certo.contains("errou")) {
      Navigator.of(context).pop();
      return;
    }

    String unidade1 = "";
    String unidade2 = "";

    unidades.forEach((e) {
      if (e['inM'] == dropDownValue1) {
        unidade1 = e['name'];
      }
      if (e['inM'] == dropDownValue2) {
        unidade2 = e['name'];
      }
    });

    double resp = 0;
    resultado = toTwo((valor / dropDownValue2) * dropDownValue1);

    resposta.text = resposta.text.replaceAll(",", ".");

    if (resposta.text != "") {
      resp = double.parse(resposta.text);
    }

    bool usou_tolerancia = (sqrt(pow(resp - resultado, 2)) <= 0.05);

    bool acertou = (resp == resultado) || usou_tolerancia;

    certo = acertou ? "acertou" : "errou";

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set({
      "usou_tolerancia": resp - resultado == 0 ? false : usou_tolerancia,
      "acertou": acertou,
      "resposta": resp,
      "resultado": resultado,
      "un1": unidade1,
      "un2": unidade2,
    });
    setState(() {});
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

    if (certo.contains("acertou") || certo.contains("errou")) {
      textoFinalizar = "Sair";
      justRead = true;

      if (certo == "errou") {
        resposta.text = resposta.text + " (" + resultado.toString() + ")";
      }
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
            child: Text(
              questao,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$valor ",
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: DropdownButton<double>(
                    isExpanded: true,
                    value: dropDownValue1,
                    onChanged: (double? newValue) {
                      if (newValue! == dropDownValue2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: SizedBox(
                              height: 30,
                              child: Center(
                                child: Text("Você não pode escolher o mesmo valor para as duas unidades"),
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        dropDownValue1 = newValue;
                      });
                    },
                    items: unidades.map<DropdownMenuItem<double>>((Map value) {
                      return DropdownMenuItem<double>(
                        value: value['inM'],
                        child: Text(
                          value['name'],
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: value['inM'] == dropDownValue1 ? Cores.primaria : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Text(
                  "para ",
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: DropdownButton<double>(
                    isExpanded: true,
                    value: dropDownValue2,
                    elevation: 16,
                    onChanged: (double? newValue) {
                      if (newValue! == dropDownValue1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: SizedBox(
                              height: 76,
                              child: Center(
                                child: Text("Você não pode escolher o mesmo valor para as duas unidades"),
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        dropDownValue2 = newValue;
                      });
                    },
                    items: unidades.map<DropdownMenuItem<double>>((Map value) {
                      return DropdownMenuItem<double>(
                        value: value['inM'],
                        child: Text(
                          value['name'],
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: value['inM'] == dropDownValue2 ? Cores.primaria : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: resposta,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Resposta",
                icon: certo == ""
                    ? null
                    : Icon(
                        certo == "acertou" ? Icons.done_all : Icons.block,
                      ),
              ),
              readOnly: justRead,
            ),
          ),
          const Spacer(flex: 10),
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
                ((certo.contains("acertou") || certo.contains("errou"))
                    ? [
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            certo = "";
                            resposta.text = "";
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
          const Spacer(flex: 1)
        ],
      ),
    );
  }
}
