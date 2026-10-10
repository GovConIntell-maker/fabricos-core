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
      final BytesBuilder buffer = BytesBuilder();
      int? expectedLength;
      const int maxPayloadBytes = 10 * 1024 * 1024; // 10 MB safety ceiling

      client.listen((Uint8List rawBytes) async {
        try {
          buffer.add(rawBytes);
          List<int> currentBytes = buffer.takeBytes();

          // Step 1: Read 4-byte length header if not yet established
          if (expectedLength == null) {
            if (currentBytes.length < 4) {
              buffer.add(currentBytes); // Wait for remaining header bytes
              return;
            }

            final ByteData header = ByteData.sublistView(
              Uint8List.fromList(currentBytes.sublist(0, 4)),
            );
            expectedLength = header.getUint32(0, Endian.big);

            // Step 2: Enforce hard payload limit before memory allocation
            if (expectedLength! > maxPayloadBytes || expectedLength! < 0) {
              client.destroy(); // Drop connection immediately on violation
              return;
            }

            currentBytes = currentBytes.sublist(4);
          }

          // Step 3: Accumulate until the full declared payload is received
          buffer.add(currentBytes);
          if (buffer.length >= expectedLength!) {
            final Uint8List fullData = buffer.takeBytes();
            final Uint8List payload = fullData.sublist(0, expectedLength!);

            // Retain any spillover bytes for subsequent messages
            if (fullData.length > expectedLength!) {
              buffer.add(fullData.sublist(expectedLength!));
            }

            expectedLength = null; // Reset for next message frame

            // Step 4: Process the validated payload safely
            String decodedString = utf8.decode(payload);
            final Map<String, dynamic> jsonPayload = jsonDecode(decodedString);
            
            // Capture potential activation tokens passing over the mesh bus
            if (jsonPayload.containsKey('activation_key')) {
              _activeLicenseKey = jsonPayload['activation_key'] ?? "UNLICENSED";
            }
            
            String text = jsonPayload['data'] ?? "";
            
            // Pass input stream and license key signature to the Coordinator graph
            String responseContext = await _coordinator.orchestratePipeline(text, _activeLicenseKey);
            client.write(jsonEncode({'status': 'SUCCESS', 'context': responseContext}));
          } else {
            // Put incomplete buffer state back for the next chunk
            buffer.add(currentBytes);
          }
        } catch (e) {
          // Step 5: Catch malformed payload exceptions and drop cleanly
          try {
            client.write(jsonEncode({'status': 'ERROR', 'msg': e.toString()}));
          } catch (_) {}
          client.destroy();
        }
      }, onError: (error) {
        client.destroy();
      }, onDone: () {
        client.destroy();
      });
    });
  }
}
