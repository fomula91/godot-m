# 에셋 카탈로그

> 프로젝트의 모든 에셋 파일 목록, scene_map/characters 매핑, 스토리 내 사용처 정리

---

## 1. 에셋 통계 요약

| 카테고리 | 파일 수 | 위치 |
|---------|---------|------|
| 배경 (backgrounds) | 40개 | `assets/backgrounds/` |
| 캐릭터 스프라이트 | 26개 | `assets/characters/` |
| CG 갤러리 | 24개 | `assets/gallery/` |
| BGM | 5곡 | `assets/music/` |
| 효과음 | 3개 | `assets/sounds/` |
| **합계** | **98개** | - |

---

## 2. 배경 (Backgrounds) - 40개

### 2.1 장소별 분류

#### 학교 정문 / 운동장 (5개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `school_front_early` | `early01.webp` | 이른 아침 | Day2Start, Day5 각 루트 |
| `school_front_day` | `day01.webp` | 낮 | Prologue, Day4Start |
| `school_grounds_early` | `early02.webp` | 이른 아침 | Day3Start |
| `school_grounds_day` | `day02.webp` | 낮 | Day2Start, Day4Start, Day5 각 루트 |
| `school_grounds_evening` | `evening02.webp` | 저녁 | Day1Afternoon, Day2 저녁들, Day3 클라이맥스 |

#### 교실 1 (3개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `classroom_day` | `classroom_01_day.webp` | 낮 | SchoolArrival, Day1UnknownHint, LunchTime, Day2WithSora/Hana, Day4Morning |
| `classroom_afternoon` | `classroom_01_afternoon.webp` | 오후 | Day1Afternoon, Day2Evening |
| `classroom_night` | `classroom_01_night.webp` | 밤 | (bedroom_night 별칭으로도 등록) |

#### 교실 2 (3개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `classroom2_morning` | `classroom_02_morning.webp` | 아침 | MorningEvent, Day2Morning |
| `classroom2_evening` | `classroom_02_evening.webp` | 저녁 | Day2SoraEvening |
| `classroom2_afternoon` | `classroom_02_afternoon.webp` | 오후 | - |

#### 교실 3 (3개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `classroom3_morning` | `classroom_03_morning.webp` | 아침 | Library |
| `classroom3_afternoon` | `classroom_03_afternoon.webp` | 오후 | Day3SoraRoute, Day4SoraAfternoon, Day5 소라 |
| `classroom3_evening` | `classroom_03_evening.webp` | 저녁 | SoraTrueLoveEnd |

#### 교실 4 (3개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `classroom4_morning` | `classroom_04_morning.webp` | 아침 | HelpSora, Day3BothHigh, Day3Balanced |
| `classroom4_afternoon` | `classroom_04_afternoon.webp` | 오후 | - |
| `classroom4_evening` | `classroom_04_evening.webp` | 저녁 | - |

#### 강당 외부 (5개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `auditorium_sunrise` | `Auditorium_Outside_Sunrise.webp` | 일출 | Start, Day5TogetherLetter |
| `auditorium_day` | `Auditorium_Outside_Day.webp` | 낮 | GoWithHana, Day3Start, Day3PhotoDiscovery, Day3MainBranch |
| `auditorium_noon` | `Auditorium_Outside_Noon.webp` | 정오 | Rooftop, Day3TogetherRoute, Day4TogetherAfternoon |
| `auditorium_afternoon` | `Auditorium_Outside_Afternoon.webp` | 오후 | Day3HanaRoute, Day4HanaAfternoon |
| `auditorium_evening` | `Auditorium_Outside_Evening.webp` | 저녁 | Day3SoraClimax, Day3TogetherClimax |

#### 버스 정류장 (4개)

| scene_map ID | 파일명 | 시간대 | 사용 라벨 |
|-------------|--------|--------|----------|
| `busstop_morning` | `bus_stop_morning.webp` | 아침 | - |
| `busstop_noon` | `bus_stop_noon.webp` | 정오 | - |
| `busstop_evening` | `bus_stop_evening.webp` | 저녁 | - |
| `busstop_night` | `bus_stop_night.webp` | 밤 | Day2End |

#### 과학실 (8개)

| scene_map ID | 파일명 | 사용 라벨 |
|-------------|--------|----------|
| `science_lab_01` | `school_science_lab_day01.webp` | Day2ScienceLab |
| `science_lab_02` | `school_science_lab_day02.webp` | Day4Morning |
| `science_lab_03` | `school_science_lab_day03.webp` | Day2ScienceLab |
| `science_lab_04` | `school_science_lab_day04.webp` | Day4Morning |
| `science_lab_05` | `school_science_lab_day05.webp` | Day2ScienceLab |
| `science_lab_06` | `school_science_lab_day06.webp` | - |
| `science_lab_07` | `school_science_lab_day07.webp` | - |
| `science_lab_08` | `school_science_lab_day08.webp` | - |

#### 기타 (6개)

| scene_map ID | 파일명 | 사용 라벨 |
|-------------|--------|----------|
| `swimming_pool` | `school_swimming_pool.webp` | Day4Lunch, Day5 하나 루트 |
| `another_building_day` | `another_school_building_day.webp` | Day1Afternoon |
| `afternoon01` | `afternoon01.webp` | - |
| `afternoon02` | `afternoon02.webp` | - |
| `noon01` | `noon01.webp` | - |
| `noon02` | `noon02.webp` | - |

### 2.2 scene_map 별칭

동일한 파일을 가리키는 별칭:

| 별칭 ID | 원본 ID | 파일명 |
|---------|---------|--------|
| `bedroom_night` | `classroom_night` | `classroom_01_night.webp` |
| `classroom2_evening_alt` | (독립) | `classroom_02_evening.webp` |

---

## 3. 캐릭터 스프라이트 - 26개

### 3.1 하루 (Haru) - 플레이어 `"p"` (5개)

| 표정 키 | 파일명 | 감정 |
|---------|--------|------|
| `normal` | `haru_A100.webp` | 보통 |
| `happy` | `haru_A101.webp` | 기쁨 |
| `angry` | `haru_A102.webp` | 화남 |
| `worried` | `haru_A103.webp` | 걱정 |
| `surprised` | `haru_A104.webp` | 놀람 |

**이름 색상**: `#ffa726` (주황)

### 3.2 소라 (Sora) `"s"` (6개)

| 표정 키 | 파일명 | 감정 |
|---------|--------|------|
| `normal` | `sora_A100.webp` | 보통 |
| `happy` | `sora_A101.webp` | 기쁨 |
| `angry` | `sora_A102.webp` | 화남 |
| `worried` | `sora_A103.webp` | 걱정 |
| `surprised` | `sora_A104.webp` | 놀람 |
| `angry2` | `sora_A190.webp` | 화남 (강) |

**이름 색상**: `#4a90d9` (파랑)

### 3.3 하나 (Hana) `"h"` (8개)

| 표정 키 | 파일명 | 감정 |
|---------|--------|------|
| `normal` | `hana_A100.webp` | 보통 |
| `normal2` | `hana_A200.webp` | 보통 (변형) |
| `happy` | `hana_A201.webp` | 기쁨 |
| `angry` | `hana_A202.webp` | 화남 |
| `worried` | `hana_A203.webp` | 걱정 |
| `surprised` | `hana_A204.webp` | 놀람 |
| `shy` | `hana_A199.webp` | 부끄러움 |
| `yandere` | `hana_B199.webp` | 얀데레 |

**이름 색상**: `#e87ba1` (분홍)

### 3.4 ??? (Yuu / Unknown) `"u"` (1개 등록, 6개 파일)

| 표정 키 | 파일명 | 비고 |
|---------|--------|------|
| `normal` | `unknown_B290.webp` | scene_map에 등록된 유일한 표정 |

**미등록 파일** (5개):
- `unknown_B290_A100.webp`
- `unknown_B290_A101.webp`
- `unknown_B290_A102.webp`
- `unknown_B290_A103.webp`
- `unknown_B290_A104.webp`

**이름 색상**: `#9370db` (보라), 표시 이름: `"???"`

---

## 4. CG 갤러리 - 24개

### 4.1 파일 목록 및 스토리 매핑

| # | CG ID (scene_map) | 파일명 | 해금 라벨 | Day | 갤러리 등록 ID |
|---|-------------------|--------|----------|-----|--------------|
| 1 | `opening_cg` | `opening.webp` | Prologue | 1 | `opening-unknown` |
| 2 | `silhouette_cg` | `silhouette.webp` | Day1Afternoon | 1 | `silhouette` |
| 3 | `library-sora_cg` | `library-sora.webp` | Library | 1 | `library-sora` |
| 4 | `rooftop-hana_cg` | `rooftop-hana.webp` | Rooftop | 1 | `rooftop-hana` |
| 5 | `crane-gift_cg` | `crane-gift.webp` | Day2WithSora | 2 | `crane-gift` |
| 6 | `sora-sunset-smile_cg` | `sora-sunset-smile.webp` | Day2SoraEvening | 2 | `sora-sunset-smile` |
| 7 | `hana-sunset-promise_cg` | `hana-sunset-promise.webp` | Day2HanaEvening | 2 | `hana-sunset-promise` |
| 8 | `three-walk-home_cg` | `three-walk-home.webp` | Day2NeutralEvening | 2 | `three-walk-home` |
| 9 | `busstop-silhouette_cg` | `busstop-silhouette.webp` | Day2End | 2 | `busstop-silhouette` |
| 10 | `photo-discovery_cg` | `photo-discovery.webp` | Day3PhotoDiscovery | 3 | `photo-discovery` |
| 11 | `sora-exhibition_cg` | `sora-exhibition.webp` | Day3SoraRoute | 3 | `sora-exhibition` |
| 12 | `pool-secret_cg` | `pool-secret.webp` | Day4Lunch | 4 | `pool-secret` |
| 13 | `yuu-first-meet_cg` | `yuu-first-meet.webp` | Day4MeetUnknownHigh | 4 | `yuu-first-meet` |
| 14 | `hana-unmasked_cg` | `hana-unmasked.webp` | Day4HanaAfternoon | 4 | `hana-unmasked` |
| 15 | `sora-past-tears_cg` | `sora-past-tears.webp` | Day4SoraAfternoon | 4 | `sora-past-tears` |
| 16 | `sora-confession_cg` | `sora-confession.webp` | Day5SoraLibrary | 5 | `sora-confession` |
| 17 | `sora-truelove_cg` | `sora-truelove.webp` | SoraTrueLoveEnd | 5 | `sora-truelove` |
| 18 | `sora-warm_cg` | `sora-warm.webp` | SoraWarmEnd | 5 | `sora-warm` |
| 19 | `hana-confession_cg` | `hana-confession.webp` | Day5HanaPool | 5 | `hana-confession` |
| 20 | `hana-truelove_cg` | `hana-truelove.webp` | HanaTrueLoveEnd | 5 | `hana-truelove` |
| 21 | `hana-warm_cg` | `hana-warm.webp` | HanaWarmEnd | 5 | `hana-warm` |
| 22 | `together-letter_cg` | `together-letter.webp` | Day5TogetherLetter | 5 | `together-letter` |

### 4.2 scene_map에 등록되었으나 gallery_unlock에 없는 CG 파일

| 파일명 | scene_map 등록 | 비고 |
|--------|---------------|------|
| `rooftop-sakura-rain.webp` | `rooftop-sakura-rain_cg` | 스토리에서 미사용 |
| `three-hands.webp` | `three-hands_cg` | 스토리에서 미사용 |

---

## 5. 오디오 - BGM 5곡

| ID | 파일명 | 분위기 | 재생 라벨 |
|----|--------|--------|----------|
| `sunny-day` | `sunny-day.mp3` | 밝고 상큼한 봄날 | Start |
| `acoustic-chill` | `acoustic-chill.mp3` | 잔잔한 어쿠스틱 | Day4Start |
| `sora-ending` | `sora-ending.mp3` | 소라 테마 | Day3SoraClimax, Day5SoraLibrary |
| `hana-ending` | `hana-ending.mp3` | 하나 테마 | Day3HanaClimax, Day5HanaPool |
| `harem-ending` | `harem-ending.mp3` | 함께 테마 | Day3TogetherClimax, Day5TogetherLetter |

---

## 6. 오디오 - 효과음 3개

| ID | 파일명 | 용도 | 재생 라벨 |
|----|--------|------|----------|
| `school-bell` | `Japanese_School_Bell.mp3` | 수업 종/시작 | SchoolArrival, MorningEvent, LunchTime, Day2Start, Day2Morning, Day2Evening, Day3Start, Day5 각 루트 |
| `footsteps` | `Footsteps.mp3` | 발소리 | Day1Afternoon, GoWithHana, HelpSora(?), Day2 저녁들, Day3 클라이맥스, Day4Evening |
| `Select` | `Select.mp3` | UI 클릭음 | (코드에서 직접 사용) |

---

## 7. 미사용 에셋 감사

### 7.1 scene_map에 등록되었으나 스토리 JSON에서 미참조

| scene_map ID | 파일명 | 상태 |
|-------------|--------|------|
| `busstop_morning` | `bus_stop_morning.webp` | 미사용 |
| `busstop_noon` | `bus_stop_noon.webp` | 미사용 |
| `busstop_evening` | `bus_stop_evening.webp` | 미사용 |
| `classroom2_afternoon` | `classroom_02_afternoon.webp` | 미사용 |
| `classroom4_afternoon` | `classroom_04_afternoon.webp` | 미사용 |
| `classroom4_evening` | `classroom_04_evening.webp` | 미사용 |
| `science_lab_06` | `school_science_lab_day06.webp` | 미사용 |
| `science_lab_07` | `school_science_lab_day07.webp` | 미사용 |
| `science_lab_08` | `school_science_lab_day08.webp` | 미사용 |
| `afternoon01` | `afternoon01.webp` | 미사용 |
| `afternoon02` | `afternoon02.webp` | 미사용 |
| `noon01` | `noon01.webp` | 미사용 |
| `noon02` | `noon02.webp` | 미사용 |
| `classroom_night` / `bedroom_night` | `classroom_01_night.webp` | 미사용 |
| `classroom2_evening_alt` | `classroom_02_evening.webp` | 미사용 (classroom2_evening과 별도 등록) |
| `rooftop-sakura-rain_cg` | `rooftop-sakura-rain.webp` | CG 미사용 |
| `three-hands_cg` | `three-hands.webp` | CG 미사용 |

**미사용 배경**: 15개 / 40개 (37.5%)
**미사용 CG**: 2개 / 24개 (8.3%)

### 7.2 characters에 미등록된 스프라이트 파일

| 파일명 | 캐릭터 | 비고 |
|--------|--------|------|
| `unknown_B290_A100.webp` | ??? (Yuu) | 표정 미등록 |
| `unknown_B290_A101.webp` | ??? (Yuu) | 표정 미등록 |
| `unknown_B290_A102.webp` | ??? (Yuu) | 표정 미등록 |
| `unknown_B290_A103.webp` | ??? (Yuu) | 표정 미등록 |
| `unknown_B290_A104.webp` | ??? (Yuu) | 표정 미등록 |

**제안**: 유우 캐릭터의 표정 스프라이트가 5개 추가로 존재하므로, `characters["u"]["sprites"]`에 등록하여 스토리에서 활용 가능

### 7.3 요약

| 카테고리 | 전체 | 사용 중 | 미사용 | 미사용률 |
|---------|------|--------|--------|---------|
| 배경 | 40 | 25 | 15 | 37.5% |
| CG | 24 | 22 | 2 | 8.3% |
| 캐릭터 | 26 | 21 | 5 | 19.2% |
| BGM | 5 | 5 | 0 | 0% |
| 효과음 | 3 | 3 | 0 | 0% |
| **합계** | **98** | **76** | **22** | **22.4%** |
