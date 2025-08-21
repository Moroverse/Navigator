//
//  PopoverDestinations.swift
//  NavigatorDemo
//
//  Created by Assistant on 2/17/25.
//

import NavigatorUI
import SwiftUI

public enum PopoverDestinations: String, NavigationDestination, CaseIterable {
    
    case filterOptions
    case help
    case settings
    case info
    case productCatalog
    case autoDetect
    case convenience
    
    public var body: some View {
        switch self {
        case .filterOptions:
            FilterOptionsView()
        case .help:
            HelpView()
        case .settings:
            QuickSettingsView()
        case .info:
            InfoView()
        case .productCatalog:
            ProductCatalogView()
        case .autoDetect:
            AutoDetectView()
        case .convenience:
            ConvenienceView()
        }
    }
    
    public var title: String {
        switch self {
        case .filterOptions:
            "Filter Options"
        case .help:
            "Help"
        case .settings:
            "Settings"
        case .info:
            "Info"
        case .productCatalog:
            "Product Catalog"
        case .autoDetect:
            "Auto Detect"
        case .convenience:
            "Convenience"
        }
    }
}

// MARK: - Popover Content Views

private struct FilterOptionsView: View {
    @Environment(\.navigator) var navigator
    @State private var showInStock = true
    @State private var showOnSale = false
    @State private var showFeatured = true
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Filter Options")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("In Stock", isOn: $showInStock)
                Toggle("On Sale", isOn: $showOnSale)
                Toggle("Featured", isOn: $showFeatured)
            }
            
            HStack {
                Button("Reset") {
                    showInStock = true
                    showOnSale = false
                    showFeatured = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Apply") {
                    navigator.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 250)
    }
}

private struct HelpView: View {
    @Environment(\.navigator) var navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Help")
                .font(.headline)
            
            Text("This is a help popover showing useful information and tips.")
                .multilineTextAlignment(.center)
            
            Button("Got it!") {
                navigator.dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 200)
    }
}

private struct QuickSettingsView: View {
    @Environment(\.navigator) var navigator
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkMode)
            }
            
            Button("Done") {
                navigator.dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 200)
    }
}

private struct InfoView: View {
    @Environment(\.navigator) var navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Version: 1.0.0")
                Text("Build: 123")
                Text("Navigator Demo")
            }
            .font(.caption)
            
            Button("Close") {
                navigator.dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 180)
    }
}

private struct ProductCatalogView: View {
    @Environment(\.navigator) var navigator
    
    var body: some View {
        NavigationView {
            List {
                Section("Categories") {
                    ForEach(["Electronics", "Clothing", "Books", "Home & Garden"], id: \.self) { category in
                        NavigationLink(category) {
                            ProductListView(category: category)
                        }
                    }
                }
            }
            .navigationTitle("Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        navigator.dismiss()
                    }
                }
            }
        }
        .frame(width: 350, height: 400)
    }
}

private struct ProductListView: View {
    let category: String
    
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { item in
                Text("\(category) Item \(item)")
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AutoDetectView: View {
    @Environment(\.navigator) var navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.largeTitle)
                .foregroundColor(.purple)
            
            Text("Auto-Detected!")
                .font(.headline)
            
            Text("This popover was automatically attached to the most recently registered source.")
                .multilineTextAlignment(.center)
                .font(.caption)
            
            Button("Dismiss") {
                navigator.dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 250)
    }
}

private struct ConvenienceView: View {
    @Environment(\.navigator) var navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.tap.fill")
                .font(.largeTitle)
                .foregroundColor(.pink)
            
            Text("Convenience Method")
                .font(.headline)
            
            Text("This popover was presented using navigator.present(popover:)")
                .multilineTextAlignment(.center)
                .font(.caption)
            
            Button("Nice!") {
                navigator.dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 220)
    }
}