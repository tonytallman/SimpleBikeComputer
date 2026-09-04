import LayoutsVM
import Observation

@MainActor
public protocol PortraitPagesViewModel: AnyObject, Observable {
    associatedtype Layout: PortraitSingleFieldLayoutViewModel
    var layout: Layout { get }
}

@MainActor
public protocol LandscapePagesViewModel: AnyObject, Observable {
    associatedtype Layout: LandscapeSingleFieldLayoutViewModel
    var layout: Layout { get }
}

@MainActor
public protocol PagesViewModel: AnyObject, Observable {
    associatedtype PortraitPages: PortraitPagesViewModel
    associatedtype LandscapePages: LandscapePagesViewModel
    var portraitPages: PortraitPages { get }
    var landscapePages: LandscapePages { get }
}
