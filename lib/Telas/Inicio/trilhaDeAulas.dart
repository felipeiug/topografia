import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class TrilhaDeAulas extends StatefulWidget {
  TrilhaDeAulas(this.user);

  final Usuario user;

  @override
  _TrilhaDeAulas createState() => _TrilhaDeAulas();
}

class _TrilhaDeAulas extends State<TrilhaDeAulas> {
  void initState() {
    super.initState();
    user = widget.user;
  }

  Usuario? user;
  String messageOffline = "Nenhuma Aula Cadastrada";

  Future<List> get aulasAluno async {
    List a = [
      {
        "subtitulo": "Levantamentos realizados em campo",
        "titulo": "Levantamentos",
      },
    ];

    if (await Usuario.connected) {
      dynamic aulas = await user!.getDb("public/aulasKeys") ?? [];
      a = a + aulas;
    } else {
      messageOffline = "Sem conecxão com a internet as aulas não estão disponíveis.";
    }
    return a;
  }

  Future<List> getAulasAluno(int aula, var aulaContent) async {
    /*if (aula == 0) {
      return [];
    }

    aula -= 1;

    //print(aulaContent);
    dynamic aulasAluno = [];

    //TODO: Fazer depois
    Map aulasFeitas = await user!.getDb("users/${user!.auth.currentUser!.uid}/aulas/$aula") ?? {};

    if (aulasFeitas.containsKey("textos")) {
      var textos = aulasFeitas['textos'];
    }

    return aulasAluno;*/
    return [];
  }

  void openClass(int index, String titulo) async {
    //index += 1;

    if (index == -1) {
      Navigator.of(context).pushNamed(
        "/levantamentos",
        arguments: {
          "user": user,
          "index": index,
          "titulo": titulo,
        },
      );
    } else {
      Navigator.of(context).pushNamed(
        "/minhaTrilha/aula",
        arguments: {
          "user": user,
          "index": index,
          "titulo": titulo,
        },
      );
    }
  }

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map && args.containsKey("user")) {
      user = args['user'];
    }

    return Scaffold(
      //drawer: DrawerEsquerda(context, user!),
      endDrawer: DrawerDireita(context, user!),
      appBar: AppBar(
        backgroundColor: Cores.primaria,
        centerTitle: true,
        title: Text("Aulas"),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.settings,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List>(
        future: aulasAluno,
        builder: (ctx, data) {
          if (!data.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (data.data == null || data.data!.isEmpty) {
            return Center(
              child: Text(messageOffline),
            );
          }

          List aulas = data.data!;

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(10),
            color: Cores.terciaria,
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: aulas.length,
                  itemBuilder: (ctx, index) {
                    return FutureBuilder<List>(
                      future: getAulasAluno(index, aulas),
                      builder: (ctx, data) {
                        if (!data.hasData) {
                          return LinearProgressIndicator();
                        }

                        Widget trailing = Icon(
                          Icons.launch_outlined,
                          color: Cores.preto,
                        );

                        if (index == 0) {
                          return Card(
                            color: Cores.branco,
                            child: ListTile(
                              onTap: () {
                                openClass(index - 1, aulas[index]['titulo']);
                              },
                              title: aulas[index] != null ? Text(aulas[index]['titulo'] ?? "") : null,
                              subtitle: aulas[index] != null && aulas[index].containsKey("subtitulo") ? Text(aulas[index]['subtitulo']) : null,
                              trailing: trailing,
                            ),
                          );
                        }

                        if (data.data != null && data.data!.isNotEmpty) {
                          List aulasAluno = data.data!;

                          if ((aulasAluno.length - 1) >= index && aulasAluno[index] != null && aulasAluno[index].containsKey("nota")) {
                            trailing = SizedBox(
                              width: 100,
                              height: 100,
                              child: Row(
                                children: [
                                  Text(
                                    "${aulasAluno[index]['nota']}%",
                                    style: TextStyle(
                                      color: Color.lerp(
                                        Colors.red,
                                        Colors.green,
                                        aulasAluno[index]['nota'] / 100,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    aulasAluno[index]['nota'] < 80 ? Icons.done : Icons.done_all,
                                    color: Cores.preto,
                                  ),
                                ],
                              ),
                            );
                          }
                        }

                        return Card(
                          color: Cores.branco,
                          child: ListTile(
                            onTap: () {
                              openClass(index - 1, aulas[index]['titulo']);
                            },
                            title: aulas[index] != null ? Text(aulas[index]['titulo'] ?? "") : null,
                            subtitle: aulas[index] != null && aulas[index].containsKey("subtitulo") ? Text(aulas[index]['subtitulo']) : null,
                            trailing: trailing,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget DrawerDireita(BuildContext ctx, Usuario user) {
  return SafeArea(
    child: Container(
      color: Cores.secundaria,
      width: 70,
      height: MediaQuery.of(ctx).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              child: Column(
                children: [
                  //Abre as configurações de usuário
                  itemDrawer(
                    ctx,
                    text: user.nomeUsuario ?? "",
                    icon: Icons.person,
                    fontSize: 12,
                  ),
                  //Abre os dados do usuário
                  itemDrawer(
                    ctx,
                    text: "Meus dados",
                    icon: Icons.person_pin,
                    fontSize: 10,
                  ),
                  //Sair para a tela de login
                  itemDrawer(
                    ctx,
                    text: "Sair",
                    icon: Icons.undo,
                    fontSize: 12,
                    onTap: () {
                      user.sair(ctx, screen: "/inicio");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget DrawerEsquerda(BuildContext ctx, Usuario user) {
  return Container(
    color: Cores.terciaria,
    width: 50,
    height: MediaQuery.of(ctx).size.height,
    child: SingleChildScrollView(
      child: Column(
        children: [],
      ),
    ),
  );
}

Widget itemDrawer(BuildContext context, {String? text, IconData? icon, double? fontSize, Function? onTap}) {
  List<Widget> widgets = [];

  if (icon != null) {
    widgets.add(Icon(
      icon,
      color: Cores.preto,
    ));
    widgets.add(SizedBox(height: 5));
  }
  if (text != null) {
    widgets.add(Text(
      text,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize ?? 14,
      ),
    ));
  }

  widgets.add(Divider(color: Cores.preto));

  return Padding(
    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
    child: InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Column(
        children: widgets,
      ),
    ),
  );
}
