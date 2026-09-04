import Observation
import PagesVM

@MainActor
public protocol RootViewModel: AnyObject, Observable {
    associatedtype Pages: PagesViewModel
    var pages: Pages { get }
}
