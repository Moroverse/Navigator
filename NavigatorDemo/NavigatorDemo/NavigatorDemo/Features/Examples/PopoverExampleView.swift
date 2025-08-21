//
//  PopoverExampleView.swift
//  NavigatorDemo
//
//  Created by Assistant on 2/17/25.
//

import NavigatorUI
import SwiftUI

struct PopoverExampleView: View {
    
    @Environment(\.navigator) var navigator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                Text("Popover Navigation Examples")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Basic Popover Example
                VStack(spacing: 16) {
                    Text("Basic Popover")
                        .font(.headline)
                    
                    Button("Show Filter Options") {
                        navigator.navigate(to: PopoverDestinations.filterOptions, method: .popover(sourceID: "filter-button"))
                    }
                    .buttonStyle(.borderedProminent)
                    .navigationPopover(id: "filter-button", arrowEdge: .top)
                    
                    Text("Tap the button to show a popover with filter options")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Multiple Source Example
                VStack(spacing: 16) {
                    Text("Multiple Popover Sources")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button("Help") {
                            navigator.navigate(to: PopoverDestinations.help, method: .popover(sourceID: "help"))
                        }
                        .buttonStyle(.bordered)
                        .navigationPopover(id: "help", arrowEdge: .bottom)
                        
                        Button("Settings") {
                            navigator.navigate(to: PopoverDestinations.settings, method: .popover(sourceID: "settings"))
                        }
                        .buttonStyle(.bordered)
                        .navigationPopover(id: "settings", arrowEdge: .top)
                        
                        Button("Info") {
                            navigator.navigate(to: PopoverDestinations.info, method: .popover(sourceID: "info"))
                        }
                        .buttonStyle(.bordered)
                        .navigationPopover(id: "info", arrowEdge: .leading)
                    }
                    
                    Text("Each button shows its popover with different arrow directions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Managed Popover Example
                VStack(spacing: 16) {
                    Text("Managed Popover (with Navigation)")
                        .font(.headline)
                    
                    Button("Show Product Catalog") {
                        navigator.navigate(to: PopoverDestinations.productCatalog, method: .managedPopover(sourceID: "catalog-button"))
                    }
                    .buttonStyle(.borderedProminent)
                    .navigationPopover(id: "catalog-button", attachmentAnchor: .point(.center), arrowEdge: .top)
                    
                    Text("This popover contains its own navigation stack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // Multiple Sources Example
                VStack(spacing: 16) {
                    Text("Multiple Sources")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Button("First Button") {
                            navigator.navigate(to: PopoverDestinations.autoDetect, method: .popover(sourceID: "first-button"))
                        }
                        .navigationPopover(id: "first-button", arrowEdge: .trailing)
                        
                        Button("Second Button") {
                            navigator.navigate(to: PopoverDestinations.autoDetect, method: .popover(sourceID: "second-button"))
                        }
                        .navigationPopover(id: "second-button", arrowEdge: .leading)
                        
                        Text("Each button has its own sourceID and shows popover with different arrow directions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                
                // Convenience Methods Example
                VStack(spacing: 16) {
                    Text("Convenience Methods")
                        .font(.headline)
                    
                    Button("Using present(popover:sourceID:)") {
                        navigator.present(popover: PopoverDestinations.convenience, sourceID: "convenience-button")
                    }
                    .buttonStyle(.bordered)
                    .navigationPopover(id: "convenience-button", arrowEdge: .bottom)
                    
                    Text("Using the convenience method for popover presentation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Popover Examples")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        PopoverExampleView()
    }
}