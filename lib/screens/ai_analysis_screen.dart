import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/claude_service.dart';
import '../services/history_service.dart';
import '../models/analysis_history.dart';

class AiAnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> systemData;

  const AiAnalysisScreen({
    super.key,
    required this.systemData,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  bool _isLoading = true;
  String? _analysis;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyzeSystem();
  }

  Future<void> _analyzeSystem() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _analysis = null;
    });

    try {
      final result = await ClaudeService.analyzeSystemStatus(widget.systemData);

      // 이력에 저장
      final history = AnalysisHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        systemData: widget.systemData,
        aiAnalysis: result,
      );
      await HistoryService.saveHistory(history);

      setState(() {
        _analysis = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_analysis != null) {
      Clipboard.setData(ClipboardData(text: _analysis!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('분석 결과가 클립보드에 복사되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 시스템 분석'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: '복사',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _analyzeSystem,
            tooltip: '다시 분석',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI가 시스템 상태를 분석하고 있습니다...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Claude Opus 4.5로 분석 중',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              '잠시만 기다려주세요',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                '분석 중 오류가 발생했습니다',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _analyzeSystem,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI 분석 결과 카드
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
                  data: _analysis ?? '',
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
        const SizedBox(height: 16),

        // 도움말 카드
        Card(
          color: Colors.amber.shade50,
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
                    Icon(Icons.lightbulb, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '도움말',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem('AI 분석은 현재 시스템 상태를 기반으로 합니다'),
                _buildTipItem('제안된 명령어는 터미널에서 실행하세요'),
                _buildTipItem('중요한 작업 전에는 백업을 권장합니다'),
                _buildTipItem('설정에서 프롬프트를 수정하여 분석 방식을 변경할 수 있습니다'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
