//
//  PostService.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/29/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    static func create(for image: UIImage, childPath: String, completion: @escaping (_ urlString: String) -> Void) {
        let imageRef = FIRStorage.storage().reference().child(childPath)
        StorageService.uploadImage(image, at: imageRef, completion: { (downloadURL) in
            guard let downloadURL = downloadURL else { return }
            let urlString = downloadURL.absoluteString
            completion(urlString)
        })
    }
}
