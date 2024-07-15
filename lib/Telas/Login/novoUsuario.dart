import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class NewUser extends StatefulWidget {
  NewUser(this.user);

  final Usuario user;

  @override
  _NewUser createState() => _NewUser();
}

class _NewUser extends State<NewUser> {
  TextEditingController _nome = TextEditingController(text: "");
  TextEditingController _matricula = TextEditingController(text: "");
  TextEditingController _email = TextEditingController(text: "");
  TextEditingController _senha = TextEditingController(text: "");
  String _curso = "Curso";

  bool _showPass = true;
  List<String> cursos = [];

  double snackBarHeight = 30;

  void initState() {
    super.initState();
    user = widget.user;
  }

  void _getCursos() async {
    var a = await user!.getDb("public/cursos");
    if (a is List) {
      cursos = a.map((val) => val.toString()).toList();
    }
    setState(() {});
  }

  void create() async {
    if (_nome.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Preencha o seu nome"),
            ),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else if (_matricula.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Preencha a sua matrícula"),
            ),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else if (_curso == "Curso") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Escolha um Curso"),
            ),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else if (!EmailValidator.validate(_email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Este e-mail não é válido"),
            ),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else if (_senha.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Você deve criar uma senha"),
            ),
          ),
        ),
      );
      return;
    } else if (_senha.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("A senha precisa ter no mínimo 8 caracteres"),
            ),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else {
      user!.context = context;
      user!.cadastrar(
        email: _email.text,
        senha: _senha.text,
        screen: "/minhaTrilha/trilhaDeAulas",
        dados: {
          "displayName": _nome.text,
          "matricula": _matricula.text,
          "curso": _curso,
        },
      );
    }
  }

  void google() async {}

  void facebook() async {}

  Usuario? user;
  void getUser() async {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map && args.containsKey("user")) {
      user = args['user'];
    }
  }

  Widget build(BuildContext context) {
    getUser();
    if (cursos.length == 0) {
      _getCursos();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores.primaria,
        iconTheme: IconThemeData(color: Cores.preto),
        title: Text(
          "Novo Usuário",
          style: TextStyle(
            color: Cores.preto,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        color: Cores.branco,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 70,
                child: Column(
                  children: [
                    Spacer(),
                    TextField(
                      controller: _nome,
                      cursorColor: Cores.primaria,
                      textAlign: _nome.text == "" ? TextAlign.center : TextAlign.left,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Cores.preto),
                        hintText: "Nome",
                        fillColor: Cores.secundaria,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _matricula,
                      cursorColor: Cores.primaria,
                      textAlign: _matricula.text == "" ? TextAlign.center : TextAlign.left,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Cores.preto),
                        hintText: "Matrícula",
                        fillColor: Cores.secundaria,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20),
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Cores.preto),
                      ),
                      tooltip: "Curso",
                      onSelected: (String item) {
                        _curso = item;
                        setState(() {});
                      },
                      initialValue: _curso,
                      itemBuilder: (ctx) {
                        return cursos
                            .map(
                              (val) => PopupMenuItem(
                                child: ListTile(title: Text(val)),
                                value: val,
                              ),
                            )
                            .toList();
                      },
                      icon: null,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        height: 50,
                        child: Center(
                          child: Text(
                            _curso == "" ? "Curso" : _curso,
                            style: TextStyle(
                              color: Cores.preto,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Cores.secundaria,
                          border: Border.all(
                            color: Cores.preto,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _email,
                      cursorColor: Cores.primaria,
                      textAlign: _email.text == "" ? TextAlign.center : TextAlign.left,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Cores.preto),
                        hintText: "E-mail",
                        fillColor: Cores.secundaria,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _senha,
                      cursorColor: Cores.primaria,
                      obscureText: _showPass,
                      textAlign: _senha.text == "" ? TextAlign.center : TextAlign.left,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPass ? Icons.visibility : Icons.visibility_off,
                            color: Cores.preto,
                          ),
                          onPressed: () {
                            _showPass = !_showPass;
                            setState(() {});
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Cores.preto),
                        hintText: "Senha",
                        fillColor: Cores.secundaria,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: create,
                      child: Text(
                        "CADASTRAR",
                        style: TextStyle(
                          color: Cores.preto,
                        ),
                      ),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.resolveWith(
                          (states) {
                            return Size(
                              MediaQuery.of(context).size.width - 90,
                              50,
                            );
                          },
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            /*
                        MaterialState.pressed,
                        MaterialState.hovered,
                        MaterialState.focused,
                        */

                            if (states.contains(MaterialState.pressed)) {
                              return Color.lerp(
                                Cores.preto,
                                Cores.secundaria,
                                0.7,
                              );
                            } else if (states.contains(MaterialState.hovered)) {
                              return Color.lerp(
                                Cores.preto,
                                Cores.secundaria,
                                0.9,
                              );
                            }
                            return Cores.primaria;
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0),
                        ),
                      ),
                    ),
                    Spacer(),
                    /*Center(child: Text("OU")),
                    Spacer(),
                    Row(
                      children: [
                        Spacer(flex: 4),
                        InkWell(
                          onTap: google,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset("assets/logos/logoGoogle.png"),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: facebook,
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.asset("assets/logos/logoFacebook.png"),
                          ),
                        ),
                        Spacer(flex: 4),
                      ],
                    ),
                    Spacer(),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
