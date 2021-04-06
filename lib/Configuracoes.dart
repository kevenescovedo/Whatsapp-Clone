import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController  _controllerNome = TextEditingController();
  String _idUsuarioLogado;
  File _imagem;
  bool _subindoImagem = false;
  String _urlimageRecuperada;
Future recuperarImagem(String origin) async {
  File imageSelecionada;
  switch(origin) {
    case "camera":
      imageSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);

      break;
    case "galeria":
      imageSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
      break;

  }
  setState(() {
    _imagem = imageSelecionada;
    if(_imagem != null) {
      _subindoImagem = true;
      uploadImage();
    }

  });
}

 Future uploadImage() async {
 FirebaseStorage storage = FirebaseStorage.instance;
 StorageReference storageReference = storage.ref();
 StorageReference arquivo = storageReference.child("perfil").child("${_idUsuarioLogado}.png");
 StorageUploadTask task = arquivo.putFile(_imagem);
 task.events.listen((event) {
if(event.type == StorageTaskEventType.progress) {
 setState(() {
   _subindoImagem = true;
 });
}
else {
  if(event.type == StorageTaskEventType.success) {
  setState(() {
    _subindoImagem = false;
  });
}
}




 });
 task.onComplete.then((StorageTaskSnapshot snapshot){
   recuperarUrl(snapshot);
 }) ;

  }
  atualizarUrlImageFireatore(String url) {
  Firestore db = Firestore.instance;
  db.collection('usuarios').document(_idUsuarioLogado).updateData({"urlImagem" : url});
  }
  atualizarNomeFireatore() {
    Firestore db = Firestore.instance;
    db.collection('usuarios').document(_idUsuarioLogado).updateData({"nome" : _controllerNome.text});
  }
  recuperarUrl( StorageTaskSnapshot snapshot) async {
 String  url = await snapshot.ref.getDownloadURL();
 atualizarUrlImageFireatore(url);
 setState(() {
   _urlimageRecuperada = url;
 });
  }
  recuperarDadosUsuarios() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser userLogado = await auth.currentUser();
  _idUsuarioLogado = userLogado.uid;
  Firestore db = Firestore.instance;
  DocumentSnapshot snapshot = await db.collection('usuarios').document(_idUsuarioLogado).get();
  Map<String,dynamic> dados = snapshot.data;
  _controllerNome.text = dados["nome"];
  if(dados["urlImagem"] != null) {
    _urlimageRecuperada = dados['urlImagem'];
  }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuarios();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text("Configurações"),),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child:    _subindoImagem ? CircularProgressIndicator() : Container(),
                ),

                CircleAvatar(
                  radius: 100,
                  backgroundImage: _urlimageRecuperada == null ? null : NetworkImage(_urlimageRecuperada),
                  backgroundColor: Colors.grey,
                ),
                Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  FlatButton(onPressed: (){
                    recuperarImagem("camera");
                  }, child: Text("Camera")),
                    FlatButton(onPressed: (){
                      recuperarImagem("galeria");
                    }, child: Text("Galeria")),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Nome",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: Color(0XFF075E54)),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    color: Color(0XFF25D366),
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      atualizarNomeFireatore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ) ,
      ),

    );
  }
}
