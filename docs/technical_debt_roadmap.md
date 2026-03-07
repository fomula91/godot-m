# 기술 부채 및 개선 로드맵

> 코드 리뷰를 통해 발견된 기술 부채, 미완성 기능, 개선 기회의 체계적 정리

---

## 1. 우선순위 매트릭스

| 우선순위 | 의미 | 기준 |
|---------|------|------|
| **P0** | 긴급 | 사용자 경험에 직접 영향, 즉시 수정 필요 |
| **P1** | 높음 | 기능 완성에 필요, 다음 마일스톤에 포함 |
| **P2** | 보통 | 코드 품질 개선, 유지보수성 향상 |
| **P3** | 낮음 | 장기 개선, 리팩토링 |

---

## 2. P0 - 긴급

### 2.1 에러 처리 부재

**현상**: JSON 파싱 실패, 에셋 로드 실패, 잘못된 라벨 점프 시 사용자에게 피드백이 없거나 게임이 멈춤.

**영향 지점**:
- `story_manager.gd:179` - `jump()`: 존재하지 않는 라벨 점프 시 `push_error`만 출력
- `story_manager.gd:160-171` - `_load_story_file()`: JSON 파싱 실패 시 `push_warning`만 출력
- `story_manager.gd:197-198` - `advance()`: 라벨 끝에 도달 시 다음 동작 없음
- `game_manager.gd:51-78` - `set_var()`: 잘못된 경로 시 무시

**개선안**:
- 사용자에게 보이는 에러 UI 추가 (DebugOverlay 활용)
- 라벨 끝 도달 시 자동으로 `end` 처리 또는 경고
- 에셋 로드 실패 시 폴백 이미지/사운드 사용

### 2.2 Supabase 통계 미완성

**현상**: `main_scene.gd:48-50`에 `_supabase_url`, `_stats_http`, `_vote_http` 변수가 선언만 되어 있고 API 호출 로직 미구현.

**영향**: 웹 버전에서 제공하는 "X%의 플레이어가 이 선택을 했습니다" 기능이 Godot에서 동작하지 않음.

**개선안**:
```
1. project.godot 또는 별도 설정 파일에 Supabase URL/Key 저장
2. _ready()에서 HTTPRequest 노드 생성
3. choice_requested 시그널 수신 시:
   - tracked_scenes 확인
   - GET /api/stats?scene_id=X 호출
   - 응답으로 선택지 버튼에 퍼센트 표시
4. 선택 완료 시:
   - POST /api/vote {scene_id, choice_key} 전송
```

---

## 3. P1 - 높음

### 3.1 MainScene 크기 문제

**현상**: `main_scene.gd` 671줄, 33+ 함수. 하나의 파일이 입력 처리, UI 업데이트, 애니메이션, 세이브/로드, 상태 관리를 모두 담당.

**개선안**: 관심사 분리

| 분리 대상 | 함수들 | 추정 줄 수 |
|----------|--------|-----------|
| `vn_input_handler.gd` | `_unhandled_input`, `_handle_advance_input`, `_toggle_auto`, `_toggle_skip` | ~80줄 |
| `vn_dialogue_ui.gd` | `_on_dialogue`, `_on_narration`, `_start_typing`, `_complete_typing` | ~120줄 |
| `vn_scene_controller.gd` | `_on_scene_change`, `_on_character_show/hide`, `_on_fade` | ~150줄 |
| `vn_choice_ui.gd` | `_on_choice`, `_on_choice_button_pressed`, 통계 표시 | ~80줄 |

### 3.2 하드코딩된 데이터

**현상**: 캐릭터 정의, 씬 매핑, 추적 대상이 모두 `story_manager.gd` 코드에 하드코딩.

**영향 지점**:
- `story_manager.gd:24-43` - `characters` 딕셔너리 (20줄)
- `story_manager.gd:46-114` - `scene_map` 딕셔너리 (68줄)
- `story_manager.gd:117-130` - `tracked_scenes` 딕셔너리 (14줄)

**개선안**:
- `res://data/characters.json` 으로 분리
- `res://data/scene_map.json` 으로 분리
- `res://data/tracked_scenes.json` 으로 분리
- `_ready()`에서 JSON 로드

### 3.3 미사용 에셋 정리

**현상**: 전체 98개 에셋 중 22개(22.4%)가 미사용.

| 카테고리 | 미사용 수 | 상세 |
|---------|----------|------|
| 배경 | 15개 | 버스정류장 3개, 교실 3개, 과학실 3개, 기타 6개 |
| CG | 2개 | rooftop-sakura-rain, three-hands |
| 캐릭터 | 5개 | unknown 표정 5개 (미등록) |

**개선안**:
- 미사용 배경: 향후 콘텐츠에서 활용하거나 삭제
- 미등록 유우 표정 5개: `characters["u"]["sprites"]`에 등록
- 미사용 CG 2개: 스토리에 이벤트 추가하거나 삭제

---

## 4. P2 - 보통

### 4.1 상태 관리 개선

**현상**: `main_scene.gd`에서 bool 플래그 조합으로 상태를 관리 (`_typing`, `_auto_mode`, `_skip_mode`, `_distraction_free`).

**문제**: 상태 전환 시 여러 플래그를 동시에 관리해야 하며, 잘못된 조합이 발생할 수 있음.

**개선안**: enum 기반 State Machine

```gdscript
enum VNState {
    IDLE,           # 대기 (입력 가능)
    TYPING,         # 타이핑 중
    WAITING,        # wait 명령 대기
    CHOICE_PENDING, # 선택지 대기
    INPUT_PENDING,  # 텍스트 입력 대기
    FADING,         # 페이드 전환 중
}
var _state: VNState = VNState.IDLE
```

### 4.2 매직 넘버 상수화

**현상**: 여러 곳에 하드코딩된 숫자값.

| 값 | 위치 | 용도 |
|----|------|------|
| `0.05` | story_manager.gd:240,248,254,260 | 자동 진행 딜레이 |
| `1.5` | story_manager.gd:274,284 | 기본 페이드 시간 |
| `0.2` | story_manager.gd:278,288 | 페이드 후 대기 |
| `1000.0` | story_manager.gd:316 | ms→초 변환 |
| `20.0` | game_manager.gd:30 | 기본 텍스트 속도 |
| `5.0` | game_manager.gd:31 | 기본 자동 진행 속도 |

**개선안**: 상단에 상수 정의

```gdscript
const AUTO_ADVANCE_DELAY := 0.05
const DEFAULT_FADE_DURATION := 1.5
const FADE_POST_WAIT := 0.2
```

### 4.3 Tween 관리

**현상**: `main_scene.gd`에서 Tween을 생성하고 사용 후 별도 관리 없음. 중복 생성 가능.

**개선안**: Tween 생성 전 이전 Tween 정리

```gdscript
func _safe_create_tween() -> Tween:
    if _typing_tween and _typing_tween.is_valid():
        _typing_tween.kill()
    return create_tween()
```

### 4.4 성능 최적화 - JSON 일괄 로드

**현상**: `story_manager.gd:144-157`의 `load_all_stories()`가 게임 시작 시 17개 JSON 파일(7,325줄)을 모두 로드.

**영향**: 시작 시간 증가 (현재 규모에서는 미미하지만 콘텐츠 증가 시 문제)

**개선안** (콘텐츠 규모 증가 시):
```gdscript
# Day별 지연 로딩
func load_day(day: int) -> void:
    var dir_name = "day%d" % day
    _load_story_dir("res://story/" + dir_name)
```

---

## 5. P3 - 낮음 (장기)

### 5.1 테스트 부재

**현상**: 유닛 테스트, 통합 테스트가 전혀 없음.

**위험 지점**:
- `evaluate_condition()`: 중첩 AND/OR, 빈 문자열 비교, null 변수
- `replace_templates()`: 존재하지 않는 변수, 중첩 템플릿
- `_dispatch_command()`: 누락 필드, 잘못된 타입
- 세이브/로드: 데이터 손상, 버전 호환성

**개선안**: GDScript 테스트 프레임워크(GdUnit4 등) 도입

### 5.2 접근성

**현상**: 키보드 네비게이션, 스크린 리더 지원, 텍스트 크기 조절 없음.

**개선안**:
- 선택지에 키보드 포커스 지원 (위/아래 화살표)
- 텍스트 크기 설정 옵션 추가
- 색약 모드 (호감도 힌트 아이콘 차별화)

### 5.3 convert_stories.py 한계

**현상**: `extract_conditional()` 함수가 복잡한 Monogatari 패턴을 자동 변환하지 못하고 `_manual_` 접두사로 폴백.

**개선안**:
- Monogatari의 `Function` 타입 분기 패턴 추가 지원
- 변환 로그에 미변환 항목 경고
- 양방향 변환 (Godot JSON → Monogatari JS) 지원

### 5.4 국제화 (i18n)

**현상**: 모든 텍스트가 한국어로 하드코딩.

**개선안** (향후 다국어 지원 시):
- 스토리 JSON에 언어 키 시스템 도입
- UI 텍스트를 Godot의 TranslationServer 활용

---

## 6. 개선 로드맵 요약

```
Phase 1 (즉시)
├── [P0] 에러 처리 보강
└── [P0] Supabase 통계 구현

Phase 2 (단기)
├── [P1] 하드코딩 데이터 분리 (JSON)
├── [P1] 유우 표정 등록
└── [P1] 미사용 에셋 정리/활용

Phase 3 (중기)
├── [P2] MainScene 분리
├── [P2] 상태 관리 enum화
├── [P2] 매직 넘버 상수화
└── [P2] Tween 관리 개선

Phase 4 (장기)
├── [P3] 테스트 프레임워크 도입
├── [P3] 접근성 개선
├── [P3] convert_stories.py 고도화
└── [P3] 성능 최적화 (지연 로딩)
```

---

## 7. 관련 파일 경로

| 파일 | 주요 이슈 |
|------|----------|
| `scripts/autoload/story_manager.gd` | 하드코딩 데이터, 에러 처리 |
| `scripts/autoload/game_manager.gd` | evaluate_condition 엣지케이스 |
| `scenes/main_scene.gd` | 크기 문제, 상태 관리, Supabase 미완성 |
| `tools/convert_stories.py` | _manual_ 폴백, 양방향 미지원 |
| `scenes/gallery_screen.gd` | CG 목록 하드코딩 |
