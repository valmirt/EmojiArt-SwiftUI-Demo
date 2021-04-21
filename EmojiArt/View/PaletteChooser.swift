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
    @State private var showPaletteEditor = false
    
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
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture { showPaletteEditor = true }
                .sheet(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPalette, showPaletteEditor: $showPaletteEditor)
                        .environmentObject(viewModel)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var viewModel: EmojiArtViewModel
    @Binding var chosenPalette: String
    @Binding var showPaletteEditor: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                Text("Palette Editor")
                    .font(.headline)
                HStack {
                    Spacer()
                    Button("Done") {
                        showPaletteEditor = false
                    }
                }
            }
            .padding()
           
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            viewModel.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            chosenPalette = viewModel.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: fontSize))
                            .onTapGesture {
                                chosenPalette = viewModel.removeEmoji(emoji, fromPalette: chosenPalette)
                            }
                    }
                    .frame(height: height)
                }
            }
            Spacer()
        }
        .onAppear { paletteName = viewModel.paletteNames[chosenPalette] ?? "" }
    }
    
    //MARK: - Constants
    let fontSize: CGFloat = 38
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(viewModel: EmojiArtViewModel(), chosenPalette: .constant(""))
    }
}
