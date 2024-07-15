import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class A3EX2 extends StatefulWidget {
  A3EX2();

  @override
  _A3EX2 createState() => _A3EX2();
}

class _A3EX2 extends State<A3EX2> {
  _A3EX2();

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

  bool justRead = false;

  TextEditingController _resp = TextEditingController();

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

    certos.add(_resp.text.isNotEmpty ? "acertou" : "errou");

    user!.dbOn.child("users/${user!.userCredential!.user!.uid}/aulas/$indexAula/textos/$indexTexto/$horario").set(
      {
        'dados': {
          "fez": _resp.text.isNotEmpty,
          "resposta": _resp.text,
        },
      },
    );

    setState(() {});
  }

  void gerarEx() {}

  Widget build(BuildContext context) {
    String questao = """Determine a declinação magnética para a data de hoje e para a data em que nasceu para os seguintes locais:
- Cidade em que nasceu:
- Rio Paranaíba:
- Belo Horizonte (centro):
- Tarauaca (Acre) para 03/02/1970 e data atual
""";

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
        title: Text("Exercício 2"),
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
                //textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 15),
          /*Expanded(
            child: Card(
              color: Cores.branco.withBlue(200),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: _resp,
                  readOnly: justRead,
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  maxLines: null,
                  decoration: InputDecoration(hintText: "Sua Resposta"),
                ),
              ),
            ),
          ),
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
          )*/
        ],
      ),
    );
  }
}
