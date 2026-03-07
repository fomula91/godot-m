# Scenes 폴더 평가 리포트

## 프로젝트 개요

| 항목 | 값 |
|------|-----|
| 엔진 | Godot 4.6 |
| 뷰포트 | 1920 x 1080 |
| Stretch Mode | canvas_items |
| 렌더러 | GL Compatibility |
| 스크립트 언어 | GDScript |

### 오토로드 싱글톤

| 이름 | 경로 |
|------|------|
| GameManager | `res://scripts/autoload/game_manager.gd` |
| AudioManager | `res://scripts/autoload/audio_manager.gd` |
| StoryManager | `res://scripts/autoload/story_manager.gd` |
| DebugOverlay | `res://scripts/autoload/debug_overlay.gd` |
| MCPGameBridge | `res://addons/godot_mcp/game_bridge/mcp_game_bridge.gd` |

### 입력 매핑

| 액션 | 키 |
|------|-----|
| vn_advance | 좌클릭, 오른쪽 화살표, Space |
| vn_skip | Shift |

---

## 씬별 상세 분석

---

### 1. title_screen (타이틀 화면)

**파일:** `scenes/title_screen.tscn` + `scenes/title_screen.gd`

#### 노드 계층
```
TitleScreen (Control) ← 스크립트 연결
├── Background (TextureRect) ── 전체 화면 배경
├── Overlay (ColorRect) ── 반투명 오버레이 (0,0,0,0.3)
├── ParticlesLayer (Control)
│   └── Petals (GPUParticles2D) ── 벚꽃잎 파티클
└── CenterContainer (CenterContainer) ── margin 200/200/100/100
    └── VBoxContainer ── separation: 20
        ├── TitleHeader (인스턴스: TitleHeader.tscn)
        ├── StartBtn (인스턴스: MenuButton.tscn) ── "시작하기"
        ├── ContinueBtn (인스턴스: MenuButton.tscn) ── "이어하기"
        ├── GalleryBtn (인스턴스: MenuButton.tscn) ── "갤러리"
        └── SettingsBtn (인스턴스: MenuButton.tscn) ── "설정"
```

#### 스크립트 분석 (title_screen.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | 배경 로드, BGM 재생, 세이브 확인, 시그널 연결 |
| `_style_buttons()` | 4개 버튼에 StyleBoxFlat 스타일 적용 |
| `_on_start()` | 게임 상태 리셋 후 main_scene 로드 |
| `_on_continue()` | 슬롯 0에서 저장 데이터 로드 |
| `_on_gallery()` | 갤러리 화면으로 전환 |
| `_on_settings()` | 설정 화면으로 전환 |

**의존성:** GameManager, AudioManager, StoryManager

#### 발견된 문제점

- `_on_continue()`에서 데이터가 없을 때 사용자에게 피드백이 없음 (빈 return)
- 사운드 에셋명 `"sunny-day"` 하드코딩
- `_style_buttons()` 함수가 있지만 MenuButton 컴포넌트도 자체 스타일링을 함 → 스타일 중복 가능성

#### 평가: **양호**

---

### 2. main_scene (메인 게임 화면)

**파일:** `scenes/main_scene.tscn` + `scenes/main_scene.gd`

#### 노드 계층
```
MainScene (Control) ← 스크립트 연결
├── BackgroundLayer (Control)
│   ├── Background1 (TextureRect) ── 현재 배경
│   └── Background2 (TextureRect) ── 전환용 (alpha=0)
├── CharacterLayer (Control)
│   ├── LeftSlot (TextureRect) ── anchor 0.1-0.4
│   ├── CenterSlot (TextureRect) ── anchor 0.3-0.7
│   └── RightSlot (TextureRect) ── anchor 0.6-0.9
├── UILayer (CanvasLayer, layer=10)
│   ├── DialogueBox (PanelContainer)
│   │   └── MarginContainer → VBoxContainer
│   │       ├── NameLabel (Label)
│   │       └── TextLabel (RichTextLabel)
│   ├── ChoicePanel (VBoxContainer, 숨김)
│   ├── CenteredText (Label, 숨김)
│   ├── QuickMenu (HBoxContainer)
│   │   ├── SaveBtn, LoadBtn, AutoBtn, SkipBtn, LogBtn, SettingsBtn
│   └── AffinityHint (PanelContainer, 숨김)
├── OverlayLayer (CanvasLayer, layer=20)
│   ├── TransitionRect (ColorRect)
│   ├── AffinityHint (PanelContainer, 숨김)
│   └── InputDialog (PanelContainer, 숨김)
└── AutoTimer (Timer, 5초, one_shot)
```

#### 스크립트 분석 (main_scene.gd)

**함수 수:** 33개 이상 (프로젝트에서 가장 큰 스크립트)

| 카테고리 | 주요 함수 |
|----------|-----------|
| 초기화 | `_ready()`, `_connect_story_signals()`, `_connect_ui_signals()`, `_setup_http_nodes()` |
| 입력 | `_unhandled_input()`, `_handle_advance_input()` |
| 대화 | `_on_dialogue()`, `_on_narration()`, `_on_centered()`, `_start_typing()` |
| 선택지 | `_on_choice()`, `_on_choice_button_pressed()`, `_finalize_choice()` |
| 오토/스킵 | `_toggle_auto()`, `_toggle_skip()`, `_on_auto_timeout()` |
| 씬/캐릭터 | `_on_scene_change()`, `_on_character_show()`, `_on_character_hide()` |
| 전환 효과 | `_on_fade()` |
| 입력 다이얼로그 | `_on_input_request()`, `_on_input_confirm()` |
| 호감도 | `_on_affinity_hint()` |
| Supabase | `_fetch_preview_stats()`, `_record_vote_and_show_stats()` |
| 세이브/로드 | `_quick_save()`, `_quick_load()`, `_restore_state()` |

**시그널 연결:** StoryManager 12개 + UI 5개 = 약 17개

**의존성:** GameManager, AudioManager, StoryManager, DebugOverlay

#### 발견된 문제점

- **Supabase 통합 미완성:** `_display_stats_preview()`, `_show_stats_result()` 함수가 실제 UI 업데이트 없음
- **AffinityHint 노드 중복:** UILayer와 OverlayLayer에 각각 존재
- **매직 넘버:** 색상, 시간, 속도 값들이 전반적으로 하드코딩
- **Tween 관리:** `_typing_tween` 존재 여부 검증 없이 kill/재생성하는 경우 있음
- **상태 관리:** `_typing`, `_auto_mode`, `_skip_mode`, `_distraction_free` 등 다수의 bool 플래그 → enum 기반 상태 머신 고려 필요
- **파일 규모:** 한 파일에 너무 많은 책임이 집중됨 → 분리 권장

#### 평가: **보통** (기능은 동작하나 구조적 개선 필요)

---

### 3. gallery_screen (갤러리 화면)

**파일:** `scenes/gallery_screen.tscn` + `scenes/gallery_screen.gd`

#### 노드 계층
```
GalleryScreen (Control) ← 스크립트 연결
├── Background (ColorRect) ── 어두운 보라색 (0.05, 0.02, 0.08)
├── VBoxContainer
│   ├── TopBar (HBoxContainer)
│   │   ├── Title (Label) ── "갤러리"
│   │   └── BackBtn (Button) ── "돌아가기"
│   └── ScrollContainer
│       └── Grid (GridContainer) ── 5열
├── FullscreenBG (ColorRect, 숨김) ── 검정 0.9 alpha
└── FullscreenViewer (TextureRect, 숨김)
```

#### 스크립트 분석 (gallery_screen.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | 버튼 연결, 스타일링, 갤러리 빌드 |
| `_build_gallery()` | 25개 갤러리 아이템 생성 (잠금/해제 상태) |
| `_style_back_btn()` | 뒤로가기 버튼 StyleBox 적용 |
| `_create_close_btn()` | 전체화면 닫기 버튼 동적 생성 |
| `_view_image(id)` | 이미지 전체화면 표시 |
| `_close_fullscreen()` | 전체화면 닫기 |
| `_unhandled_input(event)` | 클릭으로 전체화면 닫기 |

**상수:** `GALLERY_IDS` (25개 ID), `GALLERY_FILES` (ID→파일명 매핑)

**의존성:** GameManager, AudioManager

#### 발견된 문제점

- 에셋 경로 `"res://assets/gallery/"` 하드코딩
- `load()` 호출 시 텍스처 존재 여부 미검증
- 닫기 버튼 고정 좌표 사용 → 뷰포트 변경 시 위치 깨질 수 있음
- 한국어 문자열 하드코딩 (`"?"`, `"닫기"`)

#### 평가: **양호**

---

### 4. settings_screen (설정 화면)

**파일:** `scenes/settings_screen.tscn` + `scenes/settings_screen.gd`

#### 노드 계층
```
SettingsScreen (Control) ← 스크립트 연결
├── Background (ColorRect) ── 어두운 보라색
└── CenterContainer
    └── VBoxContainer (min_size: 600x0, separation: 30)
        ├── Title (Label) ── "설정", font_size=36
        ├── MusicRow (HBoxContainer)
        │   ├── MusicLabel ── "음악 볼륨"
        │   └── MusicSlider (HSlider) ── 0~1, step 0.05
        ├── SoundRow (HBoxContainer)
        │   ├── SoundLabel ── "효과음 볼륨"
        │   └── SoundSlider (HSlider) ── 0~1, step 0.05
        ├── TextSpeedRow (HBoxContainer)
        │   ├── TextSpeedLabel ── "텍스트 속도"
        │   └── TextSpeedSlider (HSlider) ── 5~60, step 5
        ├── AutoSpeedRow (HBoxContainer)
        │   ├── AutoSpeedLabel ── "오토 속도"
        │   └── AutoSpeedSlider (HSlider) ── 1~10, step 0.5
        └── BackBtn (Button) ── "돌아가기"
```

#### 스크립트 분석 (settings_screen.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | 현재 설정값 로드, 시그널 연결 |
| `_on_music_changed(value)` | 음악 볼륨 변경 → 즉시 적용 + 저장 |
| `_on_sound_changed(value)` | 효과음 볼륨 변경 → 즉시 적용 + 저장 |
| `_on_text_speed_changed(value)` | 텍스트 속도 변경 → 저장 |
| `_on_auto_speed_changed(value)` | 오토 속도 변경 → 저장 |
| `_on_back()` | 타이틀 화면으로 복귀 |

**의존성:** GameManager, AudioManager

#### 발견된 문제점

- 슬라이더에 커스텀 스타일 없음 (다른 화면과 시각적 불일치)
- 슬라이더 변경 시마다 `apply_volumes()` + `save_settings()` 호출 → 디바운스 없음
- 설정 키 문자열 (`"music_volume"` 등) 하드코딩 → 상수 분리 권장

#### 평가: **양호**

---

### 5. save_load_screen (세이브/로드 화면)

**파일:** `scenes/save_load_screen.tscn` + `scenes/save_load_screen.gd`

#### 노드 계층
```
SaveLoadScreen (Control) ← 스크립트 연결
├── Background (ColorRect) ── 어두운 보라색, alpha 0.9
└── VBoxContainer
    ├── TopBar (HBoxContainer)
    │   ├── Title (Label) ── "세이브"
    │   ├── ModeToggle (Button, toggle) ── "로드 모드"
    │   └── BackBtn (Button) ── "돌아가기"
    └── ScrollContainer
        └── Grid (GridContainer) ── 3열
```

#### 스크립트 분석 (save_load_screen.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | 시그널 연결, 슬롯 UI 빌드 |
| `set_mode(load_mode)` | 외부에서 세이브/로드 모드 설정 |
| `set_return_scene(path)` | 복귀할 씬 경로 설정 |
| `_update_title()` | 모드에 따라 타이틀/토글 텍스트 변경 |
| `_build_slots()` | 5개 세이브 슬롯 동적 생성 (메타데이터 표시) |
| `_on_slot_pressed(slot)` | 세이브 또는 로드 실행 |
| `_on_back()` | 이전 화면으로 복귀 |

**의존성:** GameManager, AudioManager, StoryManager

#### 발견된 문제점

- 한국어 문자열 하드코딩 (`"로드"`, `"세이브"`, `"슬롯"`, `"비어 있음"`)
- 로드 실패 시 사용자 피드백 없음
- `"MainScene"` 노드 이름으로 검색 → 씬 계층 변경 시 깨질 수 있음
- 색상 값 하드코딩

#### 평가: **보통**

---

### 6. MenuButton 컴포넌트

**파일:** `scenes/components/MenuButton.tscn` + `scenes/components/MenuButton.gd`

#### 노드 계층
```
MenuButton (Button)
  └── size_flags_horizontal = 3 (Fill + Expand)
  └── 스크립트: StyledMenuButton
```

#### 스크립트 분석 (MenuButton.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | StyleBoxFlat 생성 (normal, hover), 클릭 사운드 연결, 반응형 폰트 설정 |
| `_update_font_size()` | 뷰포트 높이 기준 폰트 크기 계산 (viewport_h * 0.03, 16~36px) |

**클래스명:** `StyledMenuButton`
**의존성:** AudioManager

#### 발견된 문제점

- `pressed`, `disabled`, `focus` 상태 스타일 누락 → 기본 테마와 불일치
- 색상 값 전부 하드코딩

#### 평가: **양호**

---

### 7. TitleHeader 컴포넌트

**파일:** `scenes/components/TitleHeader.tscn` + `scenes/components/TitleHeader.gd`

#### 노드 계층
```
TitleHeader (VBoxContainer)
  └── 스크립트: TitleHeader
  └── 자식 노드는 _ready()에서 동적 생성
```

#### 스크립트 분석 (TitleHeader.gd)

| 함수 | 역할 |
|------|------|
| `_ready()` | Label 2개 + Spacer 동적 생성, 반응형 폰트 설정 |
| `_update_font_size()` | 타이틀 viewport_h * 0.08 (36~96px), 서브타이틀 viewport_h * 0.03 (14~32px) |

**클래스명:** `TitleHeader`
**@export 변수:** `title_text`, `subtitle_text`
**의존성:** 없음

#### 발견된 문제점

- **tscn 파일 오타:** `fomat=3` → `format=3` 수정 필요 (파싱 에러 가능)
- 자식 노드를 모두 코드에서 생성 → 에디터에서 시각적 확인 불가
- Spacer 높이 40px 고정 → 반응형 아님

#### 평가: **보통**

---

## 전체 요약 테이블

| 파일 | 타입 | 함수 수 | 의존성 | 등급 | 주요 이슈 |
|------|------|---------|--------|------|-----------|
| title_screen | 씬+스크립트 | 6 | 3개 오토로드 | 양호 | 이어하기 실패 피드백 없음, 스타일 중복 |
| main_scene | 씬+스크립트 | 33+ | 4개 오토로드 | 보통 | 파일 과대, Supabase 미완성, 매직 넘버 |
| gallery_screen | 씬+스크립트 | 7 | 2개 오토로드 | 양호 | 에셋 경로 하드코딩, 에러 처리 부재 |
| settings_screen | 씬+스크립트 | 6 | 2개 오토로드 | 양호 | 슬라이더 스타일 없음, 디바운스 없음 |
| save_load_screen | 씬+스크립트 | 8 | 3개 오토로드 | 보통 | 노드명 하드코딩, 로드 실패 피드백 없음 |
| MenuButton | 컴포넌트 | 2 | 1개 오토로드 | 양호 | pressed/disabled 스타일 누락 |
| TitleHeader | 컴포넌트 | 2 | 없음 | 보통 | tscn 오타, 동적 생성 과다 |

---

## 공통 이슈 및 개선 권장사항

### 긴급 (즉시 수정)

1. **TitleHeader.tscn 오타** — `fomat=3` → `format=3` 수정. Godot 파싱 오류 발생 가능
2. **AffinityHint 노드 중복** — main_scene.tscn의 UILayer와 OverlayLayer에 동일 이름 존재. 의도적인지 확인 필요

### 구조 개선 (중기)

3. **main_scene.gd 분할** — 33개 이상 함수가 한 파일에 집중. 대화 시스템, 선택지, Supabase, 세이브/로드 등을 별도 클래스로 분리 권장
4. **Supabase 통합 완성 또는 제거** — `_display_stats_preview()`, `_show_stats_result()` 미완성 함수 정리
5. **상태 머신 도입** — `_typing`, `_auto_mode`, `_skip_mode`, `_distraction_free` bool 플래그 → enum 기반 상태 머신으로 전환

### 일관성 개선 (장기)

6. **테마 리소스 통합** — 각 스크립트에서 독립적으로 StyleBoxFlat을 생성하는 대신, 공통 Theme 리소스(`.tres`)로 통합
7. **색상/스타일 상수화** — 하드코딩된 색상값을 상수 또는 리소스로 분리
8. **에러 피드백** — `_on_continue()`, `_on_slot_pressed()` 등에서 실패 시 사용자에게 시각적 피드백 추가
9. **로컬라이제이션 준비** — 하드코딩된 한국어 문자열을 Godot의 `tr()` 함수 또는 상수로 분리
10. **settings_screen 슬라이더 디바운스** — 값 변경 시마다 저장하는 대신, 화면 나갈 때 한 번 저장하는 방식 고려

### 컴포넌트 개선

11. **MenuButton** — `pressed`, `disabled`, `focus` 상태 스타일 추가
12. **TitleHeader** — 자식 노드를 tscn에 정적으로 배치하고, 스크립트는 반응형 로직만 담당하도록 변경
13. **BackButton 컴포넌트화** — gallery, settings, save_load 모두 "돌아가기" 버튼을 개별 스타일링 → 공통 컴포넌트로 분리 가능
