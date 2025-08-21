//
//  ExampleDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 2/4/25.
//

import NavigatorUI
import SwiftUI

public enum ExampleDestinations: String, NavigationDestination, CaseIterable {

    case binding
    case callback
    case transition
    case popover

    public var body: some View {
        switch self {
        case .binding:
            BindingExampleView()
        case .callback:
            CallbackExampleView()
        case .transition:
            if #available(iOS 18.0, *) {
                TransitionExampleView()
            } else {
                NotAvailableView()
            }
        case .popover:
            PopoverExampleView()
        }
    }

    public var method: NavigationMethod {
        .cover
    }

    public var title: String {
        rawValue.capitalized
    }

    public var description: String {
        switch self {
        case .binding:
            "Demonstrates using a binding in navigation destinations."
        case .callback:
            "Demonstrates using callback handlers and checkpoints in navigation destinations."
        case .transition:
            "Demonstrates custom transitions with navigation destinations. (iOS 18.0+)"
        case .popover:
            "Demonstrates popover navigation with various attachment strategies."
        }
    }

}

private struct NotAvailableView: View {
    @Environment(\.navigator) var navigator
    var body: some View {
        List {
            Text("Not Available")
            Button("Dismiss") {
                navigator.dismiss()
            }
        }
    }
}
