import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:topografia/Aulas/Items/textSpeechItem.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

/*class ItemsAulaList extends StatefulWidget {
  ItemsAulaList({
    required this.aula,
  });

  final Map aula;

  @override
  _ItemsAulaList createState() => _ItemsAulaList();
}

class _ItemsAulaList extends State<ItemsAulaList> {*/

class ItemsAulaList extends StatelessWidget {
  ItemsAulaList({
    required this.index,
    required this.user,
  });

  final int index;
  final Usuario? user;

  Widget futureImage(String pathImage) {
    String nameArq = pathImage.split("/")[pathImage.split("/").length - 1];
    return FutureBuilder<Widget>(
      initialData: Container(),
      future: user!.getDownloadUrl(pathImage.replaceAll(nameArq, ""), nameArq).then((value) {
        return Image.network(
          value,
          fit: BoxFit.contain,
        );
      }),
      builder: (ctx, snapshot) {
        if (snapshot.data != null) {
          return snapshot.data!;
        }
        return Container(
          color: Cores.primaria,
        );
      },
    );
  }

  void onLinkTap(String? link) {
    print(link);
  }

  void onImageTap(String? link, BuildContext context) {
    Image? imagem;

    if (link!.contains("data:image/jpeg;base64,")) {
      String bytesStr = link.replaceAll("data:image/jpeg;base64,", "");
      Uint8List img = base64Decode(bytesStr);

      imagem = Image.memory(
        img,
        fit: BoxFit.fill,
      );
    } else if (link.contains("http")) {
      imagem = Image.network(
        link,
        fit: BoxFit.fill,
      );
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            height: MediaQuery.of(context).size.height / 3,
            child: SingleChildScrollView(
              child: Center(
                child: imagem,
              ),
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }

  void onAnchorTap(String? link) {
    print(link);
  }

  Future<Map> getDataAula() async {
    dynamic name = await user!.getDb("public/aulas/$index/titulo");
    dynamic lenText = await user!.getDb("public/aulas/$index/keysTextos") ?? [];

    return {
      'name': name,
      'lenText': lenText.length,
    };
  }

  Future<List> getTextos() async {
    dynamic textos = await user!.getDb("public/aulas/$index/titulo");
    return textos;
  }

  Future<String> getTitle(int indexTexto) async {
    String title = await user!.getDb("public/aulas/$index/keysTextos/$indexTexto") ?? "";
    return title.replaceAll("***", ".");
  }

  Future<Map> getTextComplete(int indexTexto) async {
    try {
      String key = await user!.getDb("public/aulas/$index/keysTextos/$indexTexto");

      Map text = await user!.getDb("public/aulas/$index/textos/$key");
      return text;
    } on Exception catch (_) {
      print(_);
      return {
        "conteudo": "Erro ao pegar conteúdo da Aula",
        "textTTS": "Erro ao pegar conteúdo da Aula",
      };
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: getDataAula(),
      builder: (ctx, data) {
        if (!data.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (data.data == null || data.data!.isEmpty) {
          return Center(
            child: Text("Erro na aula"),
          );
        }

        //String nameAula = data.data!['name'];
        int lenText = data.data!['lenText'];

        return ListView.builder(
          itemBuilder: (ctx, indexTexto) {
            bool open = false;

            return StatefulBuilder(
              builder: (ctx, setState) {
                if (!open) {
                  return FutureBuilder<String>(
                    future: getTitle(indexTexto),
                    builder: (ctx, data) {
                      if (!data.hasData) {
                        return Center();
                      }

                      return Card(
                        color: Cores.branco,
                        child: ListTile(
                          onTap: () async {
                            if (data.data!.contains("Exercício")) {
                              Map data = await getTextComplete(indexTexto);
                              String texto = data['conteudo'] ?? "";

                              if (texto.contains("**exercicio**")) {
                                texto = texto.replaceAll("**exercicio**", "");

                                if (!texto.startsWith("/")) {
                                  texto = "/" + texto;
                                }

                                Navigator.of(context).pushNamed(
                                  texto,
                                  arguments: {
                                    "user": user,
                                    'indexAula': index,
                                    'indexTexto': indexTexto,
                                  },
                                );
                              } else {
                                open = true;
                              }
                            } else {
                              open = true;
                            }
                            setState(() {});
                          },
                          title: Text(
                            data.data ?? "",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return FutureBuilder<Map>(
                    future: getTextComplete(indexTexto),
                    builder: (ctx, data) {
                      if (!data.hasData) {
                        return Card(
                          color: Cores.branco,
                          child: ListTile(
                            title: Text("Abrindo conteúdo..."),
                          ),
                        );
                      }

                      String textSpeech = data.data!['textTTS'] ?? "";
                      String texto = data.data!['conteudo'] ?? "";

                      TextSpeechController listSpeech = TextSpeechController(
                        text: textSpeech,
                      );

                      listSpeech.open();

                      return Card(
                        color: Cores.branco,
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => setState(() {
                                open = false;
                              }),
                              title: Icon(Icons.arrow_drop_down),
                              trailing: Container(
                                width: 150,
                                child: Row(children: <Widget>[Spacer(), listSpeech]),
                              ),
                            ),
                            Container(
                              color: Cores.branco,
                              child: Builder(
                                builder: (ctx) {
                                  if (texto.contains("**exercicio**")) {
                                    texto = texto.replaceAll("**exercicio**", "");

                                    return ListTile(
                                      title: Text(texto != "" ? texto : "Exercício  $index"),
                                      /*
                                      trailing: Icon(Icons.launch_outlined),
                                      onTap: () {
                                        
                                        if (!texto.startsWith("/")) {
                                          texto = "/" + texto;
                                        }
                                        Navigator.of(context).pushNamed(
                                          texto,
                                          arguments: {
                                            "user": user,
                                            'indexAula': index,
                                            'indexTexto': indexTexto,
                                          },
                                        );
                                      },*/
                                    );
                                  } else {
                                    return Html(
                                      data: texto,
                                      onLinkTap: (link, _, __, ___) {
                                        onLinkTap(link);
                                      },
                                      onImageTap: (link, _, __, ___) {
                                        onImageTap(link, context);
                                      },
                                      onAnchorTap: (link, _, __, ___) {
                                        onAnchorTap(link);
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
          itemCount: lenText,
        );
      },
    );
  }
}
