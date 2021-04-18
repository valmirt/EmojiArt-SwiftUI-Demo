//
//  ContentView.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtViewModel.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: defaultEmojiSize))
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                    }
                }
                
            }
            .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(Image(uiImage: viewModel.backgroundImage ?? UIImage()))
                        .ignoresSafeArea()
                        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                            var location = geometry.convert(location, from: .global)
                            location = CGPoint(
                                x: location.x - geometry.size.width / 2,
                                y: location.y - geometry.size.height / 2
                            )
                            return drop(providers: providers, at: location)
                        }
                    ForEach(viewModel.emojis) { emoji in
                        Text(emoji.text)
                            .font(font(for: emoji))
                            .position(position(for: emoji, in: geometry.size))
                    }
                }
            }
        }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x + size.width / 2, y: emoji.location.y + size.height / 2)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            viewModel.setBackgroundURL(url)
        }
        if  !found {
            found = providers.loadFirstObject(ofType: String.self) { string in
                viewModel.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 48
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: EmojiArtViewModel())
            
    }
}
