//
//
//

import SwiftUI

struct SwiftUIView: View {

    @StateObject private var interactor: ExampleCoreDataInteractor

    init(storage: DataStorage) {
        _interactor = StateObject(wrappedValue: ExampleCoreDataInteractor(dataStorage: storage))
    }

    var body: some View {
        List {
            ForEach(interactor.lazyListDataSourceItems(), content: { (item) in
                ZStack(content: {
                    switch interactor.dataItem(item: item) {
                    case .some(let data):
                        Text(data.data.identifier)
                            .font(.system(size: 10.0, weight: .bold))
                    case .none:
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                    }
                })
            })
            .onDelete(perform: { (indexes) in
                if let index = indexes.first,
                   let dataItem = interactor.dataItem(index: index) {
                    interactor.deleteItem(dataItem.data.identifier)
                }
            })
        }
        .animation(.easeInOut, value: interactor.lazyListDataSourceItems())
        .navigationBarHidden(false)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: updateItems) {
                    Image(systemName: "trash")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: insertOrDeleteItems) {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            interactor.setup()
        }
    }

}

private extension SwiftUIView {

    private func updateItems() {
        interactor.updateItems()
    }

    private func insertOrDeleteItems() {
        interactor.insertOrDeleteItems()
    }

}
