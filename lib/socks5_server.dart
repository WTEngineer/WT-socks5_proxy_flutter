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

  String parseAddress(List<int> data, int addrType) {
    switch (addrType) {
      case 0x01: // IPv4
        return data.sublist(4, 8).join('.');
      case 0x04: // IPv6
        return '::1';
      case 0x03: // Domain name
        final domainLength = data[4];
        return String.fromCharCodes(data.sublist(5, 5 + domainLength));
      default:
        throw Exception('Unknown address type: $addrType');
    }
  }
}

  void _sendSocks5Reply(Socket clientSocket, Socket remSocket) {
    final reply = BytesBuilder()
      ..addByte(5) // SOCKS version
      ..addByte(0) // Connection succeeded
      ..addByte(0) // Reserved

      ..addByte(remSocket.address.type == InternetAddressType.IPv4
          ? 1
          : 4) // Address type

      ..add(remSocket.address.rawAddress) // Address
      ..addByte(remSocket.port >> 8) // Port (high byte)
      ..addByte(remSocket.port & 0xFF); // Port (low byte)

    clientSocket.add(reply.toBytes());
  }
enum States { handshake, handling, proxying }
