dart
import 'dart:async';
import 'dart:isolate';

class GlobalCoordinator {
  final Map<String, dynamic> tokenLedger = {};

  Future<String> orchestratePipeline(String rawInput) async {
    List<String> domains = [];
    String query = rawInput.toLowerCase();
    if (query.contains("aerospace")) domains.add("Aerospace");
    if (query.contains("economic")) domains.add("Economics");

    List<String> callChain = [];
    List<String> results = [];

    for (var domain in domains) {
      String loopSignature = "Hub->$domain";
      if (callChain.contains(loopSignature)) continue; 
      callChain.add(loopSignature);

      String token = "JWT_${domain.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}";
      tokenLedger[token] = {"target": domain, "exp": DateTime.now().add(const Duration(seconds: 10))};

      final rxPort = ReceivePort();
      await Isolate.spawn(_scoutWorkerIsolate, {
        'port': rxPort.sendPort, 'domain': domain, 'token': token, 'input': rawInput
      });

      final output = await rxPort.first as Map<String, dynamic>;
      results.add(output['delta'].toString());
    }
    return results.isNotEmpty ? results.join("\n") : "Local classification complete. No anomalies detected.";
  }

  static void _scoutWorkerIsolate(Map<String, dynamic> data) {
    final SendPort port = data['port'];
    port.send({'status': 'SUCCESS', 'delta': "[${data['domain']} Isolate Node] Extracted core task vectors locally."});
  }
}
