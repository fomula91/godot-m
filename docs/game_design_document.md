# 게임 기획 문서

## 너를 이해하기엔, 봄이 너무 짧았다

> 비주얼 노벨 | Godot 4.6 | GL Compatibility
>
> project-m(웹/Monogatari)에서 Godot 4.6으로 마이그레이션한 프로젝트. 스토리는 새롭게 작성됨.

---

## 1. 게임 개요

### 1.1 컨셉

"너를 이해하기엔, 봄이 너무 짧았다"는 고등학교 2학년 봄을 배경으로 한 **학원 로맨스 비주얼 노벨**이다. 플레이어는 강현우의 시점에서 혼자 지내는 소녀 이수아에게 다가가며, 선택에 따라 두 사람의 관계가 변화하는 과정을 경험한다.

### 1.2 장르 및 플랫폼

| 항목 | 내용 |
|------|------|
| 장르 | 비주얼 노벨 (선택지 분기형) |
| 엔진 | Godot 4.6 (GL Compatibility 렌더러) |
| 해상도 | 1920 x 1080 (canvas_items 스트레치) |
| 타겟 플랫폼 | PC (Windows/Mac), 모바일 대응 가능 |
| 스크립트 언어 | GDScript |
| 예상 플레이 타임 | 1회차 약 30~50분, 전 엔딩 수집 약 2~3시간 |

### 1.3 핵심 키워드

- **거리감** — 다가감과 물러섬 사이의 미묘한 감정선
- **이해** — 타인의 아픔을 진정으로 이해한다는 것의 의미
- **용기** — 상처를 두려워하면서도 다시 다가가는 것

---

## 2. 스토리

### 2.1 시놉시스

고등학교 2학년 봄, 주인공 강현우는 항상 혼자 지내는 같은 반 여학생 이수아에게 "같이 먹을래?"라는 가벼운 말을 건넨다. 그것이 두 사람의 관계의 시작이었다.

4월 내내 학교생활 속에서 조금씩 가까워지던 두 사람. 하지만 5월, 시내 나들이를 계기로 수아는 갑자기 현우를 피하기 시작한다. 수아에게는 중학교 시절 유일한 친구 '채원'과 멀어진 상처가 있었고, 현우를 좋아하게 되면서 "또 멀어질까봐" 스스로 벽을 쌓은 것이었다.

현우는 균열이 생긴 관계를 포기하지 않고 조심스럽게 다가가며, 7월 방학 직전 수아의 진심 고백을 듣게 된다. 이 순간 현우가 어떤 말을 건네느냐에 따라 세 가지 엔딩으로 갈린다.

### 2.2 시간 흐름

| 시기 | 파트명 | 내용 |
|------|--------|------|
| 4월 초 | 프롤로그 | 첫 만남 — "같이 먹을래?" |
| 4월 | 4월 허브 | 학교 일상 이벤트 (최소 4개 선택) |
| 5월 | 균열 파트 도입 | 시내 나들이 후 수아의 회피 시작 |
| 5~6월 | 균열 파트 | 방과후, 점심, 체육대회, 기말고사, 생일 |
| 7월 | 클라이맥스 | 수아의 과거 고백 + 최종 선택 |
| 여름방학 | 엔딩 | 선택에 따른 세 가지 결말 |

### 2.3 등장인물

#### 강현우 (플레이어 캐릭터)

- **역할**: 주인공 / 시점 인물
- **성격**: 사교적이고 무난한 성격. 게임을 좋아하고 친구도 많지만, 혼자 있는 수아에게 자연스럽게 다가갈 줄 아는 따뜻한 면이 있다.
- **스프라이트**: **[미정]** — 플레이어 캐릭터의 스프라이트 표시 여부 및 표정 종류 결정 필요
- **캐릭터 ID**: `p`
- **이름 색상**: #ffa726 (주황)

#### 이수아

- **역할**: 히로인
- **성격**: 극도로 내성적이고 낯을 많이 가린다. 중학교 때 유일한 친구 채원과 멀어진 후 혼자 지내게 되었다. 직접 도시락을 싸오고, 로맨스 소설을 좋아하며, 거절을 잘 못 하는 솔직한 면이 있다. 현우를 좋아하게 되지만 "또 멀어질까봐" 스스로 피하게 된다.
- **표정**: normal, happy, shy, surprised, worried (5종)
- **캐릭터 ID**: `sua`
- **이름 색상**: #e87ba1 (핑크)

#### 채원 (미등장)

- 수아의 중학교 시절 유일한 친구. 고등학교 진학 후 반이 달라지며 자연스럽게 멀어졌다. 수아의 트라우마의 원인이 되는 인물이지만, 실제로는 수아를 여전히 친구로 여기고 있었다.

---

## 3. 게임 시스템

### 3.1 핵심 메커니즘: 거리감 (Distance)

게임의 핵심 시스템은 **거리감** 수치이다.

| 항목 | 값 |
|------|-----|
| 초기값 | 50 |
| 범위 | 0 (가장 가까움) ~ 100 (가장 멀음) |
| 게임 오버 조건 | distance >= 80 |
| 진행 조건 | april_events >= 4 AND distance < 80 |

플레이어의 선택에 따라 거리감이 증감하며, 수아와의 심리적 거리를 수치로 표현한다.

#### 거리감 변화표

| 이벤트 | 선택지 | 변화량 |
|--------|--------|--------|
| 자리배정 | 반갑게 인사한다 | -5 |
| 자리배정 | 친구와 대화한다 | +15 |
| 자리배정 | 취미를 묻는다 | -15 |
| 조별수업 | 나서서 정해준다 | -5 |
| 조별수업 | 역할을 묻는다 | +5 |
| 수학시간 | 시간 내서 가르쳐줌 | -15 |
| 수학시간 | 식 풀이만 알려줌 | -5 |
| 보지 않았다 | (단일) | -15 |
| 점심시간 | 같이 먹자 제안 | -15 |
| 점심시간 | 음료수 사줌 | -5 |
| 수학여행 | 같이 다녔다 | -15 |
| 수학여행 | 힐끗 봤다 | +5 |

> **디자인 의도**: "보지 않았다"가 대폭 가까워지는(-15) 이유는 억지로 다가가지 않는 것이 수아에게 부담을 주지 않기 때문이다. 반면 "친구와 대화한다"(+15)는 수아가 자신과 다른 세계의 사람이라고 느끼게 만든다.

### 3.2 호감도 알림

선택 후 거리감 변화 시 화면에 짧은 알림이 표시된다.

| 방향 | 아이콘 | 메시지 |
|------|--------|--------|
| 가까워짐 | ♡ | "수아와의 거리가 가까워진 것 같다." |
| 멀어짐 | ... | "수아와의 거리가 멀어진 것 같다." |

알림은 1.4초 표시 후 0.4초에 걸쳐 페이드아웃된다.

### 3.3 게임 변수

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `player.name` | String | "" | 플레이어 이름 (프롤로그에서 입력) |
| `distance` | int | 50 | 수아와의 거리감 |
| `april_events` | int | 0 | 4월 이벤트 완료 횟수 |
| `crack_progress` | int | 0 | 균열 파트 진행도 |
| `ending_type` | String | "" | 도달한 엔딩 타입 (a/b/c/gameover) |

### 3.4 선택지 통계 시스템

추적 대상 씬에서 플레이어가 선택을 하면, Supabase API를 통해 다른 플레이어들의 선택 비율을 확인할 수 있다. 선택 후 2.5초간 통계가 표시된다.

**추적 대상 씬**: SeatAssignment, GroupProject, MathClass, LunchTime, SchoolTrip, CrackAfterSchool, CrackLunchTime, CrackSportsFest, CrackExam, JulyChoice

---

## 4. 스토리 분기 구조

### 4.1 전체 흐름도

```
Start (프롤로그)
  └─ AprilHub (4월 허브 / 이벤트 선택)
       ├─ SeatAssignment (자리배정) ─┐
       ├─ GroupProject (조별수업) ───┤
       ├─ MathClass (수학시간) ─────┤
       ├─ DidNotLook (보지 않았다) ──┤ → [조건 분기]
       ├─ LunchTime (점심시간) ─────┤
       └─ SchoolTrip (수학여행) ────┘
                                      │
              ┌────────────────────────┘
              │
              ├─ distance >= 80 ────────→ GameOver
              ├─ april_events >= 4 ────→ CrackIntro (균열 파트)
              └─ else ─────────────────→ AprilHub (반복)

CrackIntro (5월 — 시내 나들이)
  └─ CrackAfterSchool (방과후)
       └─ CrackLunchTime (급식시간)
            └─ CrackSportsFest (체육대회)
                 └─ CrackExam (기말고사)
                      └─ CrackBirthday (현우 생일)
                           └─ JulyIntro (7월)
                                └─ JulyChoice (최종 선택)
                                     ├─ 선택 A → EndingA
                                     ├─ 선택 B → EndingB
                                     └─ 선택 C → EndingC
```

### 4.2 4월 이벤트 상세

4월 허브에서 플레이어는 6가지 이벤트 중 하나를 선택한다. 각 이벤트는 2단계 선택지로 구성되어 있다.

| 이벤트 | 1차 선택지 | 2차 선택지 |
|--------|-----------|-----------|
| 자리배정 | 인사 / 친구대화 / 취미질문 | 게임 / 과자 / 가위바위보 |
| 조별수업 | 역할 정해줌 / 역할 물어봄 | 발표경험 / PPT질문 |
| 수학시간 | 직접 가르침 / 힌트만 제공 | 잘하는 과목 / 수포자 질문 |
| 보지 않았다 | (선택지 없음, 단일 경로) | — |
| 점심시간 | 같이 먹자 / 음료수 제공 | 도시락 질문 / 급식 질문 |
| 수학여행 | 같이 다님 / 힐끗 관찰 | 배달 / 남자애들 화제 |

이벤트 종료마다 `april_events`가 +1 되며, 4회 이상 완료 시 균열 파트로 진행한다.

### 4.3 균열 파트 상세

5월부터 시작되는 균열 파트는 수아가 현우를 피하기 시작한 이후의 이야기다. 선형적으로 진행되며, 각 이벤트에서 선택지가 주어진다.

| 순서 | 이벤트 | 선택지 |
|------|--------|--------|
| 1 | 방과후 | 직접 물어봄 / 이름 불러봄 |
| 2 | 급식시간 | 도시락 나눠 먹기 / 내일도 오겠다 |
| 3 | 체육대회 | 같이 앉기 / 응원하자 |
| 4 | 기말고사 | (선택지 없음, 수아가 먼저 다가옴) |
| 5 | 현우 생일 | (선택지 없음, 수아의 선물) |

### 4.4 엔딩 분기

7월 최종 선택에서 세 가지 엔딩으로 분기된다.

| 엔딩 | 최종 선택 | 결과 | 톤 |
|------|----------|------|-----|
| **엔딩 A** — "있잖아…!" | "말 없이 멀어지지 않을게" | 수아가 먼저 약속을 잡고, 채원에게도 다시 연락한다. 가장 긍정적인 결말. | 희망적, 따뜻함 |
| **엔딩 B** — "그렇게 말해줘서 고마워" | "절대 그럴 일 없어" | 수아가 소중한 인형을 선물하며 작은 고백을 한다. 감정적이지만 불확실한 미래. | 달콤쌉싸름 |
| **엔딩 C** — "이해란 어려운 것" | "다 이해해" | 수아가 "비슷한 삶을 살지 않으면 이해할 수 없다"고 거부하고 멀어진다. | 씁쓸, 성찰적 |
| **게임 오버** | (4월 거리감 초과) | 수아가 의도적으로 피하기 시작하고 인연이 끊긴다. | 절망적 |

> **엔딩 A 보너스**: 엔딩 A 달성 시 수아의 회상 독백이 추가로 재생된다. 조별과제, 수학여행, 기말고사 등 과거 이벤트에 대한 수아의 속마음을 들을 수 있다.

---

## 5. UI / UX 디자인

### 5.1 화면 구성

```
┌──────────────────────────────────────────┐
│             BackgroundLayer              │
│  ┌──────────────────────────────────┐    │
│  │  Background1 / Background2      │    │
│  └──────────────────────────────────┘    │
│                                          │
│             CharacterLayer               │
│  [LeftSlot]  [CenterSlot]  [RightSlot]   │
│                                          │
│             UILayer                      │
│  ┌──────────────────────────────────┐    │
│  │  CenteredText                   │    │
│  ├──────────────────────────────────┤    │
│  │  ChoicePanel (선택지 버튼)       │    │
│  ├──────────────────────────────────┤    │
│  │  DialogueBox                    │    │
│  │  ┌─ NameLabel ──────────────┐   │    │
│  │  │  TextLabel (타이핑 효과)  │   │    │
│  │  └─────────────────────────┘   │    │
│  ├──────────────────────────────────┤    │
│  │  QuickMenu [Save][Load]        │    │
│  │            [Auto][Skip][설정]   │    │
│  └──────────────────────────────────┘    │
│                                          │
│             OverlayLayer                 │
│  TransitionRect / AffinityHint /         │
│  InputDialog                             │
└──────────────────────────────────────────┘
```

### 5.2 색상 팔레트

| 용도 | 색상 | 값 |
|------|------|-----|
| 대화창 배경 | 짙은 보라 | rgba(20, 10, 30, 0.82) |
| 대화창 테두리 | 연분홍 | rgba(244, 143, 177, 0.2) |
| 버튼 호버 | 진보라 | rgba(40, 20, 60, 0.95) |
| 버튼 호버 테두리 | 밝은 핑크 | rgba(244, 143, 177, 0.8) |
| 현우 이름 | 주황 | #ffa726 |
| 수아 이름 | 핑크 | #e87ba1 |

### 5.3 텍스트 시스템

- **타이핑 효과**: 글자가 한 글자씩 나타남 (속도 조절 가능, 기본 20ms/글자)
- **클릭 시 즉시 완성**: 타이핑 중 클릭하면 전체 텍스트 즉시 표시
- **오토 모드**: 텍스트 완성 후 설정된 시간(기본 5초) 대기 후 자동 진행
- **스킵 모드**: 0.05초 간격으로 빠르게 진행
- **템플릿 변수**: `{{player.name}}` 형식으로 플레이어 이름 등 동적 삽입

### 5.4 입력 방식

| 액션 | 입력 |
|------|------|
| 텍스트 진행 (vn_advance) | 마우스 좌클릭 / Enter / Space |
| 스킵 (vn_skip) | Escape |

---

## 6. 씬 및 화면 목록

### 6.1 메뉴 씬

| 씬 | 파일 | 설명 |
|-----|------|------|
| 타이틀 화면 | title_screen.tscn | 시작, 이어하기, 갤러리, 설정 |
| 설정 화면 | settings_screen.tscn | 음악/효과음/텍스트속도/오토속도 조절 |
| 세이브/로드 | save_load_screen.tscn | 10개 슬롯, 세이브/로드 모드 전환 |
| 갤러리 | gallery_screen.tscn | 해금된 CG 이미지 감상 |
| 메인 플레이 | main_scene.tscn | VN 본편 진행 |

### 6.2 배경 목록 (필요 에셋)

| ID | 장소 | 시간대 | 파일명 |
|----|------|--------|--------|
| school_front_morning | 학교 정문 | 아침 | school_front_morning.webp |
| school_front_day | 학교 정문 | 낮 | school_front_day.webp |
| school_front_evening | 학교 정문 | 저녁 | school_front_evening.webp |
| classroom_morning | 교실 | 아침 | classroom_morning.webp |
| classroom_day | 교실 | 낮 | classroom_day.webp |
| classroom_afternoon | 교실 | 오후 | classroom_afternoon.webp |
| classroom_evening | 교실 | 저녁 | classroom_evening.webp |
| cafeteria_day | 급식실 | 낮 | cafeteria_day.webp |
| lunch_spot | 점심 장소 (그늘) | 낮 | lunch_spot.webp |
| hallway_day | 복도 | 낮 | hallway_day.webp |
| hallway_evening | 복도 | 저녁 | hallway_evening.webp |
| school_grounds_day | 운동장 | 낮 | school_grounds_day.webp |
| school_grounds_evening | 운동장 | 저녁 | school_grounds_evening.webp |
| city_day | 시내 | 낮 | city_day.webp |
| city_evening | 시내 | 저녁 | city_evening.webp |
| jeju_scenery | 제주도 풍경 | — | jeju_scenery.webp |
| jeju_lodging | 제주도 숙소 | 밤 | jeju_lodging.webp |
| sports_festival | 체육대회 | 낮 | sports_festival.webp |

> 배치 경로: `assets/backgrounds/`

---

## 7. 에셋

### 7.1 최종 필요 에셋

에셋은 전부 교체 예정이다. 아래는 코드에서 참조하는 최종 파일 사양이다.

#### 캐릭터 스프라이트

| 캐릭터 | 폴더 | 필요 파일 | 상태 |
|--------|------|----------|------|
| 이수아 | `assets/characters/sua/` | sua_normal.webp, sua_happy.webp, sua_shy.webp, sua_surprised.webp, sua_worried.webp (5종) | 교체 예정 |
| 강현우 | `assets/characters/hyunwoo/` | **[미정]** — 스프라이트 표시 여부 결정 후 확정 | 미정 |

#### 갤러리 CG (13종)

| ID | 파일명 | 해금 시점 |
|----|--------|-----------|
| first-lunch | first_lunch.webp | 프롤로그 — 첫 만남 |
| seat-assignment | seat_assignment.webp | 자리배정 이벤트 진입 |
| group-project | group_project.webp | 조별수업 이벤트 진입 |
| math-class | math_class.webp | 수학시간 이벤트 진입 |
| jeju-together | jeju_together.webp | 수학여행 이벤트 진입 |
| jeju-delivery | jeju_delivery.webp | 수학여행 — 배달 선택 |
| sports-festival | sports_festival.webp | 체육대회 이벤트 진입 |
| birthday-gift | birthday_gift.webp | 현우 생일 이벤트 진입 |
| city-outing | city_outing.webp | 균열 파트 도입 |
| sua-confession | sua_confession.webp | 7월 — 수아의 고백 |
| ending-a | ending_a.webp | 엔딩 A 진입 |
| ending-b | ending_b.webp | 엔딩 B 진입 |
| ending-c | ending_c.webp | 엔딩 C 진입 |

> 배치 경로: `assets/gallery/`

#### BGM (7종)

| 스크립트 ID | 용도 | 파일명 | 상태 |
|------------|------|--------|------|
| bgm_daily | 일상 장면 | bgm_daily.mp3 | 교체 예정 |
| bgm_peaceful | 평화로운 장면, 수학여행 | bgm_peaceful.mp3 | 교체 예정 |
| bgm_melancholy | 균열 파트, 기말고사 | bgm_melancholy.mp3 | 교체 예정 |
| bgm_lively | 체육대회 | bgm_lively.mp3 | 교체 예정 |
| bgm_ending_a | 엔딩 A | bgm_ending_a.mp3 | 교체 예정 |
| bgm_ending_b | 엔딩 B | bgm_ending_b.mp3 | 교체 예정 |
| bgm_ending_c | 엔딩 C | bgm_ending_c.mp3 | 교체 예정 |

> 배치 경로: `assets/music/`

#### 효과음 (3종, 유지 가능)

| 파일명 | 용도 |
|--------|------|
| Select.mp3 | UI 클릭음 |
| Footsteps.mp3 | 발걸음 소리 |
| Japanese_School_Bell.mp3 | 학교 종소리 |

### 7.2 현재 임시 에셋 현황

현재 프로젝트에는 project-m(웹 버전)의 에셋이 임시로 들어있다. **코드가 참조하는 파일명과 모두 불일치**하므로 게임을 실행하려면 에셋 교체가 선행되어야 한다.

| 종류 | 현재 임시 에셋 | 코드 참조 |
|------|--------------|----------|
| 캐릭터 | hana, sora, haru, unknown (4폴더) | hyunwoo, sua (2폴더) |
| 배경 | classroom_01~04, Auditorium 등 37종 | classroom_morning, school_front 등 18종 |
| 갤러리 | hana-confession, sora-warm 등 24종 | first_lunch, seat_assignment 등 13종 |
| BGM | sunny-day, acoustic-chill 등 5곡 | bgm_daily, bgm_peaceful 등 7곡 |

---

## 8. 시스템 기능

### 8.1 세이브/로드

- **슬롯 수**: 10개 (슬롯 1~10, 슬롯 0은 사용하지 않음)
- **저장 형식**: JSON 파일 (`user://saves/slot_N.json`)
- **저장 데이터**: 게임 상태, 갤러리 해금, 현재 라벨/라인, 배경, 캐릭터 위치, BGM, 타임스탬프
- **오버레이 모달**: 퀵 메뉴의 Save/Load 버튼 클릭 시 `save_load_screen.tscn`이 CanvasLayer(25)에 모달로 표시
- **확인 다이얼로그**: 슬롯 클릭 시 커스텀 확인 패널 표시 (로드: "로드하시겠습니까?", 세이브 덮어쓰기: "덮어쓰시겠습니까?"). 빈 슬롯 세이브는 확인 없이 즉시 저장
- **데이터 수집**: `save_load_screen.gd`에서 main_scene 노드를 직접 참조하여 배경/캐릭터/BGM/스토리 데이터 수집
- **로드 시 상태 리셋**: `StoryManager.restore_from_save()`에서 `_advance_id` 증가, `_waiting`/`_choice_pending` 리셋으로 기존 타이머 무효화 및 상태 충돌 방지
- **오버레이 로드 순서**: 시그널 연결 해제 → `_on_modal_closed()` 호출(모달 상태 정리) → `_restore_state()` → `queue_free()` 순서로 실행
- **이어하기**: 타이틀 화면에서 세이브/로드 화면 진입 후 슬롯 선택

### 8.2 설정

| 설정 항목 | 기본값 | 범위 |
|----------|--------|------|
| 음악 볼륨 | 1.0 | 0.0 ~ 1.0 |
| 효과음 볼륨 | 1.0 | 0.0 ~ 1.0 |
| 텍스트 속도 | 20ms/글자 | 슬라이더 |
| 오토 속도 | 5초 | 슬라이더 (반전 로직: `10.5 - value`) |
| 화면 모드 | 창모드 | 창모드 / 전체화면(창모드) / 전체화면 |
| 해상도 | 1920x1080 | 3840x2160, 2560x1440, 1920x1080, 1600x900, 1280x720, 960x540 (6단계) |

설정은 `user://settings.json`에 자동 저장된다. 화면 모드와 해상도 변경은 `GameManager.apply_display_settings()`를 통해 즉시 적용된다.

### 8.3 갤러리

- **총 CG**: 13장
- **해금 조건**: 스토리 진행 중 특정 장면 도달 시 자동 해금
- **열람**: 썸네일 그리드 → 클릭 시 전체화면 뷰어
- **잠금 상태**: "?" 표시의 어두운 패널
- **데이터 저장**: `user://gallery.json`에 영구 저장

### 8.4 모달 시스템

설정 화면과 세이브/로드 화면은 VN 플레이 중 오버레이 모달로 동작한다.

| 항목 | 내용 |
|------|------|
| CanvasLayer | layer=25 (OverlayLayer(20) 위) |
| 열기 | 퀵메뉴 Settings/Save/Load 버튼 |
| Auto/Skip 동작 | 모달 열기 시 일시정지, 닫을 때 이전 상태 복원 |
| 퀵메뉴 | 모달 열린 동안 Save/Load/Settings 버튼 비활성화 |
| 입력 차단 | `_unhandled_input`에서 `_active_modal != NONE` 시 무시 |
| 닫기 | 모달 내 "뒤로" 버튼 → `queue_free()` → `tree_exiting` 시그널 → `_on_modal_closed()` |
| 중복 호출 방지 | `_on_modal_closed()`에서 `_active_modal == NONE` 가드로 이미 정리된 상태 재처리 방지 |

### 8.5 오디오 시스템

- **오디오 버스**: Music, SFX (런타임에 자동 생성)
- **크로스페이드**: BGM 전환 시 1초간 크로스페이드 적용
- **페이드아웃**: 음악 정지 시 서서히 볼륨 감소

---

## 9. 연출 시스템

### 9.1 캐릭터 트랜지션

| 효과 | 설명 |
|------|------|
| fadeIn | 0.5초 페이드인 |
| fadeInUp | 페이드인 + 아래에서 위로 30px 이동 |
| slideInLeft/Right | 좌/우에서 200px 슬라이드 |
| bounceIn | 0.8 → 1.0 스케일 바운스 + 페이드인 |
| fadeOut | 0.5초 페이드아웃 |
| fadeOutLeft/Right | 페이드아웃 + 좌/우로 100px 이동 |

### 9.2 배경 전환

| 효과 | 설명 |
|------|------|
| instant | 즉시 전환 |
| fadeIn | 1초간 크로스페이드 |
| fade_scene | 검은 화면으로 페이드 → 배경 교체 → 페이드 복귀 |
| fade_jump | 검은 화면으로 페이드 → 다른 라벨로 점프 |

### 9.3 기타 연출

- **중앙 텍스트**: 화면 중앙에 대형 텍스트 표시 (시간/장소 전환 등)
- **산만 방지 모드**: 대화창과 퀵메뉴를 숨기고 배경/CG만 표시
- **이름 입력**: 프롤로그에서 플레이어 이름 입력 다이얼로그

---

## 10. 기술 아키텍처

### 10.1 싱글턴 (Autoload)

| 이름 | 파일 | 역할 |
|------|------|------|
| GameManager | game_manager.gd | 상태 관리, 세이브/로드, 설정, 갤러리, 템플릿 치환 |
| AudioManager | audio_manager.gd | BGM/SFX 재생, 크로스페이드, 볼륨 관리 |
| StoryManager | story_manager.gd | JSON 스토리 로드, 명령 디스패치, 라벨 점프, 조건 분기 |
| DebugOverlay | debug_overlay.gd | 디버그 오버레이 (F3 토글, FPS/플랫폼 표시, Auto 모드 상태, 이벤트 로그, 파일 로깅) |

### 10.2 스토리 데이터 구조

스토리는 JSON 파일로 작성되며, `res://story/` 하위 폴더에 저장된다. `story/` 디렉토리 구조 생성 완료. `april/opening.json` 작성됨. 나머지 파트(`may/`, `crack/`, `july/`)는 미생성.

```
story/
  ├─ april/     # 4월 이벤트 (프롤로그, 허브, 각 이벤트)
  ├─ may/       # 균열 파트
  ├─ crack/     # 균열 상세 이벤트
  └─ july/      # 7월 클라이맥스 + 엔딩
```

#### JSON 명령어 체계

| 명령 | 기능 | 예시 |
|------|------|------|
| dialogue | 캐릭터 대사 | `{"cmd":"dialogue","character":"sua","text":"..."}` |
| narration | 내레이션 | `{"cmd":"narration","text":"..."}` |
| centered | 중앙 텍스트 | `{"cmd":"centered","text":"4월의 어느 날"}` |
| show_scene | 배경 전환 | `{"cmd":"show_scene","id":"classroom_day"}` |
| show_character | 캐릭터 표시 | `{"cmd":"show_character","id":"sua","sprite":"normal","position":"center"}` |
| hide_character | 캐릭터 숨김 | `{"cmd":"hide_character","id":"sua"}` |
| change_sprite | 표정 변경 | `{"cmd":"change_sprite","id":"sua","sprite":"happy"}` |
| choice | 선택지 | `{"cmd":"choice","dialog":"...","choices":[...]}` |
| jump | 라벨 이동 | `{"cmd":"jump","target":"AprilHub"}` |
| fade_jump | 페이드+이동 | `{"cmd":"fade_jump","target":"EndingA"}` |
| fade_scene | 페이드 배경전환 | `{"cmd":"fade_scene","id":"classroom_day"}` |
| set_var | 변수 설정 | `{"cmd":"set_var","path":"distance","value":5,"op":"sub"}` |
| conditional | 조건 분기 | `{"cmd":"conditional","branches":[...]}` |
| input | 텍스트 입력 | `{"cmd":"input","prompt":"이름을 입력하세요"}` |
| play_music | BGM 재생 | `{"cmd":"play_music","id":"bgm_daily"}` |
| stop_music | BGM 정지 | `{"cmd":"stop_music","fade":1.0}` |
| play_sound | 효과음 | `{"cmd":"play_sound","id":"Select"}` |
| wait | 대기 | `{"cmd":"wait","duration":1000}` |
| gallery_unlock | 갤러리 해금 | `{"cmd":"gallery_unlock","id":"first-lunch"}` |
| affinity_hint | 거리감 알림 | `{"cmd":"affinity_hint","character":"closer"}` |
| distraction_free | 산만방지 토글 | `{"cmd":"distraction_free"}` |
| end | 게임 종료 | `{"cmd":"end"}` |

### 10.3 시그널 흐름

컨트롤러별 분산 구독 구조로 리팩토링 완료. 각 레이어 스크립트가 StoryManager 시그널을 직접 구독한다.

```
StoryManager (JSON 파싱/디스패치)
    │
    │  DialogueController (dialogue_controller.gd)
    ├── dialogue_requested ──→ DialogueController._on_dialogue()
    ├── narration_requested ─→ DialogueController._on_narration()
    ├── centered_requested ──→ DialogueController._on_centered()
    │
    │  BackgroundController (background_controller.gd)
    ├── scene_change_requested → BackgroundController._on_scene_change()
    │
    │  CharacterController (character_controller.gd)
    ├── character_show_requested → CharacterController._on_show()
    ├── character_hide_requested → CharacterController._on_hide()
    ├── character_sprite_changed → CharacterController._on_sprite_change()
    │
    │  OverlayController (overlay_controller.gd)
    ├── fade_requested ─────→ OverlayController._on_fade()
    ├── wait_requested ─────→ OverlayController._on_wait()
    ├── input_requested ────→ OverlayController._on_input_request()
    ├── affinity_hint_requested → OverlayController._on_affinity_hint()
    │
    │  MainScene (main_scene.gd — 조율자)
    ├── choice_requested ───→ MainScene._on_choice()
    ├── gallery_unlock_requested → MainScene._on_gallery_unlock()
    ├── distraction_free_toggled → MainScene._on_distraction_free()
    └── end_requested ──────→ MainScene._on_end()

GameManager (상태 변화)
    ├── state_changed ──────→ (미사용, 확장 가능)
    └── gallery_item_unlocked → (미사용, 확장 가능)
```

---

## 11. 에셋 교체 로드맵

### 11.1 제작 파이프라인

에셋 교체 시 아래 순서로 작업한다.

```
[ ] 1. 캐릭터 스프라이트 제작 → assets/characters/sua/ 배치
[ ] 2. 강현우 스프라이트 방향 결정 (표시 여부, 표정 종류)
[ ] 3. 배경 이미지 제작 (18종) → assets/backgrounds/ 배치
[ ] 4. 갤러리 CG 제작 (13종) → assets/gallery/ 배치
[ ] 5. BGM 제작/교체 (7곡) → assets/music/ 배치
[ ] 6. story_manager.gd 캐릭터 매핑 확인/수정
[ ] 7. gallery_screen.gd 매핑 확인/수정
[ ] 8. 스토리 JSON 생성 (script_full.md → story/*.json 변환)
[ ] 9. 전체 플레이 테스트
```

### 11.2 에셋 교체 시 수정 필요 파일

| 에셋 종류 | 수정 파일 | 수정 위치 |
|----------|----------|----------|
| 캐릭터 스프라이트 | `scripts/autoload/story_manager.gd` | `characters` Dictionary (24~34행) |
| 배경 이미지 | `scripts/autoload/story_manager.gd` | `scene_map` Dictionary (37~78행) |
| 갤러리 CG | `scenes/gallery_screen.gd` | `GALLERY_IDS`, `GALLERY_FILES` (1~23행) |
| 갤러리 CG (씬 연결) | `scripts/autoload/story_manager.gd` | `scene_map` 내 CG 항목 (65~78행) |
| BGM | 스토리 JSON 파일들 | 각 `play_music` 명령의 `id` 값 |
| 타이틀 배경 | `scenes/title_screen.gd` | `_ready()` 내 배경 로드 경로 (12행) |
| 타이틀 BGM | `scenes/title_screen.gd` | `_ready()` 내 `play_music()` 호출 (17행) |

### 11.3 에셋 네이밍 규칙

코드에서 정의된 파일명 규칙:

- **캐릭터**: `{캐릭터ID}_{표정}.webp` (예: `sua_normal.webp`)
- **배경**: `{장소}_{시간대}.webp` (예: `classroom_morning.webp`)
- **갤러리**: `{이벤트명}.webp` (예: `first_lunch.webp`)
- **BGM**: `{ID}.mp3` (예: `bgm_daily.mp3`)
- **포맷**: 이미지 `.webp`, 음악 `.mp3`

### 11.4 향후 개선 가능 사항

- 대화 로그 화면 (백로그) UI 구현
- 캐릭터 blinking 애니메이션
- 모바일 터치 최적화 (스와이프 제스처 등)
- 다국어 지원 (텍스트 외부화)
- 엔딩 회수 화면 (전체 엔딩 달성률 표시)

---

## 부록: 프로젝트 파일 구조

```
godot-porject-m/
├── project.godot              # 엔진 설정
├── CLAUDE.md                  # AI 개발 가이드
│
├── scenes/                    # 씬 및 UI 스크립트
│   ├── main_scene.tscn/gd    # VN 메인 플레이 화면
│   ├── title_screen.tscn/gd  # 타이틀 화면
│   ├── settings_screen.tscn/gd # 설정 화면 (오버레이 모달 지원)
│   ├── save_load_screen.tscn/gd # 세이브/로드 (오버레이 모달 지원)
│   ├── gallery_screen.tscn/gd # 갤러리
│   ├── controller/            # 레이어별 컨트롤러
│   │   ├── dialogue_controller.gd   # 대화창/타이핑
│   │   ├── character_controller.gd  # 캐릭터 표시/애니메이션
│   │   ├── background_controller.gd # 배경 전환
│   │   └── overlay_controller.gd    # 페이드/입력/거리감 알림
│   └── components/            # 재사용 컴포넌트
│       ├── MenuButton.tscn/gd
│       └── TitleHeader.tscn/gd
│
├── scripts/autoload/          # 싱글턴
│   ├── game_manager.gd       # 상태/세이브/설정 관리
│   ├── story_manager.gd      # 스토리 엔진
│   ├── audio_manager.gd      # 오디오 관리
│   └── debug_overlay.gd      # 디버그
│
├── story/                     # 스토리 JSON 데이터
│   ├── april/                 # 4월 이벤트 (opening.json 작성 완료)
│   ├── may/                   # 5월 (균열 도입, 미생성)
│   ├── crack/                 # 균열 상세 (미생성)
│   └─ july/                  # 7월 + 엔딩 (미생성)
│
├── assets/                    # ⚠ 현재 임시 에셋 (전부 교체 예정)
│   ├── backgrounds/           # 배경 이미지 (.webp)
│   ├── characters/            # 캐릭터 스프라이트
│   ├── gallery/               # CG 이미지
│   ├── music/                 # BGM (.mp3)
│   └── sounds/                # 효과음 (.mp3)
│
├── addons/
│   ├── godot_mcp/             # MCP 플러그인
│   └── godot_ai_bridge/       # AI 브릿지
│
└── docs/                      # 문서
    ├── game_design_document.md # 본 문서
    └── script_full.md         # 전체 스크립트
```
