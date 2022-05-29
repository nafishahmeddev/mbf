import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIO{
  static IO.Socket socket = IO.io("http://0.0.0.0").close();
  static void initialize(){
    debugPrint("connecting to socket server");
    socket = IO.io('https://socketio-whiteboard-zmx4.herokuapp.com/');
    socket.onConnect((_) {
      debugPrint('connected to socket server');
      socket.emit('msg', 'test');
    });
    socket.onError((data){
      debugPrint('connected to socket server');
    });
    socket.onDisconnect((_) => debugPrint('disconnect from socket server'));
  }
  static IO.Socket getInstance(){
    return socket;
  }

}
