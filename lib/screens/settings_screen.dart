import 'package:flutter/material.dart';
import '../services/storage_service.dart';

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

    _apiKeyController.text = apiKey ?? '';
    _promptController.text = prompt;

    setState(() {
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _promptController.dispose();
    super.dispose();
  }
}
