import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const SystemCheckupApp());
}

class SystemCheckupApp extends StatelessWidget {
  const SystemCheckupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시스템 점검',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SystemCheckupHome(),
    );
  }
}

class SystemCheckupHome extends StatefulWidget {
  const SystemCheckupHome({super.key});

  @override
  State<SystemCheckupHome> createState() => _SystemCheckupHomeState();
}

class _SystemCheckupHomeState extends State<SystemCheckupHome> {
  bool _isLoading = false;
  Map<String, CheckResult> _results = {};

  @override
  void initState() {
    super.initState();
    _runCheckup();
  }

  Future<void> _runCheckup() async {
    setState(() {
      _isLoading = true;
      _results = {};
    });

    final checks = [
      _checkBootInfo(),
      _checkDiskUsage(),
      _checkMemoryUsage(),
      _checkCpuLoad(),
      _checkFailedServices(),
      _checkNetworkConnection(),
      _checkCrashReports(),
      _checkRebootHistory(),
    ];

    await Future.wait(checks);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkBootInfo() async {
    try {
      final result = await Process.run('uptime', ['-s']);
      final uptime = await Process.run('uptime', ['-p']);

      final bootTime = result.stdout.toString().trim();
      final uptimeStr = uptime.stdout.toString().trim();

      setState(() {
        _results['부팅 정보'] = CheckResult(
          status: CheckStatus.ok,
          message: '마지막 부팅: $bootTime\n가동 시간: $uptimeStr',
          icon: Icons.power_settings_new,
        );
      });
    } catch (e) {
      setState(() {
        _results['부팅 정보'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  Future<void> _checkDiskUsage() async {
    try {
      final result = await Process.run('df', ['-h', '/']);
      final lines = result.stdout.toString().split('\n');

      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        final usage = parts[4].replaceAll('%', '');
        final usagePercent = int.tryParse(usage) ?? 0;

        final status = usagePercent > 90
            ? CheckStatus.error
            : usagePercent > 75
                ? CheckStatus.warning
                : CheckStatus.ok;

        setState(() {
          _results['디스크 사용량'] = CheckResult(
            status: status,
            message: '사용량: ${parts[4]} (${parts[2]} / ${parts[1]})',
            icon: Icons.storage,
          );
        });
      }
    } catch (e) {
      setState(() {
        _results['디스크 사용량'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  Future<void> _checkMemoryUsage() async {
    try {
      final result = await Process.run('free', ['-h']);
      final lines = result.stdout.toString().split('\n');

      if (lines.length > 1) {
        final memLine = lines[1].split(RegExp(r'\s+'));
        final total = memLine[1];
        final used = memLine[2];
        final available = memLine[6];

        setState(() {
          _results['메모리 사용량'] = CheckResult(
            status: CheckStatus.ok,
            message: '사용: $used / $total\n사용 가능: $available',
            icon: Icons.memory,
          );
        });
      }
    } catch (e) {
      setState(() {
        _results['메모리 사용량'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  Future<void> _checkCpuLoad() async {
    try {
      final result = await Process.run('uptime', []);
      final output = result.stdout.toString();
      final loadMatch = RegExp(r'load average: ([\d.]+), ([\d.]+), ([\d.]+)')
          .firstMatch(output);

      if (loadMatch != null) {
        final load1 = loadMatch.group(1);
        final load5 = loadMatch.group(2);
        final load15 = loadMatch.group(3);

        setState(() {
          _results['CPU 부하'] = CheckResult(
            status: CheckStatus.ok,
            message: '1분: $load1, 5분: $load5, 15분: $load15',
            icon: Icons.speed,
          );
        });
      }
    } catch (e) {
      setState(() {
        _results['CPU 부하'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  Future<void> _checkFailedServices() async {
    try {
      final result = await Process.run('systemctl', ['--failed', '--no-pager']);
      final output = result.stdout.toString();
      final lines = output.split('\n').where((line) => line.isNotEmpty).toList();

      // Header와 footer 제외
      final failedCount = lines.length > 2 ? lines.length - 2 : 0;

      final status = failedCount > 0 ? CheckStatus.warning : CheckStatus.ok;
      final message = failedCount > 0
          ? '실패한 서비스: $failedCount개'
          : '모든 서비스 정상';

      setState(() {
        _results['서비스 상태'] = CheckResult(
          status: status,
          message: message,
          icon: Icons.settings_applications,
        );
      });
    } catch (e) {
      setState(() {
        _results['서비스 상태'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  Future<void> _checkNetworkConnection() async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '2', '8.8.8.8']);
      final success = result.exitCode == 0;

      setState(() {
        _results['네트워크 연결'] = CheckResult(
          status: success ? CheckStatus.ok : CheckStatus.error,
          message: success ? '인터넷 연결 정상' : '인터넷 연결 실패',
          icon: Icons.wifi,
        );
      });
    } catch (e) {
      setState(() {
        _results['네트워크 연결'] = CheckResult(
          status: CheckStatus.error,
          message: '연결 확인 실패: $e',
          icon: Icons.wifi_off,
        );
      });
    }
  }

  Future<void> _checkCrashReports() async {
    try {
      final crashDir = Directory('/var/crash');
      if (await crashDir.exists()) {
        final files = await crashDir
            .list()
            .where((entity) => entity.path.endsWith('.crash'))
            .toList();

        final status = files.isEmpty
            ? CheckStatus.ok
            : files.length > 5
                ? CheckStatus.error
                : CheckStatus.warning;

        final message = files.isEmpty
            ? '크래시 보고서 없음'
            : '크래시 보고서: ${files.length}개';

        setState(() {
          _results['크래시 보고서'] = CheckResult(
            status: status,
            message: message,
            icon: Icons.bug_report,
          );
        });
      } else {
        setState(() {
          _results['크래시 보고서'] = CheckResult(
            status: CheckStatus.ok,
            message: '크래시 디렉토리 없음',
            icon: Icons.check_circle,
          );
        });
      }
    } catch (e) {
      setState(() {
        _results['크래시 보고서'] = CheckResult(
          status: CheckStatus.warning,
          message: '접근 권한 없음',
          icon: Icons.lock,
        );
      });
    }
  }

  Future<void> _checkRebootHistory() async {
    try {
      final result = await Process.run('last', ['reboot', '-5']);
      final lines = result.stdout
          .toString()
          .split('\n')
          .where((line) => line.startsWith('reboot'))
          .toList();

      final message = lines.isEmpty
          ? '재부팅 이력 없음'
          : '최근 재부팅: ${lines.length}회';

      setState(() {
        _results['재부팅 이력'] = CheckResult(
          status: CheckStatus.ok,
          message: message,
          icon: Icons.history,
        );
      });
    } catch (e) {
      setState(() {
        _results['재부팅 이력'] = CheckResult(
          status: CheckStatus.error,
          message: '정보를 가져올 수 없습니다: $e',
          icon: Icons.error,
        );
      });
    }
  }

  void _openAiAnalysis() {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 시스템 점검을 실행해주세요')),
      );
      return;
    }

    // CheckResult를 Map으로 변환
    final systemData = _results.map((key, value) => MapEntry(
          key,
          {
            'status': value.status.name,
            'message': value.message,
          },
        ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiAnalysisScreen(systemData: systemData),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시스템 점검'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
            tooltip: '분석 이력',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _isLoading ? null : _openAiAnalysis,
            tooltip: 'AI 분석',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runCheckup,
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '설정',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('시스템 점검 중...'),
                ],
              ),
            )
          : _results.isEmpty
              ? const Center(child: Text('점검 결과 없음'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // AI 분석 큰 버튼
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        onPressed: _openAiAnalysis,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.purple.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI 분석 요청하기',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Claude Opus 4.5가 시스템 상태를 분석합니다',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 24,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 점검 결과 카드들
                    ..._results.entries.map((entry) {
                      return CheckResultCard(
                        title: entry.key,
                        result: entry.value,
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}

enum CheckStatus { ok, warning, error }

class CheckResult {
  final CheckStatus status;
  final String message;
  final IconData icon;

  CheckResult({
    required this.status,
    required this.message,
    required this.icon,
  });
}

class CheckResultCard extends StatelessWidget {
  final String title;
  final CheckResult result;

  const CheckResultCard({
    super.key,
    required this.title,
    required this.result,
  });

  Color _getColor(CheckStatus status) {
    switch (status) {
      case CheckStatus.ok:
        return Colors.green;
      case CheckStatus.warning:
        return Colors.orange;
      case CheckStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CheckStatus status) {
    switch (status) {
      case CheckStatus.ok:
        return Icons.check_circle;
      case CheckStatus.warning:
        return Icons.warning;
      case CheckStatus.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(result.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              result.icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Icon(
                        _getStatusIcon(result.status),
                        color: color,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
