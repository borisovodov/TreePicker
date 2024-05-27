//
//  SupportingViews.swift
//
//
//  Created by Boris Ovodov on 27.05.2024.
//

import SwiftUI

#if os(macOS)
internal struct LabelChevron: View {
    var body: some View {
        Image(systemName: "chevron.down.square.fill")
            .padding(.trailing, -4)
            .symbolRenderingMode(.multicolor)
            .foregroundStyle(Color.accentColor)
            .font(.body.bold())
            .shadow(radius: 2)
    }
}
#endif
