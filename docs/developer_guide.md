# 개발자 가이드

> 프로젝트 설정, 콘텐츠 추가, 빌드까지의 실무 가이드

---

## 1. 개발 환경 설정

### 1.1 필수 요구사항

- **Godot 4.6** (GL Compatibility 렌더러)
- **Python 3** (스토리 변환 스크립트용)
- 연관 프로젝트: `project-m` (웹 원본, 스토리 소스)

### 1.2 프로젝트 열기

```bash
# 에디터 실행
godot --path /path/to/godot-porject-m --editor

# 게임 실행 (에디터 없이)
godot --path /path/to/godot-porject-m
```

- **F5**: 전체 게임 실행 (`title_screen.tscn`부터)
- **F6**: 현재 열린 씬만 실행

### 1.3 디버그 오버레이

게임 실행 중 **F3** 키로 디버그 오버레이를 토글합니다.

표시 정보:
- 실시간 로그 메시지 (시그널 발행, 라벨 점프, 변수 변경)
- FPS 모니터링
- 현재 게임 상태

### 1.4 MCP Bridge 설정

`.mcp.json` 파일로 Claude AI 연동이 설정되어 있습니다. `addons/godot_mcp/` 플러그인이 에디터에서 활성화되어야 합니다.

---

## 2. 프로젝트 구조

```
godot-porject-m/
├── project.godot              # 엔진 설정
├── scripts/autoload/          # 싱글톤 매니저 4개
│   ├── game_manager.gd        # 상태, 세이브, 조건 평가
│   ├── story_manager.gd       # 스토리 엔진 (JSON 파싱, 명령 디스패치)
│   ├── audio_manager.gd       # BGM/SFX
│   └── debug_overlay.gd       # F3 디버그
├── scenes/                    # 게임 씬 5개 + 컴포넌트 2개
├── story/                     # JSON 스토리 데이터 (day1~5)
├── assets/                    # 배경, 캐릭터, CG, 음악, 효과음
├── tools/                     # 변환 스크립트
├── addons/                    # 에디터 플러그인
└── docs/                      # 문서
```

---

## 3. 스토리 콘텐츠 추가 가이드

### 3.1 스토리 작성 워크플로우

**권장 흐름** (웹 원본 기반):
1. `project-m/js/scripts/dayN/` 에 JS 스토리 작성
2. `python3 tools/convert_stories.py` 실행하여 JSON 변환
3. Godot에서 테스트

**직접 JSON 작성** (Godot 전용 콘텐츠):
1. `story/dayN/` 에 JSON 파일 생성
2. 라벨 딕셔너리 형식으로 작성

### 3.2 JSON 스토리 파일 형식

```json
{
  "LabelName": [
    {"cmd": "명령어", ...파라미터},
    {"cmd": "명령어", ...파라미터},
    "단순 나레이션 텍스트는 문자열로"
  ],
  "AnotherLabel": [
    ...
  ]
}
```

### 3.3 주요 명령어 빠른 참조

> 전체 레퍼런스는 `docs/signal_command_reference.md` 참조

**텍스트 표시**:
```json
{"cmd": "dialogue", "character": "s", "text": "대사"}
{"cmd": "narration", "text": "나레이션"}
{"cmd": "centered", "text": "- 챕터명 -"}
```

**씬/캐릭터 제어**:
```json
{"cmd": "show_scene", "id": "classroom_day"}
{"cmd": "show_character", "id": "s", "sprite": "happy", "position": "left"}
{"cmd": "hide_character", "id": "s"}
{"cmd": "change_sprite", "id": "s", "sprite": "surprised"}
```

**분기**:
```json
{"cmd": "choice", "dialog": "질문", "choices": [
  {"text": "선택지1", "key": "key1", "target": "Label1"},
  {"text": "선택지2", "key": "key2", "target": "Label2"}
]}
{"cmd": "jump", "target": "TargetLabel"}
{"cmd": "fade_jump", "target": "TargetLabel", "duration": 1.5}
```

**변수/조건**:
```json
{"cmd": "set_var", "path": "sora_affection", "value": 1, "op": "add"}
{"cmd": "conditional", "branches": [
  {"condition": "sora_affection >= 4", "target": "SoraRoute", "action": "jump"}
], "default": "DefaultLabel"}
```

**오디오**:
```json
{"cmd": "play_music", "id": "sunny-day"}
{"cmd": "play_sound", "id": "school-bell"}
{"cmd": "stop_music", "fade": 1.0}
```

**연출**:
```json
{"cmd": "wait", "duration": 2000}
{"cmd": "gallery_unlock", "id": "opening-unknown"}
{"cmd": "affinity_hint", "character": "sora"}
{"cmd": "end"}
```

---

## 4. 새 캐릭터 추가 절차

### 4.1 스프라이트 준비

1. `assets/characters/캐릭터폴더/` 에 .webp 파일 배치
2. 파일명 규칙: `캐릭터명_표정코드.webp`

### 4.2 story_manager.gd 등록

`characters` 딕셔너리에 항목 추가:

```gdscript
"캐릭터ID": {
    "name": "표시이름",
    "color": "#색상코드",
    "directory": "캐릭터폴더",
    "sprites": {
        "normal": "파일명.webp",
        "happy": "파일명_happy.webp",
        // ... 필요한 표정 추가
    }
}
```

### 4.3 스토리에서 사용

```json
{"cmd": "show_character", "id": "캐릭터ID", "sprite": "happy", "position": "center"}
{"cmd": "dialogue", "character": "캐릭터ID", "text": "대사"}
```

---

## 5. 새 배경 추가 절차

### 5.1 이미지 준비

1. `assets/backgrounds/` 에 .webp 파일 배치
2. 권장 해상도: 1920x1080 (16:9)

### 5.2 scene_map 등록

`story_manager.gd`의 `scene_map` 딕셔너리에 추가:

```gdscript
"배경ID": "backgrounds/파일명.webp",
```

### 5.3 스토리에서 사용

```json
{"cmd": "show_scene", "id": "배경ID"}
```

---

## 6. 새 CG 추가 절차

### 6.1 이미지 준비

1. `assets/gallery/` 에 .webp 파일 배치

### 6.2 scene_map + 갤러리 등록

```gdscript
// story_manager.gd scene_map
"cg이름_cg": "gallery/파일명.webp",
```

```gdscript
// gallery_screen.gd GALLERY_ITEMS 배열에 추가
{"id": "cg이름", "file": "gallery/파일명.webp", "title": "CG 제목"}
```

### 6.3 스토리에서 해금

```json
{"cmd": "show_scene", "id": "cg이름_cg"},
{"cmd": "gallery_unlock", "id": "cg이름"},
{"cmd": "show_scene", "id": "이전배경ID"}
```

---

## 7. 새 BGM/효과음 추가

### 7.1 파일 배치

- BGM: `assets/music/이름.mp3`
- 효과음: `assets/sounds/이름.mp3`

### 7.2 AudioManager 등록

`audio_manager.gd`의 음악/효과음 딕셔너리에 추가합니다.

### 7.3 스토리에서 사용

```json
{"cmd": "play_music", "id": "음악ID"}
{"cmd": "play_sound", "id": "효과음ID"}
```

---

## 8. 세이브/로드 데이터 구조

### 8.1 저장 위치

- 세이브 파일: `user://saves/slot_0.json` ~ `slot_9.json`
- 설정 파일: `user://settings.json`
- 갤러리 파일: `user://gallery.json`

### 8.2 세이브 데이터 형식

```json
{
  "state": {
    "player": {"name": "하루"},
    "sora_affection": 5,
    "hana_affection": 3,
    ...
  },
  "gallery": ["opening-unknown", "silhouette", ...],
  "current_label": "Day2Morning",
  "line_index": 15,
  "background": "classroom_day",
  "characters": {"s": {"sprite": "happy", "position": "left"}},
  "bgm": "sunny-day",
  "timestamp": "2026-03-07T12:00:00",
  "label_display": "Day 2 - 아침"
}
```

### 8.3 관련 함수

| 함수 | 위치 | 용도 |
|------|------|------|
| `save_game(slot, extra)` | game_manager.gd | 슬롯에 저장 |
| `load_game(slot)` | game_manager.gd | 슬롯에서 불러오기 |
| `get_save_meta(slot)` | game_manager.gd | 슬롯 메타정보 조회 |
| `has_save(slot)` | game_manager.gd | 세이브 존재 여부 |
| `delete_save(slot)` | game_manager.gd | 세이브 삭제 |

---

## 9. 웹 버전 동기화

### 9.1 스토리 변환

```bash
cd godot-porject-m
python3 tools/convert_stories.py
```

이 스크립트는 `project-m/js/scripts/day*/` → `story/day*/` 변환을 수행합니다.

### 9.2 에셋 동기화

새 에셋 추가 시 양쪽 프로젝트에 동일 파일을 배치해야 합니다.

```bash
# 배경 복사 예시
cp project-m/assets/scenes/new_bg.webp godot-porject-m/assets/backgrounds/new_bg.webp
```

**주의**: 웹의 배경 경로는 `assets/scenes/`, Godot는 `assets/backgrounds/`

### 9.3 매핑 동기화

에셋 추가 시 양쪽에서 매핑을 업데이트해야 합니다:
- 웹: `project-m/js/script.js`
- Godot: `godot-porject-m/scripts/autoload/story_manager.gd`

---

## 10. 빌드 및 배포

### 10.1 Godot 내보내기 설정

1. **프로젝트 → 내보내기** 메뉴
2. 플랫폼 선택:
   - **Windows**: D3D12 렌더링 드라이버
   - **macOS**: GL Compatibility
   - **Linux**: GL Compatibility
3. **렌더러**: GL Compatibility (모바일 호환)
4. **해상도**: 1920x1080, stretch mode: canvas_items

### 10.2 주의사항

- `.godot/` 폴더는 빌드에 포함되지 않음 (에디터 캐시)
- `addons/` 플러그인 중 `godot_mcp/`와 `godot_ai_bridge/`는 개발 전용이므로 배포 빌드에서 비활성화 권장
- JSON 스토리 파일은 `res://story/` 경로로 포함됨

---

## 11. 코딩 컨벤션

### 11.1 GDScript 스타일

- **함수/변수**: `snake_case` (예: `get_save_data()`)
- **클래스/노드**: `PascalCase` (예: `MainScene`)
- **상수**: `UPPER_SNAKE_CASE` (예: `MAX_SLOTS`)
- **비공개 함수/변수**: `_` 접두사 (예: `_dispatch_command()`)
- **타입 힌트**: 적극 사용 (예: `var text: String = ""`)

### 11.2 시그널 명명

- `동사_과거분사` 패턴: `dialogue_requested`, `gallery_item_unlocked`
- 발행자 관점에서 명명

### 11.3 JSON 스토리 컨벤션

- 라벨명: `PascalCase` (예: `Day1UnknownHint`)
- 명령어: `snake_case` (예: `show_scene`, `fade_jump`)
- 캐릭터 ID: 단일 소문자 (`p`, `s`, `h`, `u`)
- 배경 ID: `snake_case` (예: `classroom_day`)
