import 'package:flutter/material.dart';
import 'dart:io';
import 'socks5_server.dart';

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

  void _startProxyServer() async {
    final host = '188.245.104.81'; 
    // final host = '192.168.8.165'; 
    final port = 8000; 

    try {
      // Starting the primary connection (equivalent to Bootstrap.connect())
      _primarySocket = await Socket.connect(host, port);

      _primarySocket!.listen(
        (data) {
          _handlePrimaryConnectionData(data, host, port);
        },
        onDone: () {
          print('Primary connection closed');
          _primarySocket!.close();
        },
        onError: (error) {
          print('Primary connection error: $error');
          _primarySocket!.close();
        },
      );
    } catch (e) {
      print('Failed to connect to primary connection: $e');
    }
  }

  void _handlePrimaryConnectionData(List<int> data, String host, int port) {
    if (data.isNotEmpty) {
      final receivedByte = data[0];
      print('Received data from primary connection: $receivedByte');
      if (receivedByte == 55) {
        print('Received byte 55, initiating secondary connection');
        _startSecondaryConnection(host, port);
      }
    }
  }

  void _startSecondaryConnection(String host, int port) async {           //The part where the Java code uses NioEventLoopGroup, Bootstrap, and creates a new connection is represented in Dart as a simple socket connection using Socket.connect():
    try {
      _secondarySocket = await Socket.connect(host, port);
      print('Connected to $host:$port (Secondary Connection)');
      Socks5ServerHandler obj = Socks5ServerHandler(_secondarySocket);
      obj.start();

    } catch (e) {
      print('Failed to connect to secondary channel: $e');
    }
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