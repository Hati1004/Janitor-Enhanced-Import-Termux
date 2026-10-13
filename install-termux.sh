#!/data/data/com.termux/files/usr/bin/bash
# JanitorAI Enhanced Importer (Termux) 설치/업데이트 스크립트
# 사용법: bash install-termux.sh [SillyTavern 폴더 경로]   (기본값: ~/SillyTavern)
# 하는 일: 플러그인 복사 + 서버 플러그인 기능(enableServerPlugins) 켜기.
#          보안 관련 설정(CSRF 보호 등)은 건드리지 않습니다.
set -e

ST_DIR="${1:-$HOME/SillyTavern}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$ST_DIR/server.js" ]; then
    echo "❌ SillyTavern 폴더를 찾을 수 없습니다: $ST_DIR"
    echo "   사용법: bash install-termux.sh /경로/SillyTavern"
    exit 1
fi

mkdir -p "$ST_DIR/plugins"

# 예전 방식(.js)으로 설치된 이 플러그인이 있으면 충돌하므로 제거
OLD="$ST_DIR/plugins/janitor.js"
if [ -f "$OLD" ] && grep -q "JanitorAI Proxy" "$OLD"; then
    rm -f "$OLD"
    echo "🧹 예전 janitor.js 삭제"
fi

cp "$HERE/backend_plugin/janitor.cjs" "$ST_DIR/plugins/janitor.cjs"
echo "✅ 플러그인 복사: $ST_DIR/plugins/janitor.cjs"

CFG="$ST_DIR/config.yaml"
if [ -f "$CFG" ]; then
    if grep -qE '^enableServerPlugins:' "$CFG"; then
        sed -i -E 's/^enableServerPlugins:.*/enableServerPlugins: true/' "$CFG"
    else
        printf '\nenableServerPlugins: true\n' >> "$CFG"
    fi
    echo "✅ 서버 플러그인 기능 켜짐 (config.yaml의 enableServerPlugins)"
else
    echo "⚠️  config.yaml이 아직 없습니다. SillyTavern을 한 번 실행한 뒤 이 스크립트를 다시 실행하세요."
fi

echo
echo "끝! SillyTavern을 (재)시작하고 콘솔에 아래 문구가 뜨는지 확인하세요."
echo "  [Janitor 플러그인] 🟢 백엔드 서버 완벽 로드 완료!"
