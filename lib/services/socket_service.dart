import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;


  ServerStatus get serverStatus => this._serverStatus;
  
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    this._socket = IO.io('http://192.168.0.7:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });
    // socket.onConnect((_) {
    //   print('connect2');
    // });

    this._socket.on('connect', (_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    

    // socket.on('nuevo-mensaje', (payload) {
    //   print('Nuevo mensaje:');
    //   print('nombre: ${payload['nombre']}');
    //   print('mensaje: ${payload['mensaje']}');
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No tiene mensaje2');
    // });
    
    // socket.onDisconnect((_) => print('disconnect'));
  }
}
