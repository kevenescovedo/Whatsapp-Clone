import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'Home.dart';
import 'Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

void main() {
   final ThemeData tmios = ThemeData(
      primaryColor: Colors.grey[200], 
      accentColor: Color(0XFF25D366));
  final ThemeData tmpadrao = ThemeData(
      primaryColor: Color(0XFF075E54), accentColor: Color(0XFF25D366));
  runApp(MaterialApp(
    theme:Platform.isIOS ? tmios : tmpadrao,
    home: Login(),
    initialRoute: "/",
    onGenerateRoute: RouterGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
