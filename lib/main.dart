import 'package:flutter/material.dart';
import 'mesh_network.dart';
import 'stt_service.dart';

void main() => runApp(const MaterialApp(home: FabricOSMobileUI()));

class FabricOSMobileUI extends StatefulWidget {
  const FabricOSMobileUI({super.key});
  @override
  State<FabricOSMobileUI> createState() => _FabricOSMobileUIState();
}

class _FabricOSMobileUIState extends State<FabricOSMobileUI> {
  final MobileMeshGateway _meshGateway = MobileMeshGateway();
  final MobileSTTEngine _sttEngine = MobileSTTEngine();
  String _systemState = "STANDBY";
  String _consoleLogs = "Awaiting ad-hoc communication streams...";

  @override
  void initState() {
    super.initState();
    _sttEngine.initializeSTT();
  }

  void _toggleSystemGateway() async {
    setState(() {
      _systemState = "BROADCASTING MESH GATEWAY (ACTIVE)";
      _consoleLogs = "Mesh server running on port 8990. Radio perimeter secure.";
    });
    await _meshGateway.bootMeshGateway();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("FabricOS Master Console"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("System Status: $_systemState", style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
              width: double.infinity,
              height: 150,
              child: SingleChildScrollView(child: Text(_consoleLogs, style: const TextStyle(color: Colors.white70, fontFamily: 'Courier'))),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 60)),
              onPressed: _toggleSystemGateway,
              child: const Text("BOOT FABRICOS GATEWAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
