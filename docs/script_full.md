# 비주얼노벨 전체 스크립트

> 이 문서는 JSON 변환 전 전체 스토리 흐름을 확인하기 위한 스크립트입니다.
> 엔진 명령어 표기법은 `story_manager.gd`의 커맨드 체계에 대응합니다.

---

## 표기법 안내

| 표기 | 엔진 명령 | 설명 |
|------|-----------|------|
| `[scene: id]` | show_scene | 배경 전환 |
| `[fade_scene: id]` | fade_scene | 페이드로 배경 전환 |
| `[show: id, sprite, position]` | show_character | 캐릭터 표시 |
| `[hide: id]` | hide_character | 캐릭터 숨김 |
| `[sprite: id, sprite]` | change_sprite | 표정 변경 |
| `[music: id]` | play_music | BGM 재생 |
| `[stop_music]` | stop_music | BGM 정지 |
| `[sound: id]` | play_sound | 효과음 |
| `[wait: ms]` | wait | 대기 |
| `[set: path, value, op]` | set_var | 변수 설정 |
| `[input: prompt]` | input | 텍스트 입력 |
| `[choice]` | choice | 선택지 |
| `[jump: label]` | jump | 라벨 이동 |
| `[fade_jump: label]` | fade_jump | 페이드 후 이동 |
| `[conditional]` | conditional | 조건 분기 |
| `[gallery: id]` | gallery_unlock | 갤러리 해금 |
| `[affinity: type]` | affinity_hint | 거리감 알림 |
| `[centered]` | centered | 화면 중앙 텍스트 |
| `[end]` | end | 게임 종료 |
| **이름**: "대사" | dialogue | 캐릭터 대사 |
| _기울임_ | narration | 내레이션 |

**캐릭터 ID**: `p` = 강현우(플레이어), `sua` = 이수아
**수아 표정**: normal, happy, shy, sad, surprised, worried
**현우 표정**: normal, happy, surprised, worried

**거리감**: 0(가까움) ~ 100(멀음), 초기값 50. 80 이상이면 게임 오버.

---

# 1. 프롤로그

## Label: Start

`[scene: #000000]`
`[wait: 1000]`

`[centered]` 4월의 어느 날

`[fade_scene: classroom_day]`
`[music: bgm_daily]`

_쉬는 시간이 끝나고, 점심시간이 시작된 교실._
_대부분의 아이들이 삼삼오오 급식실로 향한다._

_그 중에서, 유독 눈에 밟히는 아이가 있었다._
_작년에도 같은 반이었는데, 한 번도 말을 섞어본 적 없는 여자아이._
_1학년 때는 항상 다른 반으로 사라지더니, 2학년이 된 지금은 늘 혼자 있다._

`[show: sua, sad, center, fadeInUp]`

_우울한 표정으로 도시락을 꺼내는 그 아이를 보며—_
_나는 평소처럼, 마침 가까이 있었으니까._

`[hide: sua, fadeOut]`
`[fade_scene: lunch_spot]`
`[show: sua, surprised, center, fadeIn]`
`[gallery: first_lunch]`

**현우**: "같이 먹을래?"

`[sprite: sua, worried]`

**수아**: "…어?"

**현우**: "응. 아니, 다른 애들이랑도 같이 먹을 필요까진 없고. 나도 오늘 밥 사기 귀찮아서."

`[sprite: sua, normal]`

**수아**: "…그, 그래."

_그렇게 그녀는 어떤 이유에선지, 제안을 받아들였다._
_옆에 앉아 도시락을 먹기 시작했지만, 시선은 내내 아래를 향했다._

**현우**: "…"

_말이 없다._
_불편한 건가? 내가 뭐 실수한 건가?_

`[sprite: sua, shy]`

_…아니, 잠깐. 그냥 낯을 가리는 건가?_

**현우**: "아, 맞다. 나 강현우야. 이름이…"

**수아**: "…이수아."

**현우**: "이수아. 알겠어."

`[sprite: sua, normal]`

_짧은 자기소개가 끝나고, 다시 침묵._
_그녀는 도시락만 묵묵히 먹었고, 나는 슬쩍 옆을 훑었다._

_정면을 피하는 눈. 품에 모으고 있는 손._
_다소 음침하다고 할 수 있는 첫인상이었지만—_
_어째서인지, 신경이 쓰였다._

`[hide: sua, fadeOut]`
`[fade_scene: classroom_afternoon]`

_그 날부터, 나는 수아를 힐끔힐끔 바라보며_
_그녀가 뭘 하고, 뭘 좋아하는지 알아가기 시작했다._

`[fade_scene: #000000]`
`[wait: 500]`

`[input: "이름을 입력하세요", "이름을 입력해주세요."]`

_…아, 잠깐. 내 이름을 말했지?_

`[fade_jump: AprilHub]`

---

# 2. 4월 허브

## Label: AprilHub

`[fade_scene: classroom_morning]`
`[music: bgm_daily]`

_또 하루가 시작되고, 수업이 지나간다._
_쉬는 시간마다, 나는 자연스럽게 수아 쪽을 힐끔 바라보게 됐다._

`[centered]` "나는 오늘, 수아를…"

`[choice]`
- "자리 배정 시간에 보았다" → `SeatAssignment`
- "조별 수업 시간에 보았다" → `GroupProject`
- "수학 시간에 보았다" → `MathClass`
- "보지 않았다" → `DidNotLook`
- "점심시간에 보았다" → `LunchTime`
- "수학여행에서 만났다" → `SchoolTrip`

> **분기 조건**: 선택 후 이벤트 종료 시 `april_events`를 +1.
> `april_events >= 4`이고 `distance < 80`이면 → `CrackIntro`로 진행.
> `distance >= 80`이면 → `GameOver`로 진행.
> 그 외에는 → `AprilHub`로 복귀.

---

# 3. 4월 이벤트

---

## 3-1. 자리 배정

### Label: SeatAssignment

`[fade_scene: classroom_morning]`
`[music: bgm_daily]`

_새 학기가 시작된 지 얼마 되지 않아, 자리 배정의 날이 돌아왔다._
_제비뽑기로 정해진 자리. 나는 창가 쪽 중간._

`[show: sua, normal, center, fadeIn]`
`[gallery: seat_assignment]`

_그리고 내 대각선 앞자리에— 이수아가 앉았다._
_자리가 정해지자마자, 수아는 조용히 가방을 내리며 앉았다._
_주변을 둘러보지도 않고._

**현우**: "…"

_마침 가까워진 거리. 뭐라고 말을 걸어볼까._

`[choice]`
dialog: "p 뭐라고 말을 걸어볼까."
- "반갑게 인사한다" (key: greet) → `SeatAssignment_Greet`
- "친구와 대화한다" (key: friend) → `SeatAssignment_Friend`
- "취미를 묻는다" (key: hobby) → `SeatAssignment_Hobby`

### Label: SeatAssignment_Greet

`[set: distance, 5, sub]` _(소폭 가까워짐)_
`[affinity: closer]`

**현우**: "어, 이수아. 앞자리네. 반갑다."

`[sprite: sua, surprised]`

**수아**: "…어. 응."

`[sprite: sua, normal]`

**수아**: "…반가워."

_수아는 적당히 화답하고, 바로 시선을 돌렸다._
_대화는 어색하게 마무리됐지만, 적어도 거부하지는 않았다._

`[jump: SeatAssignment_2nd]`

### Label: SeatAssignment_Friend

`[set: distance, 15, add]` _(대폭 멀어짐)_
`[affinity: farther]`

_나는 옆자리에 앉은 친구에게 먼저 말을 걸었다._

**현우**: "야, 어제 데이드림 트레인 몇 판 쳤어?"

_친구와 자연스럽게 대화를 나누며 웃었다._

`[sprite: sua, sad]`

_수아는 그 모습을 슬쩍 보더니, 조용히 고개를 숙였다._

_…나와는 다른 세계 사람이구나._
_그런 생각을 하고 있다는 건, 나중에야 알게 되었다._

`[jump: SeatAssignment_2nd]`

### Label: SeatAssignment_Hobby

`[set: distance, 15, sub]` _(대폭 가까워짐)_
`[affinity: closer]`

**현우**: "이수아, 취미 같은 거 있어? 뭐 좋아해?"

`[sprite: sua, surprised]`

**수아**: "…취, 취미?"

**현우**: "응. 쉬는 시간에 항상 뭐 읽고 있길래."

`[sprite: sua, shy]`

**수아**: "아… 그, 그건…"

_수아는 당황하며 품에 안고 있던 책을 슬쩍 가렸다._
_로맨스 소설이라고 말하기엔 부끄러운 모양이다._

**수아**: "…소설. 그냥, 소설 읽는 거."

**현우**: "오, 어떤 거? 재밌어?"

`[sprite: sua, worried]`

**수아**: "그, 그냥 유명한 거… 이거."

_수아는 적당히 유명한 작품을 들이밀며 위기를 모면했다._

**현우**: "아, 이거 나도 이름은 들어봤다. 재밌어?"

`[sprite: sua, normal]`

**수아**: "…응. 꽤."

_짧은 대답이었지만, 살짝 입꼬리가 올라간 것 같기도 했다._

`[jump: SeatAssignment_2nd]`

### Label: SeatAssignment_2nd

_자리에 앉아 다음 수업을 기다리는 시간._
_수아와의 거리가 가까워진 만큼, 한 마디 더 건네볼까._

`[choice]`
dialog: "p 한 마디 더 건네볼까."
- "게임 좋아해?" (key: game) → `SeatAssignment_Game`
- "과자 먹을래?" (key: snack) → `SeatAssignment_Snack`
- "가위바위보!" (key: rps) → `SeatAssignment_RPS`

### Label: SeatAssignment_Game

**현우**: "혹시 게임 좋아해?"

`[sprite: sua, normal]`

**수아**: "…좋아해."

**현우**: "오, 진짜? 뭐 해?"

**수아**: "…핸드폰으로 하는 거. 미니게임 같은 거…"

**현우**: "아… 그런 거구나."

_기대와는 달랐지만, 뭐. 게임은 게임이니까._

**현우**: "나는 데이드림 트레인이라고, PC 게임 하거든. 혹시 해본 적 있어?"

`[sprite: sua, worried]`

**수아**: "…아니. 들어는 봤는데…"

**현우**: "관심 있으면 한번 해봐. 재밌어."

`[sprite: sua, normal]`

**수아**: "…생각해볼게."

`[jump: SeatAssignment_End]`

### Label: SeatAssignment_Snack

**현우**: "과자 먹을래?"

_나는 가방에서 과자 봉지를 꺼내 수아 앞에 내밀었다._

`[sprite: sua, surprised]`

**수아**: "…아, 아니 괜찮—"

**현우**: "그냥 먹어. 나 많아."

_손에 과자를 쥐어주자, 수아는 조용히 받아 먹기 시작했다._
_하나, 둘, 셋…_

`[sprite: sua, normal]`

_쥐어주는 대로 계속 받아먹는다._

**현우**: "…많이 먹네?"

`[sprite: sua, surprised]`

**수아**: "…콜록!"

_사레가 들어 기침을 하고 나서야—_

`[sprite: sua, shy]`

**수아**: "…거, 거절을 못 해서 계속 먹고 있었어…"

**현우**: "…하하."

_웃음이 나왔다. 의외로 솔직한 아이였다._

`[jump: SeatAssignment_End]`

### Label: SeatAssignment_RPS

**현우**: "가위바위보!"

`[sprite: sua, surprised]`

**수아**: "…엣?!"

_갑작스러운 말에 수아도 얼떨결에 손을 펼쳐냈다._
_보._

**현우**: "아, 나도 보다. 다시!"

**현우**: "가위바위보!"

`[sprite: sua, normal]`

_이번엔 수아가 가위, 나는 주먹._

**현우**: "내가 이겼다. 딱밤."

`[sprite: sua, worried]`

**수아**: "…이, 이런 게 있어?"

**현우**: "당연하지. 진 사람은 딱밤이야."

_수아는 눈을 질끈 감고 이마를 내밀었다._
_살짝 퉁, 하고 쳤더니—_

`[sprite: sua, shy]`

**수아**: "…아프잖아."

_목소리는 불만이었지만, 입가에 미세한 웃음이 번졌다._

`[jump: SeatAssignment_End]`

### Label: SeatAssignment_End

`[hide: sua, fadeOut]`
`[set: april_events, 1, add]`

_자리 배정 시간은 그렇게 지나갔다._
_조금이나마 수아에 대해 알게 된 것 같다._

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

## 3-2. 조별 수업

### Label: GroupProject

`[fade_scene: classroom_day]`
`[music: bgm_daily]`

_오늘은 조별 수업이 있는 날이다._
_모둠이 정해지고, 다행히 수아와 같은 조가 되었다._

`[show: sua, worried, center, fadeIn]`
`[gallery: group_project]`

_하지만 수아는 대화에 끼지 않고, 조용히 앉아만 있었다._
_다른 조원들은 이미 역할 분담 얘기를 하고 있고._

`[choice]`
dialog: "p 수아에게 어떻게 해줄까."
- "해야 할 일을 나서서 정해준다" (key: assign) → `GroupProject_Assign`
- "어떤 역할을 맡고 싶은지 묻는다" (key: ask) → `GroupProject_Ask`

### Label: GroupProject_Assign

`[set: distance, 5, sub]` _(소폭 가까워짐)_
`[affinity: closer]`

**현우**: "이수아는 자료 조사 맡을래? 인터넷으로 찾으면 되니까 편할 거야."

`[sprite: sua, surprised]`

**수아**: "…어, 응. 알겠어."

_수아는 역할이 정해진 것에 안도하는 듯한 표정이었다._
_대화에 끼지 않아도 되는 것에 한숨 돌린 모양이다._

_나는 금방 다른 조원들과 다음 얘기로 넘어갔고,_
_수아는 조용히 자기 할 일을 시작했다._

`[jump: GroupProject_2nd]`

### Label: GroupProject_Ask

`[set: distance, 5, add]` _(소폭 멀어짐)_
`[affinity: farther]`

**현우**: "이수아는 어떤 역할 맡고 싶어?"

`[sprite: sua, surprised]`

**수아**: "…에?"

`[sprite: sua, worried]`

**수아**: "…아, 아무거나… 괜찮아."

_소극적인 태도에 다른 조원들이 살짝 눈치를 보았다._
_수아는 결국 역할을 하나 정하긴 했지만—_

`[sprite: sua, sad]`

_자신의 태도가 안 좋게 보였을지 신경 쓰는 듯했다._

`[jump: GroupProject_2nd]`

### Label: GroupProject_2nd

_조별 활동이 이어지는 중간. 수아에게 한 마디 더._

`[choice]`
dialog: "p 수아에게 한 마디 더 건네볼까."
- "발표 해본 적 있어?" (key: present) → `GroupProject_Present`
- "PPT 만들 줄 알아?" (key: ppt) → `GroupProject_PPT`

### Label: GroupProject_Present

**현우**: "혹시 발표 해본 적 있어?"

`[sprite: sua, worried]`

**수아**: "…나, 나는 완전 자신 없어."

`[sprite: sua, sad]`

**수아**: "나한테 시키면… 내 때문에 점수 깎일 거야, 진짜로…"

**현우**: "하하, 그 정도야?"

**수아**: "…진심이야."

_수아는 진심으로 질색하는 표정이었다._
_…발표는 다른 애한테 맡기자._

`[jump: GroupProject_End]`

### Label: GroupProject_PPT

**현우**: "혹시 PPT 만들 줄 알아?"

`[sprite: sua, worried]`

**수아**: "…만들어 본 적은 없는데, 검색해서 배우면 되지 않을까…?"

_수아는 핸드폰으로 뭔가 검색하기 시작했다._
_하지만 점점 표정이 안 좋아진다._

`[sprite: sua, sad]`

**수아**: "…이거 생각보다 복잡한데…"

**현우**: "야, 막상 해보면 그렇게 안 어려워."

`[sprite: sua, worried]`

**현우**: "기본 템플릿 하나 골라서 내용만 넣으면 돼. 내가 나중에 알려줄게."

`[sprite: sua, normal]`

**수아**: "…정말?"

**현우**: "응. 별거 아니야."

_수아는 고개를 살짝 끄덕였다._

`[jump: GroupProject_End]`

### Label: GroupProject_End

`[hide: sua, fadeOut]`
`[set: april_events, 1, add]`

_조별 수업은 그렇게 마무리됐다._

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

## 3-3. 수학 시간

### Label: MathClass

`[fade_scene: classroom_day]`
`[music: bgm_daily]`

_수학 시간._
_선생님이 칠판에 복잡한 공식을 적어가는 동안, 나는 슬쩍 수아를 봤다._

`[show: sua, worried, center, fadeIn]`
`[gallery: math_class]`

_…완전히 멘붕 상태다._
_교과서는 펼쳐져 있지만, 어디를 보고 있는 건지도 모르는 눈._

`[choice]`
dialog: "p 어떻게 도와줄까."
- "시간을 내서 가르쳐주겠다고 한다" (key: teach) → `MathClass_Teach`
- "조용히 식을 푸는 방법만 알려준다" (key: hint) → `MathClass_Hint`

### Label: MathClass_Teach

`[set: distance, 15, sub]` _(대폭 가까워짐)_
`[affinity: closer]`

**현우**: "이수아, 이 부분 어려워? 시간 나면 가르쳐줄까?"

`[sprite: sua, surprised]`

**수아**: "…에? 진, 진짜?"

**현우**: "응. 수학은 그래도 좀 하거든."

`[sprite: sua, shy]`

**수아**: "…고, 고마워."

_수아는 고마움을 느끼는 것 같았지만, 동시에 부담스러운 기색도 보였다._
_너무 오래 시간을 뺏으면 안 될 것 같다는 표정._

`[jump: MathClass_2nd]`

### Label: MathClass_Hint

`[set: distance, 5, sub]` _(소폭 가까워짐)_
`[affinity: closer]`

_쉬는 시간, 나는 수아에게 조용히 말을 걸었다._

**현우**: "이거, 여기서 이 공식 대입하면 풀려."

`[sprite: sua, surprised]`

**수아**: "…어? 여기?"

**현우**: "응. x에 이 값 넣고, 여기 정리하면 끝이야."

`[sprite: sua, normal]`

**수아**: "……아."

_수아는 고개를 끄덕이며 풀이를 따라가기 시작했다._
_다행히 진도를 따라잡는 데 성공한 모양이다._

`[jump: MathClass_2nd]`

### Label: MathClass_2nd

`[choice]`
dialog: "p 이왕 말 나온 김에."
- "혹시 어떤 과목 잘해?" (key: subject) → `MathClass_Subject`
- "수학 잘 못 해?" (key: bad_math) → `MathClass_BadMath`

### Label: MathClass_Subject

**현우**: "그러면, 혹시 잘하는 과목은 있어?"

`[sprite: sua, normal]`

**수아**: "…국어."

**현우**: "국어? 진짜?"

`[sprite: sua, surprised]`

**수아**: "…왜, 이상해?"

**현우**: "아니, 그냥 의외라서. 국어 어렵지 않아? 작가의 의도 같은 거 묻는 문제."

`[sprite: sua, normal]`

**수아**: "…그건 그냥, 읽고 가장 그럴 듯한 거 고르면 답 나오는 거 아니야?"

**현우**: "…그게 안 되니까 문제지."

_수아는 신기하다는 듯 고개를 갸웃했다._
_서로 확실히 다른 삶을 살아온 것 같다._

`[jump: MathClass_End]`

### Label: MathClass_BadMath

**현우**: "수학 좀 어렵지? 원래 잘 못 해?"

`[sprite: sua, worried]`

**수아**: "…사실, 중학생 때 수학 포기하려다가… 혼난 적 있어."

**현우**: "수포자였어?"

`[sprite: sua, shy]`

**수아**: "…거, 거의. 지금도 솔직히 잘 모르겠어."

**현우**: "그래도 완전 포기는 안 했잖아. 대단하다."

`[sprite: sua, surprised]`

**수아**: "…대, 대단한 건 아니야."

_수아는 손으로 얼굴을 살짝 가렸다._

`[jump: MathClass_End]`

### Label: MathClass_End

`[hide: sua, fadeOut]`
`[set: april_events, 1, add]`

_수학 시간은 그렇게 지나갔다._

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

## 3-4. 보지 않았다

### Label: DidNotLook

`[fade_scene: classroom_afternoon]`

_오늘은 유독 졸리고, 피곤한 하루였다._
_수업이 끝나고 쉬는 시간마다 책상에 엎드려 잤다._

_수아 쪽을 바라보지도, 말을 걸지도 않았다._

`[set: distance, 15, sub]` _(대폭 가까워짐 = 거리감 대폭 감소)_
`[affinity: closer]`

_가끔은 이런 날도 있는 거다._
_억지로 다가가지 않는 것도, 나쁘지 않은 선택일 수 있다._

`[set: april_events, 1, add]`

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

## 3-5. 점심시간

### Label: LunchTime

`[fade_scene: lunch_spot]`
`[music: bgm_daily]`

_점심시간._
_급식실이 아닌 그늘진 자리에서, 수아는 오늘도 혼자 도시락을 먹고 있었다._

`[show: sua, normal, center, fadeIn]`

_나도 슬쩍 옆에 앉았다._

`[choice]`
dialog: "p 뭐라고 말을 꺼내볼까."
- "앞으로도 같이 먹자고 제안한다" (key: together) → `LunchTime_Together`
- "음료수를 사준다" (key: drink) → `LunchTime_Drink`

### Label: LunchTime_Together

`[set: distance, 15, sub]` _(대폭 가까워짐)_
`[affinity: closer]`

**현우**: "이수아, 앞으로도 같이 밥 먹을래?"

`[sprite: sua, surprised]`

**수아**: "…에?"

`[sprite: sua, worried]`

**수아**: "…나는, 따로 식사를 챙겨오니까… 괜찮아."

**현우**: "그건 상관없잖아. 나도 여기서 먹으면 되지."

`[sprite: sua, shy]`

**수아**: "…그, 그래도… 나한테 맞춰서 굳이…"

**현우**: "맞추는 게 아니라 그냥 같이 먹는 거지."

`[sprite: sua, normal]`

**수아**: "……."

_수아는 거절했지만, 완전히 싫은 얼굴은 아니었다._

`[jump: LunchTime_2nd]`

### Label: LunchTime_Drink

`[set: distance, 5, sub]` _(소폭 가까워짐)_
`[affinity: closer]`

_수아가 물 없이 도시락을 먹는 걸 보고, 나는 매점에서 음료수를 하나 사 왔다._

**현우**: "이거."

`[sprite: sua, surprised]`

**수아**: "…에? 이, 이거…?"

**현우**: "목 안 타? 물도 없이 먹고 있길래."

`[sprite: sua, shy]`

**수아**: "…고, 고마워."

_수아는 작은 목소리로 감사를 전하며 음료수를 받았다._

`[jump: LunchTime_2nd]`

### Label: LunchTime_2nd

`[choice]`
dialog: "p 이왕 먹는 김에."
- "이 도시락은 누가 만들어?" (key: lunchbox) → `LunchTime_Lunchbox`
- "그냥 급식 먹을 때는 없어?" (key: cafeteria) → `LunchTime_Cafeteria`

### Label: LunchTime_Lunchbox

**현우**: "이수아, 이 도시락 누가 만들어? 학교에 도시락 들고 오는 거, 만화에서나 보지 않나?"

`[sprite: sua, normal]`

**수아**: "…내가 만들어."

**현우**: "직접? 대단한데."

`[sprite: sua, shy]`

**수아**: "…그, 그냥. 우리 학교 급식 맛없어서…"

**현우**: "아, 맞아. 진짜 맛없지."

`[sprite: sua, normal]`

_수아가 조용히 웃었다. 공감이 되었나 보다._
_누군가와 웃는 수아를 처음 본 것 같다._

`[jump: LunchTime_End]`

### Label: LunchTime_Cafeteria

**현우**: "매일 도시락이야? 귀찮아서 안 쌀 때는 어떡해?"

`[sprite: sua, normal]`

**수아**: "…사실, 매일 급식표를 봐."

**현우**: "급식표?"

**수아**: "…맛있을 것 같으면 급식 먹으러 가."

**현우**: "…의외로 전략적이네?"

`[sprite: sua, shy]`

**수아**: "…전, 전략이 아니라 그냥…"

**현우**: "하하, 다음에 맛있는 날에는 같이 급식 먹자."

`[sprite: sua, worried]`

**수아**: "…생각해볼게."

`[jump: LunchTime_End]`

### Label: LunchTime_End

`[hide: sua, fadeOut]`
`[set: april_events, 1, add]`

_점심시간은 그렇게 마무리됐다._

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

## 3-6. 수학여행 (제주도)

### Label: SchoolTrip

`[fade_scene: jeju_scenery]`
`[music: bgm_peaceful]`

_수학여행. 제주도._
_버스에서 내리자마자 바다 냄새가 코끝을 스쳤다._
_자유시간이 주어지고, 삼삼오오 흩어지는 아이들 사이에서—_

`[show: sua, normal, center, fadeIn]`
`[gallery: jeju_together]`

_수아는 혼자 서 있었다._

`[choice]`
dialog: "p 수아를 어떻게 할까."
- "같이 다녔다" (key: together) → `SchoolTrip_Together`
- "그냥 눈에 띌 때마다 힐끗 봤다" (key: glance) → `SchoolTrip_Glance`

### Label: SchoolTrip_Together

`[set: distance, 15, sub]` _(대폭 가까워짐)_
`[affinity: closer]`

**현우**: "이수아. 혼자 다닐 거야?"

`[sprite: sua, surprised]`

**수아**: "…어? 어, 뭐… 아마…"

**현우**: "혼자 다니면 재미없지. 같이 다니자."

`[sprite: sua, worried]`

**수아**: "…같, 같이?"

**현우**: "응. 가자."

_수아는 머뭇거리다가 조용히 따라왔다._
_우리는 해안가를 걷고, 전시관을 구경하고, 기념품 가게를 둘러보았다._

`[sprite: sua, happy]`

_처음엔 어색하게 뒤따라오기만 하던 수아도_
_어느새 이것저것 구경하며 눈을 반짝였다._

**현우**: "저거 봐. 돌하르방 미니어처."

**수아**: "…귀, 귀엽다."

**현우**: "살래?"

`[sprite: sua, shy]`

**수아**: "…그, 그냥 보는 거야."

_하지만 시선이 한참 동안 돌하르방에 머물러 있었다._

`[jump: SchoolTrip_2nd]`

### Label: SchoolTrip_Glance

`[set: distance, 5, add]` _(소폭 멀어짐)_
`[affinity: farther]`

_나는 친구들과 함께 돌아다니면서도, 수아가 눈에 들어올 때마다 힐끗 쳐다봤다._

`[sprite: sua, normal]`

_혼자 걸어다니며 경치를 바라보는 수아._
_전시물 앞에서 오래 서 있는 수아._

`[sprite: sua, happy]`

_생각보다 순수하게 즐기고 있었다._
_…다행이다._

`[jump: SchoolTrip_2nd]`

### Label: SchoolTrip_2nd

_밤. 숙소로 돌아온 뒤._

`[fade_scene: jeju_lodging]`
`[show: sua, normal, center, fadeIn]`

_같은 층 복도에서 수아와 마주쳤다._

`[choice]`
dialog: "p 숙소에서."
- "몰래 배달 시켜 먹을래?" (key: delivery) → `SchoolTrip_Delivery`
- "남자애들이 저쪽 방향으로 왜 가는 거지…?" (key: boys) → `SchoolTrip_Boys`

### Label: SchoolTrip_Delivery

`[gallery: jeju_delivery]`

**현우**: "이수아, 배달 시켜 먹을래?"

`[sprite: sua, surprised]`

**수아**: "…에?! 그, 그래도 돼?!"

**현우**: "안 들키면 되지."

`[sprite: sua, worried]`

**수아**: "…혼나면 어떡해…"

**현우**: "괜찮아. 나만 믿어."

_나는 핸드폰으로 치킨을 주문했다._
_숙소 입구에서 몰래 받아와 복도에서 나눠 먹었다._

`[sprite: sua, happy]`

**수아**: "…이거, 뭔가 나쁜 짓 하는 것 같아."

**현우**: "그치? 그래서 재밌는 거야."

**수아**: "…히히."

_수아가 소리 없이 웃었다._
_이렇게 즐거워하는 수아는 처음 봤다._

`[jump: SchoolTrip_End]`

### Label: SchoolTrip_Boys

_복도 끝에서, 몇몇 남자애들이 보드게임을 들고 여자 쪽 방으로 가고 있었다._

**현우**: "…저러다 들키면 우리까지 귀찮아지는 건데."

**현우**: "선생님한테 걸리면 전원 벌 서는 거잖아."

`[sprite: sua, shy]`

_그런데 수아는 얼굴이 빨개져 있었다._

**현우**: "…왜?"

**수아**: "…아, 아무것도 아니야."

_수아는 로맨스 소설의 한 장면이라도 떠올린 건지,_
_고개를 숙이고 귀까지 빨개진 채 방으로 사라졌다._

**현우**: "…뭐야."

`[jump: SchoolTrip_End]`

### Label: SchoolTrip_End

`[hide: sua, fadeOut]`
`[set: april_events, 1, add]`

_수학여행은 그렇게 지나갔다._
_돌아가면, 다시 일상이겠지._

`[conditional]`
- `distance >= 80` → `GameOver`
- `april_events >= 4 AND distance < 80` → `CrackIntro`
- default → `AprilHub`

---

# 4. 균열 파트

## Label: CrackIntro

`[fade_scene: city_day]`
`[music: bgm_peaceful]`
`[gallery: city_outing]`

`[centered]` 5월

_어느 날, 나는 수아에게 제안했다._

**현우**: "이번 주말에 시내 나갈 건데, 같이 갈래?"

`[show: sua, surprised, center, fadeIn]`

**수아**: "…시, 시내?"

**현우**: "응. 뭐 구경하고, 밥 먹고."

`[sprite: sua, worried]`

**수아**: "…나, 나도 가도 돼?"

**현우**: "안 되면 안 물어봤지."

`[sprite: sua, shy]`

**수아**: "……그, 그래. 갈게."

`[fade_scene: city_day]`

_주말._
_수아는 평소보다 조금 꾸민 채 나타났다._
_여전히 눈은 이리저리 피했지만, 분명 기대하고 온 것 같았다._

_우리는 시내를 돌아다녔다._
_수아가 인형 매장 '테디메이트' 앞에서 발걸음을 멈추는 것을 봤고,_
_기념품 가게에서 이것저것 구경하는 그녀의 모습은—_

`[sprite: sua, happy]`

_진심으로 즐거워 보였다._

`[hide: sua, fadeOut]`
`[fade_scene: city_evening]`

_하지만 그 날 이후._

`[show: sua, sad, center, fadeIn]`

_수아는 이전보다도 더 나를 피하기 시작했다._
_눈이 마주치면 고개를 돌리고, 말을 걸면 짧게만 대답하고 사라졌다._

**현우**: "…뭐지?"

_재밌게 놀았잖아. 뭔가 실수한 건가?_
_…아니면 다른 이유가 있는 건가?_

`[hide: sua, fadeOut]`

> 수아는 현우를 좋아하게 되었으나, 감정을 티내거나 선을 넘을 경우 채원이처럼 멀어질 것을 걱정하여 일부러 회피하고 있다.

`[fade_scene: classroom_morning]`

`[centered]` "오늘은 어떻게 다가가야 할까."

`[jump: CrackAfterSchool]`

---

## 4-1. 방과 후

### Label: CrackAfterSchool

`[fade_scene: classroom_afternoon]`
`[music: bgm_melancholy]`

_방과 후._
_대부분의 아이들이 가방을 챙겨 나가고, 교실에는 나와 수아만 남았다._

`[show: sua, sad, center, fadeIn]`

_수아는 천천히 짐을 챙기고 있었다._
_나를 피하듯, 시선을 주지 않은 채._

`[choice]`
dialog: "p 수아에게 다가갈까."
- "혹시 내가 뭐 실수해서 그래?" (key: ask_direct) → `CrackAfterSchool_AskDirect`
- "수아야." (key: call_name) → `CrackAfterSchool_CallName`

### Label: CrackAfterSchool_AskDirect

**현우**: "이수아."

`[sprite: sua, surprised]`

**수아**: "…?"

**현우**: "혹시 내가 뭐 실수해서 그래? 요즘 나 피하는 것 같아서."

`[sprite: sua, worried]`

**수아**: "…피, 피하는 거 아니야."

**현우**: "그럼 왜 눈도 안 마주쳐?"

`[sprite: sua, sad]`

**수아**: "…그건…"

_수아의 손이 가방 끈을 움켜쥐었다._

**수아**: "…네가 실수한 거 아니야. 그냥… 나, 나 때문이야."

**현우**: "네 때문?"

**수아**: "…미안해. 좀만 기다려줘."

_수아는 그 말만 남기고 교실을 나갔다._
_…기다려달라고 했으니, 기다려보자._

`[set: crack_progress, 1, add]`
`[jump: CrackLunchTime]`

### Label: CrackAfterSchool_CallName

**현우**: "수아야."

`[sprite: sua, surprised]`

_수아가 멈칫했다. 내가 '이수아'가 아닌 '수아'라고 부른 건 처음이었으니까._

**수아**: "…왜?"

**현우**: "요즘 뭔가 힘든 일 있어? 표정이 안 좋아 보여서."

`[sprite: sua, worried]`

**수아**: "……아니야. 별거 아니야."

**현우**: "별거 아니면 다행인데. 혹시 뭐 필요한 거 있으면 말해."

`[sprite: sua, sad]`

**수아**: "…응."

_수아는 짧게 대답하고 교실을 나갔다._
_완전히 벽을 친 건 아니다. 아직 괜찮다._

`[set: crack_progress, 1, add]`
`[jump: CrackLunchTime]`

---

## 4-2. 급식 시간

### Label: CrackLunchTime

`[fade_scene: lunch_spot]`
`[music: bgm_daily]`

_점심시간._
_오늘은 급식 대신 매점에서 간식을 사 들고, 수아가 도시락을 먹는 자리로 갔다._

`[show: sua, surprised, center, fadeIn]`

**수아**: "…왜 여기에…"

**현우**: "나도 여기서 먹으려고. 괜찮지?"

`[sprite: sua, worried]`

**수아**: "…어."

_수아는 거부하지 않았다._
_나란히 앉아, 나는 빵을 뜯고 수아는 도시락을 먹었다._

**현우**: "오늘 도시락 뭐야?"

`[sprite: sua, normal]`

**수아**: "…계란말이랑 볶음밥."

**현우**: "오, 맛있겠다."

_서로 말수가 적은 점심이었지만, 불편한 침묵은 아니었다._

`[choice]`
dialog: "p 좀 더 말을 걸어볼까."
- "나도 하나 먹어도 돼?" (key: share) → `CrackLunchTime_Share`
- "내일도 여기서 먹자." (key: tomorrow) → `CrackLunchTime_Tomorrow`

### Label: CrackLunchTime_Share

**현우**: "나도 하나 먹어도 돼? 계란말이."

`[sprite: sua, surprised]`

**수아**: "…어? 어, 응."

_수아는 당황하면서도 도시락을 살짝 내 쪽으로 밀었다._

**현우**: "…이거 맛있다. 직접 만든 거지?"

`[sprite: sua, shy]`

**수아**: "…응. 별, 별거 아니야."

**현우**: "아니야, 진짜 맛있어."

_수아는 작게 고개를 숙이며 도시락을 들여다봤다._
_입꼬리가 미세하게 올라간 걸 봤다._

`[set: crack_progress, 1, add]`
`[jump: CrackSportsFest]`

### Label: CrackLunchTime_Tomorrow

**현우**: "내일도 여기서 먹자."

`[sprite: sua, worried]`

**수아**: "…매일 올 거야?"

**현우**: "왜, 안 돼?"

`[sprite: sua, normal]`

**수아**: "…안 된다고는 안 했어."

**현우**: "그럼 된 거네."

`[sprite: sua, shy]`

**수아**: "…마음대로 해."

_거절 같지만 거절이 아닌 대답._
_수아다운 답이었다._

`[set: crack_progress, 1, add]`
`[jump: CrackSportsFest]`

---

## 4-3. 체육대회

### Label: CrackSportsFest

`[fade_scene: sports_festival]`
`[music: bgm_lively]`
`[gallery: sports_festival]`

`[centered]` 체육대회

_운동장 전체가 시끌벅적했다._
_체육을 싫어하는 학생이라도 참가해야 하는 행사._

`[show: sua, worried, center, fadeIn]`

_수아는 그늘 아래에 쪼그리고 앉아 있었다._
_평소 밖에 나오는 일이 없는 만큼, 유독 힘들어하고 있었다._

**현우**: "이수아, 괜찮아?"

`[sprite: sua, sad]`

**수아**: "…더, 더워."

**현우**: "물 마셔."

_내 물통을 건넸다._

`[sprite: sua, surprised]`

**수아**: "…고마워."

`[choice]`
dialog: "p 수아를 도와줄까."
- "옆에 같이 앉는다" (key: sit) → `CrackSportsFest_Sit`
- "같이 힘내자고 한다" (key: cheer) → `CrackSportsFest_Cheer`

### Label: CrackSportsFest_Sit

_나도 수아 옆에 앉았다._

**현우**: "나도 좀 쉴래."

`[sprite: sua, worried]`

**수아**: "…네 종목은 안 나가도 돼?"

**현우**: "아직 시간 있어."

_나란히 앉아 운동장을 바라봤다._
_함성 소리, 호루라기 소리._

`[sprite: sua, normal]`

_수아는 조금씩 표정이 풀렸다._

**수아**: "…다들 열심히 하네."

**현우**: "그러게. 저 애 봐, 넘어졌는데 바로 일어났다."

`[sprite: sua, normal]`

**수아**: "…대단해."

_작은 대화였지만, 둘이 같은 걸 보며 같은 이야기를 했다._

`[set: crack_progress, 1, add]`
`[jump: CrackExam]`

### Label: CrackSportsFest_Cheer

**현우**: "조금만 힘내자. 오후면 끝나니까."

`[sprite: sua, sad]`

**수아**: "…오후까지…?"

**현우**: "빨리 끝나라고 같이 응원하자. 우리 반 이기면 일찍 끝날 수도 있잖아."

`[sprite: sua, worried]`

**수아**: "…그, 그래."

_수아는 힘없이 일어나 경기를 바라보았다._
_목소리를 높이진 않았지만, 우리 반이 점수를 낼 때마다 고개를 끄덕이며 반응했다._

`[sprite: sua, normal]`

**현우**: "봐, 이겼다."

**수아**: "…다행이다."

_수아의 '다행이다'에는 여러 의미가 담겨 있는 것 같았다._

`[set: crack_progress, 1, add]`
`[jump: CrackExam]`

---

## 4-4. 기말고사

### Label: CrackExam

`[fade_scene: classroom_morning]`
`[music: bgm_melancholy]`

`[centered]` 6월 — 기말고사 기간

_기말고사가 다가오면서, 학교 분위기가 무거워졌다._
_그리고 이 무렵—_

`[show: sua, normal, center, fadeIn]`

_수아가 먼저 말을 걸어왔다._

`[sprite: sua, worried]`

**수아**: "…저, 저기."

**현우**: "응?"

**수아**: "…그, 그동안 좀… 미안했어."

**현우**: "뭐가?"

`[sprite: sua, sad]`

**수아**: "…내가 피한 거. 이상하게 보였을 텐데…"

**현우**: "신경 쓰이긴 했는데, 이유가 있었겠지 싶었어."

`[sprite: sua, surprised]`

**수아**: "…화, 안 났어?"

**현우**: "화날 이유가 있나?"

`[sprite: sua, shy]`

**수아**: "…정말?"

**현우**: "정말."

_수아는 안도하는 듯 숨을 내쉬었다._

**수아**: "…그, 그러면… 다시… 같이 밥 먹어도 돼?"

**현우**: "당연하지."

`[sprite: sua, happy]`

_그렇게 수아는 다시 내 곁으로 돌아왔다._
_하지만 예전보다 더 부끄러움이 많은 태도를 보였다._
_눈을 마주치면 바로 고개를 돌리고,_
_대화 중에 갑자기 얼굴이 빨개져서 말을 더듬기도 했다._

_이전과는 다른 종류의 어색함이었다._

`[set: crack_progress, 1, add]`
`[hide: sua, fadeOut]`
`[jump: CrackBirthday]`

---

## 4-5. 현우의 생일

### Label: CrackBirthday

`[fade_scene: classroom_day]`
`[music: bgm_daily]`
`[gallery: birthday_gift]`

`[centered]` 6월 — 현우의 생일

_기말고사를 앞둔 시기._
_교실에 들어서자마자, 친구들이 환호했다._

**현우**: "뭐야, 왜 이래."

_"생일 축하한다!"_
_"선물은 시험 끝나고 줄게, 하하."_

_장난치며 웃는 친구들 사이에서, 나는 자연스럽게 웃었다._

_…그런데._

`[show: sua, sad, center, fadeIn]`

_교실 한쪽에서, 수아가 그 모습을 바라보고 있었다._
_표정이 묘했다. 축하해주고 싶은 마음과—_
_역시 사는 세계가 다르다는 듯한, 씁쓸한 눈._

_아마 생일이 비슷한 채원이가 떠오른 것일 수도 있다._
_자신은 저렇게 축하받을 일이 없다는 생각._

`[hide: sua, fadeOut]`
`[fade_scene: classroom_afternoon]`

_방과 후._
_친구들이 하나둘 빠져나가고, 나도 가방을 챙기는데—_

`[show: sua, shy, center, fadeInUp]`

**수아**: "저, 저기."

**현우**: "응?"

_수아가 우물쭈물하며 다가왔다._
_손에 작은 선물 상자를 들고._

`[sprite: sua, worried]`

**수아**: "…이, 이거."

**현우**: "…이거 뭐야?"

**수아**: "…생, 생일이라고 해서…"

_수아는 선물을 내 손에 억지로 쥐어주고—_

`[sprite: sua, shy]`

**수아**: "축, 축하해!"

_빠른 걸음으로 교실을 빠져나갔다._

**현우**: "…"

_선물 상자를 열어보니, 작은 열쇠고리가 들어있었다._
_테디메이트 매장에서 파는 곰 모양 열쇠고리._

_…수학여행 때, 인형 매장 앞에서 발걸음을 멈추던 그 아이._
_자기가 좋아하는 걸, 나에게 선물한 거구나._

`[hide: sua, fadeOut]`
`[set: crack_progress, 1, add]`

`[conditional]`
- `crack_progress >= 4` → `JulyIntro`
- default → `CrackAfterSchool`

---

# 5. 7월

## Label: JulyIntro

`[fade_scene: school_front_evening]`
`[music: bgm_melancholy]`

`[centered]` 7월 — 방학 직전

_기말고사가 끝나고, 여름방학이 코앞으로 다가왔다._
_관계는 조심스럽게 회복되었지만,_
_수아의 태도에는 여전히 무언가 말하지 못한 것이 남아있었다._

_방과 후._
_나는 수아에게 먼저 말을 걸었다._

**현우**: "이수아, 잠깐 시간 돼?"

`[show: sua, worried, center, fadeIn]`

**수아**: "…응."

`[fade_scene: school_grounds_evening]`
`[gallery: sua_confession]`

_운동장 벤치에 나란히 앉았다._
_여름 바람이 불었다. 한동안 침묵._

_수아가 먼저 입을 열었다._

`[sprite: sua, sad]`

**수아**: "…있잖아."

**현우**: "응."

**수아**: "…나, 중학생 때 진짜 친한 친구가 있었어."

**현우**: "…"

**수아**: "채원이라고. 뭐든 같이 하고, 매일 만나고… 영원히 그럴 줄 알았어."

`[sprite: sua, worried]`

**수아**: "…근데 고등학교 올라오니까, 반이 달라졌어."

**수아**: "처음엔 나도 찾아갔어. 매일 쉬는 시간마다 채원이네 반에 가서…"

`[sprite: sua, sad]`

**수아**: "…근데 채원이는 새 친구들이 생겼고, 점점 나한테 신경 안 쓰는 것 같았어."

**수아**: "그러다가… 나도 눈치 없이 계속 가는 게 싫었을 거라고 생각했어."

**수아**: "그래서 그만 갔어. 혼자 있기로 했어."

**현우**: "…"

**수아**: "학교가 바뀌거나… 반이 달라져서 멀어지는 건 흔하다는 건 알고 있었어…"

`[sprite: sua, worried]`

**수아**: "…그냥, 나도 그렇게 될 줄은, 몰랐어."

_수아의 목소리가 떨렸다._
_그리고 나를 바라보았다._

`[sprite: sua, sad]`

**수아**: "…그래서 너한테도 그랬어."

**수아**: "…좋아하게 되면, 또 멀어질까봐. 내가 먼저 다가가서, 또 눈치 없는 짓 하는 건 아닌가 싶어서."

**수아**: "…피하면 적어도 상처는 안 받을 줄 알았는데…"

`[sprite: sua, worried]`

**수아**: "…피하니까 더 힘들더라."

**현우**: "…"

_나는 수아의 말을 가만히 들었다._
_뭐라고 해줘야 할지— 솔직히 잘 모르겠었다._
_이런 깊은 얘기를 들어본 적이 별로 없으니까._

_하지만._

_지금, 이 순간만큼은._
_수아가 용기를 내서 꺼낸 이야기를 가볍게 넘기고 싶지 않았다._

`[jump: JulyChoice]`

---

## Label: JulyChoice

`[choice]`
dialog: ""
- "말 없이 멀어지지 않을게" (key: choice_a) → `JulyChoice_A`
- "절대 그럴 일 없어" (key: choice_b) → `JulyChoice_B`
- "다 이해해" (key: choice_c) → `JulyChoice_C`

### Label: JulyChoice_A

`[set: ending_type, "a", set]`

**현우**: "…솔직히, 절대 멀어질 일 없다고는 말 못 해."

`[sprite: sua, worried]`

**수아**: "…"

**현우**: "사람 일은 모르잖아. 반이 달라질 수도 있고, 졸업하면 또 다르고."

`[sprite: sua, sad]`

**수아**: "…그, 그런 말—"

**현우**: "근데."

_나는 수아를 똑바로 바라봤다._

**현우**: "말 없이 멀어지진 않을게."

`[sprite: sua, surprised]`

**현우**: "힘든 일 있으면 말해주고, 멀어지고 싶으면 그것도 말해줘."

**현우**: "네가 눈치 없다고 생각한 적 한 번도 없어."

**현우**: "그리고… 채원이도 아마 네가 눈치 없다고 생각 안 했을 거야."

`[sprite: sua, worried]`

**수아**: "…그건 어떻게 알아."

**현우**: "그냥 느낌. 너한테 짜증 낸 적은 없었다며."

`[sprite: sua, surprised]`

**수아**: "…그, 그건 그렇긴 한데…"

**현우**: "그러니까 너 자신을 너무 탓하지 마."

`[sprite: sua, sad]`

**수아**: "……."

_수아는 한동안 아무 말 없이 고개를 숙이고 있었다._
_어깨가 미세하게 떨렸다._

`[sprite: sua, shy]`

**수아**: "…고마워."

**수아**: "…정말, 고마워."

`[fade_jump: EndingA]`

### Label: JulyChoice_B

`[set: ending_type, "b", set]`

**현우**: "절대 그럴 일 없어. 내가 왜 너한테서 멀어져?"

`[sprite: sua, worried]`

**수아**: "…채원이도, 그렇게 생각했던 친구야."

**현우**: "나는 채원이가 아니야."

`[sprite: sua, surprised]`

**현우**: "절대 멀어지지 않을 거야. 장담해."

`[sprite: sua, sad]`

**수아**: "…장담 같은 거…"

**현우**: "장담이야. 약속."

_수아는 경계하는 듯한 눈으로 나를 바라봤다._
_채원이와의 기억이 떠오르는 것 같았다._

_하지만—_

`[sprite: sua, shy]`

**수아**: "…바보."

**수아**: "…그렇게까지 말해주는 사람은 처음이야."

_수아는 작은 목소리로 중얼거리며 고개를 숙였다._
_…기쁜 건지 슬픈 건지 모를 표정이었다._

`[fade_jump: EndingB]`

### Label: JulyChoice_C

`[set: ending_type, "c", set]`

**현우**: "다 이해해. 네 기분."

`[sprite: sua, surprised]`

**수아**: "…"

`[sprite: sua, sad]`

**수아**: "…이해한다고?"

**현우**: "응. 친구랑 멀어져서 힘들었다는 거잖아. 충분히 이해해."

`[sprite: sua, worried]`

**수아**: "…너는 그런 적 없잖아."

**현우**: "없어도 이해할 수 있지."

`[sprite: sua, sad]`

**수아**: "…아니야."

**수아**: "…비슷한 삶을 살지 않은 사람이 이해할 수 있는 게 아니야."

**수아**: "…네가 사는 세계랑 내가 사는 세계는 달라."

**현우**: "이수아—"

`[sprite: sua, worried]`

**수아**: "…미안해. 오늘은… 여기까지 할게."

_수아는 자리에서 일어나 걸어갔다._
_나는 아무 말도 하지 못했다._

`[fade_jump: EndingC]`

---

# 6. 엔딩

---

## 엔딩 A — "있잖아…!"

### Label: EndingA

`[fade_scene: #000000]`
`[music: bgm_ending_a]`
`[wait: 1500]`
`[gallery: ending_a]`

`[centered]` 여름방학

`[fade_scene: city_day]`

_방학이 시작되고 며칠 뒤._
_핸드폰이 울렸다._

_수아: "있잖아…!"_
_수아: "이번 주에 시간 돼?"_
_수아: "가고 싶은 데가 있어"_

_수아가 먼저 약속을 잡았다._
_처음 있는 일이었다._

`[show: sua, shy, center, fadeInUp]`

_약속 장소에 나타난 수아는 여전히 눈을 잘 마주치지 못했지만,_
_분명히, 먼저 다가온 것이었다._

**수아**: "…기다렸어?"

**현우**: "방금 왔어."

`[sprite: sua, worried]`

**수아**: "…있잖아. 하나 더 얘기해도 돼?"

**현우**: "응."

`[sprite: sua, shy]`

**수아**: "…채원이한테, 다시 말 걸어보려고."

**현우**: "진짜?"

**수아**: "…네 말 듣고 생각했어. 멀어졌다고 생각한 건 나뿐일 수도 있다고."

`[sprite: sua, worried]`

**수아**: "…무, 무서워. 만약 진짜로 싫어하는 거였으면 어떡하지."

**현우**: "그래도 안 해보면 모르잖아."

`[sprite: sua, normal]`

**수아**: "…응. 그러니까 해보려고."

`[sprite: sua, happy]`

**수아**: "…고마워. 네가 있어서 용기 냈어."

_수아는 부끄러운 듯 웃었다._

`[hide: sua, fadeOut]`
`[fade_scene: #000000]`

_그 날 이후, 수아는 조금씩 변했다._
_먼저 약속을 잡고, 먼저 제안하고, 부끄러워하면서도 직접적으로 함께 해주기를 부탁했다._

_그리고 채원이와도— 다시 대화를 시작했다고 했다._

_멀어졌다고 생각한 건 수아뿐이었다._
_채원이는 여전히, 수아를 친구로 여기고 있었다._

_'있잖아'로 시작하는 수아의 메시지가 울릴 때마다,_
_나는 핸드폰을 들고 웃는다._

_이 관계가 어디까지 갈지는 모르겠지만—_
_적어도, 말 없이 멀어지진 않을 거다._

`[centered]` **엔딩 A — 있잖아…!**

`[wait: 3000]`

---

> **엔딩 코멘트 (A 엔딩 해금 시)**

`[centered]` 수아의 회상

**수아**: "사, 사실… 조별과제 때, 민폐 안 끼치려면 뭐라도 말해야 한다고는 생각했는데… 말이 입 밖으로 안 나오더라."

**수아**: "그래도, 네가 먼저 물어봐줘서 역할도 정해지고, 잘 끝났었지."

**수아**: "…그때 고맙다는 말을 안 한 것 같아서. 지금 말하려고. 고마워…"

**수아**: "그, 그리고. 수학여행 때, 둘이 다닌 것도 좋았고… 너 없었으면 분명 혼자 다녔을 테니까…"

**수아**: "중학생 때랑 달리 자유시간도 많아서… 혼자 다니면 아쉬웠을 것 같아."

**수아**: "혼날까봐 무서웠지만… 뭐라고 해야 하지…? 뭔가 있는 그대로 말하면 안 될 것 같지만…"

**수아**: "…왜 항상 말 안 듣고 다른 짓 하는 애가 꼭 있는지… 알 것 같았다고 해야 하나아…"

**수아**: "아, 그, 그리고! 혹시… 기말고사 때문에 필요해서 말 걸었다고 생각하고 있는 거 아니지…?"

**수아**: "저, 절대 아니야! 진짜로…!"

**수아**: "그냥… 곧 방학이고, 그럼 한 달은 꼬박 못 만날 텐데… 지금이 아니면, 완전히 멀어질 거라고 생각했어…"

`[wait: 2000]`
`[end]`

---

## 엔딩 B — "그렇게 말해줘서 고마워"

### Label: EndingB

`[fade_scene: #000000]`
`[music: bgm_ending_b]`
`[wait: 1500]`
`[gallery: ending_b]`

`[centered]` 며칠 뒤

`[fade_scene: classroom_afternoon]`

_종업식 전날._
_방과 후, 교실에서 짐을 챙기고 있는데—_

`[show: sua, shy, center, fadeInUp]`

_수아가 다가왔다._
_손에 뭔가를 꼭 쥐고 있었다._

**수아**: "…저기."

**현우**: "응?"

`[sprite: sua, worried]`

**수아**: "…그때, 절대 그럴 일 없다고 했잖아."

**현우**: "응."

**수아**: "…처음엔, 채원이랑 똑같은 말이라고 생각했어."

**현우**: "…"

`[sprite: sua, shy]`

**수아**: "…근데 생각해보니까, 네가 그렇게까지 말해준 건 처음이었어."

**수아**: "…다른 누구도 나한테 '절대'라고 해준 적 없었거든."

_수아는 쥐고 있던 것을 내 앞에 내밀었다._
_테디메이트에서 산 작은 곰 인형._

`[sprite: sua, shy]`

**수아**: "…이건, 나한테 제일 소중한 건데."

**수아**: "…너한테 주고 싶어서."

**현우**: "…이거, 네가 제일 좋아하는 거잖아."

`[sprite: sua, worried]`

**수아**: "…그, 그러니까 주는 거야."

_수아의 얼굴이 새빨개졌다._
_입을 열었다 닫았다를 반복하더니—_

`[sprite: sua, shy]`

**수아**: "…그, 그렇게 말해줘서 고마워."

_그리고, 작은 목소리로 무언가 더 말했다._
_너무 작아서 잘 들리지 않았지만._

_…들리지 않아도, 알 것 같았다._

`[hide: sua, fadeOut]`
`[fade_scene: #000000]`

_인형을 손에 쥐고 서 있는 나._
_수아가 사라진 복도를 바라보며._

_…다음엔 제대로 들어야지._

`[centered]` **엔딩 B — 그렇게 말해줘서 고마워**

`[wait: 3000]`
`[end]`

---

## 엔딩 C — "이해란 어려운 것"

### Label: EndingC

`[fade_scene: #000000]`
`[music: bgm_ending_c]`
`[wait: 1500]`
`[gallery: ending_c]`

`[centered]` 여름방학

`[fade_scene: classroom_evening]`

_종업식 날._
_교실은 벌써 반쯤 비어 있었다._

_수아의 자리도 비어 있었다._
_일찍 가버린 모양이다._

_…아니, 피한 건지도 모르겠다._

`[fade_scene: school_front_evening]`

_교문을 나서며, 나는 생각했다._

_'다 이해해'라고 말했다._
_하지만 사실, 나는 수아가 겪은 것을 제대로 이해한 적이 없었다._

_친한 친구와 멀어지는 것이 어떤 기분인지._
_다가가는 것 자체가 두려운 것이 어떤 의미인지._

_나한테는 그런 경험이 없었으니까._
_그래서, 가벼운 위로가 되어버렸다._

_수아는 그걸 느낀 거겠지._

_이해한다는 말이, 때론 가장 무책임한 말이 될 수 있다는 것._

`[fade_scene: #000000]`

_방학이 지나고, 2학기가 시작되었다._
_수아는 더 이상 내 근처에 앉지 않았고,_
_도시락도 다른 곳에서 먹었다._

_서먹서먹한 채로 자리가 바뀌었고,_
_그대로— 인연이 끊겼다._

_나는 수아를 이해해보려 한 적이 있었을까._
_있었다고 생각했는데, 아니었나 보다._

_…씁쓸했다._

`[centered]` **엔딩 C — 이해란 어려운 것**

`[wait: 3000]`
`[end]`

---

## 게임 오버

### Label: GameOver

`[stop_music]`
`[fade_scene: #000000]`
`[wait: 1000]`

_수아는 어느 순간부터 나를 의도적으로 피하기 시작했다._

_눈이 마주쳐도 바로 돌리고,_
_같은 공간에 있으면 자리를 옮겼다._

_이유를 모른 채, 나는 그저 내가 뭔가 실수한 것이 있겠다고 여겼다._

_서먹서먹한 채로 시간이 흘렀고,_
_자리를 바꾸게 된 시점에서—_

_완전히 인연이 끊겼다._

_한때 옆에 앉아 도시락을 먹던 그 아이는,_
_다시 혼자가 되었다._

_…나도._

`[centered]` **GAME OVER**

`[wait: 3000]`
`[end]`

---

# 부록: 라벨 흐름도

```
Start (프롤로그)
  └─ AprilHub (4월 허브 / 이벤트 선택)
       ├─ SeatAssignment (자리배정)
       │    ├─ SeatAssignment_Greet / _Friend / _Hobby
       │    ├─ SeatAssignment_2nd → _Game / _Snack / _RPS
       │    └─ SeatAssignment_End → [조건분기]
       ├─ GroupProject (조별수업)
       │    ├─ GroupProject_Assign / _Ask
       │    ├─ GroupProject_2nd → _Present / _PPT
       │    └─ GroupProject_End → [조건분기]
       ├─ MathClass (수학시간)
       │    ├─ MathClass_Teach / _Hint
       │    ├─ MathClass_2nd → _Subject / _BadMath
       │    └─ MathClass_End → [조건분기]
       ├─ DidNotLook (보지않았다)
       │    └─ [조건분기]
       ├─ LunchTime (점심시간)
       │    ├─ LunchTime_Together / _Drink
       │    ├─ LunchTime_2nd → _Lunchbox / _Cafeteria
       │    └─ LunchTime_End → [조건분기]
       └─ SchoolTrip (수학여행)
            ├─ SchoolTrip_Together / _Glance
            ├─ SchoolTrip_2nd → _Delivery / _Boys
            └─ SchoolTrip_End → [조건분기]

  [조건분기]
    ├─ distance >= 80 → GameOver
    ├─ april_events >= 4 AND distance < 80 → CrackIntro
    └─ else → AprilHub (반복)

CrackIntro (균열 파트 도입)
  └─ CrackAfterSchool (방과후)
       ├─ CrackAfterSchool_AskDirect / _CallName
       └─ CrackLunchTime (급식시간)
            ├─ CrackLunchTime_Share / _Tomorrow
            └─ CrackSportsFest (체육대회)
                 ├─ CrackSportsFest_Sit / _Cheer
                 └─ CrackExam (기말고사)
                      └─ CrackBirthday (현우 생일)
                           └─ [crack_progress >= 4] → JulyIntro

JulyIntro (7월 도입)
  └─ JulyChoice (최종 선택)
       ├─ JulyChoice_A → EndingA
       ├─ JulyChoice_B → EndingB
       └─ JulyChoice_C → EndingC

GameOver (게임 오버)
EndingA (엔딩 A + 엔딩 코멘트)
EndingB (엔딩 B)
EndingC (엔딩 C)
```

---

# 부록: 거리감 변화 요약

| 이벤트 | 선택지 | 거리감 변화 |
|--------|--------|-------------|
| 자리배정 | 반갑게 인사한다 | -5 (소폭 가까워짐) |
| 자리배정 | 친구와 대화한다 | +15 (대폭 멀어짐) |
| 자리배정 | 취미를 묻는다 | -15 (대폭 가까워짐) |
| 조별수업 | 나서서 정해준다 | -5 (소폭 가까워짐) |
| 조별수업 | 역할을 묻는다 | +5 (소폭 멀어짐) |
| 수학시간 | 시간 내서 가르쳐줌 | -15 (대폭 가까워짐) |
| 수학시간 | 식 풀이만 알려줌 | -5 (소폭 가까워짐) |
| 보지 않았다 | (단일) | -15 (대폭 가까워짐) |
| 점심시간 | 같이 먹자 제안 | -15 (대폭 가까워짐) |
| 점심시간 | 음료수 사줌 | -5 (소폭 가까워짐) |
| 수학여행 | 같이 다녔다 | -15 (대폭 가까워짐) |
| 수학여행 | 힐끗 봤다 | +5 (소폭 멀어짐) |

**초기 거리감**: 50
**게임 오버 조건**: distance >= 80
**진행 조건**: april_events >= 4 AND distance < 80

---

# 부록: 변수 목록

| 변수 | 타입 | 초기값 | 용도 |
|------|------|--------|------|
| `player.name` | String | "" | 플레이어 이름 (input으로 입력) |
| `distance` | int | 50 | 수아와의 거리감 (0~100) |
| `april_events` | int | 0 | 4월 이벤트 진행 횟수 |
| `crack_progress` | int | 0 | 균열 파트 진행도 |
| `ending_type` | String | "" | 엔딩 타입 (a/b/c/gameover) |

---

# 부록: 갤러리 해금 목록

| ID | 해금 시점 |
|----|-----------|
| `first_lunch` | 프롤로그 — 첫 만남 |
| `seat_assignment` | 자리배정 이벤트 진입 |
| `group_project` | 조별수업 이벤트 진입 |
| `math_class` | 수학시간 이벤트 진입 |
| `jeju_together` | 수학여행 이벤트 진입 |
| `jeju_delivery` | 수학여행 — 배달 선택 |
| `sports_festival` | 체육대회 이벤트 진입 |
| `birthday_gift` | 현우 생일 이벤트 진입 |
| `city_outing` | 균열 파트 도입 |
| `sua_confession` | 7월 — 수아의 고백 |
| `ending_a` | 엔딩 A 진입 |
| `ending_b` | 엔딩 B 진입 |
| `ending_c` | 엔딩 C 진입 |
