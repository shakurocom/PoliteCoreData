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
            ForEach(items.indices, id: \.self) { index in
                Text(items[index].identifier)
                    .font(.system(size: 10.0, weight: .bold))
            }
        }
        .navigationBarHidden(false)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: deleteLastItem) {
                    Image(systemName: "trash")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: insertLastItem) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

private extension SwiftUIView {
    private func deleteLastItem() {
        storage.deleteLastItem()
    }

    private func insertLastItem() {
        storage.insertLastItem()
    }
}
