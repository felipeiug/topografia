import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';

class TelaDeLogin extends StatefulWidget {
  TelaDeLogin(this.user);

  final Usuario user;

  @override
  _TelaDeLogin createState() => _TelaDeLogin();
}

class _TelaDeLogin extends State<TelaDeLogin> {
  TextEditingController _email = TextEditingController(text: "");
  TextEditingController _senha = TextEditingController(text: "");

  bool _showPass = true;

  void initState() {
    super.initState();
    user = widget.user;
  }

  void emailRecupercao() async {
    if (!EmailValidator.validate(_email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "O E-mail contém algum erro",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    user!.recuperarSenha(_email.text);

    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "E-mail para a troca da senha enviado para ${_email.text}",
          textAlign: TextAlign.center,
        ),
      ),
    );*/
  }

  void esqueceuSenha() async {
    if (await Usuario.connected) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Cores.secundaria,
            title: Text("Recuperar a Senha:"),
            content: Container(
              height: MediaQuery.of(ctx).size.height / 5,
              child: Column(
                children: [
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
                      fillColor: Cores.branco,
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
                    onPressed: () {
                      emailRecupercao();
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      "ENVIAR",
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
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Você não está conectado na internet, por isso não pode recuperar sua senha!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void entrar() async {
    if (!EmailValidator.validate(_email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "O E-mail contém algum erro",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    } else if (_senha.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "A senha não pode estar vazia",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    } else {
      user!.context = context;
      await user!.loginEmailSenha(
        _email.text,
        _senha.text,
        "/minhaTrilha/trilhaDeAulas",
        screenOff: "/minhaTrilha/trilhaDeAulas",
        setLastAccess: true,
      );
    }
  }

  void novoUsuario() async {
    if (await Usuario.connected) {
      await Navigator.of(context).pushNamed(
        "/newUser",
        arguments: {"user": user},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Você não está conectado na internet, por isso não pode criar um novo cadastro!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Usuario? user;
  void getUser() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map && args.containsKey("user")) {
      user = args['user'];
      user!.context = context;
    }
  }

  Widget build(BuildContext context) {
    getUser();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        color: Cores.primaria,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Spacer(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Image.asset("assets/logos/teodolitoSemFundo.png"),
                    ),
                    Spacer(),
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
                        fillColor: Cores.branco,
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
                        fillColor: Cores.branco,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Cores.preto),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    Row(
                      children: [
                        Spacer(),
                        TextButton(
                          onPressed: esqueceuSenha,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0),
                            ),
                          ),
                          child: Text(
                            "Esqueceu a Senha",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Cores.preto,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: entrar,
                      child: Text(
                        "ENTRAR",
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
                            return Cores.secundaria;
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0),
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Spacer(),
                        TextButton(
                          onPressed: novoUsuario,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0),
                            ),
                          ),
                          child: Text(
                            "Criar Nova Conta",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Cores.preto,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Spacer(),
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
