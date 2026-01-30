#!/bin/bash

# System Checkup Desktop Application Uninstaller
# 응용프로그램 메뉴에서 System Checkup을 제거합니다.

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 설치 경로
LOCAL_BIN="$HOME/.local/bin"
LOCAL_APPS="$HOME/.local/share/applications"
LOCAL_ICONS="$HOME/.local/share/icons/hicolor/256x256/apps"
TARGET_DIR="$HOME/.local/share/system-checkup"

echo -e "${BLUE}🗑️  System Checkup 제거 중...${NC}"

# 파일 및 디렉토리 제거
rm -f "$LOCAL_BIN/system-checkup"
rm -f "$LOCAL_APPS/system-checkup.desktop"
rm -f "$LOCAL_ICONS/system-checkup.png"
rm -rf "$TARGET_DIR"

# 데스크톱 데이터베이스 업데이트
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$LOCAL_APPS"
fi

echo ""
echo -e "${GREEN}✓ 제거가 완료되었습니다!${NC}"
echo ""
echo -e "${BLUE}ℹ  프로젝트 폴더는 그대로 남아있습니다:${NC}"
echo "  $(dirname "$0")"
echo ""
