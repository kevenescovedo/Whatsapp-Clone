import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Cadastrar.dart';
import 'Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _senhacontroller = TextEditingController();
  String messageError = "";
  _validarcampos() {
    String email = _emailcontroller.text;
    String senha = _senhacontroller.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.length > 6) {
        setState(() {
          messageError = "";
        });
        User user = User();
        user.email = email;
        user.password = senha;
        _logarusuario(user);
      } else {
        setState(() {
          messageError = "Por favor a senha deve possuir mais de 6 caracteres";
        });
      }
    } else {
      setState(() {
        messageError = "Por favor o email deve conter @";
      });
    }
  }

  _logarusuario(User usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.password)
        .then((FirebaseUser) {
      Navigator.pushReplacementNamed(context, "/home");
    }).catchError((onerror) {
      setState(() {
        messageError =
            "Erro a entrar, por favor verifique os campos e tente novamente";
      });
    });
  }

  Future _verificarusuariologado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseUser firebaseUser = await auth.currentUser();
    if (firebaseUser != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _verificarusuariologado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0XFF075E54),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white),
                    controller: _emailcontroller,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white),
                  obscureText: true,
                  controller: _senhacontroller,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    color: Color(0XFF25D366),
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _validarcampos();
                    },
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text("Não tem conta cadastra-se",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/cadastro");
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                    ),
                    child: Text(
                      messageError,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
