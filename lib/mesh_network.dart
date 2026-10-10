// lib/mesh_network.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'coordinator.dart';

class MobileMeshGateway {
  ServerSocket? _server;
  final _coordinator = GlobalCoordinator();
  
  // Track active device authentication state locally
  String _activeLicenseKey = "UNLICENSED";

  Future<void> bootMeshGateway() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 8990);
    _server!.listen((Socket client) {
      client.listen((Uint8List rawBytes) async {
        try {
          String decodedString = utf8.decode(rawBytes);
          final Map<String, dynamic> jsonPayload = jsonDecode(decodedString);
          
          // Capture potential activation tokens passing over the mesh bus
          if (jsonPayload.containsKey('activation_key')) {
            _activeLicenseKey = jsonPayload['activation_key'] ?? "UNLICENSED";
          }
          
          String text = jsonPayload['data'] ?? "";
          
          // Pass the input stream and the license key signature to the Coordinator graph
          String responseContext = await _coordinator.orchestratePipeline(text, _activeLicenseKey);
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
