import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../services/autostart_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _promptController = TextEditingController();
  bool _isLoading = true;
  bool _apiKeyVisible = false;
  bool _hasChanges = false;
  bool _autostartEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // 자동 저장을 위한 리스너 추가
    _apiKeyController.addListener(_markAsChanged);
    _promptController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final apiKey = await StorageService.getApiKey();
    final prompt = await StorageService.getSystemPrompt();
    final autostartEnabled = await AutostartService.isEnabled();

    _apiKeyController.text = apiKey ?? '';
    _promptController.text = prompt;

    setState(() {
      _autostartEnabled = autostartEnabled;
      _isLoading = false;
      _hasChanges = false;
    });
  }

  Future<void> _autoSave() async {
    if (!_hasChanges) return;

    final apiKey = _apiKeyController.text.trim();
    final prompt = _promptController.text.trim();

    // API 키는 비어있어도 저장 가능 (나중에 입력할 수 있음)
    if (apiKey.isNotEmpty) {
      await StorageService.saveApiKey(apiKey);
    }

    if (prompt.isNotEmpty) {
      await StorageService.saveSystemPrompt(prompt);
    }

    setState(() => _hasChanges = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ 자동 저장되었습니다'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetPrompt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프롬프트 초기화'),
        content: const Text('프롬프트를 기본값으로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.resetSystemPrompt();
      _promptController.text = StorageService.defaultSystemPrompt;
      await _autoSave();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프롬프트가 초기화되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleAutostart(bool value) async {
    final success = await AutostartService.toggle(value);

    if (success) {
      setState(() => _autostartEnabled = value);
      await StorageService.setAutostartEnabled(value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '✓ 자동 시작이 활성화되었습니다' : '✓ 자동 시작이 비활성화되었습니다'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('자동 시작 설정에 실패했습니다'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL을 열 수 없습니다: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('설정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                label: const Text('저장 안됨'),
                backgroundColor: Colors.orange.shade100,
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 자동 저장 안내
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '입력 후 다른 곳을 클릭하면 자동으로 저장됩니다',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API 키 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Claude API 키',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) _autoSave();
                    },
                    child: TextField(
                      controller: _apiKeyController,
                      obscureText: !_apiKeyVisible,
                      decoration: InputDecoration(
                        labelText: 'API 키',
                        hintText: 'sk-ant-api03-...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_apiKeyVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() => _apiKeyVisible = !_apiKeyVisible);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Claude API 키는 https://console.anthropic.com 에서 발급받을 수 있습니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // URL 열기 기능은 추후 추가 가능
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('브라우저에서 https://console.anthropic.com 을 열어주세요'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('API 키 발급받기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 프롬프트 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '시스템 프롬프트',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _resetPrompt,
                        icon: const Icon(Icons.refresh),
                        label: const Text('초기화'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI가 시스템 상태를 분석할 때 사용할 프롬프트를 설정합니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) _autoSave();
                    },
                    child: TextField(
                      controller: _promptController,
                      maxLines: 12,
                      decoration: const InputDecoration(
                        labelText: '프롬프트',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 자동 시작 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.power_settings_new, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '자동 시작',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '로그인 시 자동으로 System Checkup을 실행합니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('로그인 시 자동 실행'),
                    subtitle: Text(
                      _autostartEnabled
                          ? '활성화됨 - 로그인할 때마다 자동으로 실행됩니다'
                          : '비활성화됨 - 수동으로 실행해야 합니다',
                    ),
                    value: _autostartEnabled,
                    onChanged: _toggleAutostart,
                    activeColor: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 도움말 섹션
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '사용 방법',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Claude API 키를 입력하세요 (console.anthropic.com)\n'
                    '2. 필요한 경우 프롬프트를 수정하세요\n'
                    '3. 다른 곳을 클릭하면 자동으로 저장됩니다\n'
                    '4. 메인 화면에서 ⭐ 버튼을 눌러 AI 분석을 실행하세요',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 앱 정보 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '앱 정보',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.tag, color: Colors.blue),
                    title: const Text('버전'),
                    subtitle: const Text('1.0.0'),
                    dense: true,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: const Text('설명'),
                    subtitle: const Text('AI 기반 Linux 시스템 모니터링 도구'),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 개발자 정보 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '개발자',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: const Text('hongsw'),
                    subtitle: const Text('GitHub: @hongsw'),
                    dense: true,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl('https://github.com/hongsw/system-checkup'),
                    icon: const Icon(Icons.link),
                    label: const Text('GitHub 저장소'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl('https://github.com/hongsw/system-checkup/issues'),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('버그 신고 / 기능 제안'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl('https://github.com/sponsors/hongsw'),
                    icon: const Icon(Icons.favorite),
                    label: const Text('개발자 후원하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade100,
                      foregroundColor: Colors.pink.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 사용된 라이브러리 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.library_books, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '사용된 라이브러리',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이 앱은 오픈소스 라이브러리를 사용하여 만들어졌습니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  _buildLibraryTile(
                    'Flutter',
                    'Google의 크로스 플랫폼 UI 프레임워크',
                    'https://flutter.dev',
                  ),
                  _buildLibraryTile(
                    'http (^1.1.0)',
                    'HTTP 요청을 위한 패키지',
                    'https://pub.dev/packages/http',
                  ),
                  _buildLibraryTile(
                    'flutter_secure_storage (^9.0.0)',
                    'API 키를 안전하게 저장',
                    'https://pub.dev/packages/flutter_secure_storage',
                  ),
                  _buildLibraryTile(
                    'shared_preferences (^2.2.2)',
                    '앱 설정 저장',
                    'https://pub.dev/packages/shared_preferences',
                  ),
                  _buildLibraryTile(
                    'flutter_markdown (^0.7.4+1)',
                    'AI 분석 결과를 마크다운으로 렌더링',
                    'https://pub.dev/packages/flutter_markdown',
                  ),
                  _buildLibraryTile(
                    'url_launcher (^6.2.4)',
                    'URL 열기',
                    'https://pub.dev/packages/url_launcher',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '모든 라이브러리 개발자분들께 감사드립니다! 🙏',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTile(String name, String description, String url) {
    return ListTile(
      leading: const Icon(Icons.code, size: 20, color: Colors.orange),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new, size: 18),
        onPressed: () => _launchUrl(url),
        tooltip: 'pub.dev에서 보기',
      ),
      dense: true,
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _promptController.dispose();
    super.dispose();
  }
}
