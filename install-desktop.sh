#!/bin/bash

# System Checkup Desktop Application Installer
# 우분투 응용프로그램 메뉴에 System Checkup을 추가합니다.

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 현재 스크립트의 디렉토리
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 설치 경로
LOCAL_BIN="$HOME/.local/bin"
LOCAL_APPS="$HOME/.local/share/applications"
LOCAL_ICONS="$HOME/.local/share/icons/hicolor/256x256/apps"

# 디렉토리 생성
echo -e "${BLUE}📁 설치 디렉토리 준비 중...${NC}"
mkdir -p "$LOCAL_BIN"
mkdir -p "$LOCAL_APPS"
mkdir -p "$LOCAL_ICONS"

# 빌드 확인
BUNDLE_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"
if [ ! -d "$BUNDLE_DIR" ]; then
    echo -e "${RED}❌ 빌드된 애플리케이션을 찾을 수 없습니다.${NC}"
    echo -e "${BLUE}다음 명령어로 먼저 빌드해주세요:${NC}"
    echo "  flutter build linux --release"
    exit 1
fi

# 번들 전체를 복사
echo -e "${BLUE}📦 애플리케이션 설치 중...${NC}"
TARGET_DIR="$HOME/.local/share/system-checkup"
rm -rf "$TARGET_DIR"
cp -r "$BUNDLE_DIR" "$TARGET_DIR"

# 실행 파일 심볼릭 링크 생성
ln -sf "$TARGET_DIR/system_checkup" "$LOCAL_BIN/system-checkup"

# 아이콘 생성 (간단한 텍스트 아이콘, 나중에 교체 가능)
# 스크린샷을 임시 아이콘으로 사용
if [ -f "$SCRIPT_DIR/screenshots/main-screen.png" ]; then
    cp "$SCRIPT_DIR/screenshots/main-screen.png" "$LOCAL_ICONS/system-checkup.png"
    echo -e "${GREEN}✓ 아이콘 설치 완료${NC}"
    ICON_PATH="system-checkup"
else
    echo -e "${BLUE}ℹ 아이콘 파일이 없습니다. 기본 아이콘을 사용합니다.${NC}"
    ICON_PATH="utilities-system-monitor"
fi

# .desktop 파일 생성
DESKTOP_FILE="$LOCAL_APPS/system-checkup.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=System Checkup
Name[ko]=시스템 점검
Comment=Linux System Monitoring with AI Analysis
Comment[ko]=AI 분석 기능이 있는 리눅스 시스템 모니터링
Exec=$LOCAL_BIN/system-checkup
Icon=$ICON_PATH
Terminal=false
Categories=System;Monitor;
Keywords=system;monitor;ai;analysis;check;
Keywords[ko]=시스템;모니터;AI;분석;점검;
StartupNotify=true
EOF

# 실행 권한 부여
chmod +x "$DESKTOP_FILE"
chmod +x "$LOCAL_BIN/system-checkup"

# 데스크톱 데이터베이스 업데이트
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$LOCAL_APPS"
fi

echo ""
echo -e "${GREEN}✓ 설치가 완료되었습니다!${NC}"
echo ""
echo -e "${BLUE}🚀 사용 방법:${NC}"
echo "  1. 응용프로그램 메뉴에서 'System Checkup' 검색"
echo "  2. 또는 터미널에서: system-checkup"
echo ""
echo -e "${BLUE}📍 설치 위치:${NC}"
echo "  실행파일: $TARGET_DIR"
echo "  바로가기: $LOCAL_BIN/system-checkup"
echo "  메뉴: $DESKTOP_FILE"
echo ""
echo -e "${BLUE}🗑️  제거 방법:${NC}"
echo "  ./uninstall-desktop.sh"
echo ""
