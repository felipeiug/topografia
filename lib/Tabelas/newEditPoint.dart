import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Codigos/geradorDePoligonos.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';

typedef OnAddPoint = void Function(Map<String, dynamic> value);

class NovoPonto extends StatefulWidget {
  NovoPonto({
    this.dados,
    this.onAdd,
    this.onCancel,
    this.calcAll,
    Key? key,
  }) : super(key: key);

  final Map? dados;
  final OnAddPoint? onAdd;
  final VoidCallback? onCancel;
  final bool? calcAll;

  @override
  NovoPontoState createState() => NovoPontoState();
}

class NovoPontoState extends State<NovoPonto> {
  bool jaAddPonto = false;

  Map dados = {
    "vante": ItemTabelaValues(),
    "re": ItemTabelaValues(),
    "irradiacoes": <ItemTabelaValues>[],
  };

  TextEditingController? altInst;

  TextEditingController? fioInfVante;
  TextEditingController? fioMedVante;
  TextEditingController? fioSupVante;
  TextEditingController? descricaoVante;

  TextEditingController? fioInfRe;
  TextEditingController? fioMedRe;
  TextEditingController? fioSupRe;
  TextEditingController? descricaoRe;

  List<ItemTabelaValues> irradiacoes = [];

  double angZenitalAB = 0.0;
  double angZenitalBA = 0.0;
  double angHorizontal = 0.0;

  @override
  void initState() {
    //widget.dados.
    super.initState();

    dados = widget.dados ??
        {
          "vante": ItemTabelaValues(),
          "re": ItemTabelaValues(),
          "irradiacoes": <ItemTabelaValues>[],
        };

    altInst = TextEditingController(text: (dados['vante'].alturaInst ?? 0.0).toString());

    fioInfVante = TextEditingController(text: (dados['vante'].fioInf ?? 0.0).toString());
    fioMedVante = TextEditingController(text: (dados['vante'].fioMed ?? 0.0).toString());
    fioSupVante = TextEditingController(text: (dados['vante'].fioSup ?? 0.0).toString());
    descricaoVante = TextEditingController(text: (dados['vante'].descricao ?? ""));
    angZenitalAB = dados['vante'].angZenital ?? 0.0;

    fioInfRe = TextEditingController(text: (dados['re'].fioInf ?? 0.0).toString());
    fioMedRe = TextEditingController(text: (dados['re'].fioMed ?? 0.0).toString());
    fioSupRe = TextEditingController(text: (dados['re'].fioSup ?? 0.0).toString());
    descricaoRe = TextEditingController(text: (dados['re'].descricao ?? ""));
    angZenitalBA = dados['re'].angZenital ?? 0.0;

    angHorizontal = dados['vante'].angHorizontal ?? 0.0;

    irradiacoes = [];

    for (ItemTabelaValues item in dados['irradiacoes'] ?? []) {
      irradiacoes.add(
        item,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double irradiacoesHeight = kIsWeb ? 76 : 56;
    double irradiacoesWidth = 112;

    String estacao = dados['vante'].estacao ?? "";
    String re = dados['vante'].re ?? "";
    String vante = dados['vante'].vante ?? "";

    List<Widget> widgetIrradiacoes = [];

    //Irradiações
    for (ItemTabelaValues item in irradiacoes) {
      List<Widget> widgets = [];

      item.alturaInst = double.tryParse(altInst!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0;

      TextEditingController fs = TextEditingController(text: (item.fioSup ?? 0.0).toString().replaceAll(".", ","));
      TextEditingController fm = TextEditingController(text: (item.fioMed ?? 0.0).toString().replaceAll(".", ","));
      TextEditingController fi = TextEditingController(text: (item.fioInf ?? 0.0).toString().replaceAll(".", ","));
      TextEditingController des = TextEditingController(text: item.descricao ?? "");
      double angZenital = item.angZenital ?? 0;
      double angHorizontal = item.angHorizontal ?? 0;

      String vanteKey = item.estacao! + (irradiacoes.indexOf(item) + 1).toString();
      if (item.vante != vanteKey) {
        item.vante = vanteKey;
      }

      //Ponto
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Text(
            item.vante ?? "",
            textAlign: TextAlign.center,
          ),
        ),
      );

      //Fio Superior
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Fio Superior",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              SizedBox(
                height: kIsWeb ? 40 : 25,
                child: Focus(
                  onFocusChange: (focus) {
                    if (focus) {
                      fs.text = "";
                    } else {
                      double num = double.tryParse(fs.text.replaceAll(",", ".")) ?? 0;
                      num = num.abs();
                      fs.text = num.abs().toString().replaceAll(".", ",");
                      item.fioSup = num;
                    }
                    setState(() {});
                  },
                  child: TextField(
                    controller: fs,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      //Fio Medio
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 05, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Fio Médio",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              SizedBox(
                height: kIsWeb ? 40 : 25,
                child: Focus(
                  onFocusChange: (focus) {
                    if (focus) {
                      fm.text = "";
                    } else {
                      double num = double.tryParse(fm.text.replaceAll(",", ".")) ?? 0;
                      num = num.abs();
                      fm.text = num.abs().toString().replaceAll(".", ",");
                      item.fioMed = num;
                    }
                    setState(() {});
                  },
                  child: TextField(
                    controller: fm,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      //Fio Inferior
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Fio Inferior",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              SizedBox(
                height: kIsWeb ? 40 : 25,
                child: Focus(
                  onFocusChange: (focus) {
                    if (focus) {
                      fi.text = "";
                    } else {
                      double num = double.tryParse(fi.text.replaceAll(",", ".")) ?? 0;
                      num = num.abs();
                      fi.text = num.abs().toString().replaceAll(".", ",");
                      item.fioInf = num;
                    }
                    setState(() {});
                  },
                  child: TextField(
                    controller: fi,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      //Erro dos fios
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Text(
            "Erro Fios:\n" + (toFour((((item.fioSup ?? 0) + (item.fioInf ?? 0)) / 2) - (item.fioMed ?? 0)) * 2).toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: ((((item.fioSup ?? 0) + (item.fioInf ?? 0)) / 2) - (item.fioMed ?? 0)).abs() > 0.003 ? Colors.red : Cores.preto,
            ),
          ),
        ),
      );

      //Ang. Zenital
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Angulo Zenital:",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              Spacer(),
              TextGMSField(
                width: 70,
                height: 38,
                angleInit: angZenital,
                decimalDigits: false,
                onChange: (val) {
                  item.angZenital = val;
                },
              ),
            ],
          ),
        ),
      );

      //Ang. Horizontal
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Angulo Horizontal:",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              Spacer(),
              TextGMSField(
                width: 70,
                height: 38,
                angleInit: angHorizontal,
                decimalDigits: false,
                onChange: (val) {
                  item.angHorizontal = val;
                },
              ),
            ],
          ),
        ),
      );

      //Descrição
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Text(
                  "Descrição",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 8),
                ),
              ),
              SizedBox(
                height: kIsWeb ? 40 : 25,
                child: Focus(
                  onFocusChange: (focus) {
                    if (focus) {
                      des.text = "";
                    } else {
                      item.descricao = des.text;
                    }
                    setState(() {});
                  },
                  child: TextField(
                    controller: des,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      //Remover irradiação
      widgets.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Cores.preto),
              vertical: BorderSide(color: Cores.terciaria),
            ),
          ),
          height: irradiacoesHeight,
          width: irradiacoesWidth,
          child: IconButton(
            onPressed: () {
              irradiacoes.remove(item);
              setState(() {});
            },
            icon: Icon(Icons.delete),
          ),
        ),
      );

      widgetIrradiacoes.add(
        Row(
          children: widgets,
        ),
      );
    }

    return AlertDialog(
      contentPadding: EdgeInsets.all(5),
      backgroundColor: Cores.branco,
      title: Text("Leitura no Teodolito"),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SizedBox(
          //height: constrains.maxHeight,
          width: MediaQuery.of(context).size.width * 0.3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Divider(),
                //Altura instrumento
                Row(
                  children: [
                    Text(
                      "Altura do\ninstrumento:",
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                    //Alt. Instrumento
                    SizedBox(
                      width: 70,
                      child: Focus(
                        onFocusChange: (focus) {
                          if (focus) {
                            altInst!.text = "";
                          } else {
                            double num = double.tryParse(altInst!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0;
                            num = num.abs();
                            altInst!.text = num.abs().toString().replaceAll(".", ",") + " m";
                            dados['vante'].alturaInst = num;
                            dados['re'].alturaInst = num;
                          }
                          setState(() {});
                        },
                        child: TextField(
                          controller: altInst,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 2),
                Text("Mire no ponto $re e zere o ângulo horizontal do equipamento"),
                Divider(thickness: 2, color: Cores.primaria),
                Text("Para a Ré"),
                //Fios Ré
                SizedBox(
                  //width: MediaQuery.of(context).size.width,
                  height: 96,
                  child: GridView.count(
                    childAspectRatio: 1 / 0.3,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: [
                      Center(
                        child: Text(
                          "Fio Superior:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Fio Médio:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Fio Inferior:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioSupRe!.text = "";
                            } else {
                              double num = double.tryParse(fioSupRe!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioSupRe!.text = num.abs().toString().replaceAll(".", ",");
                              dados['re'].fioSup = num;
                            }

                            setState(() {});
                          },
                          child: TextField(
                            controller: fioSupRe,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioMedRe!.text = "";
                            } else {
                              double num = double.tryParse(fioMedRe!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioMedRe!.text = num.abs().toString().replaceAll(".", ",");
                              dados['re'].fioMed = num;
                            }
                            setState(() {});
                          },
                          child: TextField(
                            controller: fioMedRe,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioInfRe!.text = "";
                            } else {
                              double num = double.tryParse(fioInfRe!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioInfRe!.text = num.abs().toString().replaceAll(".", ",");
                              dados['re'].fioInf = num;
                            }
                            setState(() {});
                          },
                          child: TextField(
                            controller: fioInfRe,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Media dos fios
                Text(
                  "Erro de leitura: " + (toFour((((double.tryParse((fioSupRe!.text.replaceAll(",", "."))) ?? 0) + (double.tryParse(fioInfRe!.text.replaceAll(",", ".")) ?? 0)) / 2) - (double.tryParse(fioMedRe!.text.replaceAll(",", ".")) ?? 0)) * 2).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: ((((double.tryParse(fioSupRe!.text.replaceAll(",", ".")) ?? 0) + (double.tryParse(fioInfRe!.text.replaceAll(",", ".")) ?? 0)) / 2) - (double.tryParse(fioMedRe!.text.replaceAll(",", ".")) ?? 0)).abs() > 0.003 ? Colors.red : Cores.preto,
                  ),
                ),
                Divider(thickness: 2),
                //Ang. Zenital Re
                Row(
                  children: [
                    Text(
                      "Angulo Zenital\n${estacao + "-" + re}:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                    TextGMSField(
                      width: 150,
                      height: 60,
                      angleInit: angZenitalBA,
                      decimalDigits: true,
                      onChange: (val) {
                        angZenitalBA = val;
                        dados['re'].angZenital = val;
                      },
                    ),
                  ],
                ),
                Divider(thickness: 2),
                //Descrição
                SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Focus(
                    onFocusChange: (focus) {
                      if (focus) {
                        descricaoRe!.text = "";
                      } else {
                        dados['re'].descricao = descricaoRe!.text;
                      }
                    },
                    child: TextFormField(
                      controller: descricaoRe,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Descrição",
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Divider(thickness: 2, color: Cores.primaria),

                //////////////Vante//////////////////

                Text("Para a Vante"),
                //Fios Vante
                SizedBox(
                  //width: MediaQuery.of(context).size.width - 20,
                  height: 96,
                  child: GridView.count(
                    childAspectRatio: 1 / 0.3,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: [
                      Center(
                        child: Text(
                          "Fio Superior:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Fio Médio:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Fio Inferior:",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioSupVante!.text = "";
                            } else {
                              double num = double.tryParse(fioSupVante!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioSupVante!.text = num.abs().toString().replaceAll(".", ",");
                              dados['vante'].fioSup = num;
                            }

                            setState(() {});
                          },
                          child: TextField(
                            controller: fioSupVante,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioMedVante!.text = "";
                            } else {
                              double num = double.tryParse(fioMedVante!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioMedVante!.text = num.abs().toString().replaceAll(".", ",");
                              dados['vante'].fioMed = num;
                            }
                            setState(() {});
                          },
                          child: TextField(
                            controller: fioMedVante,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        child: Focus(
                          onFocusChange: (focus) {
                            if (focus) {
                              fioInfVante!.text = "";
                            } else {
                              double num = double.tryParse(fioInfVante!.text.replaceAll(",", ".")) ?? 0;
                              num = num.abs();
                              fioInfVante!.text = num.abs().toString().replaceAll(".", ",");
                              dados['vante'].fioInf = num;
                            }
                            setState(() {});
                          },
                          child: TextField(
                            controller: fioInfVante,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Media dos fios
                Text(
                  "Erro de leitura: " + (toFour((((double.tryParse((fioSupVante!.text.replaceAll(",", "."))) ?? 0) + (double.tryParse(fioInfVante!.text.replaceAll(",", ".")) ?? 0)) / 2) - (double.tryParse(fioMedVante!.text.replaceAll(",", ".")) ?? 0)) * 2).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: ((((double.tryParse(fioSupVante!.text.replaceAll(",", ".")) ?? 0) + (double.tryParse(fioInfVante!.text.replaceAll(",", ".")) ?? 0)) / 2) - (double.tryParse(fioMedVante!.text.replaceAll(",", ".")) ?? 0)).abs() > 0.003 ? Colors.red : Cores.preto,
                  ),
                ),
                Divider(thickness: 2),
                //Ang. Zenital Vante
                Row(
                  children: [
                    Text(
                      "Angulo Zenital\n${estacao + "-" + vante}:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                    TextGMSField(
                      width: 150,
                      height: 60,
                      angleInit: angZenitalAB,
                      decimalDigits: true,
                      onChange: (val) {
                        angZenitalAB = val;
                        dados['vante'].angZenital = val;
                      },
                    ),
                  ],
                ),
                Divider(thickness: 2),
                //Descrição
                SizedBox(
                  //width: MediaQuery.of(context).size.width - 20,
                  child: Focus(
                    onFocusChange: (focus) {
                      if (focus) {
                        descricaoVante!.text = "";
                      } else {
                        dados['vante'].descricao = descricaoVante!.text;
                      }
                    },
                    child: TextFormField(
                      controller: descricaoVante,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Descrição",
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Divider(thickness: 2, color: Cores.primaria),

                //////////////Ang. Horizontal//////////////////

                Text("Ângulo horizontal entre a Ré e Vante"),
                //Ang. Horizontal Vante
                Row(
                  children: [
                    Text(
                      "Angulo Horizontal\n${re + "-" + estacao + "-" + vante}:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                    TextGMSField(
                      width: 150,
                      height: 60,
                      angleInit: angHorizontal,
                      decimalDigits: true,
                      onChange: (val) {
                        angHorizontal = val;
                        dados['vante'].angHorizontal = val;
                      },
                    ),
                  ],
                ),
                Divider(thickness: 2, color: Cores.primaria),

                //////////////Irradiações//////////////////

                Text("Irradiações"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    //width: irradiacoesWidth * 6,
                    height: irradiacoes.length * irradiacoesHeight,
                    child: Column(
                      children: widgetIrradiacoes,
                    ),
                  ),
                ),
                //Nova irradiação
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        irradiacoes.add(
                          ItemTabelaValues(
                            estacao: estacao,
                            re: re,
                            vante: estacao + (irradiacoes.length + 1).toString(),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: 76.0,
          height: 36.0,
          child: OutlinedButton(
            onPressed: () {
              if (widget.onAdd != null) {
                dados['vante'] = ItemTabelaValues(
                  re: dados['vante'].re,
                  estacao: dados['vante'].estacao,
                  vante: dados['vante'].vante,
                  descricao: descricaoVante!.text,
                  alturaInst: double.tryParse(altInst!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  angHorizontal: angHorizontal,
                  angZenital: angZenitalAB,
                  fioInf: double.tryParse(fioInfVante!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  fioMed: double.tryParse(fioMedVante!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  fioSup: double.tryParse(fioSupVante!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                );

                dados['re'] = ItemTabelaValues(
                  re: dados['re'].re,
                  estacao: dados['re'].estacao,
                  vante: "",
                  descricao: descricaoVante!.text,
                  alturaInst: double.tryParse(altInst!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  angHorizontal: 0.0,
                  angZenital: angZenitalBA,
                  fioInf: double.tryParse(fioInfRe!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  fioMed: double.tryParse(fioMedRe!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                  fioSup: double.tryParse(fioSupRe!.text.replaceAll(",", ".").replaceAll(" m", "")) ?? 0.0,
                );

                Map<String, dynamic> retornar = {
                  'vante': dados['vante'],
                  're': dados['re'],
                  'irradiacoes': irradiacoes,
                  'len': irradiacoes.length + 2,
                };

                widget.onAdd!(retornar);
              }
            },
            child: Text(
              "Feito",
              style: TextStyle(
                color: Cores.preto,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
