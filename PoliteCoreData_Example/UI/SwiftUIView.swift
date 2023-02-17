//
//
//

import SwiftUI
import PoliteCoreData_Framework

struct SwiftUIView: View {

    @ObservedObject private var interactor: ExampleCoreDataInteractor

    init(storage: DataStorage) {
        _interactor = ObservedObject(initialValue: ExampleCoreDataInteractor(dataStorage: storage))
    }

    var body: some View {
        List(interactor.items) { item in
            Text(item.identifier)
                .font(.system(size: 10.0, weight: .bold))
                .id(item.id)
        }
        .animation(.easeInOut, value: interactor.items)
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
        .onAppear {
            interactor.setup()
        }
    }

}

private extension SwiftUIView {

    private func deleteLastItem() {
        interactor.deleteLastItem()
    }

    private func insertLastItem() {
        interactor.insertLastItem()
    }

}
