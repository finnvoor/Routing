import SwiftUI

public protocol PathItem: Hashable {}
public protocol SheetItem: Identifiable {}
public protocol FullScreenCoverItem: Identifiable {}

public enum EmptyPathItem: PathItem {}
public enum EmptySheetItem: SheetItem { public var id: String { "" } }
public enum EmptyFullScreenCoverItem: FullScreenCoverItem { public var id: String { "" } }

public protocol Router: AnyObject, Observable {
    associatedtype RouterPathItem: PathItem = EmptyPathItem
    associatedtype RouterSheetItem: SheetItem = EmptySheetItem
    associatedtype RouterFullScreenCoverItem: FullScreenCoverItem = EmptyFullScreenCoverItem

    associatedtype PathItemContent: View = EmptyView
    associatedtype SheetItemContent: View = EmptyView
    associatedtype FullScreenCoverItemContent: View = EmptyView

    var path: [RouterPathItem] { get set }
    var sheetItem: RouterSheetItem? { get set }
    var fullScreenCoverItem: RouterFullScreenCoverItem? { get set }

    func view(forPathItem pathItem: RouterPathItem) -> PathItemContent
    func view(forSheetItem sheetItem: RouterSheetItem) -> SheetItemContent
    func view(forFullScreenCoverItem fullScreenCoverItem: RouterFullScreenCoverItem) -> FullScreenCoverItemContent
}

public extension Router {
    var path: [EmptyPathItem] { get { [] } set {} }
    var sheetItem: EmptySheetItem? { get { nil } set {} }
    var fullScreenCoverItem: EmptyFullScreenCoverItem? { get { nil } set {} }

    func view(forPathItem _: EmptyPathItem) -> EmptyView { EmptyView() }
    func view(forSheetItem _: EmptySheetItem) -> EmptyView { EmptyView() }
    func view(forFullScreenCoverItem _: EmptyFullScreenCoverItem) -> EmptyView { EmptyView() }
}

@MainActor public extension View {
    func router<T: Router>(_ router: Binding<T>) -> some View {
        navigationDestination(for: T.RouterPathItem.self) { pathItem in
            router.wrappedValue.view(forPathItem: pathItem)
        }.sheet(item: router.sheetItem) { sheetItem in
            router.wrappedValue.view(forSheetItem: sheetItem)
        }.fullScreenCover(item: router.fullScreenCoverItem) { fullScreenCoverItem in
            router.wrappedValue.view(forFullScreenCoverItem: fullScreenCoverItem)
        }
    }
}

public struct RouterStack<StackRouter: Router, Content: View>: View {
    public init(router: Binding<StackRouter>, @ViewBuilder content: @escaping () -> Content) {
        _router = router
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .router($router)
        }.environment(router)
    }

    private let content: () -> Content
    @Binding var router: StackRouter
}
