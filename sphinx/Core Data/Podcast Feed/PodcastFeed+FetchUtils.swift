// PodcastFeed+FetchUtils.swift
//
// Created by CypherPoet.
// ✌️
//
    

import Foundation
import CoreData


// MARK: - Predicates
extension PodcastFeed {

    public enum Predicates {
        
        public static func matching(searchQuery: String) -> NSPredicate {
            let keyword = "CONTAINS"
            let formatSpecifier = "%@"

            return NSPredicate(
                format: "%K \(keyword) \(formatSpecifier)",
                #keyPath(PodcastFeed.title),
                searchQuery
            )
        }
    }
}


// MARK: - SortDescriptors
extension PodcastFeed {

    // 💡 An instance of `NSFetchedResultsController`, or an `NSFetchRequestResult` created by
    // SwiftUI's `@FetchRequest` property wrapper, requires a fetch request with sort descriptors.

    public enum SortDescriptors {

        public static let nameAscending: NSSortDescriptor = NSSortDescriptor(
            key: #keyPath(PodcastFeed.title),
            ascending: true,

            // 🔑 Any time you’re sorting user-facing strings,
            // Apple recommends that you pass in `NSString.localizedStandardCompare(_:)`
            // to sort according to the language rules of the current locale.
            // This means sort will “just work” and do the right thing for
            // languages with special character.
            selector: #selector(NSString.localizedStandardCompare(_:))
        )


        public static let nameDescending: NSSortDescriptor = {
            guard let descriptor = nameAscending.reversedSortDescriptor as? NSSortDescriptor else {
                preconditionFailure("Unable to make reversed sort descriptor")
            }

            return descriptor
        }()
    }
}


// MARK: - FetchRequests
extension PodcastFeed {

    public enum FetchRequests {

        public static func baseFetchRequest<PodcastFeed>() -> NSFetchRequest<PodcastFeed> {
            NSFetchRequest<PodcastFeed>(entityName: "PodcastFeed")
        }


        public static func `default`() -> NSFetchRequest<PodcastFeed> {
            let request: NSFetchRequest<PodcastFeed> = baseFetchRequest()

            request.sortDescriptors = [PodcastFeed.SortDescriptors.nameAscending]
            request.predicate = nil

            return request
        }
        
        
        public static func matching(searchQuery: String) -> NSFetchRequest<PodcastFeed> {
            let request: NSFetchRequest<PodcastFeed> = baseFetchRequest()

            request.sortDescriptors = [PodcastFeed.SortDescriptors.nameAscending]
            request.predicate = PodcastFeed.Predicates.matching(searchQuery: searchQuery)

            return request
        }
    }
}