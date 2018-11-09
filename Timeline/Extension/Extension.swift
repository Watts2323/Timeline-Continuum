//
//  Extension.swift
//  Timeline
//
//  Created by Xavier on 11/8/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import UIKit
extension UIViewController {
    func showAlertMessage(titleStr:String, messageStr:String) {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
