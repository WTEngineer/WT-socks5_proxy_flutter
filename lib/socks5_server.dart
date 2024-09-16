import 'dart:io';
import 'package:logging/logging.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

final Logger log = Logger('Socks5Proxy');

// Enum for address types
enum Addr { v4, v6, domain }

// Handler for SOCKS5 server connections
class Socks5ServerHandler {
  final Socket client;
  late Socket remoteSocket;

  States currentState = States.handshake;

  Socks5ServerHandler(this.client);

  void start() {
    client.listen((data) {
      processData(data);
    }, onDone: () {
      log.info('Client disconnected');
      client.close();
      remoteSocket.destroy();
    }, onError: (error) {
      log.severe('Client error: $error');
      client.close();
      remoteSocket.destroy();
    });
  }

  void startProxy() {
    remoteSocket.listen((data) {
      client.add(data);
    }, onDone: () {
      client.destroy();
    });
  }

}

enum States { handshake, handling, proxying }
