//
//
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        List {
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
        print("delete")
    }

    private func insertFirstItem() {
        print("insert")
    }
}
