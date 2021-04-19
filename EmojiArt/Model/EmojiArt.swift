//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Valmir Junior on 18/04/21.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis: [Emoji] = []
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    private var uniqueEmojiId = 0
    
    init?(json: Data?) {
        if let json = json, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    init() {
        /* not implemented */
    }
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
}
