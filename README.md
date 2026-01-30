# System Checkup - Linux 시스템 점검 GUI 애플리케이션

Flutter로 개발된 Linux 시스템 상태 점검 및 AI 분석 GUI 애플리케이션입니다.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/flutter-3.27.3-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 📋 주요 기능

### 1. 시스템 자동 점검
- ⚡ **부팅 정보**: 마지막 부팅 시간, 가동 시간
- 💾 **디스크 사용량**: 사용률 경고 (90% 이상 빨간색)
- 🧠 **메모리 사용량**: RAM 및 SWAP 상태
- ⚙️ **CPU 부하**: 1분/5분/15분 평균
- 🔧 **서비스 상태**: 실패한 systemd 서비스 확인
- 🌐 **네트워크 연결**: 인터넷 연결 상태
- 🐛 **크래시 보고서**: /var/crash 파일 확인
- 🔄 **재부팅 이력**: 최근 재부팅 기록

### 2. AI 분석 (Claude Opus 4.5)
- 🤖 **지능형 분석**: Claude Opus 4.5가 시스템 상태를 분석
- 📝 **마크다운 뷰**: 보기 좋은 형식으로 결과 표시
- 💡 **구체적인 조언**: 실행 가능한 명령어와 해결책 제공
- ⚙️ **프롬프트 커스터마이징**: 분석 방식을 원하는 대로 수정

### 3. 분석 이력 관리
- 📅 **날짜별 정리**: "오늘", "어제" 등으로 자동 그룹화
- 💾 **자동 저장**: 최대 50개 이력 저장
- 🔍 **상세 보기**: 과거 분석 결과 언제든지 확인
- 🗑️ **이력 관리**: 개별/전체 삭제 기능

### 4. 보안
- 🔒 **안전한 키 저장**: Linux keyring (libsecret)을 사용한 API 키 암호화
- 🔐 **자동 저장**: API 키와 프롬프트 자동 저장

## 🚀 설치 방법

### 사전 요구사항

```bash
# Flutter 개발 도구 설치
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev

# 보안 저장소 라이브러리
sudo apt install -y libsecret-1-dev
```

### Flutter 설치

```bash
# Flutter SDK 다운로드
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.3-stable.tar.xz

# 압축 해제
tar xf flutter_linux_3.27.3-stable.tar.xz

# PATH 추가
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 프로젝트 실행

```bash
# 프로젝트 클론
git clone <repository-url>
cd system_checkup

# 의존성 설치
flutter pub get

# Linux 데스크톱에서 실행
flutter run -d linux

# 릴리즈 빌드
flutter build linux
```

## ⚙️ 설정

### Claude API 키 설정

1. [Anthropic Console](https://console.anthropic.com)에서 API 키 발급
2. 앱 실행 후 **설정 아이콘(⚙️)** 클릭
3. API 키 입력 (자동 저장됨)
4. 프롬프트 수정 (선택사항)

## 📱 사용 방법

### 기본 사용 흐름

1. **앱 실행** → 시스템 자동 점검
2. **보라색 큰 버튼** 클릭 → "AI 분석 요청하기"
3. AI가 시스템 상태 분석 (Claude Opus 4.5)
4. **마크다운 형식**으로 결과 확인
5. **이력 버튼(🕐)** 으로 과거 분석 확인

### 화면 구성

#### 메인 화면
- 🕐 **이력**: 분석 이력 보기
- ⭐ **AI 분석**: 새로운 분석 실행
- 🔄 **새로고침**: 시스템 재점검
- ⚙️ **설정**: API 키 및 프롬프트

#### 이력 화면
- 날짜별 그룹화된 분석 이력
- 상태별 색상 표시 (정상/경고/오류)
- 개별/전체 삭제 기능

## 🛠️ 기술 스택

- **Framework**: Flutter 3.27.3
- **Language**: Dart 3.6.1
- **AI Model**: Claude Opus 4.5 (claude-opus-4-5-20251101)
- **Packages**:
  - `http`: API 통신
  - `flutter_secure_storage`: 안전한 키 저장
  - `shared_preferences`: 설정 저장
  - `flutter_markdown`: 마크다운 렌더링

## 📊 개발 과정

### 총 개발 프롬프트: 11개

이 프로젝트는 **11개의 프롬프트**를 통해 단계적으로 개발되었습니다:

#### Phase 1: 프로젝트 초기화 (프롬프트 1-2)
1. Flutter 프로젝트 생성 및 Linux 환경 설정
2. 기존 Bash 스크립트를 Flutter GUI로 전환

#### Phase 2: 시스템 점검 기능 (프롬프트 2-4)
3. 8가지 시스템 점검 항목 구현
4. Material Design 3 UI 디자인
5. 비동기 병렬 처리로 빠른 점검

#### Phase 3: AI 통합 (프롬프트 5-6)
6. Claude API 연동
7. 보안 저장소 (libsecret) 구현
8. 설정 화면 및 프롬프트 커스터마이징

#### Phase 4: UX 개선 (프롬프트 7-9)
9. 자동 저장 기능 추가
10. Claude Opus 4.5 모델 적용
11. 마크다운 뷰 및 큰 분석 버튼 추가

#### Phase 5: 이력 관리 (프롬프트 10)
12. 분석 이력 자동 저장
13. 날짜별 그룹화 및 관리 화면

#### Phase 6: 문서화 (프롬프트 11)
14. Git 저장소 초기화
15. README 작성 및 버저닝

### 개발 타임라인

```
프롬프트 1-2:   프로젝트 설정 (Flutter 설치, 환경 구성)
프롬프트 3-4:   의존성 설치 (libsecret 등)
프롬프트 5-6:   AI 기능 통합 (Claude API, 보안 저장)
프롬프트 7:     자동 저장 기능
프롬프트 8:     모델 업그레이드 (Opus 4.5)
프롬프트 9:     UI/UX 개선 (마크다운, 큰 버튼)
프롬프트 10:    이력 관리 시스템
프롬프트 11:    문서화 및 버저닝
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                          # 메인 앱 및 시스템 점검 화면
├── models/
│   └── analysis_history.dart         # 분석 이력 모델
├── services/
│   ├── claude_service.dart            # Claude API 서비스
│   ├── storage_service.dart           # 보안 저장 서비스
│   └── history_service.dart           # 이력 관리 서비스
└── screens/
    ├── settings_screen.dart           # 설정 화면
    ├── ai_analysis_screen.dart        # AI 분석 결과 화면
    ├── history_screen.dart            # 분석 이력 목록
    └── history_detail_screen.dart     # 이력 상세 보기
```

## 🎨 특징

### Material Design 3
- 현대적인 디자인 언어
- 그라데이션 헤더
- 카드 기반 레이아웃

### 반응형 UI
- 상태별 색상 구분 (녹색/주황색/빨간색)
- 아이콘과 상태 표시
- 부드러운 애니메이션

### 사용자 경험
- 자동 저장 (별도 버튼 불필요)
- 직관적인 네비게이션
- 명확한 피드백 메시지

## 🔮 향후 계획

- [ ] 자동 새로고침 기능
- [ ] 시스템 알림 통합
- [ ] 다크 모드 지원
- [ ] 여러 AI 모델 선택 지원
- [ ] 보고서 PDF 내보내기
- [ ] 다국어 지원

## 📄 라이선스

MIT License

## 👨‍💻 개발자

Claude Code로 개발됨

## 🙏 감사의 말

- Anthropic Claude API
- Flutter 팀
- Linux 커뮤니티
