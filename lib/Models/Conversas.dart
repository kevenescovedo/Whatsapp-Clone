import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  String _idremetente;
  String _iddestinatario;
  String _nome;
  String _mensagem;
  String _tipoMensagem;
  String _fotoPerfilCaminho;

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "nome": this.nome,
      "idremetente": this.idremetente,
      "iddestinatario": this.iddestinatario,
      "mensagem": this.mensagem,
      "fotoperfilcaminho": this.fotoPerfilCaminho,
      "tipo": this.tipoMensagem,
    };
  }

  Conversa();
  salvar() async {
    Firestore db = Firestore.instance;
    await db
        .collection('conversas')
        .document(this.idremetente)
        .collection('ultimas_conversa')
        .document(iddestinatario)
        .setData(this.toMap());
  }

  String get mensagem => _mensagem;

  String get fotoPerfilCaminho => _fotoPerfilCaminho;

  set fotoPerfilCaminho(String value) {
    _fotoPerfilCaminho = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }

  String get idremetente => _idremetente;

  set idremetente(String value) {
    _idremetente = value;
  }

  String get iddestinatario => _iddestinatario;

  set iddestinatario(String value) {
    _iddestinatario = value;
  }
}
