import SwiftUI

@main
struct YachtHelperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    guard let window = NSApplication.shared.windows.first else { return }
                    
                    // 1. 항상 맨 위에 고정 (게임 화면 안 가리게)
                    window.level = .floating
                    
                    // 2. 타이틀 바 제거
                    window.styleMask.insert(.fullSizeContentView)
                    window.titleVisibility = .hidden
                    window.titlebarAppearsTransparent = true
                    
                    // 3. 배경 투명 & 이동 가능
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.isMovableByWindowBackground = true
                    
                    // 4. 크기 조절 막기
                    window.styleMask.remove(.resizable)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
