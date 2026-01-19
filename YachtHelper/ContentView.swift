import SwiftUI

struct Scenario: Hashable, Identifiable {
    let id = UUID()
    let combination: [Int: Int]
    
    var difficultyScore: Int {
        combination.values.reduce(0, +) + (combination.values.filter { $0 == 5 }.count * 3)
    }
}

struct ContentView: View {
    @State private var counts: [Int] = [0, 0, 0, 0, 0, 0]
    
    var currentSum: Int {
        counts.enumerated().reduce(0) { sum, pair in
            sum + ((pair.offset + 1) * pair.element)
        }
    }
    
    var needed: Int { max(0, 63 - currentSum) }
    
    var scenarios: [Scenario] {
        if needed == 0 { return [] }
        let openSlots = counts.enumerated().filter { $0.element == 0 }.map { $0.offset + 1 }
        if openSlots.isEmpty { return [] }
        return findBestCombinations(target: needed, slots: openSlots).prefix(3).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // [1] 헤더: 점수판 (높이 고정)
            VStack(spacing: 4) {
                Text("YACHT STRATEGY")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.top, 12)
                
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(currentSum)")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(currentSum >= 63 ? .green : .white)
                    
                    Text("/ 63")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                
                if needed > 0 {
                    Text("목표까지 -\(needed)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.bottom, 8)
                } else {
                    Text("🎉 보너스 획득 성공!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 100) // 헤더 높이 고정
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.3))
            
            Divider().background(Color.white.opacity(0.15))
            
            // [2] 전략 추천 리스트
            // 내용이 있든 없든, 실패하든 성공하든 이 공간은 항상 110px을 차지합니다.
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("추천 승리 플랜")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.leading, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // 상황별 뷰 분기
                if needed == 0 {
                    // 성공 시
                    Spacer()
                    HStack {
                        Spacer()
                        Text("이미 달성했습니다! 🥳")
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    Spacer()
                } else if scenarios.isEmpty {
                    // 실패 혹은 불가능 시
                    Spacer()
                    HStack {
                        Spacer()
                        Text(counts.contains(0) ? "😱 불가능: 만점도 부족" : "❌ 실패: 남은 칸 없음")
                            .font(.system(size: 13, weight: .bold)) // 글씨 키움
                            .foregroundColor(.red.opacity(0.9))
                        Spacer()
                    }
                    Spacer()
                } else {
                    // 추천 시나리오 표시
                    VStack(spacing: 2) {
                        ForEach(Array(scenarios.enumerated()), id: \.element.id) { index, scenario in
                            ScenarioRow(index: index + 1, scenario: scenario)
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 110)
            .background(Color.white.opacity(0.05))
            
            Divider().background(Color.white.opacity(0.15))
            
            // [3] 입력 패널 (스크롤 제거, 한 번에 표시)
            VStack(spacing: 4) { // ScrollView 제거
                ForEach(0..<6, id: \.self) { index in
                    DiceInputRow(dieNumber: index + 1, count: $counts[index])
                }
            }
            .padding(.vertical, 10)
            
            Spacer() // 남은 공간 밀어내기
            
            // [4] 하단 리셋
            Divider().background(Color.white.opacity(0.1))
            Button(action: {
                withAnimation { counts = [0, 0, 0, 0, 0, 0] }
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("RESET")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 30) // 버튼 높이 확보
            }
            .buttonStyle(.plain)
            .padding(.bottom, 5)
        }
        .frame(width: 200, height: 520)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.97)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - 알고리즘
    func findBestCombinations(target: Int, slots: [Int]) -> [Scenario] {
        var results: [Scenario] = []
        func backtrack(index: Int, currentScore: Int, currentComb: [Int: Int]) {
            if results.count > 15 { return }
            if currentScore >= target {
                results.append(Scenario(combination: currentComb))
                return
            }
            if index >= slots.count || currentScore > target + 30 { return }
            
            let die = slots[index]
            for count in [3, 4, 5] {
                var newComb = currentComb
                newComb[die] = count
                backtrack(index: index + 1, currentScore: currentScore + (die * count), currentComb: newComb)
            }
        }
        backtrack(index: 0, currentScore: 0, currentComb: [:])
        return results.sorted { $0.difficultyScore < $1.difficultyScore }
    }
}

// MARK: - Subviews

struct ScenarioRow: View {
    let index: Int
    let scenario: Scenario
    
    var body: some View {
        HStack(spacing: 6) {
            Text("#\(index)")
                .font(.caption2)
                .bold()
                .foregroundColor(index == 1 ? .yellow : .gray)
                .frame(width: 18)
            
            // 가로 스크롤은 유지
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(scenario.combination.keys.sorted(), id: \.self) { die in
                        HStack(spacing: 2) {
                            Image(systemName: "die.face.\(die).fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Text("x\(scenario.combination[die]!)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.3)))
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 28) // 각 행의 높이도 일정하게
    }
}

struct DiceInputRow: View {
    let dieNumber: Int
    @Binding var count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "die.face.\(dieNumber).fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(count > 0 ? .white : .gray)
                .padding(.leading, 8)
            
            Spacer()
            
            HStack(spacing: 0) {
                Button { if count > 0 { count -= 1 } } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.2))
                    Text(count > 0 ? "\(count)" : "-")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(count > 0 ? .yellow : .gray)
                }
                .frame(width: 30, height: 32)
                
                Button { if count < 5 { count += 1 } } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .cornerRadius(8)
            .padding(.trailing, 4)
            
            Text("\(dieNumber * count)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .frame(width: 30, alignment: .trailing)
                .foregroundColor(count > 0 ? .white : .gray.opacity(0.5))
                .padding(.trailing, 10)
        }
        .padding(.vertical, 2) // 간격 조정
        .background(count > 0 ? Color.white.opacity(0.05) : Color.clear)
    }
}
