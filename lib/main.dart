import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:scoped_model/scoped_model.dart';
import './route/index.dart';
import './store/index.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  final GState gState = new GState();

  Router createRouter() {
    Application.router = new Router();
    Routes.configureRoutes(Application.router);
    return Application.router;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new ScopedModel(
        model: gState,
        child: new MaterialApp(
          title: 'Password book',
          theme: new ThemeData(
              primaryColorBrightness: Brightness.dark),
          initialRoute: '/',
          onGenerateRoute: createRouter().generator,
        ));
  }
}
