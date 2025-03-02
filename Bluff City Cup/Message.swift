//
//  Message.swift
//  Bluff City Cup
//
//  Created by Ross Montague
//  Copyright © 2024 Jumpstop Creations. All rights reserved.
//

import Foundation

enum MessageType {
    case text
    case image
    case video
}

enum ReactionType: String {
    case like = "like"
    case dislike = "dislike"
    case laugh = "laugh"
}

struct Reaction {
    let userIdentifier: String
    let reaction: ReactionType
    let timestamp: Date
}

class Message {
    private var id: Int
    private var userIdentifier: String
    private var content: String
    private var type: MessageType
    private var parentMessageId: Int?
    private var mediaUrl: String?
    private var reactions: [Reaction]
    private var timestamp: Date
    
    init(id: Int, userIdentifier: String, content: String, type: MessageType, parentMessageId: Int? = nil, mediaUrl: String? = nil) {
        self.id = id
        self.userIdentifier = userIdentifier
        self.content = content
        self.type = type
        self.parentMessageId = parentMessageId
        self.mediaUrl = mediaUrl
        self.reactions = []
        self.timestamp = Date()
    }
    
    // Getters
    func getId() -> Int { return id }
    func getUserIdentifier() -> String { return userIdentifier }
    func getContent() -> String { return content }
    func getType() -> MessageType { return type }
    func getParentMessageId() -> Int? { return parentMessageId }
    func getMediaUrl() -> String? { return mediaUrl }
    func getReactions() -> [Reaction] { return reactions }
    func getTimestamp() -> Date { return timestamp }
    
    // Add reaction
    func addReaction(_ reaction: Reaction) {
        removeReaction(userIdentifier: reaction.userIdentifier)
        reactions.append(reaction)
    }
    
    // Remove reaction
    func removeReaction(userIdentifier: String) {
        reactions.removeAll { $0.userIdentifier == userIdentifier }
    }
    
    // Get reaction counts
    func getReactionCounts() -> [ReactionType: Int] {
        var counts: [ReactionType: Int] = [:]
        for reaction in reactions {
            counts[reaction.reaction, default: 0] += 1
        }
        return counts
    }
    
    // Get user's reaction
    func getUserReaction(for userIdentifier: String) -> ReactionType? {
        return reactions.first { $0.userIdentifier == userIdentifier }?.reaction
    }
}
