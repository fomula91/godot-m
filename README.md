# 사쿠라 학원 - 봄날의 이야기 🌸

Godot 4.6 기반 비주얼 노벨 게임. 사쿠라 학원을 배경으로 펼쳐지는 5일간의 이야기를 선택과 호감도에 따라 다양한 결말로 경험할 수 있습니다.

## 기술 스택

| 항목 | 사양 |
|------|------|
| 엔진 | Godot 4.6 |
| 렌더러 | GL Compatibility (모바일 지원) |
| 물리 엔진 | Jolt Physics 3D |
| 스크립트 | GDScript |
| 해상도 | 1920×1080 |

## 프로젝트 구조

```
├── scripts/
│   └── autoload/           # 싱글톤 매니저
│       ├── StoryManager.gd     # 스토리 엔진 (JSON 파싱, 분기, 명령 실행)
│       ├── GameManager.gd      # 게임 상태, 세이브/로드, 갤러리
│       └── AudioManager.gd     # BGM 크로스페이드, SFX 재생
├── scenes/
│   ├── title_screen.tscn       # 타이틀 화면
│   ├── main_scene.tscn         # 메인 게임플레이 (VN 엔진)
│   ├── gallery_screen.tscn     # CG 갤러리
│   ├── save_load_screen.tscn   # 세이브/로드
│   └── settings_screen.tscn    # 설정
├── story/
│   ├── day1/ ~ day5/           # JSON 스토리 데이터 (17개 파일)
├── assets/
│   ├── backgrounds/            # 배경 이미지 (45+)
│   ├── characters/             # 캐릭터 스프라이트 (26장)
│   ├── gallery/                # CG 갤러리 이미지 (24장)
│   ├── music/                  # BGM (6곡)
│   └── sounds/                 # 효과음 (2개)
└── tools/
    └── convert_stories.py      # Monogatari → Godot JSON 변환기
```

## 주요 기능

### VN 엔진
- JSON 기반 스토리 데이터로 대사, 나레이션, 선택지 표시
- 8종 이상의 전환 효과 (fadeIn, slideInLeft, bounceIn 등)
- 캐릭터 스프라이트 표시/전환 (위치, 표정 변경)
- BGM 크로스페이드 및 효과음 재생

### 분기 시스템
- 170+ 스토리 라벨을 통한 복잡한 분기 구조
- 조건부 점프 (`AND`, `OR`, 비교 연산자 지원)
- 12개 주요 결정 포인트 추적

### 호감도 시스템
- 소라(Sora), 하나(Hana) 별도 호감도 관리
- 선택에 따른 호감도 변동 및 시각적 피드백
- 호감도 기반 조건부 스토리 분기

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

## 캐릭터

| 코드 | 이름 | 설명 |
|------|------|------|
| p | 하루 (Haru) | 플레이어 캐릭터 (이름 변경 가능) |
| s | 소라 (Sora) | 디렉터/아티스트 |
| h | 하나 (Hana) | 숨겨진 면모를 가진 캐릭터 |
| u | ??? (Yuu) | 미스터리 캐릭터 |

## 스토리 구조

5일간의 학원 생활을 통해 캐릭터들과의 관계를 쌓아갑니다.

```
Day 1: 프롤로그, 캐릭터 소개, 첫 번째 선택
Day 2: 관계 심화, 루트 분기 시작
Day 3: 갈등과 전환점
Day 4: 루트별 클라이맥스
Day 5: 결말 (소라 루트 / 하나 루트 / 함께 루트)
```

각 Day는 공통(common) 파트와 캐릭터별(sora, hana, together) 파트로 구성됩니다.

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
