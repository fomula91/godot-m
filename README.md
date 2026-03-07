# 너를 이해하기엔, 봄이 너무 짧았다

Godot 4.6 기반 비주얼 노벨 게임. 봄에서 여름으로 이어지는 학교생활 속에서 거리감과 선택에 따라 다양한 결말을 경험할 수 있습니다.

## 기술 스택

| 항목 | 사양 |
|------|------|
| 엔진 | Godot 4.6 |
| 렌더러 | GL Compatibility (모바일 지원) |
| 물리 엔진 | Jolt Physics 3D |
| 스크립트 | GDScript |
| 해상도 | 1920x1080 |

## 프로젝트 구조

```
├── scripts/
│   └── autoload/                # 싱글톤 매니저
│       ├── story_manager.gd         # 스토리 엔진 (JSON 파싱, 분기, 명령 실행)
│       ├── game_manager.gd          # 게임 상태, 세이브/로드, 갤러리
│       ├── audio_manager.gd         # BGM 크로스페이드, SFX 재생
│       └── debug_overlay.gd         # 디버그 오버레이
├── scenes/
│   ├── title_screen.tscn            # 타이틀 화면
│   ├── main_scene.tscn              # 메인 게임플레이 (VN 엔진)
│   ├── gallery_screen.tscn          # CG 갤러리
│   ├── save_load_screen.tscn        # 세이브/로드
│   ├── settings_screen.tscn         # 설정
│   ├── character_controller.gd      # 캐릭터 스프라이트 컨트롤러
│   └── components/                  # 재사용 UI 컴포넌트
│       ├── MenuButton.tscn          # 메뉴 버튼
│       └── TitleHeader.tscn         # 타이틀 헤더
├── story/
│   ├── april/                       # 4월 - 시작
│   ├── may/                         # 5월 - 전개
│   ├── crack/                       # 균열 - 갈등
│   └── july/                        # 7월 - 결말
├── assets/
│   ├── backgrounds/                 # 배경 이미지 (40장)
│   ├── characters/                  # 캐릭터 스프라이트 (25장, 4캐릭터)
│   │   ├── hana/
│   │   ├── haru/
│   │   ├── sora/
│   │   └── unknown/
│   ├── gallery/                     # CG 갤러리 이미지 (24장)
│   ├── music/                       # BGM (5곡)
│   └── sounds/                      # 효과음 (3개)
└── tools/
    └── convert_stories.py           # Monogatari -> Godot JSON 변환기
```

## 주요 기능

### VN 엔진
- JSON 기반 스토리 데이터로 대사, 나레이션, 선택지 표시
- 8종 이상의 전환 효과 (fadeIn, slideInLeft, bounceIn 등)
- 캐릭터 스프라이트 표시/전환 (위치, 표정 변경)
- BGM 크로스페이드 및 효과음 재생

### 분기 시스템
- april/may/crack/july 4개 파트로 구성된 스토리 구조
- 조건부 점프 (`AND`, `OR`, 비교 연산자 지원)
- 10개 주요 결정 포인트 추적 (SeatAssignment, GroupProject, MathClass 등)

### 거리감 시스템
- `distance` 변수로 관계 거리 관리 (0=가장 가까움, 100=가장 멀음, 기본값 50)
- 선택에 따른 거리감 변동 및 시각적 피드백
- 거리감 기반 조건부 스토리 분기

### 선택지 통계
- Supabase 연동을 통한 선택지 통계 추적
- 다른 플레이어들의 선택 비율 확인 가능

### 입력 시스템
- 커스텀 입력 매핑 (vn_advance, vn_skip)
- 마우스 클릭, Enter, Space로 대사 진행
- Ctrl로 스킵

### 갤러리
- 24개 CG 이벤트 이미지 수집
- 스토리 진행 중 자동 해금
- 전체화면 뷰어 지원

### 세이브/로드
- 10개 세이브 슬롯 + 퀵세이브
- 전체 게임 상태 저장/복원 (변수, 캐릭터 위치, BGM 등)

### UI
- 퀵 메뉴 (저장, 불러오기, 자동 진행, 스킵, 설정)
- 텍스트 속도 및 자동 진행 속도 조절
- 방해 없는 모드 (UI 숨김)
- 디버그 오버레이 (개발 중 상태 확인)

## 캐릭터

| 코드 | 이름 | 설명 |
|------|------|------|
| p | 플레이어 | 주인공 (이름 입력 가능) |
| sua | 이수아 | 메인 히로인 |
| friend | 친구 | 친구 캐릭터 |

## 스토리 구조

4월부터 7월까지의 학교생활을 통해 관계를 쌓아갑니다.

```
April  : 프롤로그, 캐릭터 소개, 첫 만남
May    : 관계 심화, 이벤트 전개
Crack  : 균열과 갈등, 전환점
July   : 결말 분기
```

### 엔딩 타입
- **Ending A** - 거리감에 따른 결말
- **Ending B** - 거리감에 따른 결말
- **Ending C** - 거리감에 따른 결말
- **Game Over** - 게임 오버

## 실행 방법

### Godot 에디터에서 실행
1. Godot 4.6 에디터를 설치합니다
2. 프로젝트를 열고 `project.godot`을 임포트합니다
3. `F5`로 전체 실행 또는 `F6`으로 현재 씬 실행

### 커맨드라인 실행
```bash
# 에디터 모드
godot --path . --editor

# 게임 실행
godot --path .
```

## 데이터 저장 경로

- 세이브: `user://saves/slot_X.json`
- 설정: `user://settings.json`
- 갤러리: `user://gallery.json`
