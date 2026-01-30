import 'package:flutter/material.dart';
import '../models/analysis_history.dart';
import '../services/history_service.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisHistory> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);
    final histories = await HistoryService.getHistories();
    setState(() {
      _histories = histories;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이력 삭제'),
        content: const Text('이 분석 이력을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.deleteHistory(id);
      _loadHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이력이 삭제되었습니다')),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 이력 삭제'),
        content: const Text('모든 분석 이력을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('모두 삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearAllHistory();
      _loadHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 이력이 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 이력'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_histories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
              tooltip: '모두 삭제',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '분석 이력이 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 분석을 실행하면 이력이 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final groupedHistories = HistoryService.groupByDate(_histories);
    final sortedKeys = groupedHistories.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final histories = groupedHistories[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 해당 날짜의 이력들
            ...histories.map((history) => _buildHistoryCard(history)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(AnalysisHistory history) {
    Color statusColor;
    IconData statusIcon;

    if (history.statusSummary.contains('문제')) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (history.statusSummary.contains('경고')) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailScreen(history: history),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 상태 아이콘
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.statusSummary,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey.shade600,
                onPressed: () => _deleteHistory(history.id),
              ),
              // 화살표
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
