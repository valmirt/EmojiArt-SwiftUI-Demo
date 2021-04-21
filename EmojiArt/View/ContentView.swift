//
//  ContentView.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomEmojiScale: CGFloat = 1.0
    @GestureState private var gesturePanOffset: CGSize = .zero
    @GestureState private var gesturePanEmojisOffset: CGSize = .zero
    @State private var emojiSelected: Set<EmojiArt.Emoji> = []
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @State private var steadyStateZoomEmojiScale: CGFloat = 1.0
    @State private var steadyStatePanOffset: CGSize = .zero
    @State private var chosenPalette: String = ""
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    private var zoomEmojiScale: CGFloat {
        steadyStateZoomEmojiScale * gestureZoomEmojiScale
    }
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    var isLoading: Bool {
        viewModel.backgroundURL != nil && viewModel.backgroundImage == nil
    }
    
    private var zoomGesture: some Gesture {
        if emojiSelected.isEmpty {
            return MagnificationGesture()
                .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                    gestureZoomScale = latestGestureScale
                }
                .onEnded { finalGestureScale in
                    steadyStateZoomScale *= finalGestureScale
                }
        }
        return MagnificationGesture()
            .updating($gestureZoomEmojiScale) { latestGestureScale, gestureZoomEmojiScale, _ in
                gestureZoomEmojiScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                emojiSelected.forEach { emoji in
                    viewModel.scaleEmoji(emoji, by: finalGestureScale)
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    init(viewModel: EmojiArtViewModel) {
        self.viewModel = viewModel
        _chosenPalette = State(wrappedValue: viewModel.defaultPalette)
    }

    var body: some View {
        VStack {
            HStack {
                PaletteChooser(viewModel: viewModel, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(Image(uiImage: viewModel.backgroundImage ?? UIImage()).scaleEffect(zoomScale).offset(panOffset))
                        .gesture(doubleTapToZoom(in: geometry.size))
                    
                    if isLoading {
                        Image(systemName: "hourglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .spinning()
                    } else {
                        ForEach(viewModel.emojis) { emoji in
                            let isSelected = emojiSelected.contains(matching: emoji)
                            EmojiView(text: emoji.text, isSelected: isSelected)
                                .scaleEffect(isSelected ? zoomEmojiScale : 1)
                                .frame(width: emoji.fontSize, height: emoji.fontSize)
                                .position(position(for: emoji, in: geometry.size))
                                .gesture(dragEmojisGesture(isSelected: isSelected))
                                .gesture(longPressToRemove(emoji, isSelected: isSelected))
                                .onTapGesture { handlerEmojiSelection(with: emoji) }
                        }
                    }
                }
                .clipped()
                .gesture(panGesture)
                .gesture(zoomGesture)
                .ignoresSafeArea()
                .onReceive(viewModel.$backgroundImage) { image in zoomToFit(image, in: geometry.size) }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(
                        x: location.x - geometry.size.width / 2,
                        y: location.y - geometry.size.height / 2
                    )
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
            }
            .onTapGesture { emojiSelected.removeAll() }
        }
    }
    
    private func dragEmojisGesture(isSelected: Bool) -> some Gesture {
        return DragGesture()
            .updating($gesturePanEmojisOffset) { latestDragGestureValue, gesturePanEmojisOffset, _ in
                if isSelected {
                    gesturePanEmojisOffset = latestDragGestureValue.translation / zoomScale
                }
            }
            .onEnded { finalDragGestureValue in
                if isSelected {
                    let distanceDragged = finalDragGestureValue.translation / zoomScale
                    for emoji in emojiSelected {
                        withAnimation {
                            viewModel.moveEmoji(emoji, by: distanceDragged)
                        }
                    }
                }
            }
    }
    
    private func longPressToRemove(_ emoji: EmojiArt.Emoji, isSelected: Bool) -> some Gesture {
        LongPressGesture(minimumDuration: 1)
            .onEnded { _ in
                if isSelected {
                    viewModel.removeEmoji(emoji)
                }
            }
    }
    
    private func handlerEmojiSelection(with emoji: EmojiArt.Emoji) {
        if emojiSelected.contains(matching: emoji) {
            emojiSelected.remove(emoji)
        } else {
            emojiSelected.insert(emoji)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear) {
                    zoomToFit(viewModel.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: emoji.location.x + size.width / 2, y: emoji.location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            viewModel.backgroundURL = url
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
