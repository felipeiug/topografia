import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/excel.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';

class LEVANTAMENTOS extends StatefulWidget {
  LEVANTAMENTOS();

  @override
  _LEVANTAMENTOS createState() => _LEVANTAMENTOS();
}

class _LEVANTAMENTOS extends State<LEVANTAMENTOS> {
  _LEVANTAMENTOS();

  Map? aula;
  Usuario? user;
  int? indexAula;
  int? indexTexto;
  int? indexLevantamento;

  bool iniciou = false;
  bool disconnected = false;
  bool tentarConectar = true;
  bool logando = false;

  int lenLevantamentosAns = 0;

  Timer t = Timer(Duration(seconds: 1), () {});

  Map<String, Map> levantamentos = {};
  Map<String, Map> levantamentosOff = {};
  Map<String, Map> levantamentosOn = {};

  @override
  void initState() {
    super.initState();
    t = Timer.periodic(Duration(seconds: 2), (time) async {
      if (iniciou) {
        if (tentarConectar && disconnected == true && await Usuario.connected && !logando) {
          logando = true;
          String nameApp = user!.nameApp;
          if (user!.dbOff!.containsKey("$nameApp/email") && user!.dbOff!.containsKey("$nameApp/pass")) {
            String? email = user!.dbOff!.getString("$nameApp/email");
            String? senha = user!.dbOff!.getString("$nameApp/pass");

            user!.context = context;

            disconnected = !(await user!.loginEmailSenha(
              email ?? "",
              senha ?? "",
              "",
              setLastAccess: true,
            ));

            if (disconnected == true) {
              tentarConectar = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Problemas ao conectar novamente, a sincronização acontecerá no próximo login",
                  ),
                ),
              );
            }
          }
          logando = false;
        } else if (!await Usuario.connected) {
          disconnected = true;
        }
      }
    });
    iniciar();
  }

  @override
  void dispose() {
    super.dispose();
    t.cancel();
  }

  void iniciar() async {
    Future.delayed(Duration(milliseconds: 2), () async {
      if (user == null) {
        iniciar();
        return;
      }

      if (!kIsWeb) {
        await getOffline();
      }
      await getOnline();

      setState(() {});
    });
  }

  Future<void> getOffline() async {
    //Lavantamento
    /*Map = {
      "nome"
      "data"
      "conteudo"
    }*/

    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path + "/tabelas/";

    try {
      List<String> tableNames = Directory(path).listSync().map((e) => e.path).toList();
      String fileAns = "";

      for (String fileName in tableNames) {
        String name = fileName.split("-")[0].split(path)[1];
        int data = int.tryParse(fileName.split("-")[1].replaceAll("'", "")) ?? 0;
        List<ItemTabelaValues> content = getTableSave(fileName);

        if (levantamentosOff.containsKey(name) && data < (levantamentosOff[name]!['data'] ?? 0)) {
          continue;
        }
        fileAns = fileName;
        levantamentosOff[name] = {
          'nome': name,
          'data': data,
          'conteudo': content,
        };
      }
    } catch (e) {
      await Directory(path).create(recursive: true);
    }
  }

  Future<void> getOnline() async {
    if (user == null) {
      getOnline();
    }

    //Lavantamento
    /*Map = {
      "nome"
      "data"
      "conteudo"
    }*/
    if (!await exLib) {
      return;
    }

    if (await Usuario.connected) {
      Map _levantamentos = (await user!.getDb("users/${user!.userCredential!.user!.uid}/levantamentos/") ?? {}) as Map;

      _levantamentos.forEach((key, levantamento) {
        int data = levantamento['data'] ?? 0;
        String nome = levantamento['nome'] ?? "";

        List lev = (levantamento['conteudo'] ?? []);

        List<ItemTabelaValues> conteudo = jsonToTable(lev);

        levantamentosOn[nome] = {
          'nome': nome,
          'data': data,
          'conteudo': conteudo,
        };
      });
    }
    iniciou = true;
  }

  Future<void> save() async {
    try {
      if (!kIsWeb) {
        Directory tempDir = await getTemporaryDirectory();
        String path = tempDir.path + "/tabelas/";
        List<String> tableNames = Directory(path).listSync().map((e) {
          return e.path;
        }).toList();

        levantamentos.forEach((key, value) {
          String nome = value['nome'] ?? "";
          String name = nome + "-" + (value['data'] ?? 0).toString();

          for (String file in tableNames) {
            String _name = file.split("-")[0].replaceAll(path, "");
            if (_name == nome) {
              File(file).deleteSync();
            }
          }

          setTableSave(path + name, value['conteudo'] ?? <ItemTabelaValues>[]);
        });
      }
      if (await Usuario.connected) {
        if (user != null && user!.userCredential != null && user!.userCredential!.user != null) {
          levantamentos.forEach((key, value) {
            String nome = value['nome'] ?? "";
            List<ItemTabelaValues> conteudo = value['conteudo'] ?? [];

            List<Map> contentUp = tableToJson(conteudo);

            user!.setDb("users/${user!.userCredential!.user!.uid}/levantamentos/$nome", {
              'nome': nome,
              'data': DateTime.now().microsecondsSinceEpoch,
              'conteudo': contentUp,
            });
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String key) async {
    try {
      levantamentos.remove(key);

      if (!kIsWeb) {
        Directory tempDir = await getTemporaryDirectory();
        String path = tempDir.path + "/tabelas/";
        List<String> tableNames = Directory(path).listSync().map((e) {
          return e.path;
        }).toList();

        for (String file in tableNames) {
          String _name = file.split("-")[0].replaceAll(path, "");
          if (_name == key) {
            File(file).deleteSync();
          }
        }
      }
      if (await Usuario.connected) {
        if (user != null && user!.userCredential != null && user!.userCredential!.user != null) {
          user!.deleteDb("users/${user!.userCredential!.user!.uid}/levantamentos/$key");
        }
      }

      await save();

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> novo() async {
    String? novoLev = await showDialog(
      context: context,
      builder: (ctx) {
        TextEditingController nome = TextEditingController();

        return AlertDialog(
          title: Text("Novo Levantamento"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Text(
                  "Nome do novo levantamento:",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 76,
                  child: TextFormField(
                    controller: nome,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nome.text.contains("-")) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("O nome do levantamento não pode conter o caracter '-'"),
                    ),
                  );
                } else if (nome.text.isEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("O nome do levantamento não pode estar vazio"),
                    ),
                  );
                } else {
                  List<String> keys = levantamentos.keys.toList();
                  if (keys.contains(nome.text)) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("O nome do levantamento já está em uso"),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(nome.text);
                  }
                }
              },
              child: Text("Criar"),
            )
          ],
        );
      },
    );

    if (kIsWeb && !await Usuario.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Na Web você precisa de internet para sincronizar seus levantamentos, cuidado para não perder tudo!",
          ),
        ),
      );
    }
    if (novoLev != null) {
      levantamentos[novoLev] = {
        'nome': novoLev,
        'data': DateTime.now().microsecondsSinceEpoch,
        'conteudo': <ItemTabelaValues>[],
      };
      save();
      setState(() {});
    }
  }

  Future<void> openLev(String key) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LEVANTAMENTO(
          key,
          levantamentos[key]!['conteudo'] ?? <ItemTabelaValues>[],
          (value) {
            levantamentos[key] = {
              "nome": key,
              "data": DateTime.now().microsecondsSinceEpoch,
              "conteudo": value,
            };
            save();
          },
        ),
      ),
    );
  }

  //dadosValues = getTableSave(tableSave); //////////////////////##################
  Future<bool> get exLib async {
    bool _exLib = false;

    if (await Usuario.connected) {
      dynamic res = await user!.getDb("users/${user!.userCredential!.user!.uid}/exLib");
      _exLib = res ?? false;
    } else {
      _exLib = user!.dbOff!.getBool("${user!.nameApp}/exLib") ?? false;
    }

    user!.dbOff!.setBool("${user!.nameApp}/exLib", _exLib);
    return _exLib;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores.primaria,
        title: Text("Levantamentos"),
        elevation: 0,
      ),
      body: Container(
        color: Cores.terciaria,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: FutureBuilder<bool>(
            future: exLib,
            builder: (context, data) {
              if (!data.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              bool _exLib = data.data!;

              if (!_exLib) {
                return Center(
                  child: Text(
                    'Você ainda não está liberado para utilizar esta parte do app! Termine todos os exercícios propostos e fale com o professor da disciplina',
                  ),
                );
              }

              if (iniciou) {
                levantamentos = levantamentosOn;
                List<String> keysAdd = [];
                for (String keyOff in levantamentosOff.keys) {
                  if (levantamentos.containsKey(keyOff)) {
                    int data = levantamentos[keyOff]!['data'];
                    int dataOff = levantamentosOff[keyOff]!['data'];
                    if (dataOff > data) {
                      levantamentos[keyOff] = levantamentosOff[keyOff]!;
                    }
                  } else {
                    keysAdd.add(keyOff);
                  }
                }
                for (String key in keysAdd) {
                  levantamentos[key] = levantamentosOff[key]!;
                }

                levantamentosOff = levantamentos;
                levantamentosOn = levantamentos;

                if (lenLevantamentosAns != levantamentos.length) {
                  lenLevantamentosAns = levantamentos.length;
                  save();
                }
              }

              return Container(
                child: ListView.builder(
                  itemCount: levantamentos.length + 1,
                  itemBuilder: (ctx, index) {
                    if (index == levantamentos.length) {
                      return Card(
                        color: Cores.branco,
                        child: Row(
                          children: [
                            Spacer(),
                            Text("Adicionar novo levantamento"),
                            IconButton(
                              onPressed: novo,
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                      );
                    }

                    String key = levantamentos.keys.toList()[index];

                    DateTime date = DateTime.fromMicrosecondsSinceEpoch(levantamentos[key]!['data'] ?? 0);

                    String data = "Salvo em " + date.day.toString().padLeft(2, "0") + "/" + date.month.toString().padLeft(2, "0") + "/" + date.year.toString().padLeft(4, "0") + " - " + date.hour.toString().padLeft(2, "0") + ":" + date.minute.toString().padLeft(2, "0");

                    return Card(
                      color: Cores.branco,
                      child: ListTile(
                        title: Text(key),
                        subtitle: Text(data),
                        trailing: IconButton(
                          onPressed: () async {
                            bool? exclude = await showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text("Tem certeza que deseja excluir o levantamento '$key'"),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "Sim",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Não",
                                        style: TextStyle(color: Cores.preto),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (exclude == true) {
                              delete(key);
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Cores.preto,
                          ),
                        ),
                        onTap: () {
                          openLev(key);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LEVANTAMENTO extends StatefulWidget {
  LEVANTAMENTO(
    this.nome,
    this.dadosValues,
    this.onChange,
  );

  final String nome;
  final List<ItemTabelaValues> dadosValues;
  final Function onChange;

  @override
  _LEVANTAMENTO createState() => _LEVANTAMENTO();
}

class _LEVANTAMENTO extends State<LEVANTAMENTO> {
  _LEVANTAMENTO();

  Usuario? user;
  List<ItemTabelaValues> dadosValues = [];

  Map<String, Widget> cabecalhos = {
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
      "Ângulo Horizontal",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    ),
    "angZenital": Text(
      "Ângulo Zenital",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    ),
    "fioSup": Text(
      "Fio Superior",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    ),
    "fioMed": Text(
      "Fio Médio",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    ),
    "fioInf": Text(
      "Fio Inferior",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    ),
  };
  List<String> ordem = [
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
  ];

  @override
  void initState() {
    super.initState();
    dadosValues = widget.dadosValues;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onChange() {
    widget.onChange(dadosValues);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores.primaria,
        title: Text(widget.nome),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              List<List> dadosToExcel = [];

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
                  "Abscissa Absoluta",
                  "Ordenada Absoluta",
                ],
              );

              for (ItemTabelaValues item in dadosValues) {
                dadosToExcel.add(
                  [
                    item.re ?? "-",
                    item.estacao ?? "-",
                    item.vante ?? "-",
                    item.descricao ?? "-",
                    item.alturaInst ?? "-",
                    toGrauMinSec(item.angHorizontal ?? 0),
                    item.angHorizontalCorrigido ?? 0,
                    toGrauMinSec((item.angHorizontal ?? 0.0) + (item.angHorizontalCorrigido ?? 0)),
                    toGrauMinSec(item.azimute ?? 0),
                    toGrauMinSec(item.angZenital ?? 0),
                    item.fioInf ?? "-",
                    item.fioMed ?? "-",
                    item.fioSup ?? "-",
                    item.distRed ?? "-",
                    item.abcRelX ?? 0,
                    item.abcRelY ?? 0,
                    item.abcAbsX ?? 0,
                    item.abcAbsY ?? 0,
                  ],
                );
              }

              String path = await save_excel(
                dadosToExcel,
                user,
                name: widget.nome,
                sheetName: widget.nome,
              );

              if (!kIsWeb) {
                Share.shareFiles([path], text: "Compartilhar ${widget.nome}");
              }
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: TabelaCampo(
                celulaHeight: 46,
                celulaWidth: 100,
                tabelaEstatica: false,
                dadosValues: listTabelaToMapTabela(dadosValues),
                titulos: cabecalhos,
                ordem: ordem,
                onDataChange: (value) async {
                  dadosValues = mapTabelaToListTabela(value[1]);
                  onChange();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
