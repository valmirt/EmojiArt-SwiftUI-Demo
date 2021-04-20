//
//  EmojiView.swift
//  EmojiArt
//
//  Created by Valmir Junior on 19/04/21.
//

import SwiftUI

struct EmojiView: View {
    var text: String
    var isSelected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(lineWidth: 1.5)
                    .foregroundColor(.black)
                    .opacity(isSelected ? 1 : 0)
                    .animation(.linear)
                Text(text)
                    .font(animatableWithSize: fontSize(for: geometry.size))
            }
        }
    }
    
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.6
        }
}

struct EmojiView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiView(text: "🍄", isSelected: true)
            .previewLayout(.fixed(width: 200, height: 200))
            .padding()
    }
}
