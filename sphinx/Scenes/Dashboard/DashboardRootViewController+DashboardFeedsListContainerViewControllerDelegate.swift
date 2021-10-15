import UIKit
import CoreData


extension DashboardRootViewController: DashboardFeedsListContainerViewControllerDelegate {
    
    func viewController(
        _ viewController: UIViewController,
        didSelectPodcastEpisodeWithID podcastEpisodeID: NSManagedObjectID
    ) {
        guard
            let podcastEpisode = managedObjectContext.object(with: podcastEpisodeID) as? PodcastEpisode,
            let podcastFeed = podcastEpisode.feed,
            let chat = podcastFeed.chat
        else {
            return
        }
        
        let podcastPlayerHelper = chat.getPodcastPlayer()

        presentPodcastPlayer(
            forPodcastFrom: chat,
            with: podcastPlayerHelper
        )
    }


    func viewController(
        _ viewController: UIViewController,
        didSelectPodcastFeedWithID podcastFeedID: NSManagedObjectID
    ) {
        guard
            let podcastFeed = managedObjectContext.object(with: podcastFeedID) as? PodcastFeed
        else {
            return
        }
        
        guard let feedURLPath = podcastFeed.feedURLPath else {
            AlertHelper.showAlert(title: "Failed to find a URL for the feed.", message: "")
            return
        }
        
        
        let podcastPlayerHelper: PodcastPlayerHelper
        
        if let chat = podcastFeed.chat {
            podcastPlayerHelper = chat.getPodcastPlayer()
        } else {
            // Load a podcast that was subscribed to from the Podcast Index.
            // These won't have an associated `chat`, but we can still fetch episodes.
            podcastPlayerHelper = PodcastPlayerHelper()
        }
        
        podcastPlayerHelper.podcast = podcastFeed
        
            
        API.sharedInstance.getPodcastEpisodes(
            byFeedURLPath: feedURLPath
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let episodes):
                    podcastPlayerHelper.podcast?.episodes = Set(episodes)
                    
                    self.presentPodcastPlayer(
                        forPodcastFrom: podcastFeed.chat,
                        with: podcastPlayerHelper
                    )
                case .failure(_):
                    AlertHelper.showAlert(
                        title: "Failed to fetch episodes for feed",
                        message: ""
                    )
                }
            }
        }
    }
}


extension DashboardRootViewController {
    
    internal func presentPodcastPlayer(
        forPodcastFrom chat: Chat? = nil,
        with podcastPlayerHelper: PodcastPlayerHelper
    ) {
        let podcastFeedVC = NewPodcastPlayerViewController.instantiate(
            chat: chat,
            playerHelper: podcastPlayerHelper,
            dismissButtonStyle: .backArrow,
            delegate: self
        )
        
        podcastFeedVC.modalPresentationStyle = .fullScreen
        
        navigationController?.pushViewController(podcastFeedVC, animated: true)
    }
}