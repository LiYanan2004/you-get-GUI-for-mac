//
//  you_get_GUI_for_macApp.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

@main
struct you_get_GUI_for_macApp: App {
    var body: some Scene {
        Window("Media Downloader", id: "downloader") {
            ContentView()
                .frame(minWidth: 300, maxWidth: 500, minHeight: 600)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
