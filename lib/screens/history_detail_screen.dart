import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/analysis_history.dart';

class HistoryDetailScreen extends StatelessWidget {
  final AnalysisHistory history;

  const HistoryDetailScreen({
    super.key,
    required this.history,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: history.aiAnalysis));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('분석 결과가 클립보드에 복사되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 이력 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
            tooltip: '복사',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 날짜 및 상태 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '분석 시간',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${history.timestamp.year}년 ${history.timestamp.month}월 ${history.timestamp.day}일 '
                    '${history.timestamp.hour.toString().padLeft(2, '0')}:${history.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.assessment, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '상태 요약',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    history.statusSummary,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI 분석 결과
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.blue.shade400,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI 분석 결과',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Claude Opus 4.5',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 마크다운 내용
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: MarkdownBody(
                    data: history.aiAnalysis,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      h3: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.purple.shade700,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      blockquote: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border(
                          left: BorderSide(
                            color: Colors.blue.shade400,
                            width: 4,
                          ),
                        ),
                      ),
                      listBullet: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
