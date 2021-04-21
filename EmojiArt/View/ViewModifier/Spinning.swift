//
//  Spinning.swift
//  EmojiArt
//
//  Created by Valmir Junior on 21/04/21.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { isVisible = true }
    }
}

extension View {
    func spinning() -> some View {
        modifier(Spinning())
    }
}
