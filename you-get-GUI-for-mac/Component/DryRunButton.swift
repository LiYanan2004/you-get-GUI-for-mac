//
//  DryRunButton.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/6.
//

import SwiftUI

struct DryRunButton: View {
    var json: Bool
    @EnvironmentObject private var downloadManager: DownloadManager
    @State private var messages: String = ""
    @State private var showDebugInfo = false
    @State private var shellExecutor = ShellExecutor()
    
    var running: Bool { showDebugInfo }
    
    var body: some View {
        ZStack {
            Button("Run") {
                showDebugInfo = true
                messages = ""
                let command = downloadManager.extractInfo(json: json, executor: shellExecutor)
                Task.detached {
                    // Run the task and wait until the end or it's cancelled.
                    try await self.shellExecutor.runShell(command)
                    Task { @MainActor in
                        guard !messages.isEmpty else { return }
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(messages, forType: .string)
                    }
                }
            }
            .opacity(running ? 0 : 1)
            
            ProgressView()
                .controlSize(.small)
                .opacity(running ? 1 : 0)
        }
        .popover(isPresented: $showDebugInfo) {
            ScrollViewReader { scroller in
                ScrollView {
                    VStack(alignment: .leading) {
                        let splittedText = messages
                            .split(separator: "\n", omittingEmptySubsequences: false)
                            .map({String($0)})
                        ForEach(splittedText, id: \.hash) { message in
                            Text(message)
                        }
                        Color.clear.id("bottom").frame(height: 1)
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    withAnimation {
                        scroller.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .frame(width: 500, height: 400)
            .overlay {
                if running {
                    Color.black.opacity(0.1).allowsHitTesting(false)
                    ProgressView()
                }
            }
        }
        .onChange(of: showDebugInfo) { newValue in
            if newValue == false {
                shellExecutor.terminate()
            }
        }
        .onAppear {
            shellExecutor.resultHandler = {
                logger.debug("Received a new message")
                messages = $0
            }
        }
    }
}

struct DryRunButton_Previews: PreviewProvider {
    static var previews: some View {
        DryRunButton(json: false)
    }
}

extension DownloadManager {
    @MainActor
    fileprivate func extractInfo(json: Bool, executor: ShellExecutor) -> String {
        if json {
            showExtractedJSON = true
        } else {
            showExtractedInfo = true
        }
        let command = getDownloadCommand()
        showExtractedInfo = false
        showExtractedJSON = false
        return command
    }
}
