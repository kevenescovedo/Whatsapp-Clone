import 'dart:async';
import 'Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Models/Conversas.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> listConversas = [];
  String idUsuarioLogado;
  //criando um controlador para um stream, ele carrega os dados e não chama o metdodo build novamente, nos so vamos
  //carregar se os dados forem modificicados
  final controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  Stream<QuerySnapshot> adicionarListenConversas() {
    final stream = db
        .collection('conversas')
        .document(idUsuarioLogado)
        .collection('ultimas_conversa')
        .snapshots();

    stream.listen((dados) {
      print(dados.documents);
      controller.add(dados);
    });
  }

  recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogado = await auth.currentUser();
    idUsuarioLogado = userLogado.uid;
    setState(() {
      idUsuarioLogado = userLogado.uid;
    });
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection('usuarios').document(idUsuarioLogado).get();
    adicionarListenConversas();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Conversa conversa = Conversa();
    recuperarDadosUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            print(snapshot.data.documents);
            if (snapshot.hasError) {
              return Text("erro ao carregar dados");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                    child: Text(
                  "Você não tem nenhuma conversa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ));
              } else {
                return ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> conversas =
                          querySnapshot.documents;
                      DocumentSnapshot item = conversas[indice];
                      return GestureDetector(
                        child: ListTile(
                          title: Text(item["nome"]),
                          subtitle: item["tipo"] == 'texto'
                              ? Text(item["mensagem"])
                              : Text('imagem...'),
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundImage: conversas[indice]
                                        .data["fotoperfilcaminho"] !=
                                    null
                                ? NetworkImage(
                                    conversas[indice].data["fotoperfilcaminho"])
                                : null,
                          ),
                        ),
                        onTap: () {
                          String url =
                              conversas[indice].data["fotoperfilcaminho"];
                          String nome = conversas[indice].data['nome'];
                          String id = conversas[indice].data['iddestinatario'];
                          User user = User();
                          user.name = nome;
                          user.url = url;
                          user.idUsuario = id;
                          Navigator.pushNamed(context, "/mensagem",
                              arguments: user);

                          //User user = User();
                          //user.email = snapshot.data[index].data['email'];

                          // user.url = snapshot.data[index].data['urlImagem'];
                          // user.name = snapshot.data[index].data['nome'];
                          // user.idUsuario = snapshot.data[index].documentID;
                          // print(user.name);
                          // Navigator.pushNamed(context, "/mensagem",
                          //    arguments: user);
                        },
                      );
                    });
              }
            }
        }
      },
    );
    return Container(
        child: ListView.builder(
      itemCount: listConversas.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(listConversas[index].fotoPerfilCaminho),
          ),
          title: Text(
            listConversas[index].nome,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(listConversas[index].mensagem,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              )),
        );
      },
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.close();
    super.dispose();
  }
}
