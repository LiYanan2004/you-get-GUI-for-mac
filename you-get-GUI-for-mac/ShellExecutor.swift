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
    var errorHandler: ((String) -> Void)?
    var resultTransferTask: Task<Void, Never>?
    var availableData = Data()
    
    var task: Process?
    var resultPipe: Pipe?
    var errorPipe: Pipe?
    
    @discardableResult
    func runShell(_ command: String) throws -> String {
        // 环境变量
        let processInfo = ProcessInfo.processInfo
        let environmentPath = processInfo.environment["PATH"] ?? ""

        task = Process()
        resultPipe = Pipe()
        errorPipe = Pipe()
        
        task!.standardOutput = resultPipe
        task!.standardError = errorPipe
        task!.launchPath = "/bin/zsh"
        task!.arguments = ["-c", command]
        task!.environment = ["PATH": "/usr/local/bin:\(environmentPath)"]
        
        startStreaming(pipe: resultPipe!)
        try task!.run()
        defer {
            stopStreaming()
            task = nil
            resultPipe = nil
            errorPipe = nil
        }
        
        if let errorData = try errorPipe?.fileHandleForReading.readToEnd() {
            let error = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            errorHandler?(error)
            return error
        } else if let outputData = try resultPipe?.fileHandleForReading.readToEnd() {
            let output = String(data: outputData, encoding: .utf8) ?? ""
            return output
        } else {
            return ""
        }
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
    
    func terminate() {
        self.resultTransferTask?.cancel()
        task?.terminate()
        task = nil
        resultPipe = nil
        errorPipe = nil
    }
}
