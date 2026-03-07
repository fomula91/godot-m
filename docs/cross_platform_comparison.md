# 웹 vs Godot 크로스 플랫폼 비교 분석

> 동일 IP "사쿠라 학원 - 봄날의 이야기"를 Monogatari(웹)와 Godot로 구현한 두 프로젝트의 체계적 비교

---

## 1. 프로젝트 개요 대비

| 항목 | project-m (웹) | godot-porject-m (Godot) |
|------|---------------|------------------------|
| **엔진** | Monogatari v2.0.2 | Godot 4.6 |
| **언어** | JavaScript (ES6+) | GDScript |
| **배포** | Vercel (정적 사이트) + PWA | 데스크톱 빌드 (Windows/Mac/Linux) |
| **렌더러** | 브라우저 HTML5/CSS3 | GL Compatibility (D3D12 on Windows) |
| **개발 상태** | 완성 (프로덕션) | 개발 진행 중 |
| **스토리 형식** | JS 배열 (선언적) | JSON 파일 (명령 객체) |
| **해상도** | 반응형 (landscape 고정) | 1920x1080 (canvas_items 스트레치) |

---

## 2. 아키텍처 비교

### 2.1 웹 (Monogatari)

```
[index.html] → [monogatari.js 엔진]
                    ↑
    [options.js] [storage.js] [script.js]
                    ↑
    [day1-common.js] ... [day5-together.js]  (선언적 배열)
                    ↑
    [choice-stats.js] [affinity-hint.js] [ui-sounds.js]  (확장 모듈)
```

**특징**: Monogatari 엔진이 모든 것을 관리. 스토리는 JS 배열로 선언적 작성.

```javascript
// Monogatari 방식 - 문자열 명령
monogatari.script({
    'Start': [
        'show scene school_front_day with fadeIn',
        's 안녕하세요!',
        'play music sunny-day loop',
    ]
});
```

### 2.2 Godot

```
[project.godot] → [Autoload 싱글톤 4개]
    ↓
[StoryManager] → JSON 파싱 → 시그널 발행 → [MainScene] → UI 갱신
[GameManager]  → 상태/조건/세이브
[AudioManager] → BGM/SFX
[DebugOverlay] → F3 디버그
```

**특징**: 커스텀 VN 엔진. JSON 명령 객체를 `_dispatch_command()`에서 match 문으로 처리.

```json
// Godot 방식 - JSON 명령 객체
{
    "Start": [
        {"cmd": "show_scene", "id": "school_front_day", "transition": "fadeIn"},
        {"cmd": "dialogue", "character": "s", "text": "안녕하세요!"},
        {"cmd": "play_music", "id": "sunny-day"}
    ]
}
```

### 2.3 핵심 차이점

| 관점 | 웹 | Godot |
|------|-----|-------|
| 명령 표현 | 문자열 파싱 (`'show scene X with fadeIn'`) | 구조화된 딕셔너리 (`{"cmd": "show_scene", ...}`) |
| 분기 처리 | Monogatari 내장 Choice + JS 조건 | `choice`, `conditional`, `jump` 명령 |
| 상태 관리 | `monogatari.storage()` + `monogatari.state()` | `GameManager.state` 딕셔너리 |
| 이벤트 통신 | Monogatari 내장 후크 | 시그널 기반 Observer 패턴 |
| UI 렌더링 | CSS + HTML DOM | Godot Control 노드 |

---

## 3. 스토리 데이터 변환

### 3.1 convert_stories.py

`tools/convert_stories.py`가 웹→Godot 변환을 수행합니다.

**변환 경로**: `project-m/js/scripts/day*/` → `godot-porject-m/story/day*/`

**변환 규칙**:

| Monogatari 문자열 | Godot JSON 명령 |
|------------------|----------------|
| `'show scene X with fadeIn'` | `{"cmd": "show_scene", "id": "X", "transition": "fadeIn"}` |
| `'show character s happy at left'` | `{"cmd": "show_character", "id": "s", "sprite": "happy", "position": "left"}` |
| `'hide character s with fadeOut'` | `{"cmd": "hide_character", "id": "s", "transition": "fadeOut"}` |
| `'play music sunny-day loop'` | `{"cmd": "play_music", "id": "sunny-day", "loop": true}` |
| `'play sound school-bell'` | `{"cmd": "play_sound", "id": "school-bell"}` |
| `'wait 2000'` | `{"cmd": "wait", "duration": 2000}` |
| `'s 안녕하세요!'` | `{"cmd": "dialogue", "character": "s", "text": "안녕하세요!"}` |
| `'나레이션 텍스트'` | `"나레이션 텍스트"` (단순 문자열) |
| `fadeJump('Label')` | `{"cmd": "fade_jump", "target": "Label", ...}` |
| `fadeScene('sceneId')` | `{"cmd": "fade_scene", "id": "sceneId", ...}` |

### 3.2 변환 시 특이사항

- **`_manual_` 접두사**: `extract_conditional()` 함수가 복잡한 Monogatari 분기 패턴을 자동 변환하지 못할 때 `_manual_` 접두사로 폴백
- **헬퍼 함수**: `fadeJump()`, `fadeScene()`, `makeChoice()`는 웹 전용 헬퍼로, 변환 시 직접 확장
- **조건부 분기**: Monogatari의 `Function` 타입 분기는 `conditional` 명령으로 수동 변환 필요

---

## 4. 기능 패리티 매트릭스

### 4.1 웹에만 있는 기능

| 기능 | 설명 | 구현 파일 |
|------|------|----------|
| **PWA 지원** | 앱 설치, 오프라인 플레이 | `manifest.json`, `service-worker.js` |
| **에셋 암호화** | .webp/.mp3 → .enc 변환 | `tools/encrypt-assets.js` |
| **선택지 통계 표시** | "X%의 플레이어가 선택" | `js/choice-stats.js` |
| **Vercel 서버리스 API** | GET /api/stats, POST /api/vote | `api/stats.js`, `api/vote.js` |
| **CSS 지연 로딩** | 화면별 CSS 동적 로드 | `js/main.js` |
| **벚꽃 파티클 (CSS)** | 12개 petal 요소 애니메이션 | `style/main.css` |
| **디버그 점프** | 특정 라벨로 점프 | `js/debug-jump.js` |
| **디버그 호감도** | 호감도 수정 | `js/debug-affinity.js` |

### 4.2 Godot에만 있는 기능

| 기능 | 설명 | 구현 파일 |
|------|------|----------|
| **세이브 슬롯 10개** | JSON 파일 기반 세이브/로드 | `game_manager.gd` |
| **퀵세이브/로드** | 빠른 저장/불러오기 | `main_scene.gd` |
| **디버그 오버레이** | F3 토글, FPS 모니터링, 로그 | `debug_overlay.gd` |
| **MCP Bridge** | Claude AI 실시간 에디터 연동 | `addons/godot_mcp/` |
| **AI Bridge** | Godot AI Bridge 플러그인 | `addons/godot_ai_bridge/` |
| **GPU 파티클** | 벚꽃잎 GPUParticles2D | `title_screen.tscn` |
| **오토/스킵 모드** | 자동 진행, 빠른 스킵 | `main_scene.gd` |
| **방해 없는 모드** | UI 숨김 토글 | `main_scene.gd` |
| **텍스트 타이핑 애니메이션** | Tween 기반 글자별 표시 | `main_scene.gd` |

### 4.3 양쪽 모두 있는 기능

| 기능 | 웹 구현 | Godot 구현 |
|------|---------|-----------|
| **호감도 시스템** | `storage.js` 변수 | `game_manager.gd` state |
| **CG 갤러리** | `script.js` gallery 객체 | `gallery_screen.gd` |
| **BGM 크로스페이드** | Monogatari 내장 | `audio_manager.gd` 이중 플레이어 |
| **선택지 분기** | Monogatari Choice | `choice` 명령 + 시그널 |
| **조건부 분기** | JS Function | `conditional` + `evaluate_condition()` |
| **템플릿 변수** | Monogatari 내장 `{{}}` | `replace_templates()` RegEx |
| **호감도 힌트** | `affinity-hint.js` | `affinity_hint` 명령 |
| **설정 화면** | Monogatari Settings | `settings_screen.gd` |

---

## 5. Supabase 통계 연동 비교

### 5.1 웹 (완성)

```
[브라우저] → GET /api/stats?scene_id=X → [Vercel 서버리스] → [Supabase]
[브라우저] → POST /api/vote {scene_id, choice_key} → [Vercel 서버리스] → [Supabase]
```

- **choice-stats.js**: 선택지 표시 시 통계 자동 조회/표시
- **네트워크 체크**: `isNetworkStable()` (1.5초 타임아웃)
- **API 타임아웃**: 3초
- **12개 추적 대상** 라벨과 정확히 일치

### 5.2 Godot (미완성)

`main_scene.gd`에 변수만 선언되어 있고 실제 API 호출 로직은 구현되지 않음:

```gdscript
# main_scene.gd 에 존재하는 미완성 코드
var _supabase_url: String = ""
var _stats_http: HTTPRequest
var _vote_http: HTTPRequest
```

**구현 필요사항**:
- Supabase URL/Key 설정 (환경변수 또는 설정 파일)
- HTTPRequest 노드를 통한 REST API 호출
- 선택지 표시 시 통계 조회 및 UI 표시
- 선택 시 투표 전송

---

## 6. 에셋 공유 현황

### 6.1 공유 에셋

| 카테고리 | 웹 경로 | Godot 경로 | 파일 형식 |
|---------|--------|-----------|----------|
| 배경 | `assets/scenes/` | `assets/backgrounds/` | .webp |
| 캐릭터 | `assets/characters/` | `assets/characters/` | .webp |
| CG | `assets/gallery/` | `assets/gallery/` | .webp |
| BGM | `assets/music/` | `assets/music/` | .mp3 |
| 효과음 | `assets/sounds/` | `assets/sounds/` | .mp3 |

### 6.2 에셋 보호 차이

| 항목 | 웹 | Godot |
|------|-----|-------|
| **보호 방식** | `.enc` 암호화 (빌드 시 변환) | `.import` 시스템 (Godot 자체) |
| **변환 도구** | `tools/encrypt-assets.js` | Godot 에디터 자동 |
| **런타임 복호화** | Service Worker | 불필요 |
| **원본 보존** | 빌드 시 삭제 가능 | 원본 유지 |

### 6.3 경로 매핑 차이

웹과 Godot에서 배경 폴더명이 다릅니다:

- 웹: `assets/scenes/` → Godot: `assets/backgrounds/`
- CG, 캐릭터, 음악, 효과음: 동일 경로

---

## 7. storage.js vs game_manager.gd 변수 매핑

| 변수 | storage.js (웹) | game_manager.gd (Godot) | 일치 |
|------|----------------|------------------------|------|
| `player.name` | `player: { name: '' }` | `"player": {"name": ""}` | O |
| `sora_affection` | `sora_affection: 0` | `"sora_affection": 0` | O |
| `hana_affection` | `hana_affection: 0` | `"hana_affection": 0` | O |
| `helped_sora` | `helped_sora: false` | `"helped_sora": false` | O |
| `chose_library` | `chose_library: false` | `"chose_library": false` | O |
| `day2_sora_walk` | `day2_sora_walk: false` | `"day2_sora_walk": false` | O |
| `day2_studied_together` | `day2_studied_together: false` | `"day2_studied_together": false` | O |
| `confessed` | `confessed: false` | `"confessed": false` | O |
| `chose_both` | `chose_both: false` | `"chose_both": false` | O |
| `unknown_interest` | `unknown_interest: 0` | `"unknown_interest": 0` | O |
| `met_unknown` | `met_unknown: false` | `"met_unknown": false` | O |
| `day3_ending_type` | `day3_ending_type: ''` | `"day3_ending_type": ""` | O |

**12개 변수 모두 1:1 완전 일치.**

---

## 8. 선택지 통계 추적 대상 비교

| 라벨 | choice-stats.js (웹) | tracked_scenes (Godot) | 일치 |
|------|---------------------|----------------------|------|
| Day1UnknownHint | O | O | O |
| MorningEvent | O | O | O |
| LunchTimeChoice | O | O | O |
| Day2Morning | O | O | O |
| Day2ScienceLab | O | O | O |
| Day3BothHigh | O | O | O |
| Day3SoraClimax | O | O | O |
| Day3HanaClimax | O | O | O |
| Day4Morning | O | O | O |
| Day4Evening | O | O | O |
| Day5SoraConfess2 | O | O | O |
| Day5HanaConfess2 | O | O | O |

**12개 추적 대상 모두 완전 일치.**

---

## 9. 개발 상태 비교

| 영역 | 웹 | Godot |
|------|-----|-------|
| 스토리 콘텐츠 | 완성 (Day 1~5) | 완성 (JSON 변환 완료) |
| UI/UX | 완성 (CSS 애니메이션) | 완성 (Tween 애니메이션) |
| 세이브/로드 | Monogatari 내장 (자동/수동) | 완성 (10슬롯 + 퀵세이브) |
| 갤러리 | 완성 (24 CG) | 완성 (24 CG) |
| 설정 | 완성 | 완성 |
| 선택지 통계 | **완성** (Supabase 연동) | **미완성** (변수만 선언) |
| 에셋 보호 | **완성** (.enc 암호화) | 미구현 |
| PWA/오프라인 | **완성** | 해당 없음 |
| 디버그 도구 | 부분 (점프, 호감도) | **완성** (F3 오버레이) |
| 테스트 | 없음 | 없음 |
| 문서화 | docs 폴더 (17개) | docs 폴더 (10+개) |

---

## 10. 동기화 워크플로우

### 10.1 스토리 수정 시

```
1. project-m/js/scripts/dayN/ 의 JS 파일 수정 (원본)
2. python3 tools/convert_stories.py 실행
3. godot-porject-m/story/dayN/ 에 JSON 파일 생성/갱신
4. Godot 에디터에서 테스트
```

### 10.2 에셋 추가 시

```
1. project-m/assets/ 에 새 에셋 배치
2. godot-porject-m/assets/ 에 동일 파일 복사
3. story_manager.gd의 scene_map 또는 characters에 매핑 추가
4. 웹: script.js에 에셋 등록
```

### 10.3 주의사항

- 웹 프로젝트가 **원본(source of truth)**
- Godot JSON은 변환 결과물이므로 직접 수정하면 다음 변환 시 덮어씌워짐
- 캐릭터/배경 매핑은 양쪽에서 별도 관리 (웹: `script.js`, Godot: `story_manager.gd`)
