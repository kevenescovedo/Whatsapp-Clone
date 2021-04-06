class User {
  String _name;
  String _idUsuario;
  String _email;
  String _password;
  String _url;
  User();

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "nome": this.name,
      "email": this._email,
      "senha": this._password,


    };
  }

  String get name => _name;
  set url(String value) {
    _url = value;
  }

  String get url => _url;

  set name(String value) {
    _name = value;
  }

  String get email => _email;

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  set email(String value) {
    _email = value;
  }
}
