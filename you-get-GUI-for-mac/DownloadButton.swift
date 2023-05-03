//
//  DownloadButton.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/3.
//

import SwiftUI

struct DownloadButton: View {
    @EnvironmentObject private var downloadManager: DownloadManager
    
    var body: some View {
        Button(action: download) {
            Image(systemName: "arrow.down")
                .font(.title.bold())
                .padding(8)
                .background(.background.shadow(.inner(color: .black.opacity(0.1), radius: 2, x: -1, y: -1)), in: RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 20)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: download) {
                Label("Download", systemImage: "arrow.down")
            }
            
            Button(action: copyCommand) {
                Label("Copy download command", systemImage: "text.and.command.macwindow")
            }
        }
    }
    
    private func download() {
        Task {
            try await downloadManager.download()
        }
    }
    
    private func copyCommand() {
        downloadManager.copyDownloadCommand()
    }
}

struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButton()
            .environmentObject(DownloadManager())
    }
}
