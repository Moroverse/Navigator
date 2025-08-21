//
//  PopoverSourceRegistry.swift
//  Navigator
//
//  Created by Assistant on 2/17/25.
//

import SwiftUI
import Combine

/// Registry for managing popover sources and their presentation state
internal class PopoverSourceRegistry {
    
    @MainActor static let shared = PopoverSourceRegistry()
    
    private var sources: [String: WeakPopoverSource] = [:]
    
    private init() {}
    
    /// Register a view as a popover source
    func register(id: String, source: PopoverSource) {
        sources[id] = WeakPopoverSource(source: source)
    }
    
    /// Get a registered popover source by ID
    func source(for id: String) -> PopoverSource? {
        cleanup()
        return sources[id]?.source
    }
    
    /// Remove a specific popover source
    func unregister(id: String) {
        sources.removeValue(forKey: id)
    }
    
    /// Clean up deallocated sources  
    private func cleanup() {
        // For now, keep all sources. In a real implementation, we might want to 
        // implement a more sophisticated cleanup mechanism
    }
    
    /// Remove all sources (for testing)
    func removeAll() {
        sources.removeAll()
    }
}

/// Configuration for a popover source
internal struct PopoverSource {
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    var presentationBinding: Binding<AnyNavigationDestination?>?
    
    init(attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, presentationBinding: Binding<AnyNavigationDestination?>? = nil) {
        self.attachmentAnchor = attachmentAnchor
        self.arrowEdge = arrowEdge
        self.presentationBinding = presentationBinding
    }
}

/// Wrapper for PopoverSource
internal struct WeakPopoverSource {
    let source: PopoverSource
    
    init(source: PopoverSource) {
        self.source = source
    }
}