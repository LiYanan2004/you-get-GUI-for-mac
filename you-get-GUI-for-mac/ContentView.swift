//
//  ContentView.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var downloadManager = DownloadManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                NavigationHeader(
                    largeTitle: "Media Downloader",
                    subTitle: "Powered by [you-get](https://github.com/soimort/you-get)"
                )
                Spacer()
                DownloadButton().focusable(false)
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
                    Toggle("Using M3U8", isOn: $downloadManager.usingM3U8)
                    Toggle("Auto Rename", isOn: $downloadManager.autoRename)
                    Toggle("Overwrite Files", isOn: $downloadManager.overwriteFiles)
                    Toggle("Skip Check File Size", isOn: $downloadManager.skipCheckFileSize)
                    Toggle("Download Captions", isOn: $downloadManager.downloadCaptions)
                    Toggle("Merge Video Parts", isOn: $downloadManager.mergeVideoParts)
                } label: {
                    Text("Download Options")
                }
                
                GroupBox {
                    Toggle("Ignore SSL Errors", isOn: $downloadManager.ignoreSSLErrors)
                    Toggle("Show Extracted Info", isOn: $downloadManager.showExtractedInfo)
                    Toggle("Show Extracted JSON", isOn: $downloadManager.showExtractedJSON)
                    LabeledContent("You-get Version", value: "0.4.1650")
                } label: {
                    Text("Debugging Options")
                }
            }
            .formStyle(.grouped)
            .toggleStyle(.switch)
            .groupBoxStyle(.section)
            .controlSize(.large)
        }
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
