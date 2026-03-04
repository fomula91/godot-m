#!/usr/bin/env python3
"""
Monogatari JS → Godot JSON 스토리 변환기
- 소스: project-m/js/scripts/day*/
- 출력: godot-porject-m/story/day*/
"""

import json
import os
import re
import sys

SRC_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'project-m', 'js', 'scripts')
DST_DIR = os.path.join(os.path.dirname(__file__), '..', 'story')

# 캐릭터 ID 목록
CHAR_IDS = {'p', 's', 'h', 'u'}

# fadeJump 확장: 3개 명령으로
def expand_fade_jump(label, duration=200):
    return [
        {"cmd": "fade_jump", "target": label, "duration": 1.5, "wait": duration / 1000.0, "color": "#000000"}
    ]

# fadeScene 확장
def expand_fade_scene(scene_id, duration=200):
    return [
        {"cmd": "fade_scene", "id": scene_id, "duration": 1.5, "wait": duration / 1000.0, "color": "#000000"}
    ]


def parse_string_command(s):
    """Monogatari 문자열 명령을 JSON 명령으로 변환"""
    s = s.strip()

    # show scene
    m = re.match(r'^show scene ([^\s]+)\s+with\s+(.+)$', s)
    if m:
        return {"cmd": "show_scene", "id": m.group(1), "transition": m.group(2)}

    m = re.match(r'^show scene ([^\s]+)$', s)
    if m:
        return {"cmd": "show_scene", "id": m.group(1), "transition": "fadeIn"}

    # show character
    m = re.match(r'^show character (\w+)\s+(\w+)\s+at\s+(\w+)\s+with\s+(.+)$', s)
    if m:
        return {"cmd": "show_character", "id": m.group(1), "sprite": m.group(2),
                "position": m.group(3), "transition": m.group(4)}

    m = re.match(r'^show character (\w+)\s+(\w+)\s+at\s+(\w+)$', s)
    if m:
        return {"cmd": "show_character", "id": m.group(1), "sprite": m.group(2),
                "position": m.group(3), "transition": "fadeIn"}

    # show character (sprite change only, no position)
    m = re.match(r'^show character (\w+)\s+(\w+)$', s)
    if m:
        return {"cmd": "change_sprite", "id": m.group(1), "sprite": m.group(2)}

    # show character fadeOut (no 'with')
    m = re.match(r'^show character (\w+)\s+(fadeOut\w*)$', s)
    if m:
        return {"cmd": "hide_character", "id": m.group(1), "transition": m.group(2)}

    # hide character
    m = re.match(r'^hide character (\w+)\s+with\s+(.+)$', s)
    if m:
        return {"cmd": "hide_character", "id": m.group(1), "transition": m.group(2)}

    m = re.match(r'^hide character (\w+)$', s)
    if m:
        return {"cmd": "hide_character", "id": m.group(1), "transition": "fadeOut"}

    # play music
    m = re.match(r'^play music (\S+)(\s+loop)?(\s+fade\s+(\d+))?$', s)
    if m:
        cmd = {"cmd": "play_music", "id": m.group(1), "loop": bool(m.group(2))}
        return cmd

    # stop music
    m = re.match(r'^stop music(\s+fade\s+(\d+))?$', s)
    if m:
        fade = float(m.group(2)) if m.group(2) else 1.0
        return {"cmd": "stop_music", "fade": fade}

    # play sound
    m = re.match(r'^play sound (\S+)(\s+loop)?$', s)
    if m:
        return {"cmd": "play_sound", "id": m.group(1)}

    # stop sound
    m = re.match(r'^stop sound(\s+(\S+))?(\s+fade\s+(\d+))?$', s)
    if m:
        return {"cmd": "stop_sound"}

    # wait
    m = re.match(r'^wait (\d+)$', s)
    if m:
        return {"cmd": "wait", "duration": int(m.group(1))}

    # centered
    m = re.match(r'^centered (.+)$', s)
    if m:
        return {"cmd": "centered", "text": m.group(1)}

    # jump
    m = re.match(r'^jump (\S+)$', s)
    if m:
        return {"cmd": "jump", "target": m.group(1)}

    # gallery unlock
    m = re.match(r'^gallery unlock (.+)$', s)
    if m:
        return {"cmd": "gallery_unlock", "id": m.group(1)}

    # end
    if s == 'end':
        return {"cmd": "end"}

    # 캐릭터 대사: 'X text' where X is a character id
    parts = s.split(' ', 1)
    if len(parts) == 2 and parts[0] in CHAR_IDS:
        return {"cmd": "dialogue", "character": parts[0], "text": parts[1]}

    # 내레이션 (기본)
    return {"cmd": "narration", "text": s}


def parse_js_file(filepath):
    """JS 파일에서 라벨과 명령 추출 (수동 변환 접근)"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    return content


def convert_file_manually(filepath, labels_dict):
    """각 파일을 수동으로 변환 - 파일 내용을 파싱하여 라벨 추출"""
    content = parse_js_file(filepath)

    # 라벨 추출: 'LabelName': [
    label_pattern = re.compile(r"'(\w+)'\s*:\s*\[")
    label_starts = [(m.group(1), m.start()) for m in label_pattern.finditer(content)]

    for i, (label_name, start_pos) in enumerate(label_starts):
        # 배열 끝 찾기 (다음 라벨 시작 또는 파일 끝)
        end_pos = label_starts[i+1][1] if i+1 < len(label_starts) else len(content)
        block = content[start_pos:end_pos]

        commands = []
        # 문자열 엔트리 추출
        lines = block.split('\n')

        for line in lines:
            line = line.strip()
            if not line or line.startswith('//') or line.startswith('/*') or line.startswith('*'):
                continue

            # 문자열 리터럴: 'text' 또는 "text"
            str_match = re.match(r"^'([^']*)',?\s*(?://.*)?$", line)
            if str_match:
                text = str_match.group(1)
                cmd = parse_string_command(text)
                commands.append(cmd)
                continue

            # makeChoice
            choice_match = re.match(r"makeChoice\s*\(\s*'([^']*)'", line)
            if choice_match:
                dialog = choice_match.group(1)
                # 선택지 추출
                choices = extract_choices(block, line)
                commands.append({"cmd": "choice", "dialog": dialog, "choices": choices})
                continue

            # fadeJump spread
            fj_match = re.match(r"\.\.\.\s*fadeJump\s*\(\s*'(\w+)'(?:\s*,\s*\{\s*duration\s*:\s*(\d+)\s*\})?\s*\)", line)
            if fj_match:
                label = fj_match.group(1)
                dur = int(fj_match.group(2)) if fj_match.group(2) else 200
                commands.extend(expand_fade_jump(label, dur))
                continue

            # fadeScene spread
            fs_match = re.match(r"\.\.\.\s*fadeScene\s*\(\s*'(\w+)'", line)
            if fs_match:
                scene = fs_match.group(1)
                commands.extend(expand_fade_scene(scene))
                continue

            # Function block - distractionFree
            if 'distractionFree' in line:
                # 다음에 나올 명령이 아닌, 현재 자체가 명령
                if 'Apply' in line or "'Function'" in line or "'Apply'" in line:
                    commands.append({"cmd": "distraction_free"})
                continue

            # Function block - storage (호감도/변수 설정)
            storage_match = re.search(r'(\w+):\s*this\.storage\s*\(\s*[\'"](\w+)[\'"]\s*\)\s*\+\s*(\d+)', line)
            if storage_match:
                var_name = storage_match.group(1)
                val = int(storage_match.group(3))
                commands.append({"cmd": "set_var", "path": var_name, "value": val, "op": "add"})
                continue

            # Simple storage set: variable: value
            simple_storage = re.search(r"(\w+):\s*(true|false|'[^']*')", line)
            if simple_storage and 'this.storage' not in line and 'Condition' not in line:
                var_name = simple_storage.group(1)
                val_str = simple_storage.group(2)
                if val_str == 'true':
                    val = True
                elif val_str == 'false':
                    val = False
                else:
                    val = val_str.strip("'")
                if var_name not in ('Apply', 'Revert', 'Function', 'Conditional', 'Condition',
                                     'Save', 'Validation', 'Text', 'Warning', 'Input',
                                     'SoraWarm', 'HanaWarm', 'SoraGreets', 'HanaGreets',
                                     'High', 'Normal', 'BothHigh', 'SoraHigh', 'HanaHigh', 'Balanced',
                                     'PhotoEvent', 'SkipPhoto', 'SoraScene', 'HanaScene', 'NeutralScene',
                                     'HighInterest', 'NormalMeet', 'SoraAfternoon', 'HanaAfternoon', 'TogetherAfternoon',
                                     'SoraMemory', 'HanaMemory', 'Dialog', 'Do', 'Choice'):
                    commands.append({"cmd": "set_var", "path": var_name, "value": val})
                continue

            # AffinityHint
            hint_match = re.search(r"AffinityHint\.show\s*\(\s*'(\w+)'\s*\)", line)
            if hint_match:
                commands.append({"cmd": "affinity_hint", "character": hint_match.group(1)})
                continue

            # Character name change (유우)
            if "monogatari.characters()" in line and ".name" in line:
                # 유우 이름 변경 - 스킵 (Godot에서 별도 처리)
                continue

            # Conditional blocks
            if "'Conditional'" in line or "'Condition'" in line:
                # Conditional을 수집하여 처리
                cond_block = extract_conditional(block, line, lines)
                if cond_block:
                    commands.append(cond_block)
                continue

            # Input block
            if "'Input'" in line:
                commands.append({"cmd": "input", "prompt": "이름을 입력해주세요:", "warning": "이름을 입력해야 합니다!"})
                continue

        labels_dict[label_name] = commands


def extract_choices(block, start_line):
    """makeChoice에서 선택지 추출"""
    choices = []
    # 전체 블록에서 makeChoice 이후의 선택지 찾기
    mc_pos = block.find(start_line)
    if mc_pos < 0:
        mc_pos = block.find('makeChoice')
    if mc_pos < 0:
        return choices

    sub = block[mc_pos:]
    # 패턴: Key: ['텍스트', 'Label']
    choice_pattern = re.compile(r"(\w+):\s*\[\s*'([^']+)'\s*,\s*'(\w+)'\s*\]")
    for m in choice_pattern.finditer(sub):
        choices.append({
            "key": m.group(1),
            "text": m.group(2),
            "target": m.group(3)
        })
        # 최대 3개
        if len(choices) >= 4:
            break
    return choices


def extract_conditional(block, start_line, lines):
    """Conditional 블록 추출"""
    # 블록에서 Conditional 패턴 찾기
    cond_pos = block.find("'Conditional'")
    if cond_pos < 0:
        cond_pos = block.find('"Conditional"')
    if cond_pos < 0:
        return None

    sub = block[cond_pos:]

    # 간단한 조건 분석: Condition function 내용에서 조건 추출
    branches = []

    # storage 비교 패턴
    cond_checks = re.findall(
        r"this\.storage\s*\(\s*'(\w+)'\s*\)\s*(===?|>=?|<=?|!==?)\s*(\w+|'[^']*'|\d+)",
        sub[:1000]
    )

    # 분기 결과 패턴: 'ResultKey': 'jump Label'
    jump_results = re.findall(r"'(\w+)'\s*:\s*'jump\s+(\w+)'", sub[:1500])

    if cond_checks and jump_results:
        # 조건을 결과와 매핑
        for check in cond_checks:
            var_name, op, value = check
            if value.startswith("'"):
                value = value.strip("'")
            condition = f"{var_name} {op.replace('===', '==')} {value}"

            # 해당 조건의 결과 찾기
            # 조건 텍스트에서 반환값과 jump label 연결
            for result_key, target in jump_results:
                # 반환값과 조건 매핑은 순서 기반으로
                if result_key not in [b.get('_key') for b in branches]:
                    branches.append({
                        "condition": condition,
                        "action": "jump",
                        "target": target,
                        "_key": result_key
                    })
                    break

        # _key 제거
        for b in branches:
            b.pop('_key', None)

    if not branches and jump_results:
        # 복잡한 조건 - 수동 매핑 필요
        # 기본적으로 모든 jump를 나열
        for result_key, target in jump_results:
            branches.append({
                "condition": f"_manual_{result_key}",
                "action": "jump",
                "target": target
            })

    if branches:
        return {"cmd": "conditional", "branches": branches}
    return None


def convert_all():
    """모든 스크립트 변환"""
    os.makedirs(DST_DIR, exist_ok=True)

    day_dirs = ['day1', 'day2', 'day3', 'day4', 'day5']
    for day_dir in day_dirs:
        src_path = os.path.join(SRC_DIR, day_dir)
        dst_path = os.path.join(DST_DIR, day_dir)
        os.makedirs(dst_path, exist_ok=True)

        if not os.path.isdir(src_path):
            print(f"[SKIP] {src_path} not found")
            continue

        for filename in sorted(os.listdir(src_path)):
            if not filename.endswith('.js'):
                continue
            filepath = os.path.join(src_path, filename)
            json_name = filename.replace('.js', '.json')

            labels = {}
            convert_file_manually(filepath, labels)

            # JSON 출력
            out_path = os.path.join(dst_path, json_name)
            with open(out_path, 'w', encoding='utf-8') as f:
                json.dump(labels, f, ensure_ascii=False, indent=2)
            print(f"[OK] {day_dir}/{filename} → {json_name} ({len(labels)} labels)")

    print("\nDone!")


if __name__ == '__main__':
    convert_all()
