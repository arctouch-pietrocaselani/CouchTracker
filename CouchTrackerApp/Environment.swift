import CouchTrackerCore
import Moya
import TMDBSwift
import TraktSwift
import TVDBSwift

public final class Environment {
  public static let instance = Environment()
  public let trakt: TraktProvider
  public let tmdb: TMDBProvider
  public let tvdb: TVDBProvider
  public let loginObservable: TraktLoginObservable
  public let defaultOutput: TraktLoginOutput
  public let schedulers: Schedulers
  public let realmProvider: RealmProvider
  public let buildConfig: BuildConfig
  public let appConfigurationsObservable: AppConfigurationsObservable
  public let appConfigurationsOutput: AppConfigurationsOutput
  public let showsSynchronizer: WatchedShowsSynchronizer
  public let showSynchronizer: WatchedShowSynchronizer
  public let watchedShowEntitiesObservable: WatchedShowEntitiesObservable
  public let watchedShowEntityObserable: WatchedShowEntityObserable
  public let centralSynchronizer: CentralSynchronizer
  public let userDefaults: UserDefaults
  public let genreRepository: GenreRepository
  public let syncStateObservable: SyncStateObservable
  public let syncStateOutput: SyncStateOutput

  public var currentAppState: AppConfigurationsState {
    return Environment.getAppState(userDefaults: userDefaults)
  }

  private static func getAppState(userDefaults: UserDefaults) -> AppConfigurationsState {
    let loginState = AppConfigurationsUserDefaultsDataSource.currentLoginValue(userDefaults)
    let hideSpecials = AppConfigurationsUserDefaultsDataSource.currentHideSpecialValue(userDefaults)
    return AppConfigurationsState(loginState: loginState, hideSpecials: hideSpecials)
  }

  // swiftlint:disable function_body_length
  private init() {
    userDefaults = UserDefaults.standard
    let schedulers = DefaultSchedulers.instance

    let syncStateStore = SyncStateStore()
    syncStateObservable = syncStateStore
    syncStateOutput = syncStateStore

    let debug: Bool

    var plugins = [PluginType]()

    #if DEBUG
      let traktClientId = Secrets.Trakt.clientId.isEmpty
      let tmdbAPIKey = Secrets.TMDB.apiKey.isEmpty
      let tvdbAPIKey = Secrets.TVDB.apiKey.isEmpty

      if traktClientId || tmdbAPIKey || tvdbAPIKey {
        Swift.fatalError("One or more API keys are empty. Check the class Secrets.swift")
      }

      debug = true

//      plugins.append(NetworkLoggerPlugin(verbose: false))
    #else
      debug = false
    #endif

    var traktPlugins = plugins
    // CT-TODO Remove this
    traktPlugins.append(NoCacheMoyaPlugin())

    buildConfig = DefaultBuildConfig(debug: debug)

    let traktBuilder = TraktBuilder {
      $0.clientId = Secrets.Trakt.clientId
      $0.clientSecret = Secrets.Trakt.clientSecret
      $0.redirectURL = Secrets.Trakt.redirectURL
      $0.callbackQueue = schedulers.networkQueue
      $0.plugins = traktPlugins
    }

    let tvdbBuilder = TVDBBuilder {
      $0.apiKey = Secrets.TVDB.apiKey
      $0.callbackQueue = schedulers.networkQueue
      $0.plugins = plugins
    }

    let trakt = Trakt(builder: traktBuilder)

    self.trakt = trakt
    tmdb = TMDB(apiKey: Secrets.TMDB.apiKey)
    tvdb = TVDB(builder: tvdbBuilder)

    self.schedulers = schedulers

    let traktLoginStore = TraktLoginStore(trakt: trakt)

    loginObservable = traktLoginStore
    defaultOutput = traktLoginStore.loginOutput

    realmProvider = DefaultRealmProvider(buildConfig: buildConfig)

    let appConfigurationsStore = AppConfigurationsStore(appState: Environment.getAppState(userDefaults: userDefaults))

    appConfigurationsOutput = appConfigurationsStore
    appConfigurationsObservable = appConfigurationsStore

    let genreDataSource = GenreRealmDataSource(realmProvider: realmProvider,
                                               schedulers: schedulers)

    genreRepository = TraktGenreRepository(traktProvider: trakt,
                                           dataSource: genreDataSource,
                                           schedulers: schedulers)

    let showsDownloader = DefaultWatchedShowEntitiesDownloader(trakt: trakt,
                                                               genreRepository: genreRepository,
                                                               scheduler: schedulers)

    let showDownloader = DefaultWatchedShowEntityDownloader(trakt: trakt,
                                                            scheduler: schedulers)

    let showDataSource = RealmShowDataSource(realmProvider: realmProvider, schedulers: schedulers)

    let showsDataSource = RealmShowsDataSource(realmProvider: realmProvider,
                                               syncObservable: syncStateStore,
                                               schedulers: schedulers)

    watchedShowEntitiesObservable = showsDataSource
    watchedShowEntityObserable = showDataSource

    showsSynchronizer = DefaultWatchedShowsSynchronizer(downloader: showsDownloader,
                                                        dataHolder: showsDataSource,
                                                        syncStateOutput: syncStateStore,
                                                        schedulers: schedulers)

    showSynchronizer = DefaultWatchedShowSynchronizer(downloader: showDownloader,
                                                      dataSource: showDataSource,
                                                      syncStateOutput: syncStateStore,
                                                      scheduler: schedulers)

    centralSynchronizer = CentralSynchronizer.initialize(watchedShowsSynchronizer: showsSynchronizer,
                                                         appConfigObservable: appConfigurationsObservable,
                                                         syncStateOutput: syncStateOutput)
  }
}
