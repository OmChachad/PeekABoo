//
//  PeekABooApp.swift
//  PeekABoo
//
//  Created by Om Chachad on 23/11/25.
//

import SwiftUI

@main
struct PeekABooApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        
        WindowGroup("Ask AI", id: "AskAI", for: Data.self) { $imageData in
            if let data = imageData, let uiImage = UIImage(data: data) {
                AskAIWindow(imageData: uiImage)
                    .allowsWindowActivationEvents(true)
            } else {
                Text("Could not load image.")
            }
        }
        .windowStyle(.plain)
    }
}
