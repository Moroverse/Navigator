//
//  TabView.swift
//  Nav5
//
//  Created by Michael Long on 11/15/24.
//

import NavigatorUI
import SwiftUI

struct RootTabView : View {
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            ModernTabView()
        } else {
            StandardTabView()
        }
    }
}

#Preview {
    RootTabView()
}
