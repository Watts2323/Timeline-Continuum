//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Xavier on 11/8/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationBarDelegate {

    @IBOutlet weak var captionTextField: UITextField!
    
    var photo: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        print("Add Post Button Tapped")
        guard let photo = photo, let caption = captionTextField.text, !caption.isEmpty else { return}
        
        PostController.shared.createPostWith(photo: photo, captionText: caption) { (post) in
        }
        self.tabBarController?.selectedIndex = 0
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelectVC"{
            guard let destinationVC = segue.destination as? PhotoSelectorViewController else {return}
            destinationVC.delegate = self
        }
    }
}


extension AddPostTableViewController: PhotoSelectorViewControllerDelegate{
    func photoSelected(_ photo: UIImage) {
         self.photo = photo
    }
    
   
}
