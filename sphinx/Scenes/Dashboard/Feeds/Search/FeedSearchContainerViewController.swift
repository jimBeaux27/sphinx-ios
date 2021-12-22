// FeedSearchContainerViewController.swift
//
// Created by CypherPoet.
// ✌️
//


import UIKit
import CoreData


protocol FeedSearchResultsViewControllerDelegate: AnyObject {
    
    func viewController(
        _ viewController: UIViewController,
        didSelectFeedSearchResult searchResult: FeedSearchResult
    )
}


class FeedSearchContainerViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    private var managedObjectContext: NSManagedObjectContext!
    private weak var resultsDelegate: FeedSearchResultsViewControllerDelegate?
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = Self
        .makeFetchedResultsController(
            using: managedObjectContext,
            and: ContentFeed.FetchRequests.followedFeeds()
        )
    
    
    internal lazy var searchResultsViewController: FeedSearchResultsCollectionViewController = {
        FeedSearchResultsCollectionViewController
            .instantiate(
                onSubscribedFeedCellSelected: handleFeedCellSelection,
                onFeedSearchResultCellSelected: handleSearchResultCellSelection
            )
    }()
    
    
    internal lazy var emptyStateViewController: FeedSearchEmptyStateViewController = {
        FeedSearchEmptyStateViewController.instantiate()
    }()
    
    
    private var isShowingStartingEmptyStateVC: Bool = true
}



// MARK: -  Static Properties
extension FeedSearchContainerViewController {
    
    static func instantiate(
        managedObjectContext: NSManagedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext,
        resultsDelegate: FeedSearchResultsViewControllerDelegate
    ) -> FeedSearchContainerViewController {
        let viewController = StoryboardScene
            .Dashboard
            .FeedSearchContainerViewController
            .instantiate()
        
        viewController.managedObjectContext = managedObjectContext
        viewController.resultsDelegate = resultsDelegate
        viewController.fetchedResultsController.delegate = viewController
        
        return viewController
    }
    
    
    static func makeFetchedResultsController(
        using managedObjectContext: NSManagedObjectContext,
        and fetchRequest: NSFetchRequest<ContentFeed>
    ) -> NSFetchedResultsController<ContentFeed> {
        NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}


// MARK: -  Lifecycle
extension FeedSearchContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStartingEmptyStateView()
    }
}


// MARK: - Public Methods
extension FeedSearchContainerViewController {
    
    func updateSearchQuery(
        with searchQuery: String,
        and type: FeedType?
    ) {
        if searchQuery.isEmpty {
            presentInitialStateView()
        } else {
            presentResultsListView()
            
            fetchResults(for: searchQuery, and: type)
        }
    }
    
    
    func presentResultsListView() {
        isShowingStartingEmptyStateVC = false
        
        removeChildVC(child: emptyStateViewController)
        
        addChildVC(
            child: searchResultsViewController,
            container: contentView
        )
    }
    
    
    func presentInitialStateView() {
        isShowingStartingEmptyStateVC = true
        
        removeChildVC(child: searchResultsViewController)
        
        addChildVC(
            child: emptyStateViewController,
            container: contentView
        )
    }
}


// MARK: -  Private Helpers
extension FeedSearchContainerViewController {
    
    private func fetchResults(
        for searchQuery: String,
        and type: FeedType?
    ) {
        
        var newFetchRequest: NSFetchRequest<ContentFeed> = ContentFeed.FetchRequests.matching(searchQuery: searchQuery)
        
        if let type = type {
            switch(type) {
            case FeedType.Podcast:
                newFetchRequest = PodcastFeed
                    .FetchRequests
                    .matching(searchQuery: searchQuery)
            case FeedType.Video:
                newFetchRequest = VideoFeed
                    .FetchRequests
                    .matching(searchQuery: searchQuery)
            default:
                break
            }
        }
        
        fetchedResultsController.fetchRequest.sortDescriptors = newFetchRequest.sortDescriptors
        fetchedResultsController.fetchRequest.predicate = newFetchRequest.predicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            AlertHelper.showAlert(
                title: "Data Loading Error",
                message: "\(error)"
            )
        }
        
        if let type = type {
            API.sharedInstance.searchForFeeds(
                with: type,
                matching: searchQuery
            ) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let results):
                        
                        self.searchResultsViewController.updateWithNew(
                            searchResults: results
                        )
                        
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
    
    
    private func configureStartingEmptyStateView() {
        addChildVC(
            child: emptyStateViewController,
            container: contentView
        )
    }
    
    
    private func handleFeedCellSelection(_ feedSearchResult: FeedSearchResult) {
        resultsDelegate?.viewController(
            self,
            didSelectFeedSearchResult: feedSearchResult
        )
    }
    
    private func handleSearchResultCellSelection(
        _ searchResult: FeedSearchResult
    ) {
        let existingFeedsFetchRequest: NSFetchRequest<ContentFeed> = ContentFeed
            .FetchRequests
            .matching(feedID: searchResult.feedId)
        
        let fetchRequestResult = try! managedObjectContext.fetch(existingFeedsFetchRequest)
            
        if let existingFeed = fetchRequestResult.first {
            resultsDelegate?.viewController(
                self,
                didSelectFeedSearchResult: FeedSearchResult.convertFrom(contentFeed: existingFeed)
            )
        } else {
            ContentFeed.fetchContentFeed(
                at: searchResult.feedURLPath,
                chat: nil,
                searchResultDescription: searchResult.feedDescription,
                searchResultImageUrl: searchResult.imageUrl,
                persistingIn: managedObjectContext,
                then: { result in
                    
                if case .success(let contentFeed) = result {
                    self.managedObjectContext.saveContext()
                    
                    self.resultsDelegate?.viewController(
                        self,
                        didSelectFeedSearchResult: FeedSearchResult.convertFrom(contentFeed: contentFeed)
                    )
                }
            })
        }
    }
}


extension FeedSearchContainerViewController: NSFetchedResultsControllerDelegate {
    
    /// Called when the contents of the fetched results controller change.
    ///
    /// If this method is implemented, no other delegate methods will be invoked.
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        guard
            let resultController = controller as? NSFetchedResultsController<NSManagedObject>,
            let firstSection = resultController.sections?.first,
            let foundFeeds = firstSection.objects as? [ContentFeed]
        else {
            return
        }
        
        let subscribedFeeds: [FeedSearchResult] = foundFeeds
            .compactMap {
                return FeedSearchResult.convertFrom(contentFeed: $0)
            }
        
        DispatchQueue.main.async { [weak self] in
            self?.searchResultsViewController.updateWithNew(
                subscribedFeeds: subscribedFeeds
            )
        }
    }
}