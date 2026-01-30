import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_history.dart';

class HistoryService {
  static const _historyKey = 'analysis_history';
  static const _maxHistoryCount = 50; // 최대 50개까지 저장

  // 이력 저장
  static Future<void> saveHistory(AnalysisHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    // 새 이력 추가 (최신이 맨 앞)
    histories.insert(0, history);

    // 최대 개수 제한
    if (histories.length > _maxHistoryCount) {
      histories.removeRange(_maxHistoryCount, histories.length);
    }

    // JSON으로 변환하여 저장
    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // 모든 이력 불러오기
  static Future<List<AnalysisHistory>> getHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => AnalysisHistory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 특정 이력 삭제
  static Future<void> deleteHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    histories.removeWhere((h) => h.id == id);

    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // 모든 이력 삭제
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // 날짜별로 그룹화
  static Map<String, List<AnalysisHistory>> groupByDate(
      List<AnalysisHistory> histories) {
    final grouped = <String, List<AnalysisHistory>>{};

    for (final history in histories) {
      final dateKey = _getDateKey(history.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(history);
    }

    return grouped;
  }

  static String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == yesterday) {
      return '어제';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }
}
