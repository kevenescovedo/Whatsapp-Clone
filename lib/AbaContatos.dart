import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Models/User.dart';
import 'Models/Conversas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  List<Conversa> listConversas = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuarios();
  }

  String emailUser;
  Future<List<DocumentSnapshot>> recuperarContatos() async {
    print("aaaaaaaaaaaaaaaaaaa");
    List<DocumentSnapshot> listcontatos = [];
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection('usuarios').getDocuments();

    for (var doc in querySnapshot.documents) {
      if (emailUser != doc['email']) {
        listcontatos.add(doc);
      }
    }
    return listcontatos;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<DocumentSnapshot>>(
      future: recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [Text("Caregando....."), CircularProgressIndicator()],
              ),
            );
            break;
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: ListTile(
                      title: Text(snapshot.data[index].data["nome"]),
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            snapshot.data[index].data["urlImagem"]),
                      ),
                    ),
                    onTap: () {
                      User user = User();
                      user.email = snapshot.data[index].data['email'];

                      user.url = snapshot.data[index].data['urlImagem'];
                      user.name = snapshot.data[index].data['nome'];
                      user.idUsuario = snapshot.data[index].documentID;
                      print(user.name);
                      Navigator.pushNamed(context, "/mensagem",
                          arguments: user);
                    },
                  );
                });
            break;
        }
      },
    ));
  }

  recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogado = await auth.currentUser();
    String idUsuarioLogado = userLogado.uid;
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection('usuarios').document(idUsuarioLogado).get();
    Map<String, dynamic> dados = snapshot.data;
    setState(() {
      emailUser = dados["email"];
    });
  }
}
