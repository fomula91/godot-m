# Plan: 게임 전체 기획

> Feature: game-full-plan
> Created: 2026-03-09
> Status: Draft

---

## Executive Summary

| 항목 | 내용 |
|------|------|
| Feature | 너를 이해하기엔, 봄이 너무 짧았다 - 전체 게임 기획 |
| 시작일 | 2026-03-09 |
| 예상 범위 | 스토리 JSON 변환, 에셋 교체, 시스템 완성, QA |

### Value Delivered

| 관점 | 내용 |
|------|------|
| **Problem** | 기획/시나리오/시스템 문서가 7개 이상 분산되어 있어 전체 파악이 어렵고, 구현 진행 상황과 남은 작업을 한눈에 볼 수 없음 |
| **Solution** | 전체 게임 기획을 하나의 구조화된 문서로 통합하여 개발 로드맵을 명확히 함 |
| **Function UX Effect** | 분산된 기획을 통합 참조할 수 있어 개발 효율성 향상 |
| **Core Value** | 완성도 높은 학원 로맨스 비주얼 노벨을 체계적으로 개발할 수 있는 기반 마련 |

---

## 1. 게임 개요

### 1.1 컨셉

**"너를 이해하기엔, 봄이 너무 짧았다"** — 고등학교 2학년 봄을 배경으로 한 학원 로맨스 비주얼 노벨. 플레이어(강현우)가 혼자 지내는 소녀 이수아에게 다가가며, 선택에 따라 관계가 변화하는 감정 중심의 이야기.

### 1.2 기본 사양

| 항목 | 내용 |
|------|------|
| 장르 | 비주얼 노벨 (선택지 분기형) |
| 엔진 | Godot 4.6 (GL Compatibility) |
| 해상도 | 1920x1080 (canvas_items 스트레치) |
| 플랫폼 | PC (Windows/Mac), 모바일 대응 가능 |
| 스크립트 | GDScript |
| 플레이 타임 | 1회차 30~50분, 전 엔딩 수집 2~3시간 |

### 1.3 핵심 키워드

- **거리감** — 다가감과 물러섬 사이의 미묘한 감정선
- **이해** — 타인의 아픔을 진정으로 이해한다는 것의 의미
- **용기** — 상처를 두려워하면서도 다시 다가가는 것

---

## 2. 등장인물

### 2.1 강현우 (플레이어)

| 항목 | 내용 |
|------|------|
| 나이 | 18세 (2학년) |
| 생일 | 6월 |
| 취미 | 게임 (데이드림 트레인) |
| 말투 | 편안한 반말 |
| 캐릭터 ID | `p` |
| 이름 색상 | #ffa726 (주황) |
| 스프라이트 | 미정 (표시 여부 결정 필요) |

**성격**: 사교적이고 무난. 반 대부분과 친하나 특별히 깊은 관계는 적음. 수학/암기 과목 선호, 국어(작가의 의도) 싫어함. **깊은 이야기를 무의식적으로 회피**하는 성향 — 수아와의 관계를 통해 성장.

### 2.2 이수아 (히로인)

| 항목 | 내용 |
|------|------|
| 나이 | 18세 (2학년) |
| 생일 | 7월 (방학 도중) |
| 취미 | 로맨스 소설, 인형, 망상 |
| 말투 | 자주 더듬는 반말 |
| 캐릭터 ID | `sua` |
| 이름 색상 | #e87ba1 (핑크) |
| 표정 | normal, happy, shy, surprised, worried (5종) |

**성격**: 극도로 내성적. 중학교 때 유일한 친구 채원과 멀어진 트라우마로 혼자 지냄. **애정결핍을 망상과 인형으로 해소**. 거절을 잘 못 하고, 좋아하게 되면 오히려 피함. 직접 도시락을 싸오고, 국어를 잘함.

### 2.3 박채원 (미등장 배경 인물)

수아의 중학교 시절 유일한 친구. 고등학교 진학 후 새 친구를 사귀며 자연스럽게 멀어짐. 정작 채원은 수아를 여전히 친구로 여기고 있음. 수아의 트라우마 원인이자, 엔딩 A에서 관계 회복의 열쇠.

---

## 3. 스토리 구조

### 3.1 전체 시간 흐름

| 시기 | 파트 | 내용 | 선택지 구조 |
|------|------|------|------------|
| 4월 초 | 프롤로그 | 첫 만남 — "같이 먹을래?" | 이름 입력 |
| 4월 | 4월 허브 | 학교 일상 이벤트 (6종 중 최소 4개 선택) | 허브 선택 → 1차 선택 → 2차 선택 |
| 5월 | 균열 도입 | 시내 나들이 후 수아의 회피 시작 | 선형 |
| 5~6월 | 균열 파트 | 방과후, 점심, 체육대회, 기말고사, 생일 | 각 이벤트 선택지 |
| 7월 | 클라이맥스 | 수아의 과거 고백 + 최종 선택 | 3지 선다 |
| 여름방학 | 엔딩 | 선택에 따른 3가지 결말 + 게임오버 | — |

### 3.2 분기 흐름도

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
              ├─ distance >= 80 → GameOver
              ├─ april_events >= 4 AND distance < 80 → CrackIntro
              └─ else → AprilHub (반복)

CrackIntro (5월 — 시내 나들이)
  └─ CrackAfterSchool → CrackLunchTime → CrackSportsFest
       → CrackExam → CrackBirthday → JulyIntro

JulyChoice (최종 선택)
  ├─ "말 없이 멀어지지 않을게" → EndingA (희망적)
  ├─ "절대 그럴 일 없어" → EndingB (달콤쌉싸름)
  └─ "다 이해해" → EndingC (씁쓸)
```

### 3.3 4월 이벤트 상세 (허브 구조)

| 이벤트 | 1차 선택지 | 거리감 변화 | 2차 선택지 |
|--------|-----------|------------|-----------|
| **자리배정** | 반갑게 인사 / 친구와 대화 / 취미 질문 | -5 / +15 / -15 | 게임 / 과자 / 가위바위보 |
| **조별수업** | 나서서 정해줌 / 역할 물어봄 | -5 / +5 | 발표 경험 / PPT 질문 |
| **수학시간** | 시간 내서 가르침 / 힌트만 제공 | -15 / -5 | 잘하는 과목 / 수포자 질문 |
| **보지 않았다** | (단일 경로) | -15 | — |
| **점심시간** | 같이 먹자 제안 / 음료수 사줌 | -15 / -5 | 도시락 질문 / 급식 질문 |
| **수학여행** | 같이 다님 / 힐끗 관찰 | -15 / +5 | 배달 / 남자애들 화제 |

### 3.4 균열 파트 상세 (선형 구조)

| 순서 | 이벤트 | 선택지 |
|------|--------|--------|
| 1 | 방과후 | "혹시 내가 뭐 실수해서 그래?" / "수아야." |
| 2 | 급식시간 | "나도 하나 먹어도 돼?" / "내일도 여기서 먹자." |
| 3 | 체육대회 | "옆에 같이 앉는다" / "같이 힘내자" |
| 4 | 기말고사 | (선택지 없음 — 수아가 먼저 다가옴) |
| 5 | 현우 생일 | (선택지 없음 — 수아의 선물) |

### 3.5 엔딩 분기

| 엔딩 | 최종 선택 | 톤 | 특이사항 |
|------|----------|-----|---------|
| **A — "있잖아…!"** | "말 없이 멀어지지 않을게" | 희망적, 따뜻함 | 보너스: 수아 회상 독백 |
| **B — "그렇게 말해줘서 고마워"** | "절대 그럴 일 없어" | 달콤쌉싸름 | 인형 선물, 열린 결말 |
| **C — "이해란 어려운 것"** | "다 이해해" | 씁쓸, 성찰적 | 관계 단절 |
| **Game Over** | (4월 거리감 초과) | 절망적 | distance >= 80 |

---

## 4. 게임 시스템

### 4.1 핵심 메커니즘: 거리감 (Distance)

| 항목 | 값 |
|------|-----|
| 초기값 | 50 |
| 범위 | 0 (가장 가까움) ~ 100 (가장 멀음) |
| 게임 오버 조건 | distance >= 80 |
| 진행 조건 | april_events >= 4 AND distance < 80 |

> **디자인 의도**: 억지로 다가가지 않는 것(보지 않았다 = -15)이 오히려 수아에게 부담을 주지 않음. 친구와 대화(+15)는 수아가 "다른 세계 사람"이라 느끼게 만듦.

### 4.2 게임 변수

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `player.name` | String | "" | 플레이어 이름 (프롤로그 입력) |
| `distance` | int | 50 | 수아와의 거리감 |
| `april_events` | int | 0 | 4월 이벤트 완료 횟수 |
| `crack_progress` | int | 0 | 균열 파트 진행도 |
| `ending_type` | String | "" | 도달한 엔딩 타입 |

### 4.3 호감도 알림

| 방향 | 아이콘 | 메시지 | 표시 시간 |
|------|--------|--------|----------|
| 가까워짐 | ♡ | "수아와의 거리가 가까워진 것 같다." | 1.4초 + 0.4초 페이드 |
| 멀어짐 | ... | "수아와의 거리가 멀어진 것 같다." | 1.4초 + 0.4초 페이드 |

### 4.4 선택지 통계 시스템

Supabase API를 통해 다른 플레이어의 선택 비율 확인 가능. 선택 후 2.5초간 표시.

**추적 대상 씬**: SeatAssignment, GroupProject, MathClass, LunchTime, SchoolTrip, CrackAfterSchool, CrackLunchTime, CrackSportsFest, CrackExam, JulyChoice

---

## 5. UI/UX 설계

### 5.1 화면 레이어 구조

```
BackgroundLayer     ← 배경 이미지 (Background1 / Background2)
CharacterLayer      ← 캐릭터 스프라이트 (Left / Center / Right)
UILayer             ← CenteredText, ChoicePanel, DialogueBox, QuickMenu
OverlayLayer(20)    ← TransitionRect, AffinityHint, InputDialog
ModalLayer(25)      ← Settings, SaveLoad (오버레이 모달)
```

### 5.2 색상 팔레트

| 용도 | 색상 | 값 |
|------|------|-----|
| 대화창 배경 | 짙은 보라 | rgba(20, 10, 30, 0.82) |
| 대화창 테두리 | 연분홍 | rgba(244, 143, 177, 0.2) |
| 버튼 호버 | 진보라 | rgba(40, 20, 60, 0.95) |
| 현우 이름 | 주황 | #ffa726 |
| 수아 이름 | 핑크 | #e87ba1 |

### 5.3 텍스트 시스템

| 기능 | 사양 |
|------|------|
| 타이핑 효과 | 20ms/글자 (속도 조절 가능) |
| 클릭 즉시 완성 | 타이핑 중 클릭 시 전체 표시 |
| 오토 모드 | 텍스트 완성 후 5초 대기 후 자동 진행 |
| 스킵 모드 | 0.05초 간격 빠른 진행 |
| 템플릿 변수 | `{{player.name}}` 형식 |

### 5.4 입력 매핑

| 액션 | 입력 |
|------|------|
| 텍스트 진행 | 마우스 좌클릭 / Enter / Space |
| 스킵 | Escape |

---

## 6. 연출 시스템

### 6.1 캐릭터 트랜지션

| 효과 | 설명 |
|------|------|
| fadeIn | 0.5초 페이드인 |
| fadeInUp | 페이드인 + 아래에서 30px 이동 |
| slideInLeft/Right | 좌/우에서 200px 슬라이드 |
| bounceIn | 0.8→1.0 스케일 바운스 |
| fadeOut | 0.5초 페이드아웃 |
| fadeOutLeft/Right | 페이드아웃 + 좌/우로 100px |

### 6.2 배경 전환

| 효과 | 설명 |
|------|------|
| instant | 즉시 전환 |
| fadeIn | 1초 크로스페이드 |
| fade_scene | 검은 화면 → 배경 교체 → 복귀 |
| fade_jump | 검은 화면 → 다른 라벨 점프 |

### 6.3 기타 연출

- **중앙 텍스트**: 시간/장소 전환 표시
- **산만 방지 모드**: 대화창+퀵메뉴 숨기고 배경/CG만 표시
- **이름 입력**: 프롤로그 플레이어 이름 입력

---

## 7. 기술 아키텍처

### 7.1 싱글턴 (Autoload)

| 이름 | 파일 | 역할 |
|------|------|------|
| GameManager | game_manager.gd | 상태 관리, 세이브/로드, 설정, 갤러리 |
| AudioManager | audio_manager.gd | BGM/SFX 재생, 크로스페이드 |
| StoryManager | story_manager.gd | JSON 스토리 로드, 명령 디스패치 |
| DebugOverlay | debug_overlay.gd | F3 디버그 오버레이 |

### 7.2 컨트롤러 구조

```
StoryManager (JSON 파싱/디스패치)
  ├── DialogueController  ← dialogue, narration, centered
  ├── BackgroundController ← scene_change
  ├── CharacterController  ← show, hide, sprite_change
  ├── OverlayController    ← fade, wait, input, affinity_hint
  └── MainScene (조율자)   ← choice, gallery_unlock, end
```

### 7.3 스토리 데이터 (JSON)

```
story/
  ├─ april/     ← opening.json (작성 완료)
  ├─ may/       ← (미생성)
  ├─ crack/     ← (미생성)
  └─ july/      ← (미생성)
```

### 7.4 JSON 명령어 체계

| 명령 | 기능 |
|------|------|
| dialogue | 캐릭터 대사 |
| narration | 내레이션 |
| centered | 중앙 텍스트 |
| show_scene / fade_scene | 배경 전환 |
| show_character / hide_character | 캐릭터 표시/숨김 |
| change_sprite | 표정 변경 |
| choice | 선택지 분기 |
| jump / fade_jump | 라벨 이동 |
| set_var | 변수 설정 |
| conditional | 조건 분기 |
| input | 텍스트 입력 |
| play_music / stop_music | BGM |
| play_sound | 효과음 |
| wait | 대기 |
| gallery_unlock | 갤러리 해금 |
| affinity_hint | 거리감 알림 |
| distraction_free | 산만방지 토글 |
| end | 게임 종료 |

---

## 8. 시스템 기능

### 8.1 세이브/로드

- 10개 슬롯 (`user://saves/slot_N.json`)
- JSON 저장: 게임 상태, 갤러리, 라벨/라인, 배경, 캐릭터, BGM, 타임스탬프
- 오버레이 모달 (CanvasLayer 25)
- 확인 다이얼로그: 로드/세이브 덮어쓰기 시 커스텀 확인 패널 표시 (빈 슬롯 세이브는 즉시 저장)
- 로드 시 StoryManager 상태 리셋 (`_advance_id`, `_waiting`, `_choice_pending`) 으로 크래시 방지
- 오버레이 로드 시 모달 상태 선정리 후 복원 (시그널 해제 → `_on_modal_closed()` → `_restore_state()`)

### 8.2 설정

| 항목 | 기본값 | 범위 |
|------|--------|------|
| 음악 볼륨 | 1.0 | 0.0~1.0 |
| 효과음 볼륨 | 1.0 | 0.0~1.0 |
| 텍스트 속도 | 20ms/글자 | 슬라이더 |
| 오토 속도 | 5초 | 슬라이더 (반전: 10.5 - value) |
| 화면 모드 | 창모드 | 창모드/전체화면(창모드)/전체화면 |
| 해상도 | 1920x1080 | 6단계 |

### 8.3 갤러리 (13장 CG)

| ID | 해금 시점 |
|----|-----------|
| first_lunch | 프롤로그 — 첫 만남 |
| seat_assignment | 자리배정 진입 |
| group_project | 조별수업 진입 |
| math_class | 수학시간 진입 |
| jeju_together | 수학여행 진입 |
| jeju_delivery | 수학여행 — 배달 선택 |
| sports_festival | 체육대회 진입 |
| birthday_gift | 현우 생일 진입 |
| city_outing | 균열 파트 도입 |
| sua_confession | 7월 — 수아의 고백 |
| ending_a / ending_b / ending_c | 각 엔딩 진입 |

### 8.4 오디오

- 오디오 버스: Music, SFX (런타임 자동 생성)
- BGM 크로스페이드: 1초
- 페이드아웃: 점진적 볼륨 감소

---

## 9. 에셋 현황 및 교체 계획

### 9.1 현재 상태

> **모든 에셋은 교체 예정**. 현재는 project-m(웹 버전)의 임시 에셋으로, 코드가 참조하는 파일명과 **전부 불일치**.

| 종류 | 현재 임시 | 코드 참조 (최종) |
|------|----------|----------------|
| 캐릭터 | hana, sora 등 4폴더 | sua (5종), hyunwoo (미정) |
| 배경 | 37종 (불일치) | 18종 |
| 갤러리 | 24종 (불일치) | 13종 |
| BGM | 5곡 (불일치) | 7곡 |
| 효과음 | 3종 | 3종 (유지 가능) |

### 9.2 필요 에셋 목록

**캐릭터 스프라이트**
- 이수아: `sua_normal.webp`, `sua_happy.webp`, `sua_shy.webp`, `sua_surprised.webp`, `sua_worried.webp` (5종)
- 강현우: 미정 (표시 여부 결정 필요)

**배경 이미지 (18종)**
- 학교: school_front (아침/낮/저녁), classroom (아침/낮/오후/저녁), cafeteria_day, lunch_spot, hallway (낮/저녁), school_grounds (낮/저녁)
- 시내: city (낮/저녁)
- 제주도: jeju_scenery, jeju_lodging
- 체육대회: sports_festival

**BGM (7곡)**: bgm_daily, bgm_peaceful, bgm_melancholy, bgm_lively, bgm_ending_a/b/c

**갤러리 CG (13종)**: first_lunch ~ ending_c

### 9.3 에셋 네이밍 규칙

- 캐릭터: `{ID}_{표정}.webp` (예: `sua_normal.webp`)
- 배경: `{장소}_{시간대}.webp` (예: `classroom_morning.webp`)
- 갤러리: `{이벤트명}.webp` (예: `first_lunch.webp`)
- BGM: `{ID}.mp3` / 효과음: `{이름}.mp3`

---

## 10. 개발 로드맵

### 10.1 현재 구현 완료 항목

- [x] 엔진 기본 설정 (Godot 4.6, GL Compatibility)
- [x] 싱글턴 4종 (GameManager, AudioManager, StoryManager, DebugOverlay)
- [x] 메인 씬 레이아웃 (main_scene.tscn)
- [x] 컨트롤러 분리 (Dialogue, Background, Character, Overlay)
- [x] 타이틀 화면, 설정 화면, 세이브/로드, 갤러리
- [x] 모달 시스템 (설정/세이브로드 오버레이)
- [x] JSON 명령어 체계 (22종 커맨드)
- [x] 오토/스킵 모드
- [x] 화면 설정 (해상도/화면모드)
- [x] 디버그 오버레이 (F3)
- [x] 스토리 JSON: `april/opening.json` (프롤로그)
- [x] story/ 디렉토리 구조

### 10.2 미완료 작업

#### Phase 1: 에셋 제작/수급 (블로커)
- [ ] 이수아 캐릭터 스프라이트 5종 제작
- [ ] 강현우 스프라이트 방향 결정 (표시 여부, 표정)
- [ ] 배경 이미지 18종 제작
- [ ] 갤러리 CG 13종 제작
- [ ] BGM 7곡 제작/수급
- [ ] 에셋 배치 및 파일명 매핑 확인

#### Phase 2: 스토리 JSON 변환
- [ ] `april/april_hub.json` — 4월 허브
- [ ] `april/seat_assignment.json` — 자리배정
- [ ] `april/group_project.json` — 조별수업
- [ ] `april/math_class.json` — 수학시간
- [ ] `april/did_not_look.json` — 보지 않았다
- [ ] `april/lunch_time.json` — 점심시간
- [ ] `april/school_trip.json` — 수학여행
- [ ] `may/crack_intro.json` — 균열 도입
- [ ] `crack/after_school.json` — 방과후
- [ ] `crack/lunch_time.json` — 급식시간
- [ ] `crack/sports_fest.json` — 체육대회
- [ ] `crack/exam.json` — 기말고사
- [ ] `crack/birthday.json` — 현우 생일
- [ ] `july/intro.json` — 7월 도입
- [ ] `july/choice.json` — 최종 선택
- [ ] `july/ending_a.json` — 엔딩 A (+ 엔딩 코멘트)
- [ ] `july/ending_b.json` — 엔딩 B
- [ ] `july/ending_c.json` — 엔딩 C
- [ ] `july/game_over.json` — 게임 오버

#### Phase 3: 시스템 보완
- [x] 세이브/로드 확인 다이얼로그 추가 (로드/덮어쓰기 확인)
- [x] 로드 크래시 수정 (StoryManager 상태 리셋, 모달 정리 순서)
- [ ] 선택지 통계 시스템 (Supabase 연동)
- [ ] 4월 이벤트 중복 선택 방지 (허브 UI에 완료 표시)
- [ ] 조건 분기(conditional) 동작 검증
- [ ] 엔딩 A 보너스 회상 분기 구현

#### Phase 4: QA 및 마무리
- [ ] 전체 플레이스루 테스트 (4개 엔딩 경로)
- [ ] 거리감 밸런스 검증 (게임오버 난이도 조절)
- [ ] 세이브/로드 정합성 테스트
- [ ] 갤러리 해금 테스트 (13종 전부)
- [ ] 오디오 크로스페이드/볼륨 테스트

#### Phase 5: 향후 개선 (Optional)
- [ ] 대화 로그 화면 (백로그) UI
- [ ] 캐릭터 blinking 애니메이션
- [ ] 모바일 터치 최적화 (스와이프)
- [ ] 다국어 지원
- [ ] 엔딩 회수 화면 (달성률)

---

## 11. 참조 문서 매핑

| 문서 | 내용 | 본 Plan 섹션 |
|------|------|-------------|
| `game_design_document.md` | 종합 기획서 | 전체 |
| `스토리_및_시놉시스.md` | 상세 스토리/시놉시스 | 3. 스토리 구조 |
| `강현우시트.md` | 현우 캐릭터 시트 | 2.1 강현우 |
| `이수아시트.md` | 수아/채원 캐릭터 시트 | 2.2, 2.3 |
| `script_full.md` | 전체 스크립트 (JSON 변환 원본) | 10.2 Phase 2 |
| `시나리오_선택지_분기_전체.md` | 자리배정 이벤트 상세 대본 | 3.3 |
| `시나리오_오프닝_첫만남_확장본.md` | 오프닝/첫만남 확장 대본 | 3.1 프롤로그 |
| `비주얼노벨_시나리오_스크립트_초안.md` | 시나리오 작성 원칙/초안 | 스토리 전반 |
| `main_scene_analysis.md` | 메인 씬 분석 | 7. 기술 아키텍처 |

---

## 12. 주요 의사결정 필요 항목

| # | 항목 | 현재 상태 | 영향 범위 |
|---|------|----------|----------|
| 1 | **강현우 스프라이트 표시 여부** | 미정 | 에셋 제작, story_manager 캐릭터 매핑 |
| 2 | **프롤로그 구조** | script_full.md와 오프닝 확장본에 차이 있음 (확장본이 더 상세) | opening.json 재작성 여부 |
| 3 | **균열 파트 게임오버 조건** | 스토리 문서에 "정답을 골라야 하고, 실패 시 게임오버" 언급 | distance 외 별도 조건 필요 여부 |
| 4 | **선택지 통계 시스템** | Supabase 연동 계획 | 서버 비용, 오프라인 대응 |
| 5 | **수아 표정 종류** | game_design_document에 5종, script_full.md에 6종 (sad 추가) | 스프라이트 제작 수량 |
