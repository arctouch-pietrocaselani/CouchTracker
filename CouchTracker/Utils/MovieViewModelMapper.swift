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

import Trakt_Swift

extension MovieIds {
  func tmdbModelType() -> TrendingViewModelType? {
    var type: TrendingViewModelType? = nil
    if let tmdbId = self.tmdb {
      type = TrendingViewModelType.movie(tmdbMovieId: tmdbId)
    }
    return type
  }
}

func viewModel(for movie: MovieEntity, defaultTitle: String = "TBA".localized) -> TrendingViewModel {
  return TrendingViewModel(title: movie.title ?? defaultTitle, type: movie.ids.tmdbModelType())
}

func viewModel(for movie: Movie, defaultTitle: String = "TBA".localized) -> TrendingViewModel {
  return TrendingViewModel(title: movie.title ?? defaultTitle, type: movie.ids.tmdbModelType())
}
