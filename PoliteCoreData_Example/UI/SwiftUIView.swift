//
//
//

import SwiftUI
import PoliteCoreData_Framework

struct SwiftUIView: View {

    @FetchableRequest private var items: ItemsFetchableResults<CDExampleEntity, ManagedExampleEntity>

    private let storage: DataStorage

    init(storage: DataStorage) {
        self.storage = storage
        self._items = storage.fetchableRequest()
    }

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item.identifier)
            }
            /*
            ForEach(sections.indices, id: \.self) { section in
                Section(header: Text(sections[section].name)) {
                    ForEach(sections[section].items.indices, id: \.self) { item in
                        Text(sections[section].items[item].identifier)
                            .font(.system(size: 10.0, weight: .bold))
                    }
                }
            }*/
        }
        .navigationBarHidden(false)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: deleteFirstItem) {
                    Image(systemName: "trash")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: insertFirstItem) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

private extension SwiftUIView {
    private func deleteFirstItem() {
        guard !items.isEmpty else {
            return
        }
        storage.deleteExampleItem(items[0].identifier)
    }

    private func insertFirstItem() {
        storage.insertExampleItem(ExampleEntity())
    }
}
