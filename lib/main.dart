import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:topografia/Aulas/Aula1/aula1.dart';
import 'package:topografia/Exercicios/Aula1/ex1.dart';
import 'package:topografia/Exercicios/Aula1/ex2.dart';
import 'package:topografia/Exercicios/Aula1/ex3.dart';
import 'package:topografia/Exercicios/Aula1/ex4.dart';
import 'package:topografia/Exercicios/Aula1/ex5.dart';
import 'package:topografia/Exercicios/Aula2/ex1.dart';
import 'package:topografia/Exercicios/Aula2/ex2.dart';
import 'package:topografia/Exercicios/Aula3/ex1.dart';
import 'package:topografia/Exercicios/Aula3/ex2.dart';
import 'package:topografia/Exercicios/Aula3/ex3.dart';
import 'package:topografia/Exercicios/Aula3/ex4.dart';
import 'package:topografia/Exercicios/Aula4/ex1.dart';
import 'package:topografia/Exercicios/Aula5/ex1.dart';
import 'package:topografia/Exercicios/Aula5/ex2.dart';
import 'package:topografia/Exercicios/Aula6/ex1.dart';
import 'package:topografia/Levantamentos/levantamentos.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:topografia/Paleta/cores.dart';
import 'package:topografia/Telas/Inicio/trilhaDeAulas.dart';
import 'package:topografia/Telas/Login/novoUsuario.dart';
import 'package:topografia/Telas/Login/telaInicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //Rota inicial
  final String initialRoute = "/";

  //Tempo para alguma animação inicial
  final int _animationTime = 2000;

  //Nome do app para o DB offline entre outros
  final String nameApp = "com.felipeiug.topografia";

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  void _loginOffline(BuildContext context, Usuario user) async {
    bool teste = (1 + 1 != 2);

    if (user.dbOff!.containsKey("$nameApp/email") && user.dbOff!.containsKey("$nameApp/pass") || teste) {
      String? email;
      String? senha;
      //if (!teste) {
      email = user.dbOff!.getString("$nameApp/email");
      senha = user.dbOff!.getString("$nameApp/pass");
      /*} else {
        email = "felipeiug@hotmail.com";
        senha = "12345678";
      }*/

      user.context = context;

      bool a = await user.loginEmailSenha(
        email ?? "",
        senha ?? "",
        "/minhaTrilha/trilhaDeAulas",
        screenOff: "/minhaTrilha/trilhaDeAulas",
        setLastAccess: true,
      );
      if (a == false) {
        Navigator.of(context).popAndPushNamed(
          "/inicio",
          arguments: {"user": user},
        );
      }
    } else {
      Navigator.of(context).popAndPushNamed(
        "/inicio",
        arguments: {"user": user},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Usuario user = Usuario(
      context: context,
      nameApp: nameApp,
      caminhoUserPath: "users",
    );

    return MaterialApp(
      title: 'Topografia',
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Cores.primaria,
        scaffoldBackgroundColor: Cores.branco,
        shadowColor: Cores.secundaria,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      routes: {
        "/": (ctx) {
          user = Usuario(
            context: context,
            nameApp: nameApp,
            caminhoUserPath: "users",
            onInitDBOFF: () {
              Future.delayed(Duration(milliseconds: _animationTime), () {
                _loginOffline(ctx, user);
              });
            },
          );
          return Container(
            color: Cores.terciaria,
            child: Image.asset(
              "assets/logos/logoUFV.png",
              fit: BoxFit.fitWidth,
            ),
          );
        },
        "/inicio": (ctx) => TelaDeLogin(user),
        "/newUser": (ctx) => NewUser(user),
        "/minhaTrilha/trilhaDeAulas": (ctx) => TrilhaDeAulas(user),
        "/minhaTrilha/aula": (ctx) => Aula(user),
        "/levantamentos": (ctx) => LEVANTAMENTOS(),
        "/aula1/ex1": (ctx) => A1EX1(),
        "/aula1/ex2": (ctx) => A1EX2(),
        "/aula1/ex3": (ctx) => A1EX3(),
        "/aula1/ex4": (ctx) => A1EX4(),
        "/aula1/ex5": (ctx) => A1EX5(),
        ///////////////////////////////
        "/aula2/ex1": (ctx) => A2EX1(),
        "/aula2/ex2": (ctx) => A2EX2(),
        ///////////////////////////////
        "/aula3/ex1": (ctx) => A3EX1(),
        "/aula3/ex2": (ctx) => A3EX2(),
        "/aula3/ex3": (ctx) => A3EX3(),
        "/aula3/ex4": (ctx) => A3EX4(),
        ///////////////////////////////
        "/aula4/ex1": (ctx) => A4EX1(),
        ///////////////////////////////
        "/aula5/ex1": (ctx) => A5EX1(),
        "/aula5/ex2": (ctx) => A5EX2(),
        ///////////////////////////////
        "/aula6/ex1": (ctx) => A6EX1(),
      },
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
