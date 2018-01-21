import UIKit

final class AppFlowModule {
  private init() {}

  static func setupModule() -> BaseView {
    let moviesView = MoviesManagerModule.setupModule()

    guard let moviesViewController = moviesView as? UIViewController else {
      fatalError("trendingView should be an instance of UIViewController")
    }

    let showsView = ShowsManagerModule.setupModule()
    guard let showsViewController = showsView as? UIViewController else {
      fatalError("showsView should be an instance of UIViewController")
    }

    let appConfigurationsView = AppConfigurationsModule.setupModule()
    guard let appConfigurationsViewController = appConfigurationsView as? UIViewController else {
      fatalError("appConfigurationsView should be an instance of UIViewController")
    }

    let viewControllers = [moviesViewController, showsViewController, appConfigurationsViewController]

    guard let appFlowViewController = R.storyboard.appFlow.appFlowViewController() else {
      fatalError("Can't instantiate AppFlowViewController from Storyboard")
    }

    appFlowViewController.viewControllers = viewControllers

    return appFlowViewController
  }
}
