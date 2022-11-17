//
//  ContentConsumedAction.swift
//  sphinx
//
//  Created by Tomas Timinskas on 23/09/2022.
//  Copyright © 2022 sphinx. All rights reserved.
//

import Foundation

public class ContentConsumedAction: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.feedId, forKey: .feedId)
        try container.encode(self.feedType, forKey: .feedType)
        try container.encode(self.feedUrl, forKey: .feedUrl)
        try container.encode(self.feedItemId, forKey: .feedItemId)
        try container.encode(self.feedItemUrl, forKey: .feedItemUrl)
        try container.encode(self.history, forKey: .history)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let feedId = try values.decode(String.self, forKey: .feedId)
        let feedType = try values.decode(Int.self, forKey: .feedType)
        let feedUrl = try values.decode(String.self, forKey: .feedUrl)
        let feedItemId = try values.decode(String.self, forKey: .feedItemId)
        let feedItemUrl = try values.decode(String.self, forKey: .feedItemUrl)
        let history = try values.decode([ContentConsumedHistoryItem].self, forKey: .history)

        self.feedId = feedId
        self.feedType = feedType
        self.feedUrl = feedUrl
        self.feedItemId = feedItemId
        self.feedItemUrl = feedItemUrl
        self.history = history
    }
    
    public var feedId: String
    public var feedType: Int
    public var feedUrl: String
    public var feedItemId: String
    public var feedItemUrl: String
    public var history: [ContentConsumedHistoryItem] = []
    
    init(
        feedId: String,
        feedType: Int,
        feedUrl: String,
        feedItemId: String,
        feedItemUrl: String
    ) {
        self.feedId = feedId
        self.feedType = feedType
        self.feedUrl = feedUrl
        self.feedItemId = feedItemId
        self.feedItemUrl = feedItemUrl
    }
    
    func jsonString() -> String? {
        let jsonEncoder = JSONEncoder()
        var jsonData: Data! = nil
        do {
            jsonData = try jsonEncoder.encode(self)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }

    static func messageAction(jsonString: String) -> ContentConsumedAction? {
        let data = Data(jsonString.utf8)
        let jsonDecoder = JSONDecoder()
        var contentConsumedAction: ContentConsumedAction! = nil
        do {
            contentConsumedAction = try jsonDecoder.decode(ContentConsumedAction.self, from: data)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return contentConsumedAction
    }
    
    func isValid() -> Bool {
        return self.history.count > 0
    }
    
    func addItem(historyItem: ContentConsumedHistoryItem) {
        self.history.append(historyItem)
    }
}

extension ContentConsumedAction {
    enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case feedType = "feed_type"
        case feedUrl = "feed_url"
        case feedItemId = "feed_item_id"
        case feedItemUrl = "feed_item_url"
        case firstInteraction = "first_interaction"
        case history = "history"
    }
}

public class ContentConsumedHistoryItem: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.startTimestamp, forKey: .startTimestamp)
        try container.encode(self.endTimestamp, forKey: .endTimestamp)
        try container.encode(self.currentTimestamp, forKey: .currentTimestamp)
        try container.encode(self.topics, forKey: .topics)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let startTimestamp = try values.decode(Int.self, forKey: .startTimestamp)
        let endTimestamp = try values.decode(Int.self, forKey: .endTimestamp)
        let currentTimestamp = try values.decode(Date.self, forKey: .currentTimestamp)
        let topics = try values.decode([String].self, forKey: .topics)

        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.currentTimestamp = currentTimestamp
        self.topics = topics
    }
    
    public var startTimestamp: Int
    public var endTimestamp: Int? = nil
    public var currentTimestamp: Date
    public var topics: [String] = []
    
    init(
        startTimestamp: Int,
        currentTimestamp: Date
    ) {
        self.startTimestamp = startTimestamp
        self.currentTimestamp = currentTimestamp
    }
    
    func isValid() -> Bool {
        guard let endTimestamp = endTimestamp else {
            return false
        }
        return (endTimestamp - startTimestamp > 2000)
    }
}

extension ContentConsumedHistoryItem {
    enum CodingKeys: String, CodingKey {
        case startTimestamp = "start_timestamp"
        case endTimestamp = "end_timestamp"
        case currentTimestamp = "current_timestamp"
        case topics = "topics"
    }
}