//
//  SectionGroupBox.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/2.
//

import SwiftUI

struct SectionGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        Section {
            configuration.content
        } header: {
            configuration.label
                .font(.headline)
        }
    }
}


extension GroupBoxStyle where Self == SectionGroupBox {
    static var section: SectionGroupBox {
        SectionGroupBox()
    }
}
