//
//  DependencyManager.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/8.
//

import SwiftUI

class DependencyManager: ObservableObject {
    @Published var missingDependency = false
    
    static var COMMAND_NOT_FOUND = "command not found"
    static var YOU_GET = "you-get"
    static var FFMPEG = "ffmpeg"
    
    init() {
        checkAllDependencies()
    }
    
    private func checkAllDependencies() {
        // Check `you-get`
        if !dependencyExists(name: DependencyManager.YOU_GET) {
            logger.warning("Cannot find/access to you-get. You should consider install you-get via terminal or follow the app guidance.")
            missingDependency = true
            return
        }
        
        // Check `ffmpeg`
        if !dependencyExists(name: DependencyManager.FFMPEG) {
            logger.notice("Missing framework: FFmpeg. Some functions rely on ffmpeg will be disabled, so we strongly suggest you install ffmpeg for a better experience.")
        }
    }
    
    private func dependencyExists(name: String) -> Bool {
        guard let shellOutput = runShell(name) else { return false }
        let missing = shellOutput.contains(Self.COMMAND_NOT_FOUND)
        
        return !missing
    }
    
    private func runShell(_ command: String) -> String? {
        do {
            return try ShellExecutor.default.runShell(command)
        } catch {
            logger.error("\(error.localizedDescription)")
        }
        return nil
    }
}


extension View {
    func disabledWhenMissingDependency() -> some View {
        modifier(MissingDependencyModifier())
    }
}

struct MissingDependencyModifier: ViewModifier {
    @StateObject private var manager = DependencyManager()
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content
            .disabled(manager.missingDependency)
            .alert("Missing: you-get", isPresented: $manager.missingDependency) {
                Button("Exit", role: .cancel) {
                    exit(0)
                }
                Button("Guide...") {
                    openURL(URL(string: "https://github.com/soimort/you-get#Installation")!)
                }
            } message: {
                Text("You need to install you-get first.")
            }
    }
}
