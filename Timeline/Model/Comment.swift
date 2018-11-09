//
//  Comment.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    
    //Constants
    let typeKey = "Comment"
    fileprivate let textKey = "text"
    fileprivate let timestampKey = "timestamp"
    fileprivate let postReferenceKey = "postReference"
    
    var recordID = CKRecord.ID(recordName: UUID().uuidString)
    var text: String
    var timestamp: Date
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post?) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    convenience init?(record: CKRecord){
        guard let text = record["text"] as? String,
            let timestamp = record.creationDate else { return nil }
        self.init(text: text, timestamp: timestamp, post: nil)
        self.recordID = record.recordID
    }
}

//Turning model object into a ckRecord
extension CKRecord {
    convenience init(_ comment: Comment) {
        guard let post = comment.post else {
            fatalError("Comment does not have a Post relationship")
        }
        self.init(recordType: comment.typeKey, recordID: comment.recordID)
        self.setValue(comment.text, forKey: comment.textKey)
        self.setValue(comment.timestamp, forKey: comment.timestampKey)
        self.setValue(CKRecord.Reference(recordID: post.recordID, action: .deleteSelf), forKey: comment.postReferenceKey)
    }
}

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return self.text.lowercased().contains(searchTerm.lowercased())
    }
}

