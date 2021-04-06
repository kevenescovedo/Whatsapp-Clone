import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/User.dart';
import 'Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String messageError = "";

  cadastrarusuarios(User user) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    firebaseAuth
        .createUserWithEmailAndPassword(
        email: user.email, password: user.password)
        .then(
          (value) {
        Firestore db = Firestore.instance;
        db
            .collection('usuarios')
            .document(value.uid)
            .setData(user.toMap());
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      },
    ).catchError((onError) {
      print("error:$onError");
      setState(() {
        messageError =
        'Erro ao cadastrar usuario verifique os campos e tente novamente';
      });
    });
  }

  validarCampos() {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (nome.length > 3) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.length > 6) {
          User user = User();
          user.email = email;
          user.name = nome;
          user.password = senha;
          cadastrarusuarios(user);
          print("entra");
          setState(() {
            messageError = "";
            Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
          });
        } else {
          setState(() {
            messageError = "a senha deve conter mais de 6 caracteres";
          });
        }
      } else {
        setState(() {
          messageError = "E-mail deve conter @";
        });
      }
    } else {
      setState(() {
        messageError = "O Nome tem que ter mais de três caracteres";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Color(0XFF075E54)),
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "imagens/usuario.png",
                      width: 200,
                      height: 100,
                    ),
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
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "E-mail",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(color: Color(0XFF075E54)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: TextField(
                      obscureText: true,
                      controller: _controllerSenha,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Senha",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(color: Color(0XFF075E54)),
                          )),
                    ),
                  ),
                  RaisedButton(
                    color: Color(0XFF25D366),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      validarCampos();
                    },
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        messageError,
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }


}
