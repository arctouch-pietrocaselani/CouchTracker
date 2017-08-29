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

final class MovieDetailsViewMock: MovieDetailsView {
  var invokedPresenterSetter = false
  var presenter: MovieDetailsPresenter!
  var invokedShow = false
  var invokedShowParameters: (details: MovieDetailsViewModel, Void)?

  func show(details: MovieDetailsViewModel) {
    invokedShow = true
    invokedShowParameters = (details, ())
  }
}

final class MovieDetailsRouterMock: MovieDetailsRouter {
  var invokedShowError = false
  var invokedShowErrorParameters: (message: String, Void)?

  func showError(message: String) {
    invokedShowError = true
    invokedShowErrorParameters = (message, ())
  }
}

final class ErrorMovieDetailsStoreMock: MovieDetailsRepository {

  private let error: Error

  init(error: Error) {
    self.error = error
  }

  func fetchDetails(movieId: String) -> Observable<Movie> {
    return Observable.error(error)
  }
}

final class MovieDetailsStoreMock: MovieDetailsRepository {

  private let movie: Movie

  init(movie: Movie) {
    self.movie = movie
  }

  func fetchDetails(movieId: String) -> Observable<Movie> {
    return Observable.just(movie).filter { $0.ids.slug == movieId }
  }
}

func createMovieDetailsMock() -> Movie {
  let jsonData = Movies.summary(movieId: "tron-legacy-2010", extended: .full).sampleData
  return try! jsonData.mapObject(Movie.self)
}