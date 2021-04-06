class MensagemModel {
  String _idUsuario;
  String _mensagem;
  String _url;
  String _tipo;
  String _data;

  MensagemModel();

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "idusuario": this.idUsuario,
      "mensagem": this.mensagem,
      "urlImagem": this.url,
      'tipo': this.tipo,
      "data": this.data
    };
  }
}
