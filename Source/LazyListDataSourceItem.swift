//
//
//

public struct LazyListDataSourceItem: Identifiable, Equatable {

    public let id: String

    internal init() {
        self.id = UUID().uuidString
    }

}
