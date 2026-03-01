//
//  NavigationInspectorModifier.swift
//  Navigator
//

import SwiftUI

/// View modifier that handles inspector presentation driven by Navigator state.
@available(iOS 17.0, macOS 14.0, *)
internal struct NavigationInspectorModifier: ViewModifier {

    @Environment(\.navigator) private var navigator: Navigator
    @State private var isPresented: Bool = false

    let managed: Bool

    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isPresented) {
                inspectorContent
            }
            .onReceive(navigator.state.objectWillChange) { _ in
                // Sync local isPresented with navigator state on next run loop
                DispatchQueue.main.async {
                    let shouldPresent = navigator.state.inspector != nil
                    if isPresented != shouldPresent {
                        isPresented = shouldPresent
                    }
                }
            }
            .onChange(of: isPresented) { _, newValue in
                // User dismissed inspector via UI (e.g. swipe) — sync back to state
                if !newValue && navigator.state.inspector != nil {
                    navigator.state.inspector = nil
                }
            }
    }

    @ViewBuilder
    private var inspectorContent: some View {
        if let destination = navigator.state.inspector {
            if managed || destination.method.requiresNavigationStack {
                ManagedNavigationStack {
                    navigator.state.mappedPresentationView(for: destination.wrapped)
                }
            } else {
                NavigationStack {
                    navigator.state.mappedPresentationView(for: destination.wrapped)
                }
            }
        }
    }
}

public extension View {

    /// Attaches a navigator-driven inspector panel to this view.
    ///
    /// When `navigator.showInspector(destination)` or `navigator.navigate(to:method:.inspector)` is called,
    /// the inspector will open and display the destination's body. When `navigator.hideInspector()` is called,
    /// the inspector will close.
    ///
    /// - Parameter managed: When `true`, the inspector content is wrapped in a `ManagedNavigationStack`.
    ///   Defaults to `false`. When `false`, the inspector still wraps in a plain `NavigationStack`.
    @available(iOS 17.0, macOS 14.0, *)
    func navigationInspector(managed: Bool = false) -> some View {
        modifier(NavigationInspectorModifier(managed: managed))
    }
}
