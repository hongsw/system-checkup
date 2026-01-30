import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ClaudeService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-opus-4-5-20251101';

  static Future<String> analyzeSystemStatus(
      Map<String, dynamic> systemData) async {
    final apiKey = await StorageService.getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API 키가 설정되지 않았습니다. 설정에서 API 키를 입력해주세요.');
    }

    final systemPrompt = await StorageService.getSystemPrompt();

    // 시스템 데이터를 읽기 쉬운 텍스트로 변환
    final systemReport = _formatSystemReport(systemData);

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 2000,
        'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': '다음은 현재 시스템 점검 결과입니다:\n\n$systemReport',
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
          'API 오류 (${response.statusCode}): ${error['error']?['message'] ?? '알 수 없는 오류'}');
    }
  }

  static String _formatSystemReport(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    buffer.writeln('=== 시스템 점검 보고서 ===\n');

    data.forEach((key, value) {
      buffer.writeln('[$key]');
      buffer.writeln('상태: ${value['status']}');
      buffer.writeln('내용: ${value['message']}');
      buffer.writeln();
    });

    return buffer.toString();
  }
}
