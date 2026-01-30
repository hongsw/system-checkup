import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyKey = 'claude_api_key';
  static const _systemPromptKey = 'system_prompt';

  // 기본 시스템 프롬프트
  static const defaultSystemPrompt = '''당신은 리눅스 시스템 관리 전문가입니다.
시스템 점검 결과를 분석하고 일반 사용자가 이해하기 쉽게 설명해주세요.

다음 형식으로 응답해주세요:

1. **전체 상태 요약** (한 줄로 간단히)
2. **주요 발견사항** (중요한 문제나 경고사항)
3. **권장 조치** (구체적인 해결 방법, 명령어 포함)
4. **추가 정보** (알아두면 좋은 팁)

기술적인 용어는 쉬운 말로 풀어서 설명하고, 실행 가능한 구체적인 명령어를 제공해주세요.''';

  // API 키 저장
  static Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  // API 키 불러오기
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  // API 키 삭제
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  // 시스템 프롬프트 저장
  static Future<void> saveSystemPrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_systemPromptKey, prompt);
  }

  // 시스템 프롬프트 불러오기
  static Future<String> getSystemPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_systemPromptKey) ?? defaultSystemPrompt;
  }

  // 시스템 프롬프트 초기화
  static Future<void> resetSystemPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_systemPromptKey);
  }
}
