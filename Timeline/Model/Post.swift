//
//  Post.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class Post {
    
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment] = []
    var caption: String
    
    init(timestamp: Date = Date(), comments: [Comment] = [], caption: String, photo: UIImage) {
        self.timestamp = timestamp
        self.comments = comments
        self.caption = caption
        self.photo = photo
    }
    
    var photo: UIImage? {
        
    }
}
