//
//  NavigationHeader.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

struct NavigationHeader: View {
    var largeTitle: String
    var subTitle: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(.init(largeTitle))
                .font(.largeTitle.bold().width(.expanded))
            Text(.init(subTitle))
                .font(.subheadline).foregroundColor(.secondary)
        }
    }
}

struct NavHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHeader(largeTitle: "Media Downloader", subTitle: "Powered by you-get")
    }
}
