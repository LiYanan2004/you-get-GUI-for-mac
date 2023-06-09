//
//  FileLocationButton.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/6.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileLocationButton: View {
    @Binding var location: URL
    @State private var showPannel = false
    var allowedContentTypes: [UTType]
    
    var body: some View {
        Button {
            showPannel = true
        } label: {
            HStack(spacing: 8) {
                Text("\(location.path(percentEncoded: false))")
                    .lineLimit(1)
                    .truncationMode(.head)
                Image(systemName: "magnifyingglass")
            }
        }
        .fileImporter(isPresented: $showPannel, allowedContentTypes: allowedContentTypes) { result in
            switch result {
            case .success(let url):
                location = url
            case .failure(let error):
                logger.error("\(error.localizedDescription)")
            }
        }
    }
}

struct FileLocationButton_Previews: PreviewProvider {
    static var previews: some View {
        FileLocationButton(location: .constant(.downloadsDirectory), allowedContentTypes: [.folder])
    }
}
