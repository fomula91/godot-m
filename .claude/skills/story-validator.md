---
name: story-validator
description: |
  Story JSON 검증 스킬 - 비주얼 노벨 스토리 파일의 무결성을 검증합니다.
  label 참조, 에셋 경로, 커맨드 구조, 캐릭터/스프라이트 유효성을 자동 체크합니다.
triggers:
  - story validate
  - story check
  - 스토리 검증
  - 스토리 체크
  - JSON 검증
  - validate story
  - check story
---

# Story JSON Validator

비주얼 노벨 프로젝트의 `story/` 디렉토리에 있는 JSON 스토리 파일을 검증하는 스킬입니다.

## 검증 항목

아래 7가지 카테고리를 순서대로 검증합니다.

### 1. JSON 구문 검증
- 모든 `story/**/*.json` 파일이 유효한 JSON인지 파싱 테스트
- 각 파일의 최상위 구조가 `{ "LabelName": [...commands] }` 형태인지 확인

### 2. Label 참조 무결성
- `jump`, `fade_jump`, `conditional`, `choice`에서 참조하는 `target` label이 실제 존재하는지 확인
- 모든 JSON 파일의 label을 먼저 수집한 후 크로스 파일 참조도 검증
- **데드 라벨 탐지**: 어디서도 참조되지 않고 `Start`도 아닌 label 경고

### 3. 커맨드 구조 검증
각 커맨드 타입별 필수 필드 체크:

| cmd | 필수 필드 |
|-----|----------|
| `dialogue` | `character`, `text` |
| `narration` | `text` |
| `centered` | `text` |
| `show_scene` | `id` |
| `show_character` | `id`, `sprite`, `position` |
| `hide_character` | `id` |
| `change_sprite` | `id`, `sprite` |
| `choice` | `choices` (배열, 각 항목에 `text`, `target` 필수) |
| `jump` | `target` |
| `fade_jump` | `target` |
| `fade_scene` | `id` |
| `play_music` | `id` |
| `play_sound` | `id` |
| `stop_music` | (필수 없음) |
| `stop_sound` | (필수 없음) |
| `wait` | `duration` |
| `set_var` | `path`, `value` |
| `conditional` | `branches` (배열) |
| `input` | `prompt` |
| `gallery_unlock` | `id` |
| `affinity_hint` | `character` |
| `distraction_free` | (필수 없음) |
| `end` | (필수 없음) |

- 알 수 없는 `cmd` 타입 경고

### 4. 캐릭터 검증
- `dialogue`, `show_character`, `hide_character`, `change_sprite`에서 참조하는 캐릭터 ID가 `story_manager.gd`의 `characters` Dictionary에 정의되어 있는지 확인
- 유효한 캐릭터 ID: `p`, `sua`, `friend`

### 5. 스프라이트 검증
- `show_character`, `change_sprite`에서 사용하는 sprite 이름이 해당 캐릭터의 `sprites` Dictionary에 존재하는지 확인
- 캐릭터별 유효 스프라이트:
  - `p`: normal, happy, surprised, worried
  - `sua`: normal, happy, shy, sad, surprised, worried
  - `friend`: normal

### 6. 에셋 경로 검증

#### 배경 (show_scene, fade_scene)
- `id`가 `#`으로 시작하면 색상값이므로 스킵
- 그 외 `id`가 `story_manager.gd`의 `scene_map` Dictionary에 존재하는지 확인
- `scene_map`에 매핑된 실제 파일 (`assets/` 하위)이 존재하는지 확인
- 유효한 scene ID 목록:
  ```
  school_front_morning, school_front_day, school_front_evening,
  classroom_morning, classroom_day, classroom_afternoon, classroom_evening,
  cafeteria_day, lunch_spot,
  hallway_day, hallway_evening,
  school_grounds_day, school_grounds_evening,
  city_day, city_evening,
  jeju_scenery, jeju_lodging,
  sports_festival,
  first_lunch_cg, seat_assignment_cg, group_project_cg, math_class_cg,
  jeju_together_cg, jeju_delivery_cg, sports_festival_cg, birthday_gift_cg,
  city_outing_cg, sua_confession_cg, ending_a_cg, ending_b_cg, ending_c_cg
  ```

#### 오디오 (play_music, play_sound)
- `play_music`의 `id`에 `.mp3`를 붙여 `assets/music/` 하위에 파일이 존재하는지 확인
- `play_sound`의 `id`에 `.mp3`를 붙여 `assets/sounds/` 하위에 파일이 존재하는지 확인
- 현재 존재하는 음악: `acoustic-chill`, `sunny-day`, `hana-ending`, `sora-ending`, `harem-ending`
- 현재 존재하는 효과음: `Select`, `Japanese_School_Bell`, `Footsteps`

#### 갤러리 (gallery_unlock)
- `gallery_unlock`의 `id`에 `.webp`를 붙여 `assets/gallery/` 하위에 파일이 존재하는지 확인

### 7. 포지션 검증
- `show_character`의 `position`이 유효한 값인지 확인
- 유효 값: `left`, `center`, `right`

### 8. 트랜지션 검증
- `show_character`의 `transition`: `fadeIn`, `fadeInUp`, `slideInLeft`, `slideInRight`, `bounceIn`, `instant`
- `hide_character`의 `transition`: `fadeOut`, `fadeOutLeft`, `fadeOutRight`, `instant`
- `show_scene`의 `transition`: `instant`, `fadeIn`

## 실행 방법

1. `story/**/*.json` 파일을 모두 Read로 읽기
2. `story_manager.gd`에서 characters, scene_map 정의 참조
3. `assets/` 디렉토리의 실제 파일 목록과 대조
4. 검증 결과를 아래 형식으로 출력

## 출력 형식

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Story JSON 검증 결과
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 검증 파일: [파일 목록]
📊 총 Label 수: N개
📊 총 Command 수: N개

✅ 통과 항목
──────────────────────────────────
- [통과한 검증 항목 목록]

❌ 오류 (즉시 수정 필요)
──────────────────────────────────
[ERROR-001] 파일: story/april/opening.json
  Label "XXX" → jump target "YYY" 가 존재하지 않음

⚠️ 경고 (권장 수정)
──────────────────────────────────
[WARN-001] 파일: story/april/opening.json
  Label "TestMenu" 는 어디서도 참조되지 않음 (데드 라벨)

📈 검증 요약
──────────────────────────────────
✅ 통과: N / M
❌ 오류: N건
⚠️ 경고: N건
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 오류 코드

| 코드 | 설명 |
|------|------|
| `ERR-JSON` | JSON 파싱 실패 |
| `ERR-LABEL` | 존재하지 않는 label 참조 |
| `ERR-CMD` | 알 수 없는 커맨드 타입 |
| `ERR-FIELD` | 필수 필드 누락 |
| `ERR-CHAR` | 미정의 캐릭터 ID |
| `ERR-SPRITE` | 미정의 스프라이트 이름 |
| `ERR-SCENE` | 미정의 scene ID |
| `ERR-ASSET` | 에셋 파일 미존재 |
| `ERR-POS` | 유효하지 않은 position |
| `ERR-TRANS` | 유효하지 않은 transition |
| `WARN-DEAD` | 데드 라벨 (미참조) |
| `WARN-AUDIO` | 오디오 파일 미존재 |
