//
//  ShellExecutor.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import Foundation

class ShellExecutor {
    static var `default` = ShellExecutor()
    
    var resultHandler: ((String) -> Void)?
    var resultTransferTask: Task<Void, Never>?
    var availableData = Data()
    
    @discardableResult
    func runShell(_ command: String) throws -> String {
        // 环境变量
        let processInfo = ProcessInfo.processInfo
        let environmentPath = processInfo.environment["PATH"] ?? ""

        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.environment = ["PATH": "/usr/local/bin:\(environmentPath)"]
        
        startStreaming(pipe: pipe)
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        stopStreaming()
        
        return output
    }
    
    func startStreaming(pipe: Pipe) {
        resultTransferTask = Task.detached(priority: .high) {
            var lastOutput = ""
            while true {
                guard !Task.isCancelled else { return }
                let availableData = self.updateAvailableData(with: pipe.fileHandleForReading.availableData)
                if let output = String(data: availableData, encoding: .utf8),
                   !output.isEmpty, output != lastOutput {
                    lastOutput = output
                    self.resultHandler?(output)
                }
            }
        }
    }
    
    func updateAvailableData(with data: Data) -> Data {
        availableData.append(data)
        return availableData
    }
    
    func stopStreaming() {
        resultTransferTask?.cancel()
        resultTransferTask = nil
    }
}
