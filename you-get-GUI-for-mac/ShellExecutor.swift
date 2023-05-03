//
//  ShellExecutor.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import Foundation

class ShellExecutor {
    static var `default` = ShellExecutor()
    
    var resultHandler: (@Sendable (String) -> Void)?
    var resultTransferTask: Task<Void, Never>?
    var availableData = Data()
    
    init(resultHandler: (@Sendable (String) -> Void)? = nil) {
        self.resultHandler = resultHandler
    }
    
    @discardableResult
    func runShell(_ command: String, refreshInterval: TimeInterval = 0.5) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        startStreaming(pipe: pipe, refreshInterval: refreshInterval)
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        stopStreaming()
        
        return output
    }
    
    func startStreaming(pipe: Pipe, refreshInterval: TimeInterval) {
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
