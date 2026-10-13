#!/data/data/com.termux/files/usr/bin/bash
# JanitorAI Enhanced Importer (Termux) 설치/업데이트 스크립트
# 사용법: bash install-termux.sh [SillyTavern 폴더 경로]   (기본값: ~/SillyTavern)
# 하는 일: 서버 플러그인 복사 + 확장 탭 패널 설치 + 서버 플러그인 기능(enableServerPlugins) 켜기.
#          보안 관련 설정(CSRF 보호 등)은 건드리지 않습니다.
set -e

ST_DIR="${1:-$HOME/SillyTavern}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$ST_DIR/server.js" ]; then
    echo "❌ SillyTavern 폴더를 찾을 수 없습니다: $ST_DIR"
    echo "   사용법: bash install-termux.sh /경로/SillyTavern"
    exit 1
fi

# 설치할 파일이 전부 있는지 먼저 확인 (일부만 설치되는 것을 막기 위해)
# janitor.cjs 는 저장소 맨 위에 있어도, backend_plugin/ 폴더 안에 있어도 찾아낸다.
PLUGIN_SRC=""
for CAND in "$HERE/janitor.cjs" "$HERE/backend_plugin/janitor.cjs"; do
    if [ -f "$CAND" ]; then PLUGIN_SRC="$CAND"; break; fi
done
if [ -z "$PLUGIN_SRC" ]; then
    echo "❌ janitor.cjs 파일을 찾을 수 없습니다. (찾은 폴더: $HERE)"
    echo "   이 폴더의 파일 목록:"; ls "$HERE"
    exit 1
fi
for F in index.js manifest.json style.css; do
    if [ ! -f "$HERE/$F" ]; then echo "❌ $F 파일이 없습니다. (폴더: $HERE)"; exit 1; fi
done

mkdir -p "$ST_DIR/plugins"

# 예전 방식(.js)으로 설치된 이 플러그인이 있으면 충돌하므로 제거
OLD="$ST_DIR/plugins/janitor.js"
if [ -f "$OLD" ] && grep -q "JanitorAI Proxy" "$OLD"; then
    rm -f "$OLD"
    echo "🧹 예전 janitor.js 삭제"
fi

cp "$PLUGIN_SRC" "$ST_DIR/plugins/janitor.cjs"
echo "✅ 플러그인 복사: $ST_DIR/plugins/janitor.cjs"

# ST 확장 탭에 "JanitorAI → ST 자동 추출기" 패널 설치 (안내용 패널, PC 버전과 동일한 모습)
EXT_DIR="$ST_DIR/public/scripts/extensions/third-party/Janitor-Enhanced-Import"
mkdir -p "$EXT_DIR"
cp "$HERE/index.js" "$HERE/manifest.json" "$HERE/style.css" "$EXT_DIR/"
echo "✅ 확장 패널 설치: $EXT_DIR"

# 예전 안내대로 data/<사용자>/extensions 에 수동 복사해 둔 같은 확장이 있으면 중복되므로 제거
for OLDEXT in "$ST_DIR"/data/*/extensions/Janitor-Enhanced-Import-Termux; do
    if [ -f "$OLDEXT/manifest.json" ] && grep -q "JanitorAI Enhanced Importer" "$OLDEXT/manifest.json"; then
        rm -rf "$OLDEXT"
        echo "🧹 중복된 예전 확장 폴더 삭제: $OLDEXT"
    fi
done

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
