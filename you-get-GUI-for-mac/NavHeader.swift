//
//  NavigationHeader.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

struct NavigationHeader: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Media Downloader")
                .font(.largeTitle.bold().width(.expanded))
            Text("Powered by You-Get")
                .font(.subheadline).foregroundColor(.secondary)
        }
    }
}

struct NavHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHeader()
    }
}
