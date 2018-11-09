//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    //Landing Pad
    var post: Post?{
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func updateViews(){
        guard let post = post else { return }
        photoImageView.image = post.photo
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        //Implement the present alert controller here
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let post = post, let photo = post.photo else { return }
        let activityViewController = UIActivityViewController(activityItems: [photo, post.caption], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true)
        }
        
    }
    @IBAction func followButtonTapped(_ sender: UIButton) {
        
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return post?.comments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        
        if let timestamp = comment?.timestamp{
            cell.detailTextLabel?.text = post?.timestamp.dateAsString
        }

        return cell
    }
}

extension PostDetailTableViewController {
    func presentAlertController(){
        let alertController = UIAlertController(title: "Leave a Comment", message: "Share your thoughts on this Post ", preferredStyle: .alert)
        
        alertController.addTextField { (commentTextField) in
            commentTextField.placeholder = "Type your Comment Here"
        }
        
        let okAction = UIAlertAction(title: "OK 👌🏿", style: .default) { (_) in
            guard let commentText = alertController.textFields?.first?.text, let post = self.post else { return }
            guard !commentText.isEmpty else { return }
        }
    }
}
