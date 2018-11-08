//
//  Comment.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation

class Comment {
    
    var text: String
    var timestamp: Date
    var post: Post
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
}
