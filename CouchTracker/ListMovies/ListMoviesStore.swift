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

import Carlos
import Moya
import RxSwift

extension Movies: StringConvertible {

  public func toString() -> String {
    switch self {
    case .trending(let page, let limit, _):
      return "\(self.path)-\(page)-\(limit)"
    }
  }

}

final class ListMoviesStore: ListMoviesStoreInput {

  private let cache: BasicCache<Movies, NSData>

  init(apiProvider: APIProvider) {
    let moviesProvider = apiProvider.movies

    self.cache = MemoryCacheLevel()
        .compose(MoyaFetcher(provider: moviesProvider))
  }

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]> {
    return cache.get(.trending(page: page, limit: limit, extended: .full))
        .asObservable()
        .mapArray(TrendingMovie.self)
  }

}