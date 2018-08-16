import RxSwift
import TraktSwift

public final class WatchedShowsAPIRepository {
  private let trakt: TraktProvider

  public init(trakt: TraktProvider) {
    self.trakt = trakt
  }

  func fetchWatchedShows(extended: Extended) -> Single<[BaseShow]> {
    let target = Sync.watched(type: .shows, extended: extended)
    return trakt.sync.rx.request(target).map([BaseShow].self)
  }
}
