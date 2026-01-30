class AnalysisHistory {
  final String id;
  final DateTime timestamp;
  final Map<String, dynamic> systemData;
  final String aiAnalysis;

  AnalysisHistory({
    required this.id,
    required this.timestamp,
    required this.systemData,
    required this.aiAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'systemData': systemData,
      'aiAnalysis': aiAnalysis,
    };
  }

  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      systemData: Map<String, dynamic>.from(json['systemData']),
      aiAnalysis: json['aiAnalysis'],
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String get statusSummary {
    final data = systemData;
    int okCount = 0;
    int warningCount = 0;
    int errorCount = 0;

    data.forEach((key, value) {
      final status = value['status'];
      if (status == 'ok') {
        okCount++;
      } else if (status == 'warning') {
        warningCount++;
      } else if (status == 'error') {
        errorCount++;
      }
    });

    if (errorCount > 0) {
      return '문제 $errorCount개 발견';
    } else if (warningCount > 0) {
      return '경고 $warningCount개';
    } else {
      return '모두 정상';
    }
  }
}
