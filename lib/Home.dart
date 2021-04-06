import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/AbaContatos.dart';
import 'package:whatsapp/AbasConversas.dart';

import 'Login.dart';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  _escolhaMenuItem(String itemEscolhido) {
    print(itemEscolhido);
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        print("configurações");
        break;
      case "Deslogar":
        deslogar();

        break;
    }
  }

  deslogar() async {
    var auth = await FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  List<String> listaItems = ["Configurações", "Deslogar"];
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Wathsapp"),
          elevation: Platform.isIOS ? 0 : 4,
          bottom: TabBar(
            indicatorWeight: 4,
            indicatorColor: Platform.isIOS ? Colors.grey : Colors.white,
            tabs: [Tab(icon: Text("Conversas")), Tab(icon: Text("Contatos"))],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return listaItems.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            AbaConversas(),
            AbaContatos(),
          ],
        ),
      ),
    );
  }
}
