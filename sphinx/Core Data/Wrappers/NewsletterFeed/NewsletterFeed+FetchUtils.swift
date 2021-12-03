//
//  NewsletterFeed+FetchUtils.swift
//  sphinx
//
//  Created by Tomas Timinskas on 27/10/2021.
//  Copyright © 2021 sphinx. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Predicates
extension NewsletterFeed {

    public enum Predicates {
        
        public static let newsletterFeeds: NSPredicate = {
            NSPredicate(
                format: "feedKindValue == %d",
                FeedType.Newsletter.rawValue
            )
        }()
        
        
        public static let followedNewsletterFeeds: NSPredicate = {
            NSPredicate(
                format: "chat != nil AND feedKindValue == %d",
                FeedType.Newsletter.rawValue
            )
        }()
    }
}


// MARK: - FetchRequests
extension NewsletterFeed {

    public enum FetchRequests {

        public static func baseFetchRequest<ContentFeed>() -> NSFetchRequest<ContentFeed> {
            let request = NSFetchRequest<ContentFeed>(entityName: "ContentFeed")
            request.predicate = NewsletterFeed.Predicates.newsletterFeeds
            return request
        }
        
        public static func followedFeeds() -> NSFetchRequest<ContentFeed> {
            let request: NSFetchRequest<ContentFeed> = baseFetchRequest()
            
            request.predicate = Predicates.followedNewsletterFeeds
            request.sortDescriptors = []

            return request
        }
    }
}