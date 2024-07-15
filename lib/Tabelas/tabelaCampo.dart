/*
  A tabela recebe uma lista de dados que vão conter os dados de re, estação, vante
  descrição, altura do instrumento angulos, fios
*/

/*
Ponto | Ré | Estação | Vante | Descrição |  Altura do  |         Ângulo       |        Fios        |
      |    |         |       |           | Instrumento | Horizontal | Zenital | Sup. | Méd. | Inf. |

*/
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/newEditPoint.dart';

typedef OnDataChange<List> = void Function(List value);
typedef OnChangeItem = void Function(int index);

class TabelaCampo extends StatefulWidget {
  TabelaCampo({
    Key? key,
    this.dados,
    this.dadosValues,
    required this.titulos,
    required this.ordem,
    this.celulaHeight = 100,
    this.celulaWidth = 100,
    this.onDataChange,
    this.onChangeItem,
    required this.tabelaEstatica,
    this.padding,
  }) : super(key: key);

  final List<ItemTabela>? dados;
  final Map<String, Map>? dadosValues;
  final Map<String, Widget>? titulos;
  final List<String>? ordem;
  final double celulaWidth;
  final double celulaHeight;
  final bool tabelaEstatica;
  final OnDataChange<List>? onDataChange;
  final OnChangeItem? onChangeItem;
  final EdgeInsets? padding;

  @override
  TabelaCampoState createState() => TabelaCampoState();
}

class TabelaCampoState extends State<TabelaCampo> {
  List<ItemTabela> _dados = [];
  Map<String, dynamic> dadosValues = {};
  List<ItemTabelaValues> _dadosValues = [];

  Map<String, Widget>? titulos;
  List<String>? ordem;
  late bool tabelaEstatica;

  int numPontos = 0;
  bool trocarNumPontos = true;

  LinkedScrollControllerGroup? _controllersVerticais;
  ScrollController? _controllerVertical1;
  ScrollController? _controllerVertical2;

  LinkedScrollControllerGroup? _controllersHorizontais;
  ScrollController? _controllerHorizontal1;
  ScrollController? _controllerHorizontal2;

  List<String> dropDownItems = [
    //"Mover Para Baixo",
    //"Mover Para Cima",
    "Editar Linha",
    //"Excluir Linha",
  ];

  @override
  void initState() {
    super.initState();
    _controllersVerticais = LinkedScrollControllerGroup();
    _controllerVertical1 = _controllersVerticais!.addAndGet();
    _controllerVertical2 = _controllersVerticais!.addAndGet();

    _controllersHorizontais = LinkedScrollControllerGroup();
    _controllerHorizontal1 = _controllersHorizontais!.addAndGet();
    _controllerHorizontal2 = _controllersHorizontais!.addAndGet();

    titulos = widget.titulos;
    _dados = widget.dados ?? [];
    dadosValues = widget.dadosValues ?? {};
    ordem = widget.ordem;
    tabelaEstatica = widget.tabelaEstatica;
  }

  @override
  void dispose() {
    _controllerVertical1!.dispose();
    _controllerVertical2!.dispose();

    _controllerHorizontal1!.dispose();
    _controllerHorizontal2!.dispose();
    super.dispose();
  }

  int get maxCols {
    int _max = 0;
    /*_dados.forEach((element) {
      if (element.keys().length >= _max) {
        _max = element.keys().length;
      }
    });*/
    _max = (ordem ?? []).length;

    return max(_max, titulos != null ? titulos!.length : 0);
  }

  void editDados(String key, String value) async {
    if (tabelaEstatica == true) {
      return;
    }

    /*if (item == 0 && value == "Mover Para Cima") {
      return;
    } else if (item == _dados.length - 1 && value == "Mover Para Baixo") {
      return;
    }*/

    if (value == "Editar Linha") {
      Map? ponto = await showDialog(
        context: context,
        builder: (ctx) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: NovoPonto(
              dados: dadosValues[key],
              onAdd: (Map<String, dynamic> val) {
                Navigator.of(context).pop(val);
              },
              onCancel: () {
                Navigator.of(context).pop();
              },
            ),
          );
        },
      );

      if (ponto != null) {
        setState(() {
          dadosValues[key] = ponto;
        });
      }
    } /*else if (value == "Excluir Linha") {
      setState(() {
        _dados.removeAt(item);
        _dadosValues.removeAt(item);
      });
    } else if (value == "Mover Para Baixo") {
      setState(() {
        _dados.insert(item + 2, _dados[item]);
        _dados.removeAt(item);

        _dadosValues.insert(item + 2, _dadosValues[item]);
        _dadosValues.removeAt(item);
      });
    } else if (value == "Mover Para Cima") {
      setState(() {
        _dados.insert(item - 1, _dados[item]);
        _dados.removeAt(item + 1);

        _dadosValues.insert(item - 1, _dadosValues[item]);
        _dadosValues.removeAt(item + 1);
      });
    }*/

    if (widget.onDataChange != null) {
      widget.onDataChange!([_dados, dadosValues]);
    }
  }

  @override
  Widget build(BuildContext context) {
    double ladosPadding = 20;
    double alturaPadding = 20;
    double pontosHeight = 56;
    double actionsWidth = 20;

    if (numPontos == 0) {
      dadosValues = widget.dadosValues ?? {};
      if (widget.dadosValues != null) {
        numPontos = widget.dadosValues!.length;
      }
    }

    if (widget.padding != null) {
      ladosPadding = widget.padding!.top + widget.padding!.bottom;
      alturaPadding = widget.padding!.left + widget.padding!.right;
    }

    double tableHeight = (_dados.length + 1) * widget.celulaHeight;
    double heightTotal = MediaQuery.of(context).size.height - ladosPadding;
    if (tableHeight > heightTotal) {
      tableHeight = heightTotal;
    }

    double tableWidth = maxCols * widget.celulaWidth;
    double widthTotal = MediaQuery.of(context).size.width - alturaPadding;
    if (tableWidth > widthTotal) {
      tableWidth = widthTotal;
    }

    tableHeight += 1;
    tableWidth += 1;

    if (!tabelaEstatica) {
      tableHeight += pontosHeight;
      if (numPontos == 0) {
        _dados = [];
        _dadosValues = [];
      }
    }

    while (dadosValues.length != numPontos) {
      if (dadosValues.length > numPontos) {
        dadosValues.remove(dadosValues.keys.toList().last);
      } else if (dadosValues.length < numPontos) {
        String estacao = intToText(numPontos);

        int index = numPontos - 1;

        String re = "-";
        String vante = "-";

        if (numPontos > 1) {
          int indexAns = index - 1;
          int indexDepois = index + 1;

          if (indexAns < 0) {
            indexAns = numPontos - 1;
          }
          if (indexDepois == numPontos) {
            indexDepois = 1;
          }

          re = intToText(indexAns, sub1: false);
          vante = intToText(indexDepois);
        }

        dadosValues[estacao] = {
          're': ItemTabelaValues(
            re: re,
            estacao: estacao,
            vante: "",
            angHorizontal: 0,
          ),
          'vante': ItemTabelaValues(
            re: re,
            estacao: estacao,
            vante: vante,
          ),
          'len': 2,
        };
      }
    }

    _dadosValues = [];
    int indexVal = 0;
    dadosValues.forEach(
      (key, value) {
        String re = "-";
        String vante = "-";

        if (numPontos > 1) {
          int indexAns = indexVal - 1;
          int indexDepois = indexVal + 1;

          if (indexAns < 0) {
            indexAns = numPontos - 1;
          }
          if (indexDepois == numPontos) {
            indexDepois = 0;
          }

          re = intToText(indexAns, sub1: false);
          vante = intToText(indexDepois, sub1: false);
        }

        ItemTabelaValues valRe = value['re'];
        ItemTabelaValues valVante = value['vante'];
        valRe.re = re;
        valVante.re = re;
        valVante.vante = vante;
        valVante.angHorizontal = (valVante.angHorizontal ?? 0) + (valVante.angHorizontalCorrigido ?? 0);

        _dadosValues.add(valRe);
        _dadosValues.add(valVante);

        if (value.containsKey("irradiacoes")) {
          for (ItemTabelaValues item in value['irradiacoes']) {
            _dadosValues.add(item);
          }
        }
        indexVal += 1;
      },
    );

    if (_dadosValues.length > 0) {
      _dados = [];
      for (ItemTabelaValues item in _dadosValues) {
        //String estaVante = item.estacao! + ((item.vante ?? "") == "" ? item.re! : item.vante!);
        //String reEsta = item.re! + item.estacao!;

        int index = _dadosValues.indexOf(item);
        String key = item.estacao!;

        ItemTabela dado = ItemTabela(
          re: Text(item.re ?? "-"),
          vante: Text(item.vante ?? "-"),
          estacao: Text(item.estacao ?? "-"),
          descricao: Text(item.descricao ?? "-"),
          alturaInst: Text((item.alturaInst ?? "-").toString()),
          angHorizontal: Text(toGrauMinSec((item.angHorizontal ?? 0))),
          angZenital: Text(toGrauMinSec(item.angZenital ?? 0.0)),
          azimute: Text(toGrauMinSec(item.azimute ?? 0.0)),
          distRed: Text((item.distRed ?? "-").toString()),
          fioInf: Text((item.fioInf ?? "-").toString()),
          fioMed: Text((item.fioMed ?? "-").toString()),
          fioSup: Text((item.fioSup ?? "-").toString()),
          abcRelX: Text((item.abcRelX ?? "-").toString()),
          abcRelY: Text((item.abcRelY ?? "-").toString()),
          abcAbsX: Text((item.abcAbsX ?? "-").toString()),
          abcAbsY: Text((item.abcAbsY ?? "-").toString()),
          angHorizontalCorrigido: TextGMSField(
            width: widget.celulaWidth,
            height: widget.celulaHeight,
            isNegative: true,
            angleInit: (item.angHorizontalCorrigido ?? 0),
            onChange: (val) {
              dadosValues[key]!['vante'].angHorizontalCorrigido = val;
              editDados("", "");
              setState(() {});
            },
          ),
        );

        _dados.add(dado);
      }
    }

    editDados("", "");

    return Container(
      margin: widget.padding ?? EdgeInsets.all(10),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 0.3,
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: tableWidth,
        maxHeight: tableHeight,
      ),
      //height: tableHeight,
      //width: tableWidth,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Numero de pontos
              Builder(
                builder: (ctx) {
                  if (tabelaEstatica == true) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: pontosHeight,
                    child: Row(
                      children: [
                        !kIsWeb
                            ? IconButton(
                                onPressed: () {
                                  trocarNumPontos = !trocarNumPontos;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(trocarNumPontos ? "O número de pontos está destravado, cuidado!" : "O número de pontos está travado novamente."),
                                    ),
                                  );
                                  setState(() {});
                                },
                                icon: Icon(trocarNumPontos ? Icons.lock_open : Icons.lock),
                                color: Cores.primaria,
                              )
                            : SizedBox(width: 10),
                        Text("Número de pontos:"),
                        trocarNumPontos && !kIsWeb
                            ? FittedBox(
                                child: NumberPicker(
                                  itemWidth: 200,
                                  minValue: 0,
                                  maxValue: numPontos + 2,
                                  value: numPontos,
                                  selectedTextStyle: TextStyle(color: Cores.preto, fontSize: 46),
                                  textStyle: TextStyle(color: Cores.preto.withOpacity(0.5), fontSize: 26),
                                  onChanged: (val) {
                                    if (trocarNumPontos) {
                                      numPontos = val;
                                      setState(() {});
                                    }
                                  },
                                ),
                              )
                            : Text(
                                "       " + numPontos.toString() + "       ",
                                style: TextStyle(fontSize: 18),
                              ),
                        trocarNumPontos && kIsWeb
                            ? IconButton(
                                onPressed: () {
                                  numPontos++;
                                  setState(() {});
                                },
                                icon: Icon(Icons.add),
                              )
                            : Container(),
                        trocarNumPontos && kIsWeb
                            ? IconButton(
                                onPressed: () {
                                  numPontos--;
                                  numPontos = max(0, numPontos);

                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.remove,
                                ),
                              )
                            : Container(),
                        Spacer(),
                      ],
                    ),
                  );
                },
              ),
              //Cabeçalho
              Row(
                children: [
                  //Cabeçalho
                  //Celula fixa
                  Celula(
                    value: titulos![ordem![0]],
                    color: Cores.primaria,
                    height: widget.celulaHeight,
                    width: widget.celulaWidth,
                  ),
                  SizedBox(
                    height: widget.celulaHeight,
                    width: max(
                      (constraints.maxWidth - widget.celulaWidth),
                      0,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _controllerHorizontal1,
                      itemBuilder: (ctx, i) {
                        if (tabelaEstatica == false && i == max(maxCols - 1, 0)) {
                          return SizedBox(width: actionsWidth);
                        }
                        return SizedBox(
                          height: widget.celulaHeight,
                          width: widget.celulaWidth,
                          child: Celula(
                            color: Cores.primaria,
                            value: titulos![ordem![i + 1]],
                          ),
                        );
                      },
                      itemCount: max(maxCols - 1, 0) + (tabelaEstatica == true ? 0 : 1),
                    ),
                  ),
                ],
              ),
              //Dados
              SizedBox(
                width: constraints.maxWidth,
                height: max(constraints.maxHeight - widget.celulaHeight * 1 - (tabelaEstatica ? 0 : pontosHeight), 0),
                child: Row(
                  children: [
                    //Adicionar a coluna fixa
                    SizedBox(
                      width: widget.celulaWidth,
                      height: max(
                        constraints.maxHeight - widget.celulaHeight,
                        0,
                      ),
                      child: ListView.builder(
                        controller: _controllerVertical1,
                        itemBuilder: (ctx, i) {
                          Widget valor = _dados[i].get(ordem![0]); //.toString();
                          return SizedBox(
                            width: widget.celulaWidth,
                            height: widget.celulaHeight,
                            child: Celula(
                              color: Cores.secundaria,
                              value: valor,
                            ),
                          );
                        },
                        itemCount: _dados.length,
                      ),
                    ),
                    //Linhas e colunas de conteudo
                    SizedBox(
                      width: max(constraints.maxWidth - widget.celulaWidth, 0),
                      height: max(
                        constraints.maxHeight - widget.celulaHeight,
                        0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _controllerVertical2,
                        child: Row(
                          children: [
                            //Celulas
                            SizedBox(
                              width: max(
                                constraints.maxWidth - widget.celulaWidth - ((tabelaEstatica != null && tabelaEstatica == true) ? 0 : actionsWidth),
                                0,
                              ),
                              height: (_dados.length) * widget.celulaHeight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _controllerHorizontal2,
                                child: SizedBox(
                                  height: (_dados.length) * widget.celulaHeight,
                                  width: max(maxCols - 1, 0) * widget.celulaWidth,
                                  child: Column(
                                    children: List.generate(
                                      _dados.length,
                                      (i_dado) => Row(
                                        children: List.generate(
                                          max(maxCols - 1, 0),
                                          (i_col) {
                                            dynamic valor = _dados[i_dado].get(ordem![i_col + 1]);
                                            if (valor == null) {
                                              valor = Text("-");
                                            }
                                            return SizedBox(
                                              width: widget.celulaWidth,
                                              height: widget.celulaHeight,
                                              child: Celula(
                                                color: i_dado % 2 == 0 ? Cores.branco : Cores.terciaria,
                                                value: valor,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Botões que executam ações na linha.
                            Builder(builder: (ctx) {
                              if (tabelaEstatica != null && tabelaEstatica == true) {
                                return const SizedBox(
                                  width: 0,
                                  height: 0,
                                );
                              }
                              return Expanded(
                                child: Column(
                                  children: List.generate(dadosValues.length, (i) {
                                    String key = dadosValues.keys.toList()[i];
                                    return Container(
                                      width: actionsWidth,
                                      height: widget.celulaHeight * dadosValues[key]!['len'],
                                      decoration: BoxDecoration(
                                        color: Cores.secundaria, //i % 2 == 0 ? Cores.secundaria : Cores.preto,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 0.3,
                                        ),
                                      ),
                                      child: FittedBox(
                                        child: PopupMenuButton(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 0,
                                          ),
                                          tooltip: "Opções",
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          icon: Icon(
                                            Icons.chevron_right,
                                          ),
                                          onSelected: (String value) {
                                            editDados(key, value);
                                          },
                                          itemBuilder: (ctx) {
                                            List<String> dropDownCopia = new List<String>.from(dropDownItems);
                                            if (i == 0) {
                                              dropDownCopia.remove("Mover Para Cima");
                                            }
                                            if (i == _dados.length - 1) {
                                              dropDownCopia.remove("Mover Para Baixo");
                                            }
                                            return dropDownCopia
                                                .map(
                                                  (e) => PopupMenuItem(
                                                    child: Column(
                                                      children: [
                                                        Text(e),
                                                        Divider(
                                                          color: Cores.secundaria,
                                                        ),
                                                      ],
                                                    ),
                                                    value: e,
                                                  ),
                                                )
                                                .toList();
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Linha para adicionar novos items
              /*Builder(
                builder: (ctx) {
                  if (tabelaEstatica == true) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: widget.celulaHeight,
                    child: Row(children: [
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          List? ponto = await showDialog(
                            context: context,
                            builder: (ctx) {
                              return Container(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                                ),
                                child: NovoPonto(
                                  onAdd: (ItemTabelaValues val) {
                                    ItemTabela retornar = ItemTabela(
                                      re: Text(val.re!),
                                      estacao: Text(val.estacao!),
                                      vante: Text(val.vante!),
                                      alturaInst: Text(
                                        val.alturaInst!.toString(),
                                      ),
                                      fioInf: Text(val.fioInf.toString()),
                                      fioSup: FittedBox(
                                        child: Text(val.fioSup.toString()),
                                      ),
                                      fioMed: Text(val.fioMed.toString()),
                                      angHorizontal: FittedBox(
                                        child: Text(
                                          toGrauMinSec(val.angHorizontal!),
                                        ),
                                      ),
                                      angZenital: FittedBox(
                                        child: Text(
                                          toGrauMinSec(val.angZenital!),
                                        ),
                                      ),
                                      descricao: Text(
                                        val.descricao!,
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );

                                    Navigator.of(context).pop([retornar, val]);
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          );

                          if (ponto != null) {
                            _dados.add(ponto[0]);
                            _dadosValues.add(ponto[1]);
                            setState(() {});
                          }

                          if (widget.onDataChange != null) {
                            widget.onDataChange!([_dados, _dadosValues]);
                          }
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            "Adicionar novo ponto +",
                            style: TextStyle(color: Cores.primaria),
                          ),
                        ),
                      ),
                    ]),
                  );
                },
              ),*/
            ],
          );
        },
      ),
    );
  }
}

class Celula extends StatelessWidget {
  Celula({
    required this.value,
    required this.color,
    this.height = 100,
    this.width = 100,
  });
  final dynamic value;
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.black,
            width: 0.3,
          ),
        ),
        child: Center(
          child: value,
        ),
      ),
    );
  }
}

class ItemTabela {
  ItemTabela({
    this.re,
    this.estacao,
    this.vante,
    this.descricao,
    this.alturaInst,
    this.angHorizontal,
    this.angHorizontalCorrigido,
    this.angZenital,
    this.azimute,
    this.distRed,
    this.fioInf,
    this.fioMed,
    this.fioSup,
    this.abcRelX,
    this.abcRelY,
    this.abcAbsX,
    this.abcAbsY,
  });

  final Widget? re;
  final Widget? estacao;
  final Widget? vante;
  final Widget? descricao;
  final Widget? alturaInst;
  final Widget? angHorizontal;
  final Widget? angHorizontalCorrigido;
  final Widget? angZenital;
  final Widget? azimute;
  final Widget? distRed;
  final Widget? fioInf;
  final Widget? fioMed;
  final Widget? fioSup;
  final Widget? abcRelX;
  final Widget? abcRelY;
  final Widget? abcAbsX;
  final Widget? abcAbsY;

  List<String> keys() {
    List<String> _keys = [];
    if (re != null) {
      _keys.add("re");
    }

    if (estacao != null) {
      _keys.add("estacao");
    }

    if (vante != null) {
      _keys.add("vante");
    }

    if (descricao != null) {
      _keys.add("descricao");
    }

    if (alturaInst != null) {
      _keys.add("alturaInst");
    }

    if (angHorizontal != null) {
      _keys.add("angHorizontal");
    }

    if (angHorizontalCorrigido != null) {
      _keys.add("angHorizontalCorrigido");
    }

    if (angZenital != null) {
      _keys.add("angZenital");
    }

    if (azimute != null) {
      _keys.add("azimute");
    }

    if (distRed != null) {
      _keys.add("distRed");
    }

    if (fioInf != null) {
      _keys.add("fioInf");
    }

    if (fioMed != null) {
      _keys.add("fioMed");
    }

    if (fioSup != null) {
      _keys.add("fioSup");
    }

    if (abcRelX != null) {
      _keys.add("abcRelX");
    }

    if (abcRelY != null) {
      _keys.add("abcRelY");
    }

    if (abcAbsX != null) {
      _keys.add("abcAbsX");
    }

    if (abcAbsY != null) {
      _keys.add("abcAbsY");
    }

    return _keys;
  }

  dynamic get(String key) {
    if (key == "re") {
      return re;
    }
    if (key == "estacao") {
      return estacao;
    }
    if (key == "vante") {
      return vante;
    }
    if (key == "descricao") {
      return descricao;
    }
    if (key == "descricao") {
      return descricao;
    }
    if (key == "alturaInst") {
      return alturaInst;
    }
    if (key == "angHorizontal") {
      return angHorizontal;
    }
    if (key == "angHorizontalCorrigido") {
      return angHorizontalCorrigido;
    }
    if (key == "angZenital") {
      return angZenital;
    }
    if (key == "azimute") {
      return azimute;
    }
    if (key == "distRed") {
      return distRed;
    }
    if (key == "fioInf") {
      return fioInf;
    }
    if (key == "fioMed") {
      return fioMed;
    }
    if (key == "fioSup") {
      return fioSup;
    }
    if (key == "abcRelX") {
      return abcRelX;
    }
    if (key == "abcRelY") {
      return abcRelY;
    }
    if (key == "abcAbsX") {
      return abcAbsX;
    }
    if (key == "abcAbsY") {
      return abcAbsY;
    }
  }
}

class ItemTabelaValues {
  ItemTabelaValues({
    this.re,
    this.estacao,
    this.vante,
    this.descricao,
    this.alturaInst,
    this.angHorizontal,
    this.angHorizontalCorrigido,
    this.angZenital,
    this.azimute,
    this.distRed,
    this.fioInf,
    this.fioMed,
    this.fioSup,
    this.abcRelX,
    this.abcRelY,
    this.abcAbsX,
    this.abcAbsY,
  });

  String? re;
  String? estacao;
  String? vante;
  String? descricao;
  double? alturaInst;
  double? angHorizontal;
  double? angHorizontalCorrigido;
  double? angZenital;
  double? azimute;
  double? distRed;
  double? fioInf;
  double? fioMed;
  double? fioSup;
  double? abcRelX;
  double? abcRelY;
  double? abcAbsX;
  double? abcAbsY;

  List<String> keys() {
    List<String> _keys = [];
    if (re != null) {
      _keys.add("re");
    }

    if (estacao != null) {
      _keys.add("estacao");
    }

    if (vante != null) {
      _keys.add("vante");
    }

    if (descricao != null) {
      _keys.add("descricao");
    }

    if (alturaInst != null) {
      _keys.add("alturaInst");
    }

    if (angHorizontal != null) {
      _keys.add("angHorizontal");
    }

    if (angHorizontalCorrigido != null) {
      _keys.add("angHorizontalCorrigido");
    }

    if (angZenital != null) {
      _keys.add("angZenital");
    }

    if (azimute != null) {
      _keys.add("azimute");
    }

    if (distRed != null) {
      _keys.add("distRed");
    }

    if (fioInf != null) {
      _keys.add("fioInf");
    }

    if (fioMed != null) {
      _keys.add("fioMed");
    }

    if (fioSup != null) {
      _keys.add("fioSup");
    }

    if (abcRelX != null) {
      _keys.add("abcRelX");
    }

    if (abcRelY != null) {
      _keys.add("abcRelY");
    }

    if (abcAbsX != null) {
      _keys.add("abcAbsX");
    }

    if (abcAbsY != null) {
      _keys.add("abcAbsY");
    }

    return _keys;
  }

  dynamic get(String key) {
    if (key == "re") {
      return re;
    }
    if (key == "estacao") {
      return estacao;
    }
    if (key == "vante") {
      return vante;
    }
    if (key == "descricao") {
      return descricao;
    }
    if (key == "descricao") {
      return descricao;
    }
    if (key == "alturaInst") {
      return alturaInst;
    }
    if (key == "angHorizontal") {
      return angHorizontal;
    }
    if (key == "angHorizontalCorrigido") {
      return angHorizontalCorrigido;
    }
    if (key == "angZenital") {
      return angZenital;
    }
    if (key == "azimute") {
      return azimute;
    }
    if (key == "distRed") {
      return distRed;
    }
    if (key == "fioInf") {
      return fioInf;
    }
    if (key == "fioMed") {
      return fioMed;
    }
    if (key == "fioSup") {
      return fioSup;
    }
    if (key == "abcRelX") {
      return abcRelX;
    }
    if (key == "abcRelY") {
      return abcRelY;
    }
    if (key == "abcAbsX") {
      return abcAbsX;
    }
    if (key == "abcAbsY") {
      return abcAbsY;
    }
  }
}

List<ItemTabelaValues> getTableSave(String path) {
  List<ItemTabelaValues> dadosReturn = [];
  List dados = [];
  File arq = File(path);
  if (arq.existsSync()) {
    dados = jsonDecode(arq.readAsStringSync());

    for (Map dado in dados) {
      dadosReturn.add(
        ItemTabelaValues(
          re: dado['re'],
          estacao: dado['estacao'],
          vante: dado['vante'],
          descricao: dado['descricao'],
          alturaInst: (dado['alturaInst'] ?? 0.0).toDouble(),
          angHorizontal: (dado['angHorizontal'] ?? 0.0).toDouble(),
          angHorizontalCorrigido: (dado['angHorizontalCorrigido'] ?? 0.0).toDouble(),
          angZenital: (dado['angZenital'] ?? 0.0).toDouble(),
          azimute: (dado['azimute'] ?? 0.0).toDouble(),
          distRed: (dado['distRed'] ?? 0.0).toDouble(),
          fioInf: (dado['fioInf'] ?? 0.0).toDouble(),
          fioMed: (dado['fioMed'] ?? 0.0).toDouble(),
          fioSup: (dado['fioSup'] ?? 0.0).toDouble(),
          abcRelX: (dado['abcRelX'] ?? 0.0).toDouble(),
          abcRelY: (dado['abcRelY'] ?? 0.0).toDouble(),
          abcAbsX: (dado['abcAbsX'] ?? 0.0).toDouble(),
          abcAbsY: (dado['abcAbsY'] ?? 0.0).toDouble(),
        ),
      );
    }
    return dadosReturn;
  } else {
    return [];
  }
}

bool setTableSave(String path, List<ItemTabelaValues> dados) {
  List<Map> dadosSave = [];
  File arq = File(path);
  try {
    for (ItemTabelaValues dado in dados) {
      dadosSave.add(
        {
          're': dado.re ?? "",
          'estacao': dado.estacao ?? "",
          'vante': dado.vante ?? "",
          'descricao': dado.descricao ?? "",
          'alturaInst': dado.alturaInst ?? 0,
          'angHorizontal': dado.angHorizontal ?? 0,
          'angHorizontalCorrigido': dado.angHorizontalCorrigido ?? 0,
          'angZenital': dado.angZenital ?? 0,
          'azimute': dado.azimute ?? 0,
          'distRed': dado.distRed ?? 0,
          'fioInf': dado.fioInf ?? 0,
          'fioMed': dado.fioMed ?? 0,
          'fioSup': dado.fioSup ?? 0,
          'abcRelX': dado.abcRelX ?? 0,
          'abcRelY': dado.abcRelY ?? 0,
          'abcAbsX': dado.abcAbsX ?? 0,
          'abcAbsY': dado.abcAbsY ?? 0,
        },
      );
    }

    String dadosWrite = jsonEncode(dadosSave);
    arq.writeAsStringSync(dadosWrite);
    return true;
  } catch (e) {
    return false;
  }
}

List<Map> tableToJson(List<ItemTabelaValues> dados) {
  List<Map> dadosSave = [];
  for (ItemTabelaValues dado in dados) {
    dadosSave.add(
      {
        're': dado.re ?? "",
        'estacao': dado.estacao ?? "",
        'vante': dado.vante ?? "",
        'descricao': dado.descricao ?? "",
        'alturaInst': dado.alturaInst ?? 0,
        'angHorizontal': dado.angHorizontal ?? 0,
        'angHorizontalCorrigido': dado.angHorizontalCorrigido ?? 0,
        'angZenital': dado.angZenital ?? 0,
        'azimute': dado.azimute ?? 0,
        'distRed': dado.distRed ?? 0,
        'fioInf': dado.fioInf ?? 0,
        'fioMed': dado.fioMed ?? 0,
        'fioSup': dado.fioSup ?? 0,
        'abcRelX': dado.abcRelX ?? 0,
        'abcRelY': dado.abcRelY ?? 0,
        'abcAbsX': dado.abcAbsX ?? 0,
        'abcAbsY': dado.abcAbsY ?? 0,
      },
    );
  }

  return dadosSave;
}

List<ItemTabelaValues> jsonToTable(List dados) {
  List<ItemTabelaValues> dadosReturn = [];

  for (Map dado in dados) {
    dadosReturn.add(
      ItemTabelaValues(
        re: dado['re'],
        estacao: dado['estacao'],
        vante: dado['vante'],
        descricao: dado['descricao'],
        alturaInst: (dado['alturaInst'] ?? 0.0).toDouble(),
        angHorizontal: (dado['angHorizontal'] ?? 0.0).toDouble(),
        angHorizontalCorrigido: (dado['angHorizontalCorrigido'] ?? 0.0).toDouble(),
        angZenital: (dado['angZenital'] ?? 0.0).toDouble(),
        azimute: (dado['azimute'] ?? 0.0).toDouble(),
        distRed: (dado['distRed'] ?? 0.0).toDouble(),
        fioInf: (dado['fioInf'] ?? 0.0).toDouble(),
        fioMed: (dado['fioMed'] ?? 0.0).toDouble(),
        fioSup: (dado['fioSup'] ?? 0.0).toDouble(),
        abcRelX: (dado['abcRelX'] ?? 0.0).toDouble(),
        abcRelY: (dado['abcRelY'] ?? 0.0).toDouble(),
        abcAbsX: (dado['abcAbsX'] ?? 0.0).toDouble(),
        abcAbsY: (dado['abcAbsY'] ?? 0.0).toDouble(),
      ),
    );
  }

  return dadosReturn;
}

List<ItemTabelaValues> mapTabelaToListTabela(Map<String, Map> dados) {
  List<ItemTabelaValues> dadosReturn = [];

  dados.forEach((key, value) {
    dadosReturn.add(value['re']);
    dadosReturn.add(value['vante']);
    if (value.containsKey("irradiacoes")) {
      for (ItemTabelaValues item in value['irradiacoes']) {
        dadosReturn.add(item);
      }
    }
  });

  return dadosReturn;
}

Map<String, Map> listTabelaToMapTabela(List<ItemTabelaValues> dados) {
  Map<String, Map> dadosReturn = {};

  List<String> pontos = [];
  for (ItemTabelaValues item in dados) {
    if (!pontos.contains(item.estacao)) {
      pontos.add(item.estacao!);
    }
  }

  List<String> irradiacoes = [];
  for (ItemTabelaValues item in dados) {
    if (!pontos.contains(item.vante) && item.vante! != "") {
      irradiacoes.add(item.vante!);
    }
  }

  for (ItemTabelaValues item in dados) {
    String estacao = item.estacao!;
    //String vante = item.estacao!;
    //String re = item.estacao!;

    if (!dadosReturn.containsKey(estacao)) {
      dadosReturn[estacao] = {};
    }

    if (item.vante == "") {
      dadosReturn[estacao]!['re'] = item;
      dadosReturn[estacao]!['len'] = (dadosReturn[estacao]!['len'] ?? 0) + 1;
    } else if (item.vante != "" && irradiacoes.contains(item.vante)) {
      if (dadosReturn[estacao]!['irradiacoes'] == null) {
        dadosReturn[estacao]!['irradiacoes'] = [];
      }
      dadosReturn[estacao]!['irradiacoes'].add(item);
      dadosReturn[estacao]!['len'] = (dadosReturn[estacao]!['len'] ?? 0) + 1;
    } else if (item.vante != "" && pontos.contains(item.vante)) {
      dadosReturn[estacao]!['vante'] = item;
      dadosReturn[estacao]!['len'] = (dadosReturn[estacao]!['len'] ?? 0) + 1;
    }
  }

  return dadosReturn;
}
