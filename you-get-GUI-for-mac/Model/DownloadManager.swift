//
//  DownloadManager.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/3.
//

import SwiftUI
import Combine

class DownloadManager: ObservableObject {
    @Published var videoURLString = ""
    @AppStorage("destinationString") var destinationString = "~/Downloads"
    @AppStorage("usingM3U8") var usingM3U8 = false
    @AppStorage("playlist") var playlist = true
    @Published var downloadWholePlaylist = true
    @Published var playlistOption = PlaylistOption.first
    @Published var playlistCount = 1
    @AppStorage("autoRename") var autoRename = true
    @AppStorage("overwriteFiles") var overwriteFiles = false
    @AppStorage("skipCheckFileSize") var skipCheckFileSize = false
    @AppStorage("downloadCaptions") var downloadCaptions = false
    @AppStorage("mergeVideoParts") var mergeVideoParts = true
    @AppStorage("ignoreSSLErrors") var ignoreSSLErrors = false
    @AppStorage("usingCookies") var usingCookies = false
    @AppStorage("cookies") var cookies = ""

    @Published var showExtractedInfo = false
    @Published var showExtractedJSON = false
    
    @Published var working = false
    @Published var downloading = false
    @Published var progress = 0.0
    
    let shellExecutor: ShellExecutor!
    let errorNotification = PassthroughSubject<LocalizedError, Never>()
    
    init() {
        shellExecutor = ShellExecutor()
        shellExecutor.resultHandler = {
            self.update(terminalMessage: $0)
        }
        shellExecutor.errorHandler = { error in
            self.runOnMainActor {
                // If there is an issue occured, send a notification.
                // If message doesn't contains these sentences, it'll be regarded as a normal message.
                // If the message contains other normal message, trim it.
                guard let index = error.firstRange(of: "you-get: [error] oops, something went wrong.")?.lowerBound ?? error.firstRange(of: "ffmpeg version")?.lowerBound else { return }
                self.errorNotification.send(String(error[index...]))
            }
        }
    }
    
    private func update(terminalMessage: String) {
        // Update download state
        if !downloading && terminalMessage.contains("Downloading") {
            runOnMainActor {
                self.progress = 0
                self.downloading = true
            }
        }
        let lastLine = terminalMessage
            .split(separator: "\n")
            .compactMap { $0.isEmpty ? nil : String($0) }
            .last
        if let lastLine {
            /// Get current progress.
            ///
            /// ```python
            /// self.bar = '{:>4}%% ({:>%s}/%sMB) ├{:─<%s}┤[{:>%s}/{:>%s}] {}' % (
            ///     total_str_width, total_str, self.bar_size, total_pieces_len,
            ///     total_pieces_len
            /// )
            /// ```
            if var lastestBar = lastLine.split(separator: "\r").last {
                guard lastestBar.count > 0 else { return }
                if lastestBar.first!.isWhitespace {
                    lastestBar = lastestBar.dropFirst()
                    lastestBar.insert("0", at: lastestBar.startIndex)
                }
                runOnMainActor {
                    if let progress = Double(lastestBar.prefix(4)) {
                        self.progress = progress
                        if !self.downloading { self.downloading = true }
                    } else {
                        self.downloading = false
                    }
                }
            }
        }
    }
    
    func download() async throws {
        runOnMainActor {
            self.working = true
        }
        let command = getDownloadCommand()
        logger.log("Command: \(command)")
        try shellExecutor.runShell(command)
        runOnMainActor {
            self.working = false
            self.downloading = false
        }
    }
    
    func copyDownloadCommand() {
        let command = getDownloadCommand()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
    }
    
    internal func getDownloadCommand() -> String {
        var command = "you-get "

        command += usingM3U8 ? "-m " : ""
        command += autoRename ? "-a " : ""
        command += overwriteFiles ? "-f " : ""
        command += skipCheckFileSize ? "--skip-existing-file-size-check " : ""
        command += !downloadCaptions ? "--no-caption " : ""
        command += !mergeVideoParts ? "--no-merge " : ""
        command += ignoreSSLErrors ? "-k " : ""
        command += showExtractedInfo ? "-i " : ""
        command += showExtractedJSON ? "--json " : ""
        command += usingCookies ? "--cookies \(cookies) " : ""
        if playlist {
            command += "-l "
            if !downloadWholePlaylist {
                command += "\(playlistOption.argument) \(playlistCount) "
            }
        }
        command += "-o \(destinationString) "
        command += "\"\(videoURLString)\""
//        if let cookiesFile = cookiesFile {
//            command += "-c \(cookiesFile) "
//        }
//        if let player = player {
//            command += "-p \(player) "
//        }
//        if let password = password {
//            command += "-P \(password) "
//        }
        return command
    }
    
    internal func runOnMainActor(_ action: @escaping () -> Void) {
        Task { @MainActor in
            action()
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

enum PlaylistOption {
    case first
    case last
    
    mutating func toggle() {
        switch self {
        case .first: self = .last
        case .last: self = .first
        }
    }
    
    var argument: String {
        self == .first ? "--first" : "--last"
    }
}
