//
//  ContentView.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                steadyStateZoomScale *= finalGestureScale
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
                        .overlay(Image(uiImage: viewModel.backgroundImage ?? UIImage()).scaleEffect(zoomScale).offset(panOffset))
                        .gesture(doubleTapToZoom(in: geometry.size))
                    
                    ForEach(viewModel.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
                            .position(position(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .gesture(panGesture)
                .gesture(zoomGesture)
                .ignoresSafeArea()
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
