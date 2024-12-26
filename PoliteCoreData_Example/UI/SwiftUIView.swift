//
//
//

import SwiftUI
import PoliteCoreData_Framework

struct SwiftUIView: View {

    @StateObject private var interactor: ExampleCoreDataInteractor

    init(storage: DataStorage) {
        _interactor = StateObject(wrappedValue: ExampleCoreDataInteractor(dataStorage: storage))
    }

    var body: some View {
        List(interactor.items) { result in
            switch result {
            case .value(let item):
                Text(item.data.identifier)
                    .font(.system(size: 10.0, weight: .bold))
            case .empty:
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 1)
            }
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
