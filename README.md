# JanitorAI Enhanced Importer — Termux(안드로이드) 버전

JanitorAI의 캐릭터 카드(PNG)와 로어북(Scripts)을 **폰의 Termux에서 돌리는 SillyTavern**으로 바로 가져오는 도구입니다.

> 💻 PC용은 별도 저장소입니다: https://github.com/Hati1004/Janitor-Enhanced-Import
> 이 저장소는 **Termux 전용**이며, 두 저장소를 같은 SillyTavern에 같이 설치하지 마세요(서로 충돌합니다).

## PC 버전과 다른 점
- **`sharp` 설치가 필요 없습니다.** (Termux에선 설치가 안 됨) webp→PNG 변환을 SillyTavern에 내장된 jimp(WASM)가 처리합니다.
- 플러그인 확장자가 **`.cjs`** 입니다. (`.js`면 Termux 환경에서 `require is not defined`로 로드에 실패할 수 있음)
- **JanitorAI 토큰을 자동으로 감지**합니다. 개발자도구(F12)가 없는 폰을 위한 기능입니다.
- `install-termux.sh` 한 번이면 플러그인 복사 + `config.yaml` 설정까지 끝납니다.

## 구성
| 파일 | 역할 |
|---|---|
| `janitor-enhanced-import-termux.user.js` | 브라우저(Firefox)에서 janitorai.com 데이터를 읽어 ST로 전송하는 유저스크립트 **(필수)** |
| `janitor.cjs` | ST 서버 쪽 플러그인. 받은 데이터를 캐릭터 PNG / 로어북으로 저장 **(필수)** |
| `index.js` `manifest.json` `style.css` | ST 확장 탭 패널(안내용). `install-termux.sh`가 자동 설치 |
| `install-termux.sh` | 플러그인 설치 스크립트 |

## 준비물
- 폰에 **Termux** + **SillyTavern** (ST 1.13 이상 권장)
- **Firefox (안드로이드)** — 확장 프로그램을 지원하는 브라우저가 필요합니다. 크롬 안드로이드는 유저스크립트를 못 씁니다.
- Firefox에 **Tampermonkey** 설치

## 설치

### 1. 플러그인 (Termux)
```bash
pkg install git
cd ~
git clone https://github.com/Hati1004/Janitor-Enhanced-Import-Termux
cd Janitor-Enhanced-Import-Termux
bash install-termux.sh
```
- `pkg install git`은 git이 처음이라면 필요합니다. 이미 있으면 건너뛰세요.
- ST가 `~/SillyTavern`에 있으면 `bash install-termux.sh`만 실행하면 됩니다. 다른 위치라면 `bash install-termux.sh /실제/SillyTavern/경로`처럼 경로를 뒤에 붙이세요.

스크립트가 하는 일:
- `plugins/janitor.cjs` 복사
- 예전 방식으로 설치된 `janitor.js`가 있으면 제거
- `config.yaml`에서 **서버 플러그인 기능**(`enableServerPlugins`)을 켬 — 플러그인이 로드되려면 필요한 설정입니다.

보안 관련 설정(CSRF 보호, 접속 허용 목록 등)은 **건드리지 않습니다.**

그 다음 SillyTavern을 (재)시작하고 콘솔에 아래 문구가 뜨면 정상입니다.
```
[Janitor 플러그인] 🟢 백엔드 서버 완벽 로드 완료!
```

**업데이트할 때:**
```bash
cd ~/Janitor-Enhanced-Import-Termux && git reset --hard && git pull && bash install-termux.sh
```

### 2. 유저스크립트 (Firefox)
1. Firefox에서 아래 Raw 링크를 열면 Tampermonkey의 **설치 화면**이 뜹니다.
   ```
   https://raw.githubusercontent.com/Hati1004/Janitor-Enhanced-Import-Termux/main/janitor-enhanced-import-termux.user.js
   ```
2. 설치를 누르면 끝. (ST 주소 기본값 `http://127.0.0.1:8000` 그대로 사용)

### 3. ST 확장 탭 패널
`install-termux.sh`가 PC 버전과 똑같은 **"🎭 JanitorAI → ST 자동 추출기"** 패널을 ST 확장 탭에 함께 설치합니다. (안내용 패널이라 없어도 가져오기는 동작합니다.)
설치 후 ST를 재시작하고 브라우저에서 ST 페이지를 **새로고침**하면 Extensions 메뉴에 나타납니다.

## 사용법
1. Termux에서 SillyTavern 실행 (`cd ~/SillyTavern && node server.js`)
   - 백그라운드에서 꺼지지 않게 Termux 알림창의 **Acquire wakelock**을 켜 두세요.
2. Firefox로 janitorai.com 접속 → **로그인**
3. **캐릭터 페이지**에서 `📤 ST로 보내기` → ST 캐릭터 목록에 저장됩니다. (안 보이면 새로고침)
4. **로어북(Scripts) 편집 페이지**에서 `📚 로어북 ST로 보내기` → 이름을 확인하면 World Info에 추가됩니다.

### 정의가 비공개인 캐릭터
작가가 "character definition is hidden"으로 정의를 숨긴 캐릭터는 사이트가 설명/첫 인사말을 내려주지 않습니다. 이 경우:
- 사이트의 **공개 소개글은 ST의 캐릭터 설명칸이 아니라 제작자 메모(Creator's Notes)** 에 들어갑니다.
- datacat/JannyAI에 저장본이 있으면 그것으로 빈칸을 채우려고 시도합니다.
- 채우지 못하면 설명/첫 인사말이 빈 카드로 저장되고, 화면에 경고가 뜹니다.

### 로어북과 "모든 채팅에 활성화" 목록
이 도구는 로어북을 **파일로 저장만** 하며, ST의 활성화 설정은 건드리지 않습니다. ST 소스에서도 새 월드 파일을 자동으로 활성화하는 부분은 없습니다. 가져온 로어북은 World Info 메뉴에서 직접 켜야 적용됩니다.
만약 가져오자마자 "Active World(s) for all chats"에 선택돼 있다면, 같은 이름이 이전 설정에 남아 있는 경우일 수 있으니 아래로 확인해 보세요.
```bash
grep -n -A8 globalSelect ~/SillyTavern/data/default-user/settings.json
```
그 목록에서 빼고 싶으면 ST 화면에서 해당 항목의 선택을 해제하면 됩니다.

## JanitorAI 토큰
**대부분 신경 쓸 필요 없습니다.** 로그인한 상태로 janitorai.com을 한두 페이지 둘러보면 스크립트가 알아서 토큰을 저장합니다. 자동 감지가 안 되면 전송 버튼을 눌렀을 때 수동 입력 창이 뜹니다.
Tampermonkey 메뉴의 **🔍 저장된 토큰 상태 확인**으로 저장 여부를 볼 수 있습니다.

### 수동으로 구하기 (자동 감지가 안 될 때)
폰에는 F12가 없어서 아래 방법 중 하나를 씁니다.

**방법 A. 북마클릿 (가장 간단)**
1. 아무 페이지나 북마크하고, 북마크 주소를 아래 한 줄로 바꿉니다.
   ```
   javascript:(function(){var f=window.fetch;window.fetch=function(i,o){try{var h=(o&&o.headers)||{};var a=h.Authorization||h.authorization||(h.get&&h.get('Authorization'));if(a&&/^Bearer /i.test(a)){prompt('토큰 (복사하세요)',a.replace(/^Bearer /i,''))}}catch(e){}return f.apply(this,arguments)};alert('감지 시작: 이제 사이트에서 아무 페이지나 눌러 보세요')})();
   ```
2. 로그인한 janitorai.com에서 이 북마크를 실행 → 사이트 안에서 다른 페이지로 이동하면 토큰이 입력창에 떠서 복사할 수 있습니다.

**방법 B. Eruda(모바일 개발자도구)**
1. janitorai.com에서 북마클릿으로 실행:
   ```
   javascript:(function(){var s=document.createElement('script');s.src='https://cdn.jsdelivr.net/npm/eruda';document.body.appendChild(s);s.onload=function(){eruda.init()}})();
   ```
2. 우측 하단 톱니 → **Network** 탭 → 요청 선택 → Headers의 `authorization: Bearer ...`에서 `Bearer ` 뒤 값 복사.

> 사이트 보안 설정(CSP)에 따라 B는 막힐 수 있습니다. 그땐 A를 쓰세요.

복사한 값은 Tampermonkey 메뉴의 **🔑 JanitorAI 토큰 재설정**에 붙여넣으면 됩니다.
토큰은 **비밀번호와 같으니 남에게 공유하지 마세요.**

## 문제 해결
| 증상 | 해결 |
|---|---|
| 콘솔에 플러그인 로드 문구가 안 뜸 | `plugins/janitor.cjs`가 있는지, `config.yaml`의 `enableServerPlugins`가 켜져 있는지 확인 후 ST 재시작 (`install-termux.sh`를 다시 실행해도 됩니다) |
| `require is not defined` | `plugins`에 `.js` 버전이 남아 있는지 확인. `install-termux.sh`를 다시 실행 |
| `이미지를 PNG로 변환하지 못했습니다` | 움직이는 webp 아바타이거나 ST 버전이 낮음(1.13+ 권장) |
| 캐릭터는 들어오는데 설명/첫 인사말이 비어 있음 | 1) janitorai.com에 **로그인**되어 있는지 확인 후 새로고침하고 다시 보내기 2) Tampermonkey 메뉴 **🔍 저장된 토큰 상태 확인**에서 role이 `anon`/익명이면 로그인이 안 된 토큰이니 로그아웃→재로그인 후 재시도 3) 그래도 비면 Termux 콘솔의 `[Janitor][DEBUG] 네이티브 응답 필드(길이)` 줄을 확인 (작가가 정의를 비공개로 한 캐릭터일 수 있음). 비어 있으면 JannyAI/datacat 저장본으로 자동 보충을 시도하고, 그래도 안 되면 화면에 경고가 뜹니다. |
| 버튼은 뜨는데 `ST 서버 연결 실패` | Termux에서 ST가 켜져 있는지, 주소/포트(기본 8000) 확인 |
| `CSRF 토큰` 에러가 나옴 | 기본 상태(보호 켜짐)에서 먼저 시도하세요. 에러가 날 때만 아래 "CSRF 에러가 날 때"를 참고하세요. |
| `worlds 디렉토리를 찾을 수 없습니다` | ST 버전이 너무 낮음(1.12+ 필요) |
| 로어북 엔트리를 못 찾음 | 로어북 소스 창이 끝까지 보이는지 확인 |

## CSRF 에러가 날 때
ST의 CSRF 보호는 **다른 웹사이트가 내 로컬 ST에 몰래 요청을 보내는 것을 막는 보안 장치**입니다. 기본 설정(`disableCsrfProtection: false`)이 보호가 켜진 상태이고, 대부분은 그대로 잘 동작합니다.

에러가 날 때는 이 순서로 하세요.
1. Firefox의 **쿠키/추적 차단 설정**을 완화해 보세요. 로컬 서버 쿠키가 차단되면 CSRF 확인이 실패할 수 있습니다.
2. 그래도 안 되면 **임시로만** `config.yaml`에서 `disableCsrfProtection: true`로 바꾸고 ST를 재시작한 뒤, **캐릭터를 가져오고 나서 바로 `false`로 되돌리세요.**
   - ST가 폰 안에서만 열려 있을 때(`listen: false`)에만 하세요.
   - 켜둔 채로 다른 사이트를 돌아다니면 위험합니다. 그 사이트가 내 ST에 요청을 보낼 수 있게 되기 때문입니다.

## 주의사항
JanitorAI의 비공식 API/페이지 구조에 의존합니다. 사이트 구조가 바뀌면 일부 기능이 동작하지 않을 수 있습니다.
