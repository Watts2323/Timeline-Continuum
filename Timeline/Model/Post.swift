//
//  Post.swift
//  Timeline
//
//  Created by Xavier on 11/7/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    
    //Constants
    let recordTypeKey = "Post"
    fileprivate let captionKey = "caption"
    fileprivate let timestampKey = "timestamp"
    fileprivate let photoDataKey = "photoData"
    
    var recordID = CKRecord.ID(recordName: UUID().uuidString)
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment] = []
    var caption: String
    //that copies the contents of the photoData: NSData? property to a file in a temporary directory and returns the URL to the file. Must write to temporary directory to be able to pass image file path url to CKAsset
    var tempPhotoURL: URL?
    
    init(timestamp: Date = Date(), comments: [Comment] = [], caption: String, photo: UIImage) {
        self.timestamp = timestamp
        self.comments = comments
        self.caption = caption
        self.photo = photo
    }
    
    var photo: UIImage? {
        get{
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            self.tempPhotoURL = fileURL
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    deinit {
        if let url = tempPhotoURL {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                print("Error deleting temp file, or may cause memory leak: \(error)")
            }
        }
    }
    
    //Turn the ckRecord back into our Model Object and pull pur values out
    init?(ckrecord: CKRecord){
        guard let caption = ckrecord["caption"] as? String,
            let timestamp = ckrecord.creationDate,
            let imageAsset = ckrecord["photoData"] as? CKAsset else { return nil }
        guard let photoData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        
        self.caption = caption
        self.timestamp = timestamp
        self.photoData = photoData
        self.comments = []
        self.recordID = ckrecord.recordID
        
    }
}
//Turning our model object into a ckRecord
extension CKRecord{
    convenience init?(post: Post){
        let recordID = post.recordID
        self.init(recordType: post.recordTypeKey, recordID: recordID)
        self.setValue(post.caption, forKey: post.captionKey)
        self.setValue(post.timestamp, forKey: post.timestampKey)
        self.setValue(post.imageAsset, forKey: post.photoDataKey)
        
    }
}

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()){
            return true
        }
        for comment in self.comments{
            if comment.matches(searchTerm: searchTerm) {
                return true
            }
        }
        return false
    }
}
