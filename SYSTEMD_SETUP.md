# System Checkup - systemd 서비스 설정

## 설치 완료 ✓

System Checkup이 systemd 사용자 서비스로 설정되었습니다.

### 설치된 파일

- **서비스 파일**: `~/.config/systemd/user/system-checkup.service`
- **실행 파일**: `~/dev/linux_small_tools/system_checkup/build/linux/x64/release/bundle/system_checkup`
- **자동 시작**: 로그인 시 자동 실행 (enabled)

## 서비스 관리 명령어

### 상태 확인
```bash
systemctl --user status system-checkup.service
```

### 시작/중지/재시작
```bash
systemctl --user start system-checkup.service
systemctl --user stop system-checkup.service
systemctl --user restart system-checkup.service
```

### 자동 시작 설정
```bash
# 활성화 (부팅 시 자동 시작)
systemctl --user enable system-checkup.service

# 비활성화
systemctl --user disable system-checkup.service
```

### 로그 확인
```bash
# 실시간 로그
journalctl --user -u system-checkup.service -f

# 전체 로그
journalctl --user -u system-checkup.service

# 최근 50줄
journalctl --user -u system-checkup.service -n 50
```

## 서비스 파일 내용

```ini
[Unit]
Description=System Checkup - System Health Monitoring GUI
Documentation=https://github.com/hongsw/system-checkup
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/home/martin/dev/linux_small_tools/system_checkup/build/linux/x64/release/bundle/system_checkup
Restart=on-failure
RestartSec=5s
# 환경 변수는 세션에서 상속됨

[Install]
WantedBy=default.target
```

## 특징

- **자동 재시작**: 오류 발생 시 5초 후 자동 재시작
- **그래픽 세션 연동**: graphical-session.target 이후 실행
- **로그인 시 자동 시작**: default.target에 연결됨
- **표준 systemd 방식**: 리눅스 표준 서비스 관리 도구 사용

## 제거 방법

```bash
# 서비스 중지 및 비활성화
systemctl --user stop system-checkup.service
systemctl --user disable system-checkup.service

# 서비스 파일 삭제
rm ~/.config/systemd/user/system-checkup.service

# systemd 데몬 재로드
systemctl --user daemon-reload
```

## 문제 해결

### GUI 창이 안 뜨는 경우
```bash
# 로그 확인
journalctl --user -u system-checkup.service -n 20

# 수동으로 실행해보기
~/dev/linux_small_tools/system_checkup/build/linux/x64/release/bundle/system_checkup
```

### 재빌드 후 재시작
```bash
cd ~/dev/linux_small_tools/system_checkup
~/flutter/bin/flutter build linux --release
systemctl --user restart system-checkup.service
```
