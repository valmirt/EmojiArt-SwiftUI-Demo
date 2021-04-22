//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    private let viewModel = EmojiArtDocumentStore(named: "Emoji Art")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(viewModel)
        }
    }
}
