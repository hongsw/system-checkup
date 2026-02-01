# System Checkup - Project Specification

## 📋 Project Overview

**Name**: System Checkup
**Type**: Linux Desktop Application
**Framework**: Flutter 3.27.3
**Platform**: Linux (with future support for Windows/macOS)
**Purpose**: AI-powered Linux system monitoring and analysis tool

## 🎯 Core Features

### 1. System Monitoring (8 Items)

The application must check and display the following system information:

1. **Boot Information**
   - Command: `uptime -s` (last boot time)
   - Command: `uptime -p` (uptime)
   - Display: Last boot time and total uptime

2. **Disk Usage**
   - Command: `df -h --output=source,size,used,pcent,target`
   - Warning: Red color if usage > 90%
   - Display: All mounted filesystems with usage percentages

3. **Memory Usage**
   - Command: `free -h`
   - Display: RAM usage (used/total) and SWAP usage
   - Show both in GB with percentages

4. **CPU Load**
   - Command: `cat /proc/loadavg`
   - Display: 1-minute, 5-minute, and 15-minute load averages

5. **Service Status**
   - Command: `systemctl --failed`
   - Display: List of failed systemd services
   - Status: "모든 서비스 정상" if none failed

6. **Network Connection**
   - Command: `ping -c 1 8.8.8.8`
   - Display: Internet connectivity status
   - Status: Connected or Disconnected

7. **Crash Reports**
   - Command: `ls /var/crash 2>/dev/null`
   - Display: Presence of crash reports
   - Status: "크래시 보고서 없음" if empty

8. **Reboot History**
   - Command: `last reboot -n 5`
   - Display: Last 5 system reboots

### 2. AI Analysis Integration

**AI Provider**: Claude API (Anthropic)
**Model**: Claude Opus 4.5 (`claude-opus-4-20250514`)

**Workflow**:
1. Collect all 8 system check results
2. Send to Claude API with system prompt
3. Receive markdown-formatted analysis
4. Display results in markdown viewer
5. Auto-save to history

**Default System Prompt** (Korean):
```
당신은 리눅스 시스템 관리 전문가입니다.
시스템 점검 결과를 분석하고 일반 사용자가 이해하기 쉽게 설명해주세요.

다음 형식으로 응답해주세요:

1. **전체 상태 요약** (한 줄로 간단히)
2. **주요 발견사항** (중요한 문제나 경고사항)
3. **권장 조치** (구체적인 해결 방법, 명령어 포함)
4. **추가 정보** (알아두면 좋은 팁)

기술적인 용어는 쉬운 말로 풀어서 설명하고, 실행 가능한 구체적인 명령어를 제공해주세요.
```

### 3. Analysis History Management

**Features**:
- Save up to 50 analysis results
- Date grouping: "오늘", "어제", "이번 주", "이번 달", "이전"
- Status indicators: Normal (green), Warning (yellow), Error (red)
- Detail view: Re-display previous analysis
- Deletion: Individual or bulk delete

**Storage**:
- Use `shared_preferences` package
- JSON serialization for history items
- Each item contains:
  - Timestamp
  - System check results
  - AI analysis response
  - Overall status

### 4. Settings Screen

**API Configuration**:
- Claude API key input (secure storage)
- Visibility toggle for API key
- Link to https://console.anthropic.com

**System Prompt**:
- Editable text area (12 lines)
- Reset to default button
- Auto-save on focus loss

**Auto-start Configuration**:
- Toggle switch for login auto-start
- Manages `~/.config/autostart/system-checkup.desktop`
- Status indicator

**App Information**:
- Version: 1.0.0
- Description: AI 기반 Linux 시스템 모니터링 도구

**Developer Information**:
- Developer: hongsw
- GitHub repository link
- Bug report/feature request link
- Sponsor button (GitHub Sponsors)

**Used Libraries**:
- List all dependencies with descriptions
- Links to pub.dev for each package
- Thank you message to library developers

## 🎨 UI/UX Requirements

### Main Screen

**Top Bar** (4 buttons):
- 🕐 History - Navigate to history screen
- ⭐ AI Analysis - Trigger AI analysis (purple button)
- 🔄 Refresh - Re-run system checks
- ⚙️ Settings - Open settings screen

**System Check Results**:
- 8 Cards displaying check results
- Icons for each check type
- Status indicators (✓ green checkmark)
- Clear, readable typography

**AI Analysis Button**:
- Large purple card
- "AI 분석 요청하기" text
- "Claude Opus 4.5가 시스템 상태를 분석합니다" subtitle
- Prominent placement

### AI Analysis Screen

**Features**:
- Full-screen markdown viewer
- Scrollable content
- Back button
- Markdown rendering with `flutter_markdown`

### History Screen

**Layout**:
- Date-grouped list
- Each item shows:
  - Timestamp
  - Summary
  - Status color indicator
- Tap to view details
- Delete buttons (individual and bulk)

### Settings Screen

**Sections** (in order):
1. Auto-save info banner (blue)
2. API Key card
3. System Prompt card
4. Auto-start card
5. Help/Usage card (amber)
6. App Info card
7. Developer Info card
8. Used Libraries card

**Color Scheme**:
- Primary: Purple (`Theme.of(context).colorScheme.inversePrimary`)
- Success: Green
- Warning: Orange
- Error: Red
- Info: Blue

## 🔧 Technical Requirements

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0                      # HTTP requests
  flutter_secure_storage: ^9.0.0   # Secure API key storage
  shared_preferences: ^2.2.2       # Settings storage
  json_annotation: ^4.8.1          # JSON serialization
  flutter_markdown: ^0.7.4+1       # Markdown rendering
  url_launcher: ^6.2.4             # Open URLs

dev_dependencies:
  flutter_lints: ^5.0.0
```

### File Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── analysis_history.dart         # History data model
├── services/
│   ├── claude_service.dart           # Claude API integration
│   ├── storage_service.dart          # Secure storage & preferences
│   ├── history_service.dart          # History management
│   └── autostart_service.dart        # Auto-start management
└── screens/
    ├── settings_screen.dart          # Settings UI
    ├── ai_analysis_screen.dart       # AI analysis viewer
    ├── history_screen.dart           # History list
    └── history_detail_screen.dart    # History detail view
```

### Data Models

**AnalysisHistory**:
```dart
class AnalysisHistory {
  final String id;              // UUID
  final DateTime timestamp;
  final String systemInfo;      // JSON of system checks
  final String aiAnalysis;      // Markdown response
  final String status;          // 'normal', 'warning', 'error'
}
```

## 🔒 Security Requirements

1. **API Key Storage**:
   - Use `flutter_secure_storage`
   - Encrypted with Linux keyring (libsecret)
   - Never log or expose in UI

2. **Auto-save**:
   - Save settings immediately on change
   - Visual feedback (snackbar)

3. **Input Validation**:
   - Validate API key format
   - Handle empty inputs gracefully

## 📱 Installation & Deployment

### Desktop Integration Script

Create `install-desktop.sh`:
- Build release version
- Copy bundle to `~/.local/share/system-checkup/`
- Create symlink in `~/.local/bin/system-checkup`
- Create `.desktop` file in `~/.local/share/applications/`
- Use main-screen.png as icon
- Update desktop database

Create `uninstall-desktop.sh`:
- Remove all installed files
- Clean up desktop integration

### Auto-start Management

**Enable**:
- Copy `.desktop` file to `~/.config/autostart/`
- Add `X-GNOME-Autostart-enabled=true`

**Disable**:
- Remove `.desktop` file from `~/.config/autostart/`

## 🌐 Localization

**Primary Language**: Korean (한국어)
**UI Text**: All user-facing text in Korean
**Code Comments**: Korean for clarity

**Key Phrases**:
- "시스템 점검" - System Checkup
- "AI 분석 요청하기" - Request AI Analysis
- "설정" - Settings
- "이력" - History
- "새로고침" - Refresh

## 📊 System Commands

All system commands must:
- Handle errors gracefully
- Timeout after 5 seconds
- Return empty/default on failure
- Never crash the app

**Example Error Handling**:
```dart
try {
  final result = await Process.run('command', ['args'],
    timeout: Duration(seconds: 5)
  );
  return result.stdout;
} catch (e) {
  return 'Error: Unable to fetch data';
}
```

## 🎯 User Stories

1. **As a Linux user**, I want to see my system status at a glance
2. **As a non-technical user**, I want AI to explain system issues in simple terms
3. **As a system admin**, I want specific commands to fix problems
4. **As a daily user**, I want the app to start automatically on login
5. **As a privacy-conscious user**, I want my API key securely stored

## 📝 Additional Requirements

1. **Responsive Layout**: Handle different window sizes
2. **Error Messages**: Clear, helpful Korean messages
3. **Loading States**: Show progress indicators
4. **Empty States**: Helpful messages when no data
5. **Offline Gracefully**: Work without internet (except AI analysis)

## 🚀 Future Enhancements (Out of Scope for v1.0)

### Security Monitoring (v2.0 Planned)

**침투 탐지 (Intrusion Detection)**:

1. **Failed Login Attempts**
   - Command: `grep "Failed password" /var/log/auth.log 2>/dev/null | tail -20`
   - Alternative: `lastb -n 20` (failed login database)
   - Display: Recent failed SSH/login attempts with IP addresses
   - Warning: Red alert if > 10 failed attempts in last hour

2. **Sudo Usage Log**
   - Command: `grep "sudo:" /var/log/auth.log 2>/dev/null | tail -15`
   - Display: Recent sudo command usage with user and timestamp
   - Purpose: Detect unauthorized privilege escalation

3. **Critical File Modifications**
   - Command: `find /etc -type f -mtime -1 2>/dev/null | head -20`
   - Display: System configuration files modified in last 24 hours
   - Warning: Alert on unexpected changes to /etc/passwd, /etc/shadow, /etc/sudoers

4. **New User Accounts**
   - Command: `awk -F: '$3 >= 1000 {print $1":"$3":"$7}' /etc/passwd`
   - Command: `ls -lt /home | head -10`
   - Display: Recently created user accounts (UID >= 1000)
   - Warning: Alert on unknown new accounts

5. **Suspicious Processes**
   - Command: `ps aux --sort=-%mem | head -15`
   - Command: `ps aux | grep -E "(nc|ncat|netcat|/tmp/)" | grep -v grep`
   - Display: Processes with unusual names or running from /tmp
   - Warning: Alert on known malicious process patterns

**네트워크 보안 (Network Security)**:

1. **Firewall Status**
   - Command: `sudo ufw status verbose` (UFW)
   - Alternative: `sudo iptables -L -n | head -30` (iptables)
   - Display: Firewall enabled/disabled status and active rules
   - Warning: Red alert if firewall is disabled

2. **Open Ports & Listening Services**
   - Command: `ss -tulnp | grep LISTEN`
   - Alternative: `netstat -tulnp | grep LISTEN`
   - Display: All listening ports with associated services
   - Warning: Alert on unexpected open ports (e.g., 23-Telnet, unusual high ports)

3. **Active Network Connections**
   - Command: `ss -tunap | grep ESTAB | head -20`
   - Display: Currently established connections with remote IPs
   - Purpose: Detect unusual outbound connections

4. **SSH Security Configuration**
   - Command: `grep -E "^(PermitRootLogin|PasswordAuthentication|Port)" /etc/ssh/sshd_config 2>/dev/null`
   - Display: SSH security settings
   - Warning: Alert if PermitRootLogin=yes or PasswordAuthentication=yes

5. **Recent Network Authentication Failures**
   - Command: `grep -i "authentication failure" /var/log/auth.log 2>/dev/null | tail -15`
   - Display: Failed authentication attempts with source IPs
   - Warning: Alert on repeated failures from same IP (potential brute force)

**Implementation Notes**:

- Many commands require sudo privileges - handle permission errors gracefully
- Add permission request dialog on first security check
- Store sudo credentials temporarily (with user consent)
- Add "Security Check" toggle in settings (disabled by default)
- Update AI prompt to include security analysis when enabled
- Color coding: Green (secure), Yellow (warning), Red (critical)

**Updated System Prompt for Security Mode**:

```text
당신은 리눅스 시스템 및 보안 전문가입니다.
시스템 점검 및 보안 분석 결과를 검토하고 일반 사용자가 이해하기 쉽게 설명해주세요.

다음 형식으로 응답해주세요:

1. **전체 상태 요약** (시스템 상태 및 보안 수준을 한 줄로)
2. **주요 발견사항** (중요한 문제, 보안 경고사항, 침투 흔적)
3. **보안 권장사항** (구체적인 보안 강화 방법 및 명령어)
4. **권장 조치** (즉시 취해야 할 조치사항)
5. **추가 정보** (보안 모범 사례 및 팁)

보안 위협은 심각도 순으로 정리하고, 실행 가능한 구체적인 해결 명령어를 제공해주세요.
```

### Other Planned Features

- Windows/macOS support
- Auto-refresh functionality
- Dark mode
- Multiple AI model selection
- PDF report export
- Multi-language support
- Mobile apps (Android/iOS)

## ✅ Acceptance Criteria

1. ✓ All 8 system checks work correctly
2. ✓ Claude API integration functional
3. ✓ History saves and loads properly
4. ✓ Settings persist across restarts
5. ✓ Desktop installation script works
6. ✓ Auto-start toggle works
7. ✓ All links open in browser
8. ✓ Markdown renders correctly
9. ✓ UI is responsive and polished
10. ✓ No crashes or data loss

## 📖 Development Notes

- Developed with Claude Code (AI pair programming)
- Iterative development approach
- Focus on user experience
- Clean, maintainable code
- Comprehensive error handling

---

**Version**: 1.0.0
**Last Updated**: 2026-01-31
**Author**: hongsw
**License**: MIT
