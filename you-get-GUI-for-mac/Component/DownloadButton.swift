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
            let working = downloadManager.working
            let downloading = downloadManager.downloading
            ZStack {
                Image(systemName: "arrow.down")
                    .rotationEffect(.degrees(working ? 540 : 0))
                    .scaleEffect(working ? 0.6 : 1)
                    .blur(radius: working ? 2 : 0)
                    .opacity(working ? 0 : 1)
                ProgressView()
                    .controlSize(.small)
                    .rotationEffect(.degrees(working ? 0 : 360))
                    .scaleEffect(downloading ? 0.8 : 1)
                    .blur(radius: working && !downloading ? 0 : 2)
                    .opacity(working && !downloading ? 1 : 0)
            }
            .font(.title.bold())
            .padding(8)
            .overlay {
                Text("\(downloadManager.progress.formatted(.number.precision(.fractionLength(0))))%")
                    .monospaced()
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .blendMode(.difference)
                    .overlay {
                        Text("\(downloadManager.progress.formatted(.number.precision(.fractionLength(0))))%")
                            .monospaced()
                            .font(.headline.bold())
                            .blendMode(.hue)
                    }
                    .overlay {
                        Text("\(downloadManager.progress.formatted(.number.precision(.fractionLength(0))))%")
                            .monospaced()
                            .font(.headline.bold())
                            .foregroundColor(.cyan)
                            .blendMode(.overlay)
                    }
                    .overlay {
                        Text("\(downloadManager.progress.formatted(.number.precision(.fractionLength(0))))%")
                            .monospaced()
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .blendMode(.overlay)
                    }
                    .overlay {
                        Text("\(downloadManager.progress.formatted(.number.precision(.fractionLength(0))))%")
                            .monospaced()
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .blendMode(.overlay)
                    }
                    .opacity(downloading ? 1 : 0)
            }
            .background(backgroundWaves.clipShape(RoundedRectangle(cornerRadius: 8)))
            .animation(.easeInOut, value: working)
            .background(.background.shadow(.inner(color: .black.opacity(0.1), radius: 2, x: -1, y: -1)), in: RoundedRectangle(cornerRadius: 8))
            .compositingGroup()
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
    
    @ViewBuilder
    private var backgroundWaves: some View {
        Rectangle()
            .fill(Color.cyan.gradient)
            .opacity(downloadManager.downloading ? 1 : 0)
            .mask {
                if downloadManager.downloading {
                    WaveView(value: downloadManager.progress, total: 100)
                        .animation(.spring(), value: downloadManager.progress)
                        .transition(.offset(y: 100).animation(.spring()))
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
        @StateObject var manager = DownloadManager()
        DownloadButton()
            .environmentObject(manager)
            .onTapGesture {
                Task {
                    manager.working = true
                    for i in 0...100 {
                        manager.progress = Double(i)
                        try await Task.sleep(for: .microseconds(100))
                    }
                }
            }
    }
}
