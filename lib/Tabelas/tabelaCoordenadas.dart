/*
  A tabela recebe uma lista de dados que vão conter os dados de re, estação, vante
  descrição, altura do instrumento angulos, fios
*/

/*
Ponto | Ré | Estação | Vante | Descrição |  Altura do  |         Ângulo       |        Fios        |
      |    |         |       |           | Instrumento | Horizontal | Zenital | Sup. | Méd. | Inf. |

*/
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:topografia/Paleta/cores.dart';

typedef OnDataChange<ItemTabela> = void Function(List<ItemTabela> value);

class TabelaCoords extends StatefulWidget {
  TabelaCoords(
    this.dados, {
    Key? key,
    required this.titulos,
    required this.ordem,
    this.celulaHeight = 100,
    this.celulaWidth = 100,
    this.onDataChange,
  }) : super(key: key);

  final List<ItemTabela> dados;
  final Map<String, String>? titulos;
  final List<String>? ordem;
  final double celulaWidth;
  final double celulaHeight;
  final OnDataChange? onDataChange;

  @override
  TabelaCoordsState createState() => TabelaCoordsState();
}

class TabelaCoordsState extends State<TabelaCoords> {
  List<ItemTabela>? dados;
  Map<String, String>? titulos;
  List<String>? ordem;

  LinkedScrollControllerGroup? _controllersVerticais;
  ScrollController? _controllerVertical1;
  ScrollController? _controllerVertical2;

  LinkedScrollControllerGroup? _controllersHorizontais;
  ScrollController? _controllerHorizontal1;
  ScrollController? _controllerHorizontal2;

  List<String> dropDownItems = [
    "Mover Para Baixo",
    "Mover Para Cima",
    "Editar Linha",
    "Excluir Linha",
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
  }

  @override
  void dispose() {
    _controllerVertical1!.dispose();
    _controllerVertical2!.dispose();

    _controllerHorizontal1!.dispose();
    _controllerHorizontal2!.dispose();
    super.dispose();
  }

  int maxCols() {
    int max = 0;
    dados!.forEach((element) {
      if (element.keys().length >= max) {
        max = element.keys().length;
      }
    });
    return max;
  }

  void editDados(int item, String value) async {
    if (item == 0 && value == "Mover Para Cima") {
      return;
    } else if (item == dados!.length - 1 && value == "Mover Para Baixo") {
      return;
    }

    if (value == "Editar Linha") {
      //TODO: Adicionar editar linha
    } else if (value == "Excluir Linha") {
      setState(() {
        dados!.removeAt(item);
      });
    } else if (value == "Mover Para Baixo") {
      setState(() {
        dados!.insert(item + 2, dados![item]);
        dados!.removeAt(item);
      });
    } else if (value == "Mover Para Cima") {
      setState(() {
        dados!.insert(item - 1, dados![item]);
        dados!.removeAt(item + 1);
      });
    }

    widget.onDataChange!(dados!);
  }

  @override
  Widget build(BuildContext context) {
    titulos = widget.titulos;
    dados = widget.dados;
    ordem = widget.ordem;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 0.3,
        ),
      ),
      height: (dados!.length + 1) * widget.celulaHeight >
              MediaQuery.of(context).size.height
          ? MediaQuery.of(context).size.height
          : (dados!.length + 1) * widget.celulaHeight,
      width: maxCols() * widget.celulaWidth > MediaQuery.of(context).size.width
          ? MediaQuery.of(context).size.width
          : maxCols() * widget.celulaWidth,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    width: (constraints.maxWidth - widget.celulaWidth) - 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _controllerHorizontal1,
                      itemBuilder: (ctx, i) {
                        return SizedBox(
                          height: widget.celulaHeight,
                          width: widget.celulaWidth,
                          child: Celula(
                            color: Cores.primaria,
                            value: titulos![ordem![i + 1]],
                          ),
                        );
                      },
                      itemCount: maxCols() - 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight - widget.celulaHeight,
                child: Row(
                  children: [
                    //Adicionar a coluna fixa
                    SizedBox(
                      width: widget.celulaWidth,
                      height: constraints.maxHeight - widget.celulaHeight,
                      child: ListView.builder(
                        controller: _controllerVertical1,
                        itemBuilder: (ctx, i) {
                          String valor = dados![i].get(ordem![0]).toString();
                          return SizedBox(
                            width: widget.celulaWidth,
                            height: widget.celulaHeight,
                            child: Celula(
                              color: Cores.secundaria,
                              value: valor,
                            ),
                          );
                        },
                        itemCount: dados!.length,
                      ),
                    ),
                    //Linhas e colunas de conteudo
                    SizedBox(
                      width: constraints.maxWidth - widget.celulaWidth,
                      height: constraints.maxHeight - widget.celulaHeight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _controllerVertical2,
                        child: Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth -
                                  widget.celulaWidth -
                                  40,
                              height: (dados!.length) * widget.celulaHeight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _controllerHorizontal2,
                                child: SizedBox(
                                  height: (dados!.length) * widget.celulaHeight,
                                  width: (maxCols() - 1) * widget.celulaWidth,
                                  child: Column(
                                    children: List.generate(
                                      dados!.length,
                                      (i_dado) => Row(
                                        children: List.generate(
                                          maxCols() - 1,
                                          (i_col) {
                                            dynamic valor = dados![i_dado]
                                                .get(ordem![i_col + 1]);
                                            if (valor == null) {
                                              valor = "-";
                                            }
                                            return SizedBox(
                                              width: widget.celulaWidth,
                                              height: widget.celulaHeight,
                                              child: Celula(
                                                color: i_dado % 2 == 0
                                                    ? Cores.branco
                                                    : Cores.terciaria,
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
                            Expanded(
                              child: Column(
                                children: List.generate(dados!.length, (i) {
                                  return Container(
                                    width: 40,
                                    height: widget.celulaHeight,
                                    decoration: BoxDecoration(
                                      color: i % 2 == 0
                                          ? Cores.branco
                                          : Cores.terciaria,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 0.3,
                                      ),
                                    ),
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
                                        editDados(i, value);
                                      },
                                      itemBuilder: (ctx) {
                                        List<String> dropDownCopia =
                                            new List<String>.from(
                                                dropDownItems);
                                        if (i == 0) {
                                          dropDownCopia
                                              .remove("Mover Para Cima");
                                        }
                                        if (i == dados!.length - 1) {
                                          dropDownCopia
                                              .remove("Mover Para Baixo");
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
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Celula extends StatelessWidget {
  Celula(
      {required this.value,
      required this.color,
      this.height = 100,
      this.width = 100});
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
          child: Text("$value"),
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
    this.angZenital,
    this.fioInf,
    this.fioMed,
    this.fioSup,
  });

  final String? re;
  final String? estacao;
  final String? vante;
  final String? descricao;
  final double? alturaInst;
  final double? angHorizontal;
  final double? angZenital;
  final double? fioInf;
  final double? fioMed;
  final double? fioSup;

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

    if (angZenital != null) {
      _keys.add("angZenital");
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
    if (key == "angZenital") {
      return angZenital;
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
  }
}
