//
//  CommandGenerator.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/3.
//

import SwiftUI

class DownloadManager: ObservableObject {
    @Published var videoURLString = "https://www.bilibili.com/video/BV1Eg4y1L79p/?spm_id_from=333.999.0.0&vd_source=55ee9459b59c21c0c87d1bd1acb2902c"
    @Published var destinationString = "~/Desktop"
    @Published var usingM3U8 = false
    @Published var autoRename = false
    @Published var overwriteFiles = false
    @Published var skipCheckFileSize = false
    @Published var downloadCaptions = false
    @Published var mergeVideoParts = false
    @Published var ignoreSSLErrors = false
    @Published var showExtractedInfo = true
    @Published var showExtractedJSON = false
    
    let shellExecutor: ShellExecutor!
    
    init() {
        shellExecutor = ShellExecutor { output in
            print("---")
            print(output)
            print("---")
        }
    }
    
    func download() async throws {
        let command = getDownloadCommand()
        print(command)
        let result = try shellExecutor.runShell(command)
        print("Finished. Result: \(result)")
    }
    
    func copyDownloadCommand() {
        let command = getDownloadCommand()
        NSPasteboard.general.setString(command, forType: .string)
    }
    
    internal func getDownloadCommand() -> String {
        var command = "~/Downloads/you-get/you-get "

        command += usingM3U8 ? "-m " : ""
        command += autoRename ? "-a " : ""
        command += overwriteFiles ? "-f " : ""
        command += skipCheckFileSize ? "--skip-existing-file-size-check " : ""
        command += !downloadCaptions ? "--no-caption " : ""
        command += !mergeVideoParts ? "--no-merge " : ""
        command += ignoreSSLErrors ? "-k " : ""
        command += showExtractedInfo ? "-i " : ""
        command += showExtractedJSON ? "--json " : ""
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
//        if playlist {
//            command += "-l "
//            if let first = playlistFirst {
//                command += "--first \(first) "
//            }
//            if let last = playlistLast {
//                command += "--last \(last) "
//            }
//            if let pageSize = playlistPageSize {
//                command += "--size \(pageSize) "
//            }
//        }
        return command
    }
}
