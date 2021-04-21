//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Valmir Junior on 21/04/21.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    chosenPalette = viewModel.palette(after: chosenPalette)
                },
                onDecrement: {
                    chosenPalette = viewModel.palette(before: chosenPalette)
                },
                label: { EmptyView() })
            Text(viewModel.paletteNames[chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(viewModel: EmojiArtViewModel(), chosenPalette: .constant(""))
    }
}
