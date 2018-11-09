//
//  PostController.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

//Implement crud funtions

import Foundation
import CloudKit
import UIKit
import UserNotifications


//Here we are adding on to the postController class, add a new computed Instance
extension PostController {
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
}


class PostController {
    
    //Shared instance
    static let shared = PostController()
    
    private init(){}
    
    let publicDataBase = CKContainer.default().publicCloudDatabase
    
    //Source of TRUTH!!!!!
    var posts = [Post](){
        didSet{
            DispatchQueue.main.async {
                // each app comes with a default N, so what we are doing here is creating our own NC
                let nc = NotificationCenter.default
                //We are accesssing the properties of the instance post, we wrote an ext in the PC file
                nc.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    
    //Simply just checking the account status,is logged in of type bool because eithrer the user is logged in or they aren't, closure are non escaping by default we have to mark them as @escaping
    func checkAccountStatus(completion: @escaping (_ isLoggedIn: Bool) -> Void) {
        CKContainer.default().accountStatus { [weak self] (status, error) in
            if let error = error {
                print("Error checking accountStatus \(error) \(error.localizedDescription)")
                completion(false); return
            } else {
                let errrorText = "Sign into iCloud in Settings"
                switch status {
                case .available:
                    completion(true)
                case .noAccount:
                    let noAccount = "No account found"
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: noAccount)
                    completion(false)
                case .couldNotDetermine:
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: "Error with iCloud account status")
                    completion(false)
                case .restricted:
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: "Restricted iCloud account")
                    completion(false)
                }
            }
        }
    }
    
    func presentErrorAlert(errorTitle: String, errorMessage: String) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.showAlertMessage(titleStr: errorTitle, messageStr: errorMessage)
            }
        }
        
    }
    
    
    
    
    
    //Add an `addComment` function that takes a `text` parameter as a `String`, and a `Post` parameter. This should return a Comment object in a completion closure.
    func addComment(_ text: String, to post: Post, completion: @escaping (Comment?) ->()){
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
    //MARK: Create function
    // Add a `createPostWith` function that takes an image parameter as a `UIImage` and a caption as a `String`. This should return a Post object in a completion closure.
    func createPostWith(photo: UIImage, captionText: String, completion: @escaping (Post?) ->()){
        let post = Post(caption: captionText, photo: photo)
        self.posts.append(post)
        publicDataBase.save(CKRecord(post: post)!) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription) ")
                completion(nil);return
            }
            completion(post)
        }
    }
    
    // MARK: Fetch Functions
    func fetchAllPostsFromCloudKit(completion: @escaping([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Post", predicate: predicate)
        
        publicDataBase.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error fetching posts from cloudKit \(#function) \(error) \(error.localizedDescription)")
                completion(nil);return
            }
            
            guard let records = records else {completion(nil); return }
            
            let posts = records.compactMap{Post(ckrecord: $0)}
            
            self.posts = posts
            completion(posts)
        }
    }
    
    func fetchComments(from post: Post, completion: @escaping (Bool) -> Void) {
        let postRefence = post.recordID
        let predicate = NSPredicate(format: "postReference == %@", postRefence)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDataBase.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error fetching comments from cloudKit \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else {completion(false); return }
            
            let comments = records.compactMap{Comment(record: $0)}
            post.comments.append(contentsOf: comments)
            completion(true)
        }
    }
    
    //MARK: - CloudKit Subscriptions
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?){
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "Post", predicate: predicate, subscriptionID: "AllPosts", options: .firesOnRecordCreation)
        
        let notifcationInfo = CKSubscription.NotificationInfo()
        notifcationInfo.alertBody = "New post added"
        notifcationInfo.shouldBadge = true
        notifcationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifcationInfo
        
        publicDataBase.save(subscription) { (subscription, error) in
            if let error = error {
                print("🙅🏿‍♂️  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  🙅🏿‍♂️")
                completion?(false, error)
            }else {
                completion?(true, nil)
            }
        }
    }
    
    func addSubscritptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        let postRecordID = post.recordID
        
        //Might need to change this predicate
        let predicate = NSPredicate(format: "postReference = %@", postRecordID)
        let subscription = CKQuerySubscription(recordType: "Comment", predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "A new comment was added!"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = nil
        subscription.notificationInfo = notificationInfo
        
        publicDataBase.save(subscription) { (_, error) in
            if let error = error {
                print("🙅🏿‍♂️  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  🙅🏿‍♂️")
                completion?(false, error)
            }else{
                completion?(true, nil)
            }
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> ())?){
        let subscriptionID = post.recordID.recordName
        publicDataBase.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("🙅🏿‍♂️  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  🙅🏿‍♂️")
                completion?(false)
                return
            }else {
                print("Subscription deleted")
                completion?(true)
            }
            
        }
    }
    
    func checkForSubscription(to post: Post, completion: ((Bool) -> ())?){
        let subscriptionID = post.recordID.recordName
        publicDataBase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("  🙅🏿‍♂️There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  🙅🏿‍♂️")
                completion?(false)
                return
            }
            if subscription != nil{
                completion?(true)
            }else {
                completion?(false)
            }
            
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        checkForSubscription(to: post) { (isSubscribed) in
            if isSubscribed{
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                    if success{
                        print("Successfully removed the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    }else{
                        print("Whoops somthing went wrong removing the subscription to the post with caption: \(post.caption)") ; completion?(true, nil)
                        completion?(false, nil)
                    }
                })
            }else {
                self.addSubscritptionTo(commentsForPost: post, completion: { (success, error) in
                    if let error = error {
                        print("🙅🏿‍♂️  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  🙅🏿‍♂️")
                        completion?(false, error)
                        return
                    }
                    if success{
                        print("Successfully added the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    }else{
                        print("Whoops somthing went wrong adding the subscription to the post with caption: \(post.caption)") ; completion?(true, nil)
                        completion?(false, nil)
                    }
                })
            }
        }
    }
}
