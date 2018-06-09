import RxSwift
import TraktSwift

public protocol MovieDetailsRouter: class {
	func showError(message: String)
}

public protocol MovieDetailsPresenter: class {
	init(view: MovieDetailsView, interactor: MovieDetailsInteractor, router: MovieDetailsRouter)

	func viewDidLoad()

	func observeViewState() -> Observable<MovieDetailsViewState>
	func observeImagesState() -> Observable<MovieDetailsImagesState>
}

public protocol MovieDetailsView: BaseView {
	var presenter: MovieDetailsPresenter! { get set }

	func show(details: MovieDetailsViewModel)
	func show(images: ImagesViewModel)
}

public protocol MovieDetailsInteractor: class {
	init(repository: MovieDetailsRepository, genreRepository: GenreRepository,
						imageRepository: ImageRepository, movieIds: MovieIds)

	func fetchDetails() -> Observable<MovieEntity>
	func fetchImages() -> Maybe<ImagesEntity>
}

public protocol MovieDetailsRepository: class {
	func fetchDetails(movieId: String) -> Observable<Movie>
}
