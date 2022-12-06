//
//  RecommendationDetailsView.swift
//  sphinx
//
//  Created by Tomas Timinskas on 02/12/2022.
//  Copyright © 2022 sphinx. All rights reserved.
//

import UIKit

class RecommendationDetailsView: UIView {
    
    weak var delegate: RecommendationPlayerViewDelegate?
    
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var podcastPlayerControlsView: PodcastPlayerControlsView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Bundle.main.loadNibNamed("RecommendationDetailsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

// MARK: - Public methods
extension RecommendationDetailsView {
    func configure(
        withRecommendation recommendation: RecommendationResult,
        podcast: PodcastFeed,
        andDelegate delegate: RecommendationPlayerViewDelegate?
    ) {
        titleLabel.text = recommendation.title
        descriptionLabel.text = recommendation.subtitle
        
        if let date = recommendation.date {
            dateLabel.text = Date(timeIntervalSince1970: TimeInterval(date)).getLastMessageDateFormat()
        } else {
            dateLabel.text = "-"
        }
        
        podcastPlayerControlsView.configure(
            withRecommendation: recommendation,
            podcast: podcast,
            andDelegate: delegate
        )
    }
    
    func configureControls(
        playing: Bool,
        speedDescription: String
    ) {
        podcastPlayerControlsView.configureControls(playing: playing, speedDescription: speedDescription)
    }
}

extension RecommendationDetailsView : RecommendationPlayerViewDelegate {
    func shouldShowSpeedPicker() {
        delegate?.shouldShowSpeedPicker()
    }
}