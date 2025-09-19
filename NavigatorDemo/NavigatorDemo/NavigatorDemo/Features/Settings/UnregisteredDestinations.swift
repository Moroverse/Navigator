//
//  LoadingDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 3/9/25.
//

import NavigatorUI
import SwiftUI

public enum UnregisteredDestinations: @MainActor NavigationDestination {

    case page1
    case page2

    public var body: some View {
        switch self {
        case .page1:
            Text("Page 1")
        case .page2:
            Text("Page 2")
        }
    }

}
