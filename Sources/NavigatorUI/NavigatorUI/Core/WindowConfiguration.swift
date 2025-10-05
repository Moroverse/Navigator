//
//  WindowConfiguration.swift
//  NavigatorUI
//
//  Created by Daniel Moro on 5. 10. 2025..
//

import SwiftUI

nonisolated public struct WindowConfiguration<T>: Equatable, Hashable, Sendable where T: Codable & Hashable {
    internal let identifier: String
}

internal struct AnyWindowConfiguration: Hashable, Sendable {
    var identifier: String
}

public protocol WindowConfigurations {}

extension WindowConfigurations {
    public static func configuration<T: Codable & Hashable>(_ identifier: String = #function) -> WindowConfiguration<T> {
        return WindowConfiguration<T>(identifier: identifier)
    }
}


internal struct WindowNavigationModifier<T: Codable & Hashable>: ViewModifier {
    @State internal var configuration: WindowConfiguration<T>
    @Environment(\.navigator) private var navigator: Navigator
    @Environment(\.openWindow) private var openWindow
    func body(content: Content) -> some View {
        content
            .onReceive(navigator.state.publisher) { values in
                if let value: T = values.consume(configuration.identifier) {
                    openWindow(id: configuration.identifier, value: value)
                    values.resume(.auto)
                }
            }
            .modifier(AddWindowConfigurationModifier(configuration: configuration))
    }
}

private struct AddWindowConfigurationModifier<T: Codable & Hashable>: ViewModifier {
    @Environment(\.navigator) var navigator: Navigator
    internal let configuration: WindowConfiguration<T>
    func body(content: Content) -> some View {
        content
            .task { navigator.addWindowConfiguration(configuration) }
    }
}

extension View {
    public func windowConfiguration<T: Codable & Hashable>(_ configuration: WindowConfiguration<T>) -> some View {
        self.modifier(WindowNavigationModifier(configuration: configuration))
    }
}


extension Navigator {
    @MainActor
    internal func addWindowConfiguration<T: Codable & Hashable>(_ configuration: WindowConfiguration<T>) {
        state.addWindowConfiguration(configuration)
    }

    @MainActor
    public func openWindow<T: Codable & Hashable>(_ configuration: WindowConfiguration<T>, value: T) {
        state.openWindow(configuration, value: value)
    }
}


extension NavigationState {
    @MainActor internal func addWindowConfiguration<T: Codable & Hashable>(_ windowConfiguration: WindowConfiguration<T>) {
        if windowConfigurations[windowConfiguration.identifier] != nil {
            return
        }
        windowConfigurations[windowConfiguration.identifier] = AnyWindowConfiguration(identifier: windowConfiguration.identifier)
    }

    internal func find<T: Codable & Hashable>(_ configuration: WindowConfiguration<T>) -> AnyWindowConfiguration? {
        if let found = windowConfigurations.values
            .filter({ $0.identifier == configuration.identifier })
            .first {
            return found
        }
        return parent?.find(configuration)
    }

    @MainActor internal func openWindow<T: Codable & Hashable>(_ configuration: WindowConfiguration<T>, value: T) {
        guard let found = find(configuration) else {
            log(.warning("window configuration value handler not found: \(configuration.identifier)"))
            return
        }
        
        let values = NavigationSendValues(navigator: Navigator(state: self), identifier: found.identifier, value: value)
        publisher.send(values)
    }
}
