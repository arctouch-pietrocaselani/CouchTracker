/*
Copyright 2017 ArcTouch LLC.
All rights reserved.
 
This file, its contents, concepts, methods, behavior, and operation
(collectively the "Software") are protected by trade secret, patent,
and copyright laws. The use of the Software is governed by a license
agreement. Disclosure of the Software to third parties, in any form,
in whole or in part, is expressly prohibited except as authorized by
the license agreement.
*/

import Foundation
import RxSwift
import Trakt_Swift

let trendingRepositoryMock = TrendingRepositoryMock(traktProvider: traktProviderMock)

func createTrendingShowsMock() -> [TrendingShow] {
  let jsonArray = parseToJSONArray(data: Shows.trending(page: 0, limit: 10, extended: .full).sampleData)
  return try! jsonArray.map { try TrendingShow(JSON: $0) }
}

final class TrendingViewMock: TrendingView {
  var presenter: TrendingPresenter!
  var searchView: SearchView!
  var invokedShowEmptyView = false

  func showEmptyView() {
    invokedShowEmptyView = true
  }

  var invokedShow = false
  var invokedShowParameters: (viewModels: [TrendingViewModel], Void)?

  func show(trending: [TrendingViewModel]) {
    invokedShow = true
    invokedShowParameters = (trending, ())
  }
}

final class TrendingPresenterMock: TrendingPresenter {
  let currentTrendingType = Variable<TrendingType>(.movies)
  var invokedViewDidLoad = false

  init(view: TrendingView, interactor: TrendingInteractor, router: TrendingRouter) {}

  func viewDidLoad() {
    invokedViewDidLoad = true
  }

  var invokedShowDetailsOfTrending = false
  var invokedShowDetailsOfTrendingParameters: (index: Int, Void)?

  func showDetailsOfTrending(at index: Int) {
    invokedShowDetailsOfTrending = true
    invokedShowDetailsOfTrendingParameters = (index, ())
  }
}

final class TrendingRouterMock: TrendingRouter {
  var invokedShowDetails = false
  var invokedShowDetailsParameters: (movie: TrendingMovieEntity, Void)?

  func showDetails(of movie: TrendingMovieEntity) {
    invokedShowDetails = true
    invokedShowDetailsParameters = (movie, ())
  }

  var invokedShowError = false
  var invokedShowErrorParameters: (message: String, Void)?

  func showError(message: String) {
    invokedShowError = true
    invokedShowErrorParameters = (message, ())
  }
}

final class EmptyTrendingRepositoryMock: TrendingRepository {
  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]> {
    return Observable.empty()
  }

  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShow]> {
    return Observable.empty()
  }
}

final class ErrorTrendingRepositoryMock: TrendingRepository {
  private let error: Error

  init(error: Error) {
    self.error = error
  }

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]> {
    return Observable.error(error)
  }

  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShow]> {
    return Observable.error(error)
  }
}

final class TrendingMoviesRepositoryMock: TrendingRepository {

  private let movies: [TrendingMovie]

  init(movies: [TrendingMovie]) {
    self.movies = movies
  }

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]> {
    return Observable.just(movies).take(limit)
  }

  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShow]> {
    return Observable.empty()
  }
}

final class TrendingRepositoryMock: TrendingRepository {
  private let traktProvider: TraktProvider

  init(traktProvider: TraktProvider) {
    self.traktProvider = traktProvider
  }

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]> {
    return traktProvider.movies.request(.trending(page: page, limit: limit, extended: .full))
      .mapArray(TrendingMovie.self)
  }

  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShow]> {
    return traktProvider.shows.request(.trending(page: page, limit: limit, extended: .full))
      .mapArray(TrendingShow.self)
  }
}

final class TrendingServiceMock: TrendingInteractor {

  let trendingRepo: TrendingRepository
  let imageRepo: ImageRepository

  init(repository: TrendingRepository, imageRepository: ImageRepository) {
    self.trendingRepo = repository
    self.imageRepo = imageRepository
  }

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovieEntity]> {
    let moviesObservable = trendingRepo.fetchMovies(page: page, limit: limit)
    let imagesObservable = imageRepo.fetchImages(for: 30, posterSize: nil, backdropSize: nil)

    return Observable.combineLatest(moviesObservable, imagesObservable) { (movies, images) -> [TrendingMovieEntity] in
      return movies.map { entity(for: $0, with: images) }
    }
  }

  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShowEntity]> {
    return trendingRepo.fetchShows(page: page, limit: limit).map {
      return $0.map { entity(for: $0) }
    }
  }
}