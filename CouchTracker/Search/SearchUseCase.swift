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

import RxSwift

final class SearchUseCase: SearchInteractor {
  private let repository: SearchRepository

  init(repository: SearchRepository) {
    self.repository = repository
  }

  func searchMovies(query: String) -> Observable<[SearchResult]> {
    return repository.search(query: query, types: [.movie], page: 0, limit: 50)
  }
}