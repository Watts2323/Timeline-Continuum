//
//  PostController.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class PostController {
    
    //Shared Instance
    static let shared = PostController()
    
    //Shared truth
    var posts = [Post]()
    
    func addComment(toPost post: Post, text: String, completion: @escaping (Comment?) -> ()) {

        
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> ()) {
        
        let post = Post(caption: caption, photo: photo)
    }
}
