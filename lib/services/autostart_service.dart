import 'dart:io';
import 'package:path/path.dart' as path;

class AutostartService {
  // autostart 디렉토리 경로
  static String get _autostartDir {
    final home = Platform.environment['HOME'] ?? '';
    return path.join(home, '.config', 'autostart');
  }

  // autostart .desktop 파일 경로
  static String get _autostartFilePath {
    return path.join(_autostartDir, 'system-checkup.desktop');
  }

  // 설치된 .desktop 파일 경로
  static String get _installedDesktopPath {
    final home = Platform.environment['HOME'] ?? '';
    return path.join(home, '.local', 'share', 'applications', 'system-checkup.desktop');
  }

  // 자동 시작 활성화 여부 확인
  static Future<bool> isEnabled() async {
    try {
      final file = File(_autostartFilePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // 자동 시작 활성화
  static Future<bool> enable() async {
    try {
      // autostart 디렉토리 생성
      final autostartDir = Directory(_autostartDir);
      if (!await autostartDir.exists()) {
        await autostartDir.create(recursive: true);
      }

      // 설치된 .desktop 파일이 있는지 확인
      final installedDesktop = File(_installedDesktopPath);
      if (!await installedDesktop.exists()) {
        // 설치되지 않은 경우 직접 .desktop 파일 생성
        await _createDesktopFile();
      } else {
        // 설치된 .desktop 파일 복사
        final autostartFile = File(_autostartFilePath);
        await installedDesktop.copy(_autostartFilePath);
      }

      return true;
    } catch (e) {
      print('자동 시작 활성화 실패: $e');
      return false;
    }
  }

  // 자동 시작 비활성화
  static Future<bool> disable() async {
    try {
      final file = File(_autostartFilePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('자동 시작 비활성화 실패: $e');
      return false;
    }
  }

  // .desktop 파일 직접 생성
  static Future<void> _createDesktopFile() async {
    final home = Platform.environment['HOME'] ?? '';
    final executablePath = path.join(home, '.local', 'bin', 'system-checkup');

    final desktopContent = '''[Desktop Entry]
Version=1.0
Type=Application
Name=System Checkup
Name[ko]=시스템 점검
Comment=Linux System Monitoring with AI Analysis
Comment[ko]=AI 분석 기능이 있는 리눅스 시스템 모니터링
Exec=$executablePath
Icon=system-checkup
Terminal=false
Categories=System;Monitor;
Keywords=system;monitor;ai;analysis;check;
Keywords[ko]=시스템;모니터;AI;분석;점검;
StartupNotify=true
X-GNOME-Autostart-enabled=true
''';

    final file = File(_autostartFilePath);
    await file.writeAsString(desktopContent);
  }

  // 자동 시작 토글
  static Future<bool> toggle(bool enable) async {
    if (enable) {
      return await AutostartService.enable();
    } else {
      return await AutostartService.disable();
    }
  }
}
