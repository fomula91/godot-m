# 시그널 & 명령어 레퍼런스

> StoryManager의 JSON 명령어 체계와 시그널 아키텍처의 완전한 API 레퍼런스

---

## 1. 아키텍처 개요

```
[JSON 스토리 파일] → [StoryManager._dispatch_command()] → [시그널 발행] → [MainScene 핸들러] → [UI 갱신]
```

- **StoryManager** (`scripts/autoload/story_manager.gd`): JSON 파싱, 명령 디스패치, 시그널 발행
- **GameManager** (`scripts/autoload/game_manager.gd`): 상태 변수 관리, 조건 평가, 템플릿 치환
- **MainScene** (`scenes/main_scene.gd`): 시그널 수신, UI 노드 제어

---

## 2. 명령어 레퍼런스 (22종)

### 2.1 텍스트 표시 계열

#### `dialogue` - 캐릭터 대사

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"dialogue"` |
| `character` | String | O | - | 캐릭터 ID (`"p"`, `"s"`, `"h"`, `"u"`) |
| `text` | String | O | - | 대사 텍스트 (템플릿 치환 지원) |

- **시그널**: `dialogue_requested(character, name_text, text)`
- **진행**: 수동 (플레이어 클릭 대기)
- **예시**:
```json
{"cmd": "dialogue", "character": "s", "text": "안녕하세요, {{player.name}}씨!"}
```

#### `narration` - 나레이션

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"narration"` |
| `text` | String | O | - | 나레이션 텍스트 |

- **시그널**: `narration_requested(text)`
- **진행**: 수동
- **참고**: JSON에서 단순 문자열(`"나레이션 텍스트"`)도 narration으로 처리됨
- **예시**:
```json
{"cmd": "narration", "text": "봄바람이 불어오는 교실 안."}
```

#### `centered` - 중앙 텍스트

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"centered"` |
| `text` | String | O | - | 화면 중앙에 표시할 텍스트 |

- **시그널**: `centered_requested(text)`
- **진행**: 수동
- **예시**:
```json
{"cmd": "centered", "text": "- 1일차 -"}
```

---

### 2.2 씬(배경) 제어 계열

#### `show_scene` - 배경 전환

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"show_scene"` |
| `id` | String | O | - | `scene_map`에 등록된 배경 ID |
| `transition` | String | X | `"fadeIn"` | 전환 효과 |

- **시그널**: `scene_change_requested(id, transition)`
- **진행**: 자동 (0.05초 후)
- **예시**:
```json
{"cmd": "show_scene", "id": "classroom_day", "transition": "fadeIn"}
```

#### `fade_scene` - 페이드 배경 전환

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"fade_scene"` |
| `id` | String | O | - | 배경 ID |
| `duration` | float | X | `1.5` | 페이드 시간 (초) |
| `color` | String | X | `"#000000"` | 페이드 색상 |

- **시그널**: `fade_requested("to_black", ...)` → `scene_change_requested(id, "instant")` → `fade_requested("from_black", ...)`
- **진행**: 대기 후 자동 (duration x 2 + 0.2초)
- **예시**:
```json
{"cmd": "fade_scene", "id": "school_front_day", "duration": 1.0}
```

---

### 2.3 캐릭터 제어 계열

#### `show_character` - 캐릭터 표시

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"show_character"` |
| `id` | String | O | - | 캐릭터 ID (`"p"`, `"s"`, `"h"`, `"u"`) |
| `sprite` | String | X | `"normal"` | 표정 키 |
| `position` | String | X | `"center"` | 위치 (`"left"`, `"center"`, `"right"`) |
| `transition` | String | X | `"fadeIn"` | 전환 효과 |

- **시그널**: `character_show_requested(id, sprite, position, transition)`
- **진행**: 자동 (0.05초 후)
- **예시**:
```json
{"cmd": "show_character", "id": "s", "sprite": "happy", "position": "left"}
```

#### `hide_character` - 캐릭터 숨김

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"hide_character"` |
| `id` | String | O | - | 캐릭터 ID |
| `transition` | String | X | `"fadeOut"` | 전환 효과 |

- **시그널**: `character_hide_requested(id, transition)`
- **진행**: 자동 (0.05초 후)
- **예시**:
```json
{"cmd": "hide_character", "id": "h", "transition": "fadeOut"}
```

#### `change_sprite` - 표정 변경

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"change_sprite"` |
| `id` | String | O | - | 캐릭터 ID |
| `sprite` | String | X | `"normal"` | 새 표정 키 |

- **시그널**: `character_sprite_changed(id, sprite)`
- **진행**: 자동 (0.05초 후)
- **예시**:
```json
{"cmd": "change_sprite", "id": "s", "sprite": "surprised"}
```

---

### 2.4 분기 제어 계열

#### `choice` - 선택지

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"choice"` |
| `dialog` | String | X | `""` | 선택지 상단 텍스트 |
| `choices` | Array | O | - | 선택지 배열 |
| `choices[].text` | String | O | - | 선택지 표시 텍스트 |
| `choices[].key` | String | O | - | 선택지 고유 키 (통계용) |
| `choices[].target` | String | O | - | 점프할 라벨명 |

- **시그널**: `choice_requested(dialog, choices)`
- **진행**: 선택 대기 (`_choice_pending = true`)
- **예시**:
```json
{
  "cmd": "choice",
  "dialog": "누구에게 다가갈까?",
  "choices": [
    {"text": "소라에게 말을 걸어본다", "key": "talk_sora", "target": "Day1SoraBreak"},
    {"text": "하나에게 말을 걸어본다", "key": "talk_hana", "target": "Day1HanaBreak"}
  ]
}
```

#### `jump` - 라벨 점프

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"jump"` |
| `target` | String | O | - | 점프할 라벨명 |

- **시그널**: 없음 (내부 처리)
- **진행**: 즉시 (대상 라벨 첫 명령 실행)
- **예시**:
```json
{"cmd": "jump", "target": "Day1Afternoon"}
```

#### `fade_jump` - 페이드 후 점프

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"fade_jump"` |
| `target` | String | O | - | 점프할 라벨명 |
| `duration` | float | X | `1.5` | 페이드 시간 (초) |
| `wait` | float | X | `0.2` | 페이드 후 추가 대기 (초) |
| `color` | String | X | `"#000000"` | 페이드 색상 |

- **시그널**: `fade_requested("to_black", duration, color)`
- **진행**: 대기 후 점프 (duration + wait 초)
- **예시**:
```json
{"cmd": "fade_jump", "target": "Day2Morning", "duration": 1.5}
```

#### `conditional` - 조건부 분기

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"conditional"` |
| `branches` | Array | O | - | 조건 분기 배열 |
| `branches[].condition` | String | O | - | 조건식 (아래 문법 참조) |
| `branches[].target` | String | O | - | 조건 충족 시 점프 라벨 |
| `branches[].action` | String | X | `""` | `"jump"` 지정 시 점프 실행 |
| `default` | String | X | - | 모든 조건 불충족 시 점프 라벨 |

- **시그널**: 없음 (내부 처리)
- **진행**: 즉시 (조건 평가 후 점프 또는 다음 명령)
- **예시**:
```json
{
  "cmd": "conditional",
  "branches": [
    {"condition": "sora_affection >= 4 AND hana_affection >= 4", "target": "Day3BothHigh", "action": "jump"},
    {"condition": "sora_affection > hana_affection", "target": "Day3SoraRoute", "action": "jump"},
    {"condition": "hana_affection > sora_affection", "target": "Day3HanaRoute", "action": "jump"}
  ],
  "default": "Day3BothHigh"
}
```

---

### 2.5 오디오 제어 계열

#### `play_music` - BGM 재생

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"play_music"` |
| `id` | String | O | - | 음악 ID (AudioManager에 등록된 키) |
| `loop` | bool | X | `true` | 반복 재생 여부 |

- **시그널**: 없음 (AudioManager 직접 호출)
- **진행**: 즉시 자동
- **예시**:
```json
{"cmd": "play_music", "id": "sunny-day"}
```

#### `stop_music` - BGM 정지

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"stop_music"` |
| `fade` | float | X | `1.0` | 페이드아웃 시간 (초) |

- **시그널**: 없음 (AudioManager 직접 호출)
- **진행**: 즉시 자동

#### `play_sound` - 효과음 재생

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"play_sound"` |
| `id` | String | O | - | 효과음 ID |

- **시그널**: 없음 (AudioManager 직접 호출)
- **진행**: 즉시 자동

#### `stop_sound` - 효과음 정지

- **진행**: 즉시 자동
- **예시**: `{"cmd": "stop_sound"}`

---

### 2.6 게임 상태 제어 계열

#### `set_var` - 변수 설정

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"set_var"` |
| `path` | String | O | - | 변수 경로 (예: `"sora_affection"`, `"player.name"`) |
| `value` | Variant | O | - | 설정할 값 |
| `op` | String | X | `"set"` | 연산: `"set"`, `"add"`, `"sub"` |

- **시그널**: `state_changed(key, value)` (GameManager 발행)
- **진행**: 즉시 자동
- **예시**:
```json
{"cmd": "set_var", "path": "sora_affection", "value": 1, "op": "add"}
{"cmd": "set_var", "path": "helped_sora", "value": true}
```

#### `gallery_unlock` - 갤러리 해금

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"gallery_unlock"` |
| `id` | String | O | - | CG 이미지 ID (예: `"opening-unknown"`) |

- **시그널**: `gallery_item_unlocked(id)` (GameManager 발행)
- **진행**: 즉시 자동

#### `affinity_hint` - 호감도 힌트 표시

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"affinity_hint"` |
| `character` | String | O | - | 캐릭터 키 (`"sora"`, `"hana"`, `"both"`, `"unknown"`) |

- **시그널**: `affinity_hint_requested(character)`
- **진행**: 즉시 자동
- **예시**:
```json
{"cmd": "affinity_hint", "character": "sora"}
```

---

### 2.7 연출 제어 계열

#### `wait` - 시간 대기

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"wait"` |
| `duration` | float | O | `1000` | 대기 시간 (**밀리초** 단위) |

- **시그널**: `wait_requested(duration)` (초 단위로 변환되어 전달)
- **진행**: 대기 후 자동
- **주의**: JSON에는 ms 단위로 입력하지만, 내부에서 `/1000.0`으로 초 변환
- **예시**:
```json
{"cmd": "wait", "duration": 2000}
```

#### `input` - 텍스트 입력

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `cmd` | String | O | - | `"input"` |
| `prompt` | String | X | `""` | 입력 안내 텍스트 |
| `warning` | String | X | `""` | 경고 메시지 |

- **시그널**: `input_requested(prompt, warning)`
- **진행**: 입력 대기 (`_waiting = true`, `on_input_completed()` 호출 시 해제)
- **참고**: 입력값은 자동으로 `player.name`에 저장됨

#### `distraction_free` - UI 숨김 토글

- **시그널**: `distraction_free_toggled()`
- **진행**: 즉시 자동
- **예시**: `{"cmd": "distraction_free"}`

#### `end` - 게임 종료

- **시그널**: `end_requested()`
- **진행**: 타이틀 화면으로 전환
- **예시**: `{"cmd": "end"}`

---

## 3. 시그널 레퍼런스

### 3.1 StoryManager 시그널 (17개)

| 시그널 | 파라미터 | 수신자 | UI 효과 |
|--------|----------|--------|---------|
| `dialogue_requested` | `character: String, name_text: String, text: String` | MainScene | 대화창에 캐릭터명 + 대사 표시, 타이핑 애니메이션 |
| `narration_requested` | `text: String` | MainScene | 대화창에 나레이션 표시 (이름 없음) |
| `centered_requested` | `text: String` | MainScene | 화면 중앙에 텍스트 표시 |
| `choice_requested` | `dialog: String, choices: Array` | MainScene | 선택지 패널 표시, 버튼 생성 |
| `scene_change_requested` | `id: String, transition: String` | MainScene | 배경 이미지 교체 (이중 버퍼 페이드) |
| `character_show_requested` | `id: String, sprite: String, position: String, transition: String` | MainScene | 캐릭터 스프라이트 표시 (좌/중앙/우) |
| `character_hide_requested` | `id: String, transition: String` | MainScene | 캐릭터 스프라이트 숨김 |
| `character_sprite_changed` | `id: String, sprite: String` | MainScene | 캐릭터 표정 교체 |
| `fade_requested` | `fade_type: String, duration: float, color: Color` | MainScene | 화면 페이드 효과 (`"to_black"` / `"from_black"`) |
| `wait_requested` | `duration: float` | MainScene | 지정 시간 대기 |
| `input_requested` | `prompt: String, warning: String` | MainScene | 텍스트 입력 다이얼로그 표시 |
| `affinity_hint_requested` | `character: String` | MainScene | 호감도 변화 알림 표시 |
| `gallery_unlock_requested` | `id: String` | MainScene | 갤러리 해금 알림 |
| `distraction_free_toggled` | (없음) | MainScene | UI 표시/숨김 토글 |
| `end_requested` | (없음) | MainScene | 타이틀 화면 전환 |
| `command_completed` | (없음) | (현재 미사용) | - |

### 3.2 GameManager 시그널 (2개)

| 시그널 | 파라미터 | 용도 |
|--------|----------|------|
| `state_changed` | `key: String, value: Variant` | 변수 변경 알림 |
| `gallery_item_unlocked` | `id: String` | CG 해금 알림 |

---

## 4. 명령-시그널 매핑표

| 명령어 | 발행 시그널 | 자동진행 | 대기 방식 |
|--------|------------|---------|----------|
| `dialogue` | `dialogue_requested` | 수동 | 플레이어 클릭 |
| `narration` | `narration_requested` | 수동 | 플레이어 클릭 |
| (문자열) | `narration_requested` | 수동 | 플레이어 클릭 |
| `centered` | `centered_requested` | 수동 | 플레이어 클릭 |
| `choice` | `choice_requested` | 선택 대기 | `_choice_pending` |
| `show_scene` | `scene_change_requested` | 자동 0.05초 | 타이머 |
| `show_character` | `character_show_requested` | 자동 0.05초 | 타이머 |
| `hide_character` | `character_hide_requested` | 자동 0.05초 | 타이머 |
| `change_sprite` | `character_sprite_changed` | 자동 0.05초 | 타이머 |
| `jump` | (없음) | 즉시 | - |
| `fade_jump` | `fade_requested` | 대기 후 점프 | `_waiting` + await |
| `fade_scene` | `fade_requested` + `scene_change_requested` | 대기 후 자동 | `_waiting` + await |
| `play_music` | (없음, AudioManager 직접) | 즉시 자동 | - |
| `stop_music` | (없음, AudioManager 직접) | 즉시 자동 | - |
| `play_sound` | (없음, AudioManager 직접) | 즉시 자동 | - |
| `stop_sound` | (없음, AudioManager 직접) | 즉시 자동 | - |
| `wait` | `wait_requested` | 대기 후 자동 | `_waiting` + await |
| `set_var` | `state_changed` (간접) | 즉시 자동 | - |
| `conditional` | (없음) | 즉시 | - |
| `input` | `input_requested` | 입력 대기 | `_waiting` |
| `gallery_unlock` | `gallery_item_unlocked` (간접) | 즉시 자동 | - |
| `affinity_hint` | `affinity_hint_requested` | 즉시 자동 | - |
| `distraction_free` | `distraction_free_toggled` | 즉시 자동 | - |
| `end` | `end_requested` | - | 게임 종료 |

---

## 5. 조건식 문법

`GameManager.evaluate_condition()` 함수가 조건식을 평가합니다.

### 5.1 비교 연산자

| 연산자 | 의미 | 예시 |
|--------|------|------|
| `==` | 같음 | `day3_ending_type == 'normal'` |
| `!=` | 다름 | `day3_ending_type != ''` |
| `>=` | 이상 | `sora_affection >= 4` |
| `<=` | 이하 | `hana_affection <= 2` |
| `>` | 초과 | `sora_affection > hana_affection` |
| `<` | 미만 | `unknown_interest < 2` |

### 5.2 논리 연산자

| 연산자 | 의미 | 예시 |
|--------|------|------|
| `AND` | 그리고 | `sora_affection >= 4 AND hana_affection >= 4` |
| `OR` | 또는 | `helped_sora OR chose_library` |

- **주의**: AND와 OR의 중첩(혼합) 사용은 지원되지 않음. AND 우선 파싱.

### 5.3 단순 불리언 체크

변수명만 쓰면 truthy 평가:
```
helped_sora        → state["helped_sora"]가 true이면 통과
met_unknown        → state["met_unknown"]가 true이면 통과
```

### 5.4 값 파싱 규칙

조건식의 우변 값은 다음 순서로 파싱됩니다:

1. `"true"` / `"false"` → bool
2. 정수 문자열 → int
3. 실수 문자열 → float
4. 따옴표로 감싼 문자열 → String (따옴표 제거)
5. 나머지 → 그대로 String

---

## 6. 템플릿 변수 문법

`GameManager.replace_templates()` 함수가 `{{변수경로}}` 패턴을 치환합니다.

### 6.1 문법

```
{{변수명}}          → state["변수명"]의 값으로 치환
{{객체.속성}}       → state["객체"]["속성"]의 값으로 치환
```

### 6.2 사용 예시

```json
{"cmd": "dialogue", "character": "s", "text": "{{player.name}}씨, 안녕하세요!"}
```

- `player.name`이 `"하루"`이면 → `"하루씨, 안녕하세요!"`로 치환

### 6.3 적용 범위

템플릿 치환이 적용되는 필드:
- `dialogue`의 `text`
- `narration`의 `text`
- `centered`의 `text`
- `choice`의 `dialog`
- 캐릭터 이름 (`characters` 딕셔너리의 `name` 필드)
- 단순 문자열 나레이션

---

## 7. 게임 상태 변수

### 7.1 기본 상태 (`_default_state`)

| 변수 경로 | 타입 | 초기값 | 설명 |
|-----------|------|--------|------|
| `player.name` | String | `""` | 플레이어 이름 (input 명령으로 설정) |
| `sora_affection` | int | `0` | 소라 호감도 |
| `hana_affection` | int | `0` | 하나 호감도 |
| `helped_sora` | bool | `false` | Day1 소라 도움 여부 |
| `chose_library` | bool | `false` | 점심 장소 도서관 선택 |
| `day2_sora_walk` | bool | `false` | Day2 소라와 산책 |
| `day2_studied_together` | bool | `false` | Day2 함께 공부 |
| `confessed` | bool | `false` | 고백 여부 |
| `chose_both` | bool | `false` | 둘 다 선택 |
| `unknown_interest` | int | `0` | 유우 관심도 |
| `met_unknown` | bool | `false` | 유우 만남 여부 |
| `day3_ending_type` | String | `""` | Day3 엔딩 타입 |

### 7.2 설정 변수 (`settings`)

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `text_speed` | float | `20.0` | 글자당 밀리초 |
| `auto_speed` | float | `5.0` | 자동 진행 대기 (초) |
| `music_volume` | float | `1.0` | BGM 볼륨 (0.0~1.0) |
| `sound_volume` | float | `1.0` | SFX 볼륨 (0.0~1.0) |

### 7.3 set_var 연산자

| op | 동작 | 예시 |
|----|------|------|
| `"set"` | 값 직접 설정 | `state[path] = value` |
| `"add"` | 현재 값에 더하기 | `state[path] += value` |
| `"sub"` | 현재 값에서 빼기 | `state[path] -= value` |

---

## 8. 세이브 데이터 구조

`GameManager.save_game()`이 저장하는 JSON 구조:

```json
{
  "state": { ... },           // 게임 상태 변수 전체 복사
  "gallery": ["cg1", "cg2"],  // 해금된 갤러리 ID 목록
  "current_label": "Day2Morning", // 현재 스토리 라벨
  "line_index": 15,           // 현재 라벨 내 줄 번호
  "background": "classroom_day", // 현재 배경 ID
  "characters": { ... },      // 화면의 캐릭터 상태
  "bgm": "sunny-day",         // 현재 재생 중인 BGM
  "timestamp": "2026-03-07T12:00:00", // 저장 시각
  "label_display": "Day 2 - 아침" // 표시용 라벨명
}
```

- **저장 경로**: `user://saves/slot_0.json` ~ `slot_9.json`
- **설정 파일**: `user://settings.json`
- **갤러리 파일**: `user://gallery.json`

---

## 9. 선택지 통계 추적 대상

`tracked_scenes` 딕셔너리에 등록된 12개 라벨에서 choice 명령이 실행될 때 통계가 추적됩니다:

| 라벨명 | Day | 설명 |
|--------|-----|------|
| `Day1UnknownHint` | 1 | 빈 책상 관심 여부 |
| `MorningEvent` | 1 | 쉬는시간 누구에게 다가갈지 |
| `LunchTimeChoice` | 1 | 점심 장소 선택 |
| `Day2Morning` | 2 | Day2 아침 선택 |
| `Day2ScienceLab` | 2 | 과학실 선택 |
| `Day3BothHigh` | 3 | 양쪽 높은 호감도 분기 |
| `Day3SoraClimax` | 3 | 소라 클라이맥스 |
| `Day3HanaClimax` | 3 | 하나 클라이맥스 |
| `Day4Morning` | 4 | Day4 아침 선택 |
| `Day4Evening` | 4 | Day4 저녁 선택 |
| `Day5SoraConfess2` | 5 | 소라 고백 2차 |
| `Day5HanaConfess2` | 5 | 하나 고백 2차 |
