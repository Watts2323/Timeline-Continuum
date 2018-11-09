//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    //LandingPad
    var post: Post?{
        didSet{
         updateViews()
        }
    }
    
    func updateViews(){
        guard let post = post else { return }
        
        PostController.shared.fetchComments(from: post) { (success) in
            if success{
                DispatchQueue.main.async {
                    self.commentCountLabel.text = "\(post.comments.count)"
                }
            }
        }
        postImageView.image = post.photo
        captionLabel.text = post.caption
    }

}
