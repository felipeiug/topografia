import 'package:flutter/material.dart';
import 'package:topografia/Aulas/Items/expansionPanelAula.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class Aula extends StatefulWidget {
  Aula(this.user);

  final Usuario user;

  @override
  _Aula createState() => _Aula();
}

class _Aula extends State<Aula> {
  void initState() {
    super.initState();
    user = widget.user;
    
  }

  void dispose() {
    super.dispose();
  }

  Usuario? user;
  int? index;
  String? titulo;

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map && args.containsKey("user")) {
      user = args['user'];
    }

    if (args != null && args is Map && args.containsKey("index")) {
      index = args['index'];
    } else {
      index = 0;
    }

    if (args != null && args is Map && args.containsKey("titulo")) {
      titulo = args['titulo'];
    } else {
      titulo = "Aula $index";
    }

    return Scaffold(
      backgroundColor: Cores.terciaria,
      appBar: AppBar(
        title: Text(titulo ?? "Aula $index"),
        centerTitle: true,
        backgroundColor: Cores.primaria,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
          child: Container(
            child: ItemsAulaList(
              index: index!,
              user: user,
            ),
          ),
        ),
      ),
    );
  }
}
