//
//  NavigationPopoverModifier.swift
//  Navigator
//
//  Created by Assistant on 2/17/25.
//

import SwiftUI

/// View modifier that registers a view as a popover source and handles popover presentation
internal struct NavigationPopoverModifier: ViewModifier {
    
    let id: String
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    
    @Environment(\.navigator) private var navigator: Navigator
    @State private var popoverDestination: AnyNavigationDestination? = nil
    
    init(id: String, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge) {
        self.id = id
        self.attachmentAnchor = attachmentAnchor
        self.arrowEdge = arrowEdge
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .popover(item: $popoverDestination, attachmentAnchor: attachmentAnchor, arrowEdge: arrowEdge) { destination in
                    managedView(for: destination)
                }
                .onChange(of: navigator.state.popover) { newValue in
                    handlePopoverChange(newValue)
                }
                .onAppear {
                    registerAsPopoverSource()
                }
                .onDisappear {
                    unregisterPopoverSource()
                }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder 
    private func managedView(for destination: AnyNavigationDestination) -> some View {
        ManagedPresentationView {
            if destination.method.requiresNavigationStack {
                ManagedNavigationStack {
                    destination()
                }
            } else {
                destination()
            }
        }
    }
    
    private func registerAsPopoverSource() {
        let source = PopoverSource(
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            presentationBinding: $popoverDestination
        )
        PopoverSourceRegistry.shared.register(id: id, source: source)
    }
    
    private func unregisterPopoverSource() {
        PopoverSourceRegistry.shared.unregister(id: id)
    }
    
    private func handlePopoverChange(_ newPopover: AnyNavigationDestination?) {
        guard let newPopover = newPopover else {
            popoverDestination = nil
            return
        }
        
        // Check if this popover should be presented by this source
        let targetSourceID = newPopover.method.popoverSourceID!
        let shouldPresentHere = (targetSourceID == id)
        
        if shouldPresentHere {
            popoverDestination = newPopover
        } else {
            popoverDestination = nil
        }
    }
}

public extension View {
    
    /// Register this view as a popover source with a specific ID
    func navigationPopover(
        id: String,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge = .top
    ) -> some View {
        modifier(NavigationPopoverModifier(
            id: id,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge
        ))
    }
}
