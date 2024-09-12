import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket? _primarySocket;
  late Socket _secondarySocket;
  }

  @override
  void dispose() {
    _primarySocket?.close();
    _secondarySocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket Proxy Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startProxyServer,
          child: Text('Start Proxy Server'),
        ),
      ),
    );
  }
}