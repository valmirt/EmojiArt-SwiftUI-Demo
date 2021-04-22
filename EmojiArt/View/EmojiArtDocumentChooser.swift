//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Valmir Junior on 21/04/21.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var viewModel: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.documents) { document in
                    NavigationLink(
                        destination: EmojiArtView(viewModel: document)
                            .navigationTitle(viewModel.name(for: document))
                    ) {
                        EditableText(viewModel.name(for: document), isEditing: editMode.isEditing) { name in
                            viewModel.setName(name, for: document)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.documents[$0] }.forEach { document in
                        viewModel.removeDocument(document)
                    }
                }
            }
            .navigationTitle(viewModel.name)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.addDocument()
                    }, label: { Image(systemName: "plus").imageScale(.large) })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
