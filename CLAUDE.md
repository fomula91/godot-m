# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Godot 4.6 게임 프로젝트 (GL Compatibility 렌더러, Jolt Physics 3D 물리 엔진 사용).

## Engine & Configuration

- **Godot 버전**: 4.6
- **렌더러**: GL Compatibility (모바일 포함)
- **물리 엔진**: Jolt Physics (3D)
- **Windows 렌더링 드라이버**: D3D12
- **스크립트 언어**: GDScript (`.gd` 파일)

## Project Structure

- `project.godot` - 엔진 설정 파일 (에디터 UI로 편집 권장)
- `.godot/` - 에디터 캐시 (git에서 제외됨)
- `icon.svg` - 프로젝트 아이콘

## Development

- Godot 에디터에서 F5(전체 실행) 또는 F6(현재 씬 실행)으로 테스트
- 커맨드라인 실행: `godot --path . --editor` (에디터), `godot --path .` (게임 실행)
- `.editorconfig`에 따라 UTF-8 인코딩 사용

## Conventions

- GDScript 파일은 Godot 공식 스타일 가이드를 따름 (snake_case 함수/변수, PascalCase 클래스)
- 씬 파일(`.tscn`)과 리소스 파일(`.tres`)은 텍스트 형식으로 저장
