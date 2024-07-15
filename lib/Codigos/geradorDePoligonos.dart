///Aqui ficam alguns widgets padrào em todo o app
///

import 'dart:math';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Tabelas/tabelaCampo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

String intToText(int num, {bool sub1 = true}) {
  List<String> alfabeto = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

  if (sub1) {
    num = num - 1;
  }

  List<int> letras = [];

  if (num > alfabeto.length - 1) {
    int resto = 0;
    int valor = num;
    int valorAns = valor;
    bool sair = false;

    while (!sair) {
      valor = valor ~/ alfabeto.length;

      resto = valorAns - valor * alfabeto.length;

      letras.add(resto);

      if (valor < alfabeto.length) {
        letras.add(valor);
        break;
      }

      valorAns = valor;
    }
  } else {
    letras.add(num);
  }

  String texto = "";
  letras = List.from(letras.reversed);
  letras.forEach((e) {
    texto += alfabeto[e];
  });

  return texto;
}

/*
  returns a String with degres, minutes and secondsa
  */
String toGrauMinSec(double ang) {
  int _ang = ang ~/ 1;
  int min = ((ang.abs() % 1) * 60).toInt();
  int sec = int.parse(((ang.abs() - _ang.abs() - min / 60) * 3600).toStringAsFixed(0));

  return _ang.toString().padLeft(2, "0") + "°" + min.toString().padLeft(2, "0") + "'" + sec.toString().padLeft(2, "0") + '"';
}

/*
  returns a double with one String contains degres, minutes and seconds
*/
double gmsToDoube(String _val) {
  if (!(_val.contains("°") || _val.contains("º"))) {
    return 0;
  } else if (!_val.contains('"')) {
    return 0;
  } else if (!_val.contains("'")) {
    return 0;
  } else {
    int d = int.tryParse(_val.split("°")[0]) ?? 0;
    int m = int.tryParse(_val.split("°")[1].split("'")[0]) ?? 0;
    int s = int.tryParse(_val.replaceAll(",", ".").split("'")[1].split('"')[0]) ?? 0;

    return d + m / 60 + s / 3600;
  }
}

/*
returns a double with 2 fixed decimal places
*/
double toTwo(double _val) {
  String toStr = _val.toStringAsFixed(2);
  return double.parse(toStr);
}

/*
  returns a double with 4 fixed decimal places
  */
double toFour(double _val) {
  String toStr = _val.toStringAsFixed(4);
  return double.parse(toStr);
}

/*
  returns a double with 6 fixed decimal places
  */
double toSix(double _val) {
  String toStr = _val.toStringAsFixed(6);
  return double.parse(toStr);
}

/*
Gera poligonos com n lados mas não todos, é bem limitado, mas vai servir.
*/
List<List<Offset>> gerarPoligono(int lados, int distMax, Random rnd) {
  List<List<Offset>> pontos = [];

  //double ang = 360 / lados;

  if (lados > 1000) {
    return pontos;
  }

  for (int i = 0; i < lados; i++) {
    double x = toSix(rnd.nextDouble() * rnd.nextInt(distMax));
    double y = toSix(rnd.nextDouble() * rnd.nextInt(distMax));

    pontos.add(
      [
        Offset(
          x,
          y,
        ),
      ],
    );
  }

  if (lados == 3) {
    return pontos;
  }

  bool sair = false;
  int _cont = 0;

  while (!sair && _cont < 10000000) {
    _cont += 1;
    sair = true;
    for (int index = 0; index < pontos.length; index++) {
      Offset p1 = pontos[index][0];

      //print("Para index: $index\n");

      int index1;

      if (index == pontos.length - 1) {
        index1 = 0;
      } else {
        index1 = index + 1;
      }

      Offset p2 = pontos[index1][0];
      //print("Index p2: $index1");

      bool troquei = false;

      for (int i = 0; i < pontos.length; i++) {
        if (i == index) {
          continue;
        }

        index1 = index + i;

        if (index1 > pontos.length - 1) {
          index1 = i;
        }

        Offset p3 = pontos[index1][0];
        //print("Index p3: $index1");

        index1 += 1;

        if (index1 > pontos.length - 1) {
          index1 = i;
        }

        Offset p4 = pontos[index1][0];
        //print("Index p4: $index1\n");

        double det = (p4.dx - p3.dx) * (p2.dy - p1.dy) - (p4.dy - p3.dy) * (p2.dx - p1.dx);

        if (det == 0) {
          //Não ha interação entre as retas
          continue;
        }

        double s = ((p4.dx - p3.dx) * (p3.dy - p1.dy) - (p4.dy - p3.dy) * (p3.dx - p1.dx)) / det;
        double t = ((p2.dx - p1.dx) * (p3.dy - p1.dy) - (p2.dy - p1.dy) * (p3.dx - p1.dx)) / det;

        if (p1 == p3 || p1 == p4 || p2 == p3 || p2 == p4) {
          continue;
        }

        if ((s <= 1 && s >= 0) && (t <= 1 && t >= 0)) {
          int p1i = pontos.indexOf([p1]);
          int p4i = pontos.indexOf([p4]);

          if (p1i == -1) {
            for (List<Offset> ponto in pontos) {
              Offset pt = ponto[0];

              if (pt.dx == p1.dx && pt.dy == p1.dy) {
                p1i = pontos.indexOf(ponto);
                break;
              }
            }
          }

          if (p4i == -1) {
            for (List<Offset> ponto in pontos) {
              Offset pt = ponto[0];

              if (pt.dx == p4.dx && pt.dy == p4.dy) {
                p4i = pontos.indexOf(ponto);
                break;
              }
            }
          }
          //print("iteração\n");
          try {
            pontos[p1i] = [p4];
            pontos[p4i] = [p1];
          } catch (e) {
            print(e);
            break;
          }

          sair = false;
          troquei = true;

          break;
        }
      }
      if (troquei) {
        break;
      }
    }
  }

  //Checar se os pontos estão no sentido horário ou não.
  //A-B
  double bax = pontos[0][0].dx - pontos[1][0].dx;
  double bay = pontos[0][0].dy - pontos[1][0].dy;

  //B-C
  double bcx = pontos[3][0].dx - pontos[1][0].dx;
  double bcy = pontos[3][0].dy - pontos[1][0].dy;

  double sentido = (bax * bcy) - (bay * bcx);

  if (sentido < 0) {
    pontos = pontos.reversed.toList();
  }

  return pontos;
}

/*
Gera poligonos com base nos azimutes e distâncias reduzidas de uma leitura.
*/
List<List<Offset>> gerarPoligonoByTableValues({List<ItemTabelaValues>? dadosValues, Map<String, Map>? dadosMap}) {
  List<List<Offset>> points = [
    [Offset(0, 0)]
  ];

  if (dadosValues != null) {
    List<String> pontos = [];
    for (ItemTabelaValues item in dadosValues) {
      if (!pontos.contains(item.estacao!) && item.re != "" && item.vante != "") {
        pontos.add(item.estacao!);
      }
    }

    int indexPonto = 0;

    for (ItemTabelaValues item in dadosValues) {
      if (item.angHorizontal == 0) {
        continue;
      }

      double dr = item.distRed ?? 0;
      double az = item.azimute ?? 0;
      int pointIndex = pontos.indexOf(item.estacao ?? "");

      if (!pontos.contains(item.vante)) {
        double x = dr * sin(az * pi / 180) + points[pointIndex][0].dx;
        double y = dr * cos(az * pi / 180) + points[pointIndex][0].dy;

        points[pointIndex].add(Offset(x, y));
      } else {
        if (indexPonto >= pontos.length - 1) {
          continue;
        }

        double x = dr * sin(az * pi / 180) + points[pointIndex][0].dx;
        double y = dr * cos(az * pi / 180) + points[pointIndex][0].dy;
        points.add([Offset(x, y)]);

        indexPonto += 1;
      }
    }
  } else if (dadosMap != null) {
    int indexPonto = 0;

    dadosMap.forEach(
      (key, value) {
        ItemTabelaValues item = value['vante'];

        double dr = item.distRed ?? 0;
        double az = item.azimute ?? 0;

        double x = dr * sin(az * pi / 180) + indexPonto == 0 ? 0 : points[indexPonto][0].dx;
        double y = dr * cos(az * pi / 180) + indexPonto == 0 ? 0 : points[indexPonto][0].dy;

        if (indexPonto != 0) {
          points[indexPonto].add(Offset(x, y));
        }

        if (value.containsKey("irradiacoes")) {
          for (ItemTabelaValues item in value['irradiacoes']) {
            double dr = item.distRed ?? 0;
            double az = item.azimute ?? 0;

            double x = dr * sin(az * pi / 180) + points[indexPonto][0].dx;
            double y = dr * cos(az * pi / 180) + points[indexPonto][0].dy;

            points[indexPonto].add(Offset(x, y));
          }
        }
        indexPonto += 1;
      },
    );
  }
  return points;
}

/*
Gerar os azimutes de um ItemTabelValues
*/
Map<String, double> getAzFromItemTabelaValue(double azInicial, List<ItemTabelaValues> dadosValues) {
  Map<String, double> azs = {};

  List<String> pontos = [];
  List<String> irradiacoes = [];

  for (ItemTabelaValues item in dadosValues) {
    if (!pontos.contains(item.estacao!) && item.re != "" && item.vante != "") {
      pontos.add(item.estacao!);
    }
  }

  for (ItemTabelaValues item in dadosValues) {
    if (item.vante != "" && !irradiacoes.contains(item.vante!) && pontos.contains(item.estacao!) && !pontos.contains(item.vante!)) {
      irradiacoes.add(item.vante!);
    }
  }

  bool primeiroPonto = true;
  for (String ponto in pontos) {
    for (ItemTabelaValues item in dadosValues) {
      if (item.estacao! == ponto && !irradiacoes.contains(item.vante!)) {
        if (item.angHorizontal == 0 || item.vante == "") {
          continue;
        }

        String pontoKey = item.estacao! + item.vante!;
        String anteriorKey = item.re! + item.estacao!;

        if (primeiroPonto) {
          azs[pontoKey] = azInicial;
          primeiroPonto = false;
          continue;
        }

        double soma = azs[anteriorKey]! + item.angHorizontal!;

        if (soma < 180) {
          soma += 180;
        } else if (soma >= 180 && soma < 540) {
          soma -= 180;
        } else {
          soma -= 540;
        }

        azs[pontoKey] = soma;
      }
    }
  }

  for (String ponto in irradiacoes) {
    for (ItemTabelaValues item in dadosValues) {
      if (item.vante! == ponto) {
        if (item.angHorizontal == 0) {
          continue;
        }

        String pontoKey = item.estacao! + item.vante!;
        String anteriorKey = item.re! + item.estacao!;

        if (primeiroPonto) {
          azs[pontoKey] = azInicial;
          primeiroPonto = false;
          continue;
        }

        if (!azs.containsKey(anteriorKey)) {
          return {"erro": 0};
        }

        double soma = azs[anteriorKey]! + item.angHorizontal!;

        if (soma < 180) {
          soma += 180;
        } else if (soma >= 180 && soma < 540) {
          soma -= 180;
        } else {
          soma -= 540;
        }

        azs[pontoKey] = soma;
      }
    }
  }

  return azs;
}

/*
Widget para entrar com dados de grau, min, seg e quadrante quando necessário
*/
class TextGMSField extends StatefulWidget {
  TextGMSField({
    required this.angleInit,
    required this.onChange,
    this.decimalDigits,
    this.width,
    this.height,
    this.isRumo,
    this.quad,
    this.isNegative,
    this.maxValue,
  });

  final double angleInit;
  final ValueChanged<dynamic> onChange;
  final bool? decimalDigits;
  final double? width;
  final double? height;
  final bool? isRumo;
  final String? quad;
  final bool? isNegative;
  final int? maxValue;

  @override
  _TextGMSField createState() => _TextGMSField();
}

class _TextGMSField extends State<TextGMSField> {
  _TextGMSField();

  TextEditingController angle = TextEditingController();
  TextEditingController mins = TextEditingController();
  TextEditingController secs = TextEditingController();
  TextEditingController secs1 = TextEditingController();

  int grau = 0;
  int minu = 0;
  double sec = 0;
  int sec1 = 0;
  int sec2 = 0;
  String quad = "NE";
  bool isMinus = false;

  void onChanged() {
    double angle = (isMinus ? -1 : 1) * (grau + minu / 60 + (sec + sec1 / 10 + sec2 / 100) / 3600);

    if (widget.isRumo ?? false) {
      widget.onChange([
        angle,
        quad,
      ]);
    } else {
      widget.onChange(angle);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.angleInit < 0) {
      isMinus = true;
    }

    grau = (widget.angleInit).abs() ~/ 1;
    minu = (grau < 0 ? -1 : 1) * (((widget.angleInit).abs() % 1) * 60).toInt();
    sec = (grau < 0 ? -1 : 1) * double.parse((((widget.angleInit).abs() - grau - minu / 60) * 3600).toStringAsFixed(0));

    if (sec == 60) {
      minu += 1;
      sec = 0;
    }
    if (minu == 60) {
      grau += 1;
      minu = 0;
    }

    angle.text = grau.toString();
    mins.text = minu.toString();
    secs.text = sec.toString().replaceAll(".", ",");
  }

  @override
  Widget build(context) {
    grau = min(
        grau,
        (widget.isRumo ?? false)
            ? 90
            : (widget.maxValue ?? 0) != 0
                ? (widget.maxValue ?? 0)
                : 360);

    return Container(
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          Spacer(),
          //Plus or minus signal
          Builder(
            builder: (ctx) {
              if (!(widget.isNegative ?? false)) {
                return SizedBox();
              } else {
                return FittedBox(
                  child: Transform.scale(
                    scale: 0.8,
                    child: IconButton(
                      icon: Icon(isMinus ? Icons.remove : Icons.add),
                      onPressed: () {
                        isMinus = !isMinus;
                        onChanged();
                        setState(() {});
                      },
                    ),
                  ),
                );
              }
            },
          ),
          //Picker with degres
          Expanded(
            flex: 5,
            child: Focus(
              onFocusChange: (focus) {
                if (focus) {
                  angle.text = "";
                } else {
                  int num = int.tryParse(angle.text.replaceAll(",", ".")) ?? 0;
                  angle.text = num.abs().toString().replaceAll(".", ",");
                  grau = num;
                  onChanged();
                }
                setState(() {});
              },
              child: AutoSizeTextField(
                controller: angle,
                minFontSize: 8,
                stepGranularity: 1,
                maxLines: 1,
                wrapWords: false,
                keyboardType: TextInputType.numberWithOptions(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
          ),
          FittedBox(child: Text("° ")),
          //Picker with mins
          Expanded(
            flex: 4,
            child: Focus(
              onFocusChange: (focus) {
                if (focus) {
                  mins.text = "";
                } else {
                  int num = int.tryParse(mins.text.replaceAll(",", ".")) ?? 0;
                  mins.text = num.abs().toString().replaceAll(".", ",").padLeft(2, "0");
                  minu = num;
                  if (minu >= 60) {
                    grau += 1;
                    minu = 0;
                    mins.text = "00";
                  }
                  onChanged();
                }
                setState(() {});
              },
              child: AutoSizeTextField(
                controller: mins,
                minFontSize: 8,
                stepGranularity: 1,
                maxLines: 1,
                wrapWords: false,
                keyboardType: TextInputType.numberWithOptions(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
          ),
          FittedBox(child: Text("' ")),
          //Picker with secs
          Expanded(
            flex: 4,
            child: Focus(
              onFocusChange: (focus) {
                if (focus) {
                  secs.text = "";
                } else {
                  double num = double.tryParse(secs.text.replaceAll(",", ".")) ?? 0;
                  num = num.abs();
                  secs.text = num.abs().toString().replaceAll(".", ",").padLeft(4, "0");
                  sec = num;
                  if (sec >= 60) {
                    minu += 1;
                    sec = 0;
                    secs.text = "00";
                  }
                  onChanged();
                }
                setState(() {});
              },
              child: AutoSizeTextField(
                controller: secs,
                minFontSize: 8,
                stepGranularity: 1,
                maxLines: 1,
                wrapWords: false,
                keyboardType: TextInputType.numberWithOptions(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,]{0,1}[0-9]*')),
                ],
              ),
            ),
          ),
          FittedBox(child: Text('"')),
          /*FittedBox(
            child: NumberPicker(
              minValue: 0,
              maxValue: (widget.maxValue ?? 0) != 0 ? (widget.maxValue ?? 0) : ((widget.isRumo ?? false) ? 89 : 359),
              value: ((widget.isRumo ?? false) && grau > 89) ? 89 : grau,
              infiniteLoop: true,
              itemHeight: 25,
              itemWidth: 40,
              textStyle: TextStyle(
                color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                fontSize: 12,
              ),
              selectedTextStyle: TextStyle(
                color: Cores.preto,
                fontSize: 18,
              ),
              textMapper: (val) {
                return "$valº";
              },
              onChanged: (val) {
                grau = val;
                onChanged();
                setState(() {});
              },
            ),
          ),
          //Picker with minutes
          FittedBox(
            child: NumberPicker(
              minValue: 0,
              maxValue: 59,
              value: minu,
              infiniteLoop: true,
              itemHeight: 25,
              itemWidth: 35,
              textStyle: TextStyle(
                color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                fontSize: 12,
              ),
              selectedTextStyle: TextStyle(
                color: Cores.preto,
                fontSize: 18,
              ),
              textMapper: (val) {
                return "$val'";
              },
              onChanged: (val) {
                minu = val;
                onChanged();
                setState(() {});
              },
            ),
          ),
          //Picker with seconds
          FittedBox(
            child: NumberPicker(
              minValue: 0,
              maxValue: 59,
              value: sec,
              infiniteLoop: true,
              itemHeight: 25,
              itemWidth: 35,
              textStyle: TextStyle(
                color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                fontSize: 12,
              ),
              selectedTextStyle: TextStyle(
                color: Cores.preto,
                fontSize: 18,
              ),
              textMapper: (val) {
                if (!(widget.decimalDigits ?? false)) {
                  return '$val"';
                } else {
                  return "$val ,";
                }
              },
              onChanged: (val) {
                sec = val;
                onChanged();
                setState(() {});
              },
            ),
          ),
          //Decimal digits
          Builder(
            builder: (ctx) {
              if (!(widget.decimalDigits ?? false)) {
                return SizedBox();
              }
              return Row(
                children: [
                  FittedBox(
                    child: NumberPicker(
                      minValue: 0,
                      maxValue: 9,
                      value: sec1,
                      infiniteLoop: true,
                      itemHeight: 25,
                      itemWidth: 25,
                      textStyle: TextStyle(
                        color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                        fontSize: 12,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Cores.preto,
                        fontSize: 18,
                      ),
                      onChanged: (val) {
                        sec1 = val;
                        onChanged();
                        setState(() {});
                      },
                    ),
                  ),
                  FittedBox(
                    child: NumberPicker(
                      minValue: 0,
                      maxValue: 9,
                      value: sec2,
                      infiniteLoop: true,
                      itemHeight: 25,
                      itemWidth: 25,
                      textStyle: TextStyle(
                        color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                        fontSize: 12,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Cores.preto,
                        fontSize: 18,
                      ),
                      textMapper: (val) {
                        return '$val"';
                      },
                      onChanged: (val) {
                        sec2 = val;
                        onChanged();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              );
            },
          ),*/
          //Picker with quadrant
          Builder(
            builder: (ctx) {
              if (!(widget.isRumo ?? false)) {
                return SizedBox();
              }

              if (kIsWeb) {
                return PopupMenuButton<String>(
                  tooltip: "Items",
                  child: Text(quad),
                  onSelected: (value) {
                    quad = value;
                    onChanged();
                    setState(() {});
                  },
                  itemBuilder: (ctx) {
                    return List.generate(
                      ["NE", "SE", "SW", "NW"].length,
                      (index) => PopupMenuItem<String>(
                        value: ["NE", "SE", "SW", "NW"][index],
                        child: Text(["NE", "SE", "SW", "NW"][index]),
                      ),
                    );
                  },
                );
              }
              return NumberPicker(
                minValue: 0,
                maxValue: 3,
                value: ["NE", "SE", "SW", "NW"].indexOf(quad),
                infiniteLoop: true,
                itemHeight: 25,
                itemWidth: 30,
                textStyle: TextStyle(
                  color: Color.lerp(Cores.preto, Colors.transparent, 0.8),
                  fontSize: 12,
                ),
                selectedTextStyle: TextStyle(
                  color: Cores.preto,
                  fontSize: 18,
                ),
                textMapper: (val) {
                  return ["NE", "SE", "SW", "NW"][int.parse(val)];
                },
                onChanged: (val) {
                  quad = ["NE", "SE", "SW", "NW"][val];
                  onChanged();
                  setState(() {});
                },
              );
            },
          ),
          Spacer(),
        ],
      ),
    );
  }
}
