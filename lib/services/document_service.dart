import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/document_status.dart';

const _base = 'https://nexoeliteadvisor.com';

class DocumentService {
  final String jwtToken;

  const DocumentService(this.jwtToken);

  Future<DocumentStatus> getStatus() async {
    final res = await http.get(
      Uri.parse('$_base/api/v1/driver/documents/status'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      return DocumentStatus.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>> uploadDocuments({
    required Uint8List cdlBytes,
    required String cdlName,
    required Uint8List insuranceBytes,
    required String insuranceName,
    required Uint8List cabCardBytes,
    required String cabCardName,
    required Uint8List selfieBytes,
    required String selfieName,
  }) async {
    final uri = Uri.parse('$_base/api/v1/driver/documents');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $jwtToken'
      ..files.addAll([
        http.MultipartFile.fromBytes('cdl', cdlBytes,
            filename: cdlName),
        http.MultipartFile.fromBytes('insurance', insuranceBytes,
            filename: insuranceName),
        http.MultipartFile.fromBytes('cab_card', cabCardBytes,
            filename: cabCardName),
        http.MultipartFile.fromBytes('selfie', selfieBytes,
            filename: selfieName),
      ]);

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 200) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    throw Exception('Error ${streamed.statusCode}: $body');
  }
}
