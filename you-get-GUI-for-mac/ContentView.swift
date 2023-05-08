//
//  ContentView.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var downloadManager = DownloadManager()
    @State private var showAlert = false
    @State private var error: String? = nil
    @Namespace private var container
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                NavigationHeader(
                    largeTitle: "Media Downloader",
                    subTitle: "Powered by [you-get](https://github.com/soimort/you-get)"
                )
                Spacer()
                DownloadButton()
                    .focusable(false)
                    .allowsHitTesting(!downloadManager.working)
            }
            .scenePadding()
            
            Form {
                TextField("Video URL", text: $downloadManager.videoURLString)
                LabeledContent("Destination") {
                    let location = Binding<URL> {
                        URL(filePath: downloadManager.destinationString)
                    } set: {
                        downloadManager.destinationString = $0.path()
                    }
                    FileLocationButton(location: location)
                        .buttonStyle(.borderless)
                }
                
                GroupBox {
                    Toggle("Auto Rename", isOn: $downloadManager.autoRename)
                    Toggle("Download Captions", isOn: $downloadManager.downloadCaptions)
                    Toggle("Overwrite Files", isOn: $downloadManager.overwriteFiles)
                    Toggle("Skip Check File Size", isOn: $downloadManager.skipCheckFileSize)
                    Toggle("Using M3U8", isOn: $downloadManager.usingM3U8)
                    Toggle("Merge Video Parts", isOn: $downloadManager.mergeVideoParts)
                } label: {
                    Text("Download Options")
                }
                
                GroupBox {
                    Toggle("Download Playlist", isOn: $downloadManager.playlist)
                    if downloadManager.playlist {
                        Toggle("Whole Playlist", isOn: $downloadManager.downloadWholePlaylist.animation())
                        if !downloadManager.downloadWholePlaylist {
                            LabeledContent("Download") {
                                HStack {
                                    Button(downloadManager.playlistOption == .first ? "First" : "Last") {
                                        downloadManager.playlistOption.toggle()
                                    }
                                    TextField("Count", value: $downloadManager.playlistCount, formatter: NumberFormatter())
                                        .frame(width: 60)
                                    Text("Page")
                                }
                                .buttonStyle(.borderless)
                                .labelsHidden()
                            }
                        }
                        
                    }
                } label: {
                    Text("Playlist")
                }
                
                GroupBox {
                    Toggle("Ignore SSL Errors", isOn: $downloadManager.ignoreSSLErrors)
                    LabeledContent("Show Extracted Info") {
                        DryRunButton(json: false)
                    }
                    LabeledContent("Show Extracted JSON") {
                        DryRunButton(json: true)
                    }
                    LabeledContent("You-get Version", value: "0.4.1650")
                } label: {
                    Text("Debugging Options")
                }
                .buttonStyle(.link)
            }
            .formStyle(.grouped)
            .toggleStyle(.switch)
            .groupBoxStyle(.section)
            .controlSize(.large)
            .prefersDefaultFocus(in: container)
        }
        .disabledWhenMissingDependency()
        .focusScope(container)
        .onReceive(downloadManager.errorNotification) {
            self.error = $0 as? String
            self.showAlert = true
        }
        .alert(isPresented: $showAlert, error: error) { }
        .environmentObject(downloadManager)
        .scrollContentBackground(.hidden)
        .background {
            MaterialView().ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 300, maxWidth: 500, minHeight: 600)
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
