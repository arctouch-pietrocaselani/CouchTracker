import Foundation

public final class ShowsManagerDefaultModuleSetup: ShowsManagerDataSource {
  private static let defaultIndexKey = "showsManagerDefaultIndex"

  private let creator: ShowsManagerModuleCreator
  private let userDefaults: UserDefaults

  public var defaultModuleIndex: Int {
    get {
      userDefaults.integer(forKey: ShowsManagerDefaultModuleSetup.defaultIndexKey)
    }
    set {
      userDefaults.set(newValue, forKey: ShowsManagerDefaultModuleSetup.defaultIndexKey)
    }
  }

  public init(creator _: ShowsManagerModuleCreator) {
    Swift.fatalError("Please, use init(creator: userDefaults:)")
  }

  public init(creator: ShowsManagerModuleCreator, userDefaults: UserDefaults) {
    self.creator = creator
    self.userDefaults = userDefaults
  }

  public var options: [ShowsManagerOption] {
    let progress = ShowsManagerOption.progress
    let now = ShowsManagerOption.now
    let trending = ShowsManagerOption.trending
    let search = ShowsManagerOption.search

    return [progress, now, trending, search]
  }

  public var modulePages: [ModulePage] {
    let pages = options.map { option -> ModulePage in
      let view = self.creator.createModule(for: option)
      let name = moduleNameFor(option: option)

      return ModulePage(page: view, title: name)
    }

    return pages
  }

  private func moduleNameFor(option: ShowsManagerOption) -> String {
    switch option {
    case .progress:
      return CouchTrackerCoreStrings.showsProgress()
    case .now:
      return CouchTrackerCoreStrings.showsNow()
    case .trending:
      return CouchTrackerCoreStrings.trending()
    case .search:
      return CouchTrackerCoreStrings.search()
    }
  }
}
