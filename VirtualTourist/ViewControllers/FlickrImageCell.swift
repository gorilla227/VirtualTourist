//
//  FlickrImageCell.swift
//  VirtualTourist
//
//  Created by Andy Xu on 6/3/16.
//  Copyright © 2016 Andy Xu. All rights reserved.
//

import UIKit

class FlickrImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configureCell(flickrImage: FlickrImage, isSelected: Bool) {
        if let imageData = flickrImage.image {
            imageView.image = UIImage(data: imageData)
        } else {
            loadImage(flickrImage)
        }
        
        changeSelectionStatus(isSelected)
    }
    
    func changeSelectionStatus(isSelected: Bool) {
        // Set UI base on selection status
        if isSelected {
            contentView.alpha = 0.2
        } else {
            contentView.alpha = 1.0
        }
    }
    
    private func loadImage(flickrImage: FlickrImage) {
        let imageURL = NSURL(string: flickrImage.imagePath)!
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: imageURL)
        
        activityIndicator.startAnimating()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print(error)
                self.updateUIOnMainThread({
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                print("Return run statusCode when download image from \(imageURL)")
                self.updateUIOnMainThread({
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            guard let imageData = data else {
                print("Can't get image data from \(imageURL)")
                self.updateUIOnMainThread({
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            self.updateUIOnMainThread({
                flickrImage.image = imageData
                self.saveContext()
                self.imageView.image = UIImage(data: imageData)
                self.activityIndicator.stopAnimating()
            })
        }
        
        task.resume()
    }
    
    private func updateUIOnMainThread(block: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    // MARK: - CoreData functions
    func saveContext() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
    }
}
