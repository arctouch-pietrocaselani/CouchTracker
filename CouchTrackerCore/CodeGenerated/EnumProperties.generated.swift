// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: - EnumProperties

public extension MovieDetailsViewState {
    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
    public var isShowing: Bool {
        guard case .showing = self else { return false }
        return true
    }
    public var isError: Bool {
        guard case .error = self else { return false }
        return true
    }
    public var showing: MovieEntity? {
        guard case let .showing(movie) = self else { return nil }
        return (movie)
    }
    public var error: Error? {
        guard case let .error(error) = self else { return nil }
        return (error)
    }
}
public extension MoviesManagerViewState {
    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
    public var isShowing: Bool {
        guard case .showing = self else { return false }
        return true
    }
    public var showing: (pages: [ModulePage], selectedIndex: Int)? {
        guard case let .showing(pages, selectedIndex) = self else { return nil }
        return (pages, selectedIndex)
    }
}
