//import 'dart:ffi';
import 'dart:async';
import 'dart:io';

//Nativas do flutter
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//Salvar arquivos no dispositivo
import 'package:shared_preferences/shared_preferences.dart';
//Http para download do firebase
import 'package:http/http.dart' as http;
//Saber se o projeto está rodando na web
import 'package:flutter/foundation.dart' show kIsWeb;

class Usuario {
  //User -------------------------------------------------------
  //Imagem de perfil, vai ser ou um network image ou uma imagem offline.
  File? imagePerfil;
  String? urlImgPerfil;
  bool usuarioCadastrado = false;
  bool verificado = false;
  String? nomeUsuario;
  //User -------------------------------------------------------
  //Variáveis de inicialização
  //Contexto do app
  BuildContext context;
  double fileLen;
  Map cache = {};

  //Variavel que desativa o timer que salva o horário do usuário
  bool _sair = false;

  //Variaveis de ambiente
  String horarioEntrouSemCadastro = "";

  //Firebase ---------------------------------------------------
  //Autenticação
  FirebaseAuth auth = FirebaseAuth.instance;
  UserCredential? userCredential; //AuthResult userCredential;
  //Storage
  FirebaseStorage storage = FirebaseStorage.instance;
  //Database
  DatabaseReference dbOn = FirebaseDatabase.instance.ref();
  //Caminho da pasta usuário que vem antes do uid
  String caminhoUserPath;
  //Firebase ---------------------------------------------------

  //Banco de dados offline
  SharedPreferences? dbOff;

  //Nome do app para o sharedPreferences
  String nameApp;

  //Tamanho do snackbar de info
  double snackBarHeight = 30;

  //Banco de dados offline inciado
  final Function? onInitDBOFF;

  static Future<bool> get connected async {
    ConnectivityResult conect = await Connectivity().checkConnectivity();
    if (conect == ConnectivityResult.ethernet || conect == ConnectivityResult.wifi || conect == ConnectivityResult.ethernet) {
      return true;
    }
    return false;
  }

  //Inicialização da classe
  Usuario({
    required this.context,
    required this.nameApp,
    required this.caminhoUserPath,
    this.fileLen = 10E6,
    this.onInitDBOFF,
  }) {
    if (kIsWeb) {
      snackBarHeight = 70;
    }

    _initDbOff().then((value) {
      if (value == true && onInitDBOFF != null) {
        onInitDBOFF!();
      }
    });
  }

  void dispose() async {
    cache = {};
    _sair = true;
  }

  Future<bool> _initDbOff() async {
    dbOff = await SharedPreferences.getInstance();

    if (dbOff != null) {
      return true;
    } else {
      return false;
    }
  }

  String dataAtual() {
    String dia = DateTime.now().day < 10 ? "0" + DateTime.now().day.toString() : DateTime.now().day.toString();

    String mes = DateTime.now().month < 10 ? "0" + DateTime.now().month.toString() : DateTime.now().month.toString();

    String ano = DateTime.now().year < 10 ? "0" + DateTime.now().year.toString() : DateTime.now().year.toString();

    return "$dia/$mes/$ano";
  }

  void setDb(String caminho, dynamic data) async {
    try {
      await dbOn.child(caminho).set(data);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<bool> deleteDb(String caminho) async {
    try {
      await dbOn.child(caminho).remove();
      return true;
    } on Exception catch (e) {
      print(e);
    }
    return false;
  }

  Future<dynamic> getDb(String caminho, {String? orderBy, int? num}) async {
    try {
      DatabaseEvent result;
      if (num != null && orderBy != null) {
        result = await dbOn.child(caminho).orderByChild(orderBy).limitToLast(num).once();
      } else if (num != null && orderBy == null) {
        result = await dbOn.child(caminho).limitToFirst(num).once();
      } else if (num == null && orderBy != null) {
        result = await dbOn.child(caminho).orderByChild(orderBy).once();
      } else {
        result = await dbOn.child(caminho).once();
      }

      return result.snapshot.value;
    } on Exception catch (_) {
      return null;
    }
  }

  Future<UploadTask?> setArq(BuildContext ctx, String caminho, File data, String name) async {
    int tamanho = data.lengthSync();
    if (tamanho > fileLen) {
      String lenMax = (fileLen / 10E6).toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text(
                "O tamanho máximo de arquivos para upload é de ${lenMax}MB",
              ),
            ),
          ),
        ),
      );
      return null;
    } else {
      Reference reference = storage.ref("$caminho/$name");
      return reference.putFile(data);
    }
  }

  Future<String> getDownloadUrl(String caminho, String name) async {
    String link = await storage.ref("$caminho/$name").getDownloadURL();
    return link;
  }

  Future<File> getArq(String caminho, String name, String pathSave, BuildContext ctx, {bool isUrl = false, bool replace = false}) async {
    File arq = File("$pathSave" + "/" + name);

    Function download = () async {
      if (arq.existsSync()) {
        arq.deleteSync();
      }

      await arq.create();

      if (isUrl) {
        Uri uri = Uri.parse(caminho);
        http.Response response = await http.get(uri);
        await arq.writeAsBytes(response.bodyBytes);
      } else {
        storage.ref("$caminho").writeToFile(arq);
      }
      return arq;
    };

    if (arq.existsSync() && !replace) {
      return arq;
    } else {
      return await download();
    }
  }

  void entrarSemCadastro(String caminho, dynamic dados, String screen) async {
    Loading.open(context);

    try {
      horarioEntrouSemCadastro = DateTime.now().microsecondsSinceEpoch.toString();

      //Adicionar o realtime data base para armaenar os valores do usuário que entrou sem cadastro
      dbOn.child("$caminho/$horarioEntrouSemCadastro").set(dados);

      usuarioCadastrado = false;

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, screen, arguments: this);
      });
    } on Exception catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("$e"),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("$e"),
            ),
          ),
        ),
      );
    }
  }

  ///Return true if screen == "" and login is ok, else return false
  Future<bool> loginEmailSenha(String email, String senha, String screen, {String? screenOff, bool? setLastAccess, int secondsToUpdate = 120}) async {
    if (!await connected) {
      if (screenOff != null) {
        Navigator.popAndPushNamed(
          context,
          screenOff,
          arguments: {"user": this},
        );
      }
      return true;
    }

    Loading.open(context);

    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      if (setLastAccess != null && setLastAccess == true) {
        try {
          if (userCredential!.user != null) {
            await dbOn.child("$caminhoUserPath/${userCredential!.user!.uid}/lastAccess").set(DateTime.now().microsecondsSinceEpoch);
          }
        } on Exception catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text("$e"),
                ),
              ),
            ),
          );
        }
      }

      urlImgPerfil = userCredential!.user!.photoURL;
      verificado = userCredential!.user!.emailVerified;
      nomeUsuario = userCredential!.user!.displayName;

      try {
        await dbOff!.setString("$nameApp/email", email);
        await dbOff!.setString("$nameApp/pass", senha);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("$e"),
            ),
          ),
        ));
      }

      usuarioCadastrado = true;

      Navigator.of(context).pop(); //Fechar o loading
      //Se tiver alguma tela pra abrir
      if (screen == "") {
        return true;
      } else {
        Navigator.popAndPushNamed(
          context,
          screen,
          arguments: {"user": this},
        );

        _sair = false;
        Timer.periodic(Duration(seconds: secondsToUpdate), (dt) async {
          if (_sair) {
            dt.cancel();
          } else {
            try {
              await dbOn
                  .child(
                    "$caminhoUserPath/${userCredential!.user!.uid}/lastAccess",
                  )
                  .set(
                    DateTime.now().microsecondsSinceEpoch,
                  );
            } catch (e) {
              print("Erro ao salvar ultimo horário");
              /*ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: SizedBox(
                    height: snackBarHeight,
                    child: Center(
                      child: Text("Erro ao salvar ultimo horário $e"),
                    ),
                  ),
                ),
              );*/
            }
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    "Bem vindo ${userCredential!.user!.displayName}",
                  ),
                ),
              ),
            ),
          );
        });
        return true;
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      if (e.code == 'user-not-found') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text(
                    "Usuário não encontrado",
                  ),
                ),
              ),
            ),
          );
        });
      } else if (e.code == 'wrong-password') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text(
                    "Senha incorreta",
                  ),
                ),
              ),
            ),
          );
        });
      } else if (e.code == 'network-request-failed') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text(
                    "Sem conexão com a internet",
                  ),
                ),
              ),
            ),
          );
        });
        return true;
      }
      return false;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  void sair(BuildContext ctx, {String? screen}) async {
    Loading.open(ctx);

    dbOff!.clear();
    try {
      auth.signOut();
    } catch (e) {
      print(e);
    }

    if (screen != null) {
      Navigator.pushNamedAndRemoveUntil(
        ctx,
        screen,
        (route) => false,
        arguments: {"user": this},
      );
      Future.delayed(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    }
    _sair = true;
  }

  Future<String> cadastrar({required String email, required String senha, required String screen, Map? dados, bool? setLastAccess, int secondsToUpdate = 120, String? caminhoImagem}) async {
    Loading.open(context);

    try {
      await auth.signOut();

      if (imagePerfil != null) {
        int tamanho = imagePerfil!.lengthSync();
        if (tamanho > fileLen) {
          /*try {
            Navigator.of(context).pop(); //Fechar o loading
          } catch (e) {
            print(e);
          }*/
          return "__Overflow__/${fileLen / 10E6}MB";
        }
      }

      UserCredential newUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      userCredential = newUser;

      if (dados != null) {
        if (dados.containsKey("imgPerfil")) {
          if (caminhoImagem == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: SizedBox(
                  height: snackBarHeight,
                  child: Center(
                    child: Text("Caminho para a imagem de perfil inválido"),
                  ),
                ),
              ),
            );
          } else {
            uploadImagePerfil(caminhoImagem!, dados["imgPerfil"]);
            urlImgPerfil = await setIagePerfil(caminhoImagem);
          }
          dados.remove("imgPerfil");
        }
      }

      try {
        Navigator.of(context).pop(); //Fechar o loading
      } catch (e) {
        print(e);
      }

      setCredentials(
        urlImgPerfil != null ? urlImgPerfil : "",
        dados!.containsKey('displayName') ? dados['displayName'] : "",
      );

      //if (dados.containsKey('displayName')) {
      //  dados.remove('displayName');
      //}

      setDb(
        "$caminhoUserPath/${userCredential!.user!.uid}/dados_pessoais",
        dados,
      );

      loginEmailSenha(
        email,
        senha,
        screen,
        setLastAccess: setLastAccess,
        secondsToUpdate: secondsToUpdate,
      );
    } on FirebaseAuthException catch (e) {
      try {
        Navigator.of(context).pop(); //Fechar o loading
      } catch (e) {
        print(e);
      }

      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("A senha é muito curta"),
              ),
            ),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("Este e-mail já está cadastrado"),
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("$e"),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      try {
        Navigator.of(context).pop(); //Fechar o loading
      } catch (e) {
        print(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("$e"),
            ),
          ),
        ),
      );
    }
    return "OK";
  }

  void verificarEmail() async {
    if (auth.currentUser != null) {
      auth.currentUser!.sendEmailVerification();
    }
  }

  Future<bool> trocarEmail(BuildContext ctx, {Color? btnColor, Color? textColor, Color? imputColor}) async {
    Loading.open(ctx);

    TextEditingController _controller = TextEditingController();
    TextEditingController _senha = TextEditingController();

    bool foi = false;

    String? email = userCredential!.user!.email;

    if (email == null) {
      return false;
    }

    await showDialog(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                child: Text(
                  "Atualizar",
                  style: TextStyle(
                    color: btnColor ?? btnColor,
                  ),
                ),
                onPressed: () {
                  email = _controller.text;
                  foi = true;
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: btnColor ?? btnColor,
                  ),
                ),
                onPressed: () {
                  foi = false;
                  Navigator.of(ctx).pop();
                },
              ),
            ],
            title: Text("Trocar o e-mail"),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Novo E-mail",
                      hintStyle: TextStyle(color: textColor ?? textColor),
                      fillColor: imputColor ?? imputColor,
                      focusColor: imputColor ?? imputColor,
                      hoverColor: imputColor ?? imputColor,
                    ),
                  ),
                  TextField(
                    controller: _senha,
                    decoration: InputDecoration(
                      hintText: "Senha atual",
                      hintStyle: TextStyle(color: textColor ?? textColor),
                      fillColor: imputColor ?? imputColor,
                      focusColor: imputColor ?? imputColor,
                      hoverColor: imputColor ?? imputColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    if (foi == false) {
      return false;
    } else {
      Loading.open(ctx);
    }

    if (!EmailValidator.validate(email!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Este e-mail não é válido"),
            ),
          ),
        ),
      );
    } else if (email != userCredential!.user!.email) {
      try {
        await loginEmailSenha(userCredential!.user!.email!, _senha.text, "");

        await auth.currentUser!.updateEmail(email!);

        email = _controller.text;
        await loginEmailSenha(email!, _senha.text, "");

        Navigator.of(context).pop(); //Fecha o loading

        return true;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("Erro ao atualizar email: ${e.message}"),
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Este e-mail é igual ao anterior"),
            ),
          ),
        ),
      );
    }

    Navigator.of(context).pop(); //Fecha o loading

    return false;
  }

  Future<bool> trocarSenha(BuildContext ctx, {Color? btnColor, Color? textColor, Color? imputColor}) async {
    Loading.open(ctx);

    TextEditingController _controller = TextEditingController();
    TextEditingController _senha = TextEditingController();
    TextEditingController _email = TextEditingController();

    bool foi = false;

    String? senha;

    await showDialog(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                child: Text(
                  "Atualizar",
                  style: TextStyle(
                    color: textColor ?? textColor,
                  ),
                ),
                onPressed: () {
                  senha = _controller.text;
                  foi = true;
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: textColor ?? textColor,
                  ),
                ),
                onPressed: () {
                  foi = false;
                  Navigator.of(ctx).pop();
                },
              ),
            ],
            title: Text("Trocar a senha"),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      hintText: "E-mail",
                      hintStyle: TextStyle(color: textColor ?? textColor),
                      fillColor: imputColor ?? imputColor,
                      focusColor: imputColor ?? imputColor,
                      hoverColor: imputColor ?? imputColor,
                    ),
                  ),
                  TextField(
                    controller: _senha,
                    decoration: InputDecoration(
                      hintText: "Senha atual",
                      hintStyle: TextStyle(color: textColor ?? textColor),
                      fillColor: imputColor ?? imputColor,
                      focusColor: imputColor ?? imputColor,
                      hoverColor: imputColor ?? imputColor,
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Nova senha",
                      hintStyle: TextStyle(color: textColor ?? textColor),
                      fillColor: imputColor ?? imputColor,
                      focusColor: imputColor ?? imputColor,
                      hoverColor: imputColor ?? imputColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    if (foi == false) {
      return false;
    } else {
      Loading.open(ctx);
    }

    if (_email.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: SizedBox(
          height: snackBarHeight,
          child: Center(
            child: Text("Digite seu e-mail"),
          ),
        )),
      );
    } else if (senha! == "" || senha!.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Esta senha não é válida"),
            ),
          ),
        ),
      );
    } else if (_senha.text == senha!) {
      try {
        bool logou = await loginEmailSenha(_email.text, _senha.text, "");

        if (!logou) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text("Problemas ao fazer login, verifique seu email e sua senha"),
                ),
              ),
            ),
          );
          return false;
        }

        await auth.currentUser!.updatePassword(senha!);

        logou = await loginEmailSenha(_email.text, senha!, "");

        if (!logou) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: snackBarHeight,
                child: Center(
                  child: Text("Problemas ao fazer login, feche o app e entre novamente com sua nova senha"),
                ),
              ),
            ),
          );
        }

        Navigator.of(context).pop(); //Fechar o loading

        return true;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("Erro ao atualizar a senha: ${e.message}"),
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Esta senha é igual a anterior"),
            ),
          ),
        ),
      );
    }

    Navigator.of(context).pop(); //Fecha o loading

    return false;
  }

  Future<bool> trocarDisplayName(BuildContext ctx, {Color? btnColor, Color? textColor, Color? imputColor}) async {
    Loading.open(ctx);

    TextEditingController _controller = TextEditingController();

    bool foi = false;

    String? displayName = userCredential!.user!.displayName;

    await showDialog(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                child: Text(
                  "Atualizar",
                  style: TextStyle(
                    color: btnColor ?? btnColor,
                  ),
                ),
                onPressed: () {
                  displayName = _controller.text;
                  foi = true;
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: btnColor ?? btnColor,
                  ),
                ),
                onPressed: () {
                  foi = false;
                  Navigator.of(ctx).pop();
                },
              ),
            ],
            title: Text("Novo nome de usuário"),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Novo nome de usuario",
                hintStyle: TextStyle(color: textColor ?? textColor),
                fillColor: imputColor ?? imputColor,
                focusColor: imputColor ?? imputColor,
                hoverColor: imputColor ?? imputColor,
              ),
            ),
          );
        });

    if (foi == false) {
      return false;
    } else {
      Loading.open(ctx);
    }

    if (displayName == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Este nome de usuário não é válido"),
            ),
          ),
        ),
      );
    } else if (displayName != userCredential!.user!.displayName) {
      try {
        await auth.currentUser!.updateDisplayName(displayName);

        //TODO: Testar se precisa fazer login novamente ou não...

        Navigator.of(context).pop(); //Fechar o loading

        return true;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("Erro ao atualizar o nome de usuário: ${e.message}"),
              ),
            ),
          ),
        );

        Navigator.of(context).pop(); //Fechar o loading
        return false;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: snackBarHeight,
              child: Center(
                child: Text("Erro : $e"),
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Este nome de usuario é igual ao anterior"),
            ),
          ),
        ),
      );
    }

    Navigator.of(context).pop(); //Fechar o loading

    return false;
  }

  /*
   * Retorna o link da imagem adicionada no perfil do usuário
  */
  Future<UploadTask> uploadImagePerfil(String caminhoImagem, File imagePerfil) async {
    //Processo de upload da imagem de perfil e retorna o url da imagem.
    Reference reference = storage.ref(
      "$caminhoUserPath/${userCredential!.user!.uid}/$caminhoImagem/img_perfil.png",
    );
    return reference.putFile(imagePerfil);
  }

  Future<String> setIagePerfil(String caminhoImagem) async {
    String link = await storage
        .ref(
          "$caminhoUserPath/${userCredential!.user!.uid}/$caminhoImagem/img_perfil.png",
        )
        .getDownloadURL();

    auth.currentUser!.updatePhotoURL(link);
    return link;
  }

  Future<void> setCredentials(String? linkImgPerfil, String? displayName) async {
    if (linkImgPerfil != null) {
      auth.currentUser!.updatePhotoURL(linkImgPerfil);
    }
    if (displayName != null) {
      auth.currentUser!.updateDisplayName(displayName);
    }
  }

  Future<void> recuperarSenha(email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("E-mail de recuperação enviado para $email"),
            ),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("Erro ao enviar email de recuperação de senha: ${e.message}"),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            height: snackBarHeight,
            child: Center(
              child: Text("$e"),
            ),
          ),
        ),
      );
    }
  }
}

//Implementar o loading.
class Loading {
  static open(
    BuildContext ctx, {
    Color? roundColor,
    Color? backgroundColor,
    Color? shadowColor,
    String? text,
    double? height,
    double? width,
    TextStyle? textStyle,
  }) {
    textStyle = textStyle != null
        ? textStyle
        : TextStyle(
            color: Colors.black87,
            fontSize: 24,
            decoration: TextDecoration.none,
          );

    Future.delayed(
      Duration(milliseconds: 2),
      () {
        showDialog(
          context: ctx,
          builder: (ctx) {
            if (text == null) {
              return Center(
                child: SizedBox(
                  width: height ?? height,
                  height: height ?? height,
                  child: CircularProgressIndicator(
                    color: roundColor ?? roundColor,
                  ),
                ),
              );
            } else {
              return Container(
                color: backgroundColor ?? backgroundColor,
                height: height ?? height,
                width: width ?? width,
                child: Row(
                  children: [
                    Spacer(),
                    SizedBox(
                      width: height ?? height,
                      height: height ?? height,
                      child: CircularProgressIndicator(
                        color: roundColor ?? roundColor,
                      ),
                    ),
                    Spacer(),
                    Text(
                      text,
                      style: textStyle ?? textStyle,
                    ),
                    Spacer(),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  static close(BuildContext context) {
    print("Fechar");
    Navigator.of(context).pop();
  }
}
