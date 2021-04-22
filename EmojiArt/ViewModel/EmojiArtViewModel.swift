//
//  EmojiArtViewModel.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import SwiftUI
import Combine

final class EmojiArtViewModel: ObservableObject, Hashable, Identifiable {
    let id: UUID
    static let palette: String = "🍎🍄🪖🏀"
    private let defaultsKey: String!
    private var fetchImageCancellable: AnyCancellable?
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStateZoomEmojiScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    @Published private var model: EmojiArt = EmojiArt() {
        didSet {
            UserDefaults.standard.set(model.json, forKey: defaultsKey)
        }
    }
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] {
        model.emojis
    }
    var backgroundURL: URL? {
        get { model.backgroundURL }
        set {
            model.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        defaultsKey = "EmojiArtViewModel.\(self.id.uuidString)"
        model = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EmojiArtViewModel, rhs: EmojiArtViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    //MARK: - Intent(s)
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        model.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func removeEmoji(_ emoji: EmojiArt.Emoji) {
        if let index = model.emojis.firstIndex(matching: emoji) {
            model.emojis.remove(at: index)
        }
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = model.emojis.firstIndex(matching: emoji) {
            model.emojis[index].x += Int(offset.width)
            model.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = model.emojis.firstIndex(matching: emoji) {
            model.emojis[index].size = Int((CGFloat(model.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = model.backgroundURL {
            fetchImageCancellable?.cancel()
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
            fetchImageCancellable = publisher.assign(to: \.backgroundImage, on: self)
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat {
        CGFloat(size)
    }
    
    var location: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
