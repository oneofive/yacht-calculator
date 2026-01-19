# 🎲 Yacht Dice Strategy HUD (macOS)

> **요트다이스 게임을 위한 실시간 전략 계산기 & 오버레이 유틸리티** > 플레이어의 현재 점수를 기반으로 '상단 보너스(63점)' 달성을 위한 최적의 주사위 조합을 실시간으로 분석해 추천합니다.

![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=flat-square&logo=swift)
![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey?style=flat-square&logo=apple)
![UI](https://img.shields.io/badge/UI-SwiftUI-blue?style=flat-square&logo=swift)

---

## 📸 Screenshots
<img src="https://via.placeholder.com/600x400?text=App+Screenshot+Here" width="600">

---

## 💡 Key Features (핵심 기능)

### 1. Always-On-Top HUD (헤드업 디스플레이)
- 게임 화면을 가리지 않으면서 항상 최상단에 떠 있는 **Floating Window** 구현
- `NSWindow` 스타일링을 통해 타이틀 바를 제거하고 투명한 배경(`ultraThinMaterial`) 적용
- 게임 중 방해되지 않도록 미니멀한 사이즈와 드래그 이동 지원

### 2. Smart Strategy Engine (승리 플랜 추천)
- **백트래킹(Backtracking) 알고리즘**을 사용하여 남은 빈칸(Category)에 대한 최적의 시나리오 계산
- 단순히 "점수가 부족하다"는 경고를 넘어, **"어떤 주사위를 몇 개(3개/4개/5개) 모아야 하는지"** 구체적인 조합 제시
- 경우의 수를 난이도별(Triple, Quad, Yahtzee)로 분류하여 상위 3개 추천

### 3. Real-time Score Tracking
- 직관적인 `+/-` 버튼 인터페이스로 빠른 점수 입력
- 상단 보너스(63점)까지 남은 점수(Gap)를 실시간 계산 및 시각화 (Green/Red 상태 표시)

---

## 🛠 Tech Stack (기술 스택)

- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM Pattern (View - Data Model 분리)
- **Algorithm**: Recursive Backtracking (DFS 기반 조합 탐색)
- **Environment**: Xcode 15+

---

## 🧩 Algorithm Logic

사용자가 점수를 입력할 때마다 앱은 다음 로직을 수행합니다:

1. **상태 감지**: 현재 비어있는 슬롯(0점)과 부족한 점수(Target)를 파악합니다.
2. **조합 탐색 (DFS)**: 남은 슬롯에서 얻을 수 있는 현실적인 주사위 개수(3~5개)의 모든 조합을 탐색합니다.
3. **최적화 & 가지치기**: 
   - 목표 점수를 달성할 수 없는 경로는 조기에 종료(Pruning)합니다.
   - 달성 가능한 조합 중 '난이도(Difficulty Score)'가 낮은 순서대로 정렬하여 사용자에게 제공합니다.
