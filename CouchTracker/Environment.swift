import TraktSwift
import TMDBSwift
import TVDBSwift
import Moya

final class Environment {
  static let instance = Environment()
  let trakt: TraktProvider
  let tmdb: TMDBProvider
  let tvdb: TVDBProvider
  let loginObservable: TraktLoginObservable
  let defaultOutput: TraktLoginOutput
  let diskCache: AnyCache<Int, NSData>
  let memoryCache: AnyCache<Int, NSData>
  let schedulers: Schedulers
  let realmProvider: RealmProvider
  let debug: Bool

  private init() {
    let schedulers = DefaultSchedulers()

    #if DEBUG
      self.debug = true
    #else
      self.debug = false
    #endif

    var plugins = [PluginType]()

    if debug {
      plugins = [NetworkLoggerPlugin()]
    }

    let traktBuilder = TraktBuilder {
      $0.clientId = Secrets.Trakt.clientId
      $0.clientSecret = Secrets.Trakt.clientSecret
      $0.redirectURL = Secrets.Trakt.redirectURL
      $0.callbackQueue = schedulers.networkQueue
      $0.plugins = plugins
    }

    let tvdbBuilder = TVDBBuilder {
      $0.apiKey = Secrets.TVDB.apiKey
      $0.callbackQueue = schedulers.networkQueue
      $0.plugins = plugins
    }

    let trakt = Trakt(builder: traktBuilder)

    self.trakt = trakt
    self.tmdb = TMDB(apiKey: Secrets.TMDB.apiKey)
    self.tvdb = TVDB(builder: tvdbBuilder)

    self.schedulers = schedulers

    let traktLoginStore = TraktLoginStore(trakt: trakt)

    self.loginObservable = traktLoginStore
    self.defaultOutput = traktLoginStore.loginOutput

    let simpleCache = AnyCache(SimpleMemoryCache())

    self.memoryCache = simpleCache
    self.diskCache = simpleCache
    self.realmProvider = DefaultRealmProvider()
  }
}
