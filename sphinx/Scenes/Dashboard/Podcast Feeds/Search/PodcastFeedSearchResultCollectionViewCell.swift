// PodcastFeedSearchResultCollectionViewCell.swift
//
// Created by CypherPoet.
// ✌️
//
    
import UIKit
import SDWebImage


class PodcastFeedSearchResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var feedThumbnailImageView: UIImageView!
    @IBOutlet weak var feedTitleLabel: UILabel!
    @IBOutlet weak var feedSubtitleLabel: UILabel!
    @IBOutlet weak var feedSubscriptionButton: UIButton!
    
    
    var item: PodcastFeedSearchResult! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateViewsWithItem()
            }
        }
    }
    
    var onSubscriptionButtonTapped: (() -> Void)?
}



// MARK: - Static Properties
extension PodcastFeedSearchResultCollectionViewCell {
    static let reuseID = "PodcastFeedSearchResultCollectionViewCell"
    
    static let nib: UINib = {
        UINib(nibName: "PodcastFeedSearchResultCollectionViewCell", bundle: nil)
    }()
}


// MARK: - Computeds
extension PodcastFeedSearchResultCollectionViewCell {
    
    var imageURL: URL? {
        item.imageURLPath.flatMap{ URL(string: $0) }
    }
}
    

// MARK: - Lifecycle
extension PodcastFeedSearchResultCollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedThumbnailImageView.layer.cornerRadius = 6.0
        feedThumbnailImageView.clipsToBounds = true
    }
}


// MARK: - Public Methods
extension PodcastFeedSearchResultCollectionViewCell {
    
    public func configure(withItem searchResult: PodcastFeedSearchResult) {
        self.item = searchResult
    }
}


// MARK: - Event Handling
extension PodcastFeedSearchResultCollectionViewCell {
    
    @IBAction func subscriptionButtonTapped(_ sender: UIButton) {
        onSubscriptionButtonTapped?()
    }
}


// MARK: - Private Helpers
extension PodcastFeedSearchResultCollectionViewCell {
    
    private func updateViewsWithItem() {
        if let imageURL = imageURL {
            feedThumbnailImageView.sd_setImage(
                with: imageURL,
                placeholderImage: UIImage(named: "podcastTagIcon"),
                options: [.highPriority],
                progress: nil
            )
            
            feedThumbnailImageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        } else {
            // TODO: What's the recommended placeholder to use here?
            feedThumbnailImageView.image = UIImage(named: "podcastTagIcon")
        }
        
        feedTitleLabel.text = item.title
        feedSubtitleLabel.text = item.subtitle
    }
}