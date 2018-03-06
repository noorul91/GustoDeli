//
//  StorageService.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/29/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageService {
    
    static func uploadImage(_ image: UIImage, at reference: FIRStorageReference, completion: @escaping (URL?) -> Void) {
        //change UIImage to Data and reduce the quality of the image.
        //Reduce the quality of image because otherwise the images will take a long time to upload/download
        //from Firebase Storage
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        //upload our media data to the path provided
        reference.put(imageData, metadata: nil, completion: { (metadata, error) in
            //if there is error, return nil to completion closure to signal there was an error.
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            completion(metadata?.downloadURL())
        })
    }
    
    static func getPhoto(_ userPhoto: UIImageView!, childPath: String)  {
        let storageRef = FIRStorage.storage().reference().child(childPath)
        storageRef.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
            if data != nil && error == nil {
                userPhoto.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
}
