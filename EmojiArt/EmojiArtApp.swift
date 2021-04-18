//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = EmojiArtViewModel()
            ContentView(viewModel: viewModel)
        }
    }
}
