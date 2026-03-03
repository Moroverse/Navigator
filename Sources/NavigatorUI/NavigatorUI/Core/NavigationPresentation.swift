//
//  NavigationPresentation.swift
//  Navigator
//
//  Created by Michael Long on 1/22/25.
//

import SwiftUI

extension Navigator {

    /// Convenience method resents a sheet/managed sheet.
    ///
    /// Managed attribute (wrapped in a ManagedNavigationStack) can be used to override NavigationDestination's default method. Otherwise
    /// the method will take its cue from the destination.method (true if method == .managedCover, false if anything else).
    @MainActor
    public func present(sheet destination: any NavigationDestination, managed: Bool? = nil) {
        if let managed {
            let method: NavigationMethod = managed ? .managedSheet : .sheet
            navigate(to: destination, method: method)
        } else if case .managedSheet = destination.method {
            navigate(to: destination, method: .managedSheet)
        } else {
            navigate(to: destination, method: .sheet)
        }
    }

    /// Convenience method resents a cover/managed cover.
    ///
    /// Managed attribute (wrapped in a ManagedNavigationStack) can be used to override NavigationDestination's default method. Otherwise
    /// the method will take its cue from the destination.method (true if method == .managedCover, false if anything else).
    @MainActor
    public func present(cover destination: any NavigationDestination, managed: Bool? = nil) {
        if let managed {
            let method: NavigationMethod = managed ? .managedCover : .cover
            navigate(to: destination, method: method)
        } else if case .managedCover = destination.method {
            navigate(to: destination, method: .managedCover)
        } else {
            navigate(to: destination, method: .cover)
        }
    }

    /// Convenience method presents a popover with a specific source ID
    @MainActor
    public func present(popover: any NavigationDestination, sourceID: String) {
        navigate(to: popover, method: .popover(sourceID: sourceID))
    }

    /// Convenience method presents a destination in the inspector panel.
    ///
    /// Managed attribute (wrapped in a ManagedNavigationStack) can be used to override NavigationDestination's default method. Otherwise
    /// the method will take its cue from the destination.method (true if method == .managedInspector, false if anything else).
    @MainActor
    public func present(inspector destination: any NavigationDestination, managed: Bool? = nil) {
        if let managed {
            let method: NavigationMethod = managed ? .managedInspector : .inspector
            navigate(to: destination, method: method)
        } else if case .managedInspector = destination.method {
            navigate(to: destination, method: .managedInspector)
        } else {
            navigate(to: destination, method: .inspector)
        }
    }

    /// Shows the given destination in the inspector panel.
    @MainActor
    public func showInspector(_ destination: any NavigationDestination) {
        navigate(to: destination, method: destination.method)
    }

    /// Hides the inspector panel.
    @MainActor
    public func hideInspector() {
        state.inspector = nil
    }

    /// Returns true if the inspector panel is currently showing content.
    public nonisolated var isInspectorVisible: Bool {
        state.inspector != nil
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isPresenting: Bool {
        state.isPresenting
    }

    /// Returns true if any child of the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isAnyChildPresenting: Bool {
        state.isAnyChildPresenting
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presented.
    public nonisolated var isPresented: Bool {
        state.isPresented
    }

    /// Returns NavigationDestination of sheet or cover we're currently presenting, if any.
    public nonisolated var presentingSheetOrCover: (any NavigationDestination)? {
        (state.sheet ?? state.cover)?.wrapped as? NavigationDestination
    }
}

extension View {

    /// Allows presented views not in a navigation stack to be dismissed using a Navigator.
    ///
    /// Also supports nested sheets and covers.
    ///
    /// If you present sheets or covers in your own code, outside of `navigate(to:)`, and if those presented
    /// views don't use ``ManagedNavigationStack``, then `ManagedPresentationView`  tells Navigator about them.
    /// ```swift
    /// Button("Present Page 3 via Sheet") {
    ///     showSettings = .page3
    /// }
    /// .sheet(item: $showSettings) { destination in
    ///     destination()
    ///         .managedPresentationView()
    /// }
    /// ```
    /// That in turn allows them to be manipulated or closed when performing deep linking actions like dismissAny().
    ///
    /// This modifier is just a wrapper around ``ManagedPresentationView``.
    /// ```swift
    /// .sheet(item: $showSettings) { destination in
    ///     ManagedPresentationView {
    ///         destination()
    ///     }
    /// }
    /// ```
    /// > Warning: Failure to tag presented views as such can lead to inconsistent deep linking and navigation behavior.
    public func managedPresentationView() -> some View {
        ManagedPresentationView {
            self
        }
    }

}

extension NavigationState {

    internal nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    internal nonisolated var isAnyChildPresenting: Bool {
        children.values.first(where: {
            if let object = $0.object, object.isPresented || object.isAnyChildPresenting {
                return true
            }
            return false
        }) != nil
    }

}

internal struct NavigationPresentationModifiers: ViewModifier {

    @ObservedObject internal var state: NavigationState

    func body(content: Content) -> some View {
        content
            .sheet(item: $state.sheet) { (destination) in
                managedView(for: destination)
            }
            #if os(iOS) || os(tvOS) || os(watchOS)
            .fullScreenCover(item: $state.cover) { (destination) in
                managedView(for: destination)
            }
            #endif
    }

    @ViewBuilder func managedView(for destination: AnyNavigationDestination) -> some View {
        ManagedPresentationView {
            if destination.method.requiresNavigationStack {
                ManagedNavigationStack {
                    state.mappedPresentationView(for: destination.wrapped)
                }
            } else {
                state.mappedPresentationView(for: destination.wrapped)
            }
        }
    }

}

@available(iOS 17.0, macOS 14.0, *)
internal struct NavigationInspectorStackModifier: ViewModifier {
    @ObservedObject internal var state: NavigationState
    @State private var isPresented: Bool = false

    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isPresented) {
                inspectorContent
            }
            .onReceive(state.objectWillChange) { _ in
                DispatchQueue.main.async {
                    let shouldPresent = state.inspector != nil
                    if isPresented != shouldPresent {
                        isPresented = shouldPresent
                    }
                }
            }
            .onChange(of: isPresented) { _, newValue in
                if !newValue && state.inspector != nil {
                    state.inspector = nil
                }
            }
    }

    @ViewBuilder
    private var inspectorContent: some View {
        if let destination = state.inspector {
            if destination.method.requiresNavigationStack {
                ManagedNavigationStack {
                    state.mappedPresentationView(for: destination.wrapped)
                }
            } else {
                NavigationStack {
                    state.mappedPresentationView(for: destination.wrapped)
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func applyInspectorIfAvailable(state: NavigationState) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.modifier(NavigationInspectorStackModifier(state: state))
        } else {
            self
        }
    }
}
