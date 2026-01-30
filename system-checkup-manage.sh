#!/bin/bash
# System Checkup 서비스 관리 스크립트

SERVICE_NAME="system-checkup.service"
PROJECT_DIR="$HOME/dev/linux_small_tools/system_checkup"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 도움말 표시
show_help() {
    echo -e "${BLUE}System Checkup 서비스 관리 도구${NC}"
    echo ""
    echo "사용법: $0 [명령어]"
    echo ""
    echo "명령어:"
    echo "  status      서비스 상태 확인"
    echo "  start       서비스 시작"
    echo "  stop        서비스 중지"
    echo "  restart     서비스 재시작"
    echo "  enable      자동 시작 활성화"
    echo "  disable     자동 시작 비활성화"
    echo "  logs        실시간 로그 보기"
    echo "  logs-all    전체 로그 보기"
    echo "  rebuild     다시 빌드하고 재시작"
    echo "  install     systemd 서비스 설치"
    echo "  uninstall   systemd 서비스 제거"
    echo "  help        이 도움말 표시"
    echo ""
}

# 서비스 상태 확인
check_status() {
    echo -e "${BLUE}서비스 상태:${NC}"
    systemctl --user status $SERVICE_NAME
}

# 서비스 시작
start_service() {
    echo -e "${GREEN}서비스 시작 중...${NC}"
    systemctl --user start $SERVICE_NAME
    sleep 1
    systemctl --user status $SERVICE_NAME | head -5
}

# 서비스 중지
stop_service() {
    echo -e "${YELLOW}서비스 중지 중...${NC}"
    systemctl --user stop $SERVICE_NAME
    echo -e "${GREEN}서비스가 중지되었습니다.${NC}"
}

# 서비스 재시작
restart_service() {
    echo -e "${YELLOW}서비스 재시작 중...${NC}"
    systemctl --user restart $SERVICE_NAME
    sleep 1
    systemctl --user status $SERVICE_NAME | head -5
}

# 자동 시작 활성화
enable_service() {
    echo -e "${GREEN}자동 시작 활성화 중...${NC}"
    systemctl --user enable $SERVICE_NAME
    echo -e "${GREEN}로그인 시 자동으로 시작됩니다.${NC}"
}

# 자동 시작 비활성화
disable_service() {
    echo -e "${YELLOW}자동 시작 비활성화 중...${NC}"
    systemctl --user disable $SERVICE_NAME
    echo -e "${GREEN}자동 시작이 비활성화되었습니다.${NC}"
}

# 실시간 로그
show_logs() {
    echo -e "${BLUE}실시간 로그 (Ctrl+C로 종료):${NC}"
    journalctl --user -u $SERVICE_NAME -f
}

# 전체 로그
show_all_logs() {
    echo -e "${BLUE}전체 로그:${NC}"
    journalctl --user -u $SERVICE_NAME
}

# 다시 빌드
rebuild() {
    echo -e "${BLUE}프로젝트 다시 빌드 중...${NC}"
    cd "$PROJECT_DIR" || exit 1

    if [ ! -f "$HOME/flutter/bin/flutter" ]; then
        echo -e "${RED}Flutter가 설치되어 있지 않습니다.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}릴리즈 빌드 생성 중...${NC}"
    "$HOME/flutter/bin/flutter" build linux --release

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}빌드 완료!${NC}"
        echo -e "${YELLOW}서비스 재시작 중...${NC}"
        systemctl --user restart $SERVICE_NAME
        sleep 1
        systemctl --user status $SERVICE_NAME | head -5
    else
        echo -e "${RED}빌드 실패!${NC}"
        exit 1
    fi
}

# 서비스 설치
install_service() {
    echo -e "${BLUE}System Checkup 서비스 설치 중...${NC}"

    # 서비스 디렉토리 생성
    mkdir -p "$HOME/.config/systemd/user"

    # 서비스 파일 생성
    cat > "$SERVICE_FILE" << 'EOF'
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
EOF

    echo -e "${GREEN}서비스 파일 생성됨: $SERVICE_FILE${NC}"

    # systemd 데몬 재로드
    systemctl --user daemon-reload

    # 서비스 활성화
    systemctl --user enable $SERVICE_NAME

    # 서비스 시작
    systemctl --user start $SERVICE_NAME

    sleep 1

    echo -e "${GREEN}설치 완료!${NC}"
    systemctl --user status $SERVICE_NAME | head -5
}

# 서비스 제거
uninstall_service() {
    echo -e "${RED}System Checkup 서비스 제거 중...${NC}"

    # 서비스 중지 및 비활성화
    systemctl --user stop $SERVICE_NAME 2>/dev/null
    systemctl --user disable $SERVICE_NAME 2>/dev/null

    # 서비스 파일 삭제
    if [ -f "$SERVICE_FILE" ]; then
        rm "$SERVICE_FILE"
        echo -e "${GREEN}서비스 파일 삭제됨${NC}"
    fi

    # systemd 데몬 재로드
    systemctl --user daemon-reload

    echo -e "${GREEN}제거 완료!${NC}"
}

# 메인 로직
case "${1:-help}" in
    status)
        check_status
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    enable)
        enable_service
        ;;
    disable)
        disable_service
        ;;
    logs)
        show_logs
        ;;
    logs-all)
        show_all_logs
        ;;
    rebuild)
        rebuild
        ;;
    install)
        install_service
        ;;
    uninstall)
        uninstall_service
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}알 수 없는 명령어: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
