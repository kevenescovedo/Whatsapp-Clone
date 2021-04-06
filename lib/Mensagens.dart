import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whatsapp/Models/Conversas.dart';

import 'Models/User.dart';
import 'Models/Mensagem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class Mensagens extends StatefulWidget {
  User contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  bool _subindoImagem = false;
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  Firestore db = Firestore.instance;

  TextEditingController _controllerMensagem = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController scrollController = ScrollController();
  StreamController<QuerySnapshot> adicionarListenerMensagens() {
    Stream<QuerySnapshot> stream = db
        .collection("mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario).orderBy("data",descending: false)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        //pro final da lista
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    });
  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      MensagemModel mensagem = MensagemModel();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.url = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";
      // salvar para remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
      //salvar para destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
      print("indo salvar conversa");
      //salvar conversa;
      _salvarConversa(mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, MensagemModel msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //Limpa texto
    _controllerMensagem.clear();

    /*

    + mensagens
      + jamiltondamasceno
        + joserenato
          + identicadorFirebase
            <Mensagem>

    * */
  }

  _enviarFoto() async {
    File imagemSelecionada;
    imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    _uploadImagem(imagemSelecionada);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    _idUsuarioDestinatario = widget.contato.idUsuario;
    adicionarListenerMensagens();
  }

  _uploadImagem(File imagem) {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference storageReference = storage.ref();
    String nomeImamgem = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference arquivo = storageReference
        .child("perfil")
        .child(_idUsuarioLogado)
        .child("${nomeImamgem}.png");
    StorageUploadTask task = arquivo.putFile(imagem);
    task.events.listen((event) {
      if (event.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (event.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      recuperarUrl(snapshot);
    });
  }

  recuperarUrl(snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    MensagemModel mensagem = MensagemModel();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.url = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";
    // salvar para remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    //salvar para destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
    _salvarConversa(mensagem);
  }

  _salvarConversa(MensagemModel msg) {
    print("eontrou");
    //salvar para o remetente
    Conversa cRemetente = Conversa();
    cRemetente.idremetente = _idUsuarioLogado;
    cRemetente.iddestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.name;
    cRemetente.fotoPerfilCaminho = widget.contato.url;
    cRemetente.tipoMensagem = 'texto';
    cRemetente.salvar();

    //salvar para o destinátario
    Conversa cDestinatario = Conversa();
    cDestinatario.idremetente = _idUsuarioDestinatario;
    cDestinatario.iddestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.name;
    cDestinatario.fotoPerfilCaminho = widget.contato.url;
    cDestinatario.tipoMensagem = 'texto';
    cDestinatario.salvar();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: IconButton(
                        icon: Icon(Icons.camera_alt), onPressed: _enviarFoto)),
              ),
            ),
          ),
          _subindoImagem
              ? CircularProgressIndicator()
              : FloatingActionButton(
                  backgroundColor: Color(0xff075E54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents;
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);

                      print(_idUsuarioLogado);
                      print(item["idUsuario"]);
                      if (_idUsuarioLogado != item["idusuario"]) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: item['tipo'] == 'texto'
                                ? Text(
                                    item["mensagem"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item['urlImagem']),
                          ),
                        ),
                      );
                    }),
              );
            }

            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.url != null
                    ? NetworkImage(widget.contato.url)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.name),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              stream,
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }
}
