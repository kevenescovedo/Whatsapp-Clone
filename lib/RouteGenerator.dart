import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastrar.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Mensagens.dart';
class RouterGenerator
{
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
   switch(settings.name) {
     case "/":
      return MaterialPageRoute(builder: (context) => Login());
       break;
     case "/login":
       return MaterialPageRoute(builder: (context) => Login());
       break;
     case "/home":
       return MaterialPageRoute(builder: (context) => Home());
       break;
     case "/cadastro":
      return MaterialPageRoute(builder: (context) => Cadastro());
       break;
     case "/configuracoes":
       return MaterialPageRoute(builder: (context) => Configuracoes());
       break;
     case "/mensagem":
       return MaterialPageRoute(builder: (context) => Mensagens(args));
       break;

     default:
       _erroRota();
       break;
   }
  }
  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(title: Text("Página não encontrada")),
        body: Center(
          child: Text("Página não encontrada") ,
        ),
      );
    });
  }
}
