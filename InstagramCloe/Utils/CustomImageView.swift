//
//  CustomImageView.swift
//  InstagramCloe
//
//  Created by Apple on 11.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit


var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastImgUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String) {
        
        //set image to nil
        self.image = nil
        
        //set lastImgUrlUsedToLoadImage
        lastImgUrlUsedToLoadImage = urlString //taking last imgurl we used to load img and setting it on var last.. area
            
            //check if image exists in cache
            if let cachedImage = imageCache[urlString] {
                self.image = cachedImage
                return
            }
            
            //if image doesnt exists in cache
            
            //url for image location
            
            guard let url = URL(string: urlString) else { return }
            
            // fetch contents of URL
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                //handle error
                if let error = error {
                    print("failed to load image with error", error.localizedDescription)
                    
                    
                }
                
                if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                    return
                }
                
                // image data
                guard let imageData = data else { return }
                
                //set image using image data
                let photoImage = UIImage(data: imageData)
                
                //set key and value for image cache
                imageCache[url.absoluteString] = photoImage
                
                //set image
                DispatchQueue.main.async {
                    self.image = photoImage
                }
            }.resume()
            
            
            
        }
    }

