// lib/mesh_network.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'coordinator.dart';

class MobileMeshGateway {
  ServerSocket? _server;
  final _coordinator = GlobalCoordinator();

  Future<void> bootMeshGateway() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 8990);
    _server!.listen((Socket client) {
      // Decode data streams by parsing incoming bytes directly into strings
      client.listen((Uint8List rawBytes) async {
        try {
          String decodedString = utf8.decode(rawBytes);
          final Map<String, dynamic> jsonPayload = jsonDecode(decodedString);
          String text = jsonPayload['data'] ?? "";
          String responseContext = await _coordinator.orchestratePipeline(text);
          client.write(jsonEncode({'status': 'SUCCESS', 'context': responseContext}));
        } catch (e) {
          client.write(jsonEncode({'status': 'ERROR', 'msg': e.toString()}));
        } finally {
          client.close();
        }
      });
    });
  }
}
