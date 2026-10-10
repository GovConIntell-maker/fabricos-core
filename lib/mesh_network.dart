import 'dart:io';
import 'dart:convert';
import 'coordinator.dart';

class MobileMeshGateway {
  ServerSocket? _server;
  final _coordinator = GlobalCoordinator();

  Future<void> bootMeshGateway() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 8990);
    _server!.listen((Socket client) {
      client.transform(utf8.decoder).listen((String data) async {
        try {
          final Map<String, dynamic> jsonPayload = jsonDecode(data);
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
