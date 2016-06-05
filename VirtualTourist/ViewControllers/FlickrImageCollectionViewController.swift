//
//  FlickrImageCollectionViewController.swift
//  VirtualTourist
//
//  Created by Andy Xu on 6/3/16.
//  Copyright © 2016 Andy Xu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrImageCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let PerPage: Int = 18
    var mapPin: MapPin!
    let flickAPI = FlickrAPI.SharedInstance
    var maxPages: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        navigationController?.setToolbarHidden(false, animated: false)
        initializeMap()
        configureCollectionViewFlowLayout()
        
        // TODO: Need check persistent data first
        requestMaxPages()
    }
    
    func displayError(errorMessage: String) {
        setViewEnabled(true
        )
        let alertView = UIAlertController(title: nil, message: errorMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertView.addAction(action)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func setViewEnabled(enable: Bool) {
        dispatch_async(dispatch_get_main_queue()) { 
            if enable {
                self.activityIndicator.stopAnimating()
                self.collectionButton.enabled = true
            } else {
                self.activityIndicator.startAnimating()
                self.collectionButton.enabled = false
            }
        }
    }
    
    // MARK: - Initialize Map
    func initializeMap() {
        guard mapPin != nil else {
            print("No mapPin")
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        mapView.addAnnotation(mapPin)
        mapView.showAnnotations([mapPin], animated: true)
    }
    
    // MARK: - Flickr functions
    func requestMaxPages() {
        let parameters: [String: AnyObject] = [
            FlickrAPI.Constants.ParameterKeys.APIKey: FlickrAPI.Constants.ParameterValues.APIKeys,
            FlickrAPI.Constants.ParameterKeys.Method: FlickrAPI.Constants.ParameterValues.Method_PhotsForLocation,
            FlickrAPI.Constants.ParameterKeys.Format: FlickrAPI.Constants.ParameterValues.ResponseFormat,
            FlickrAPI.Constants.ParameterKeys.Extras: FlickrAPI.Constants.ParameterValues.MediumURL,
            FlickrAPI.Constants.ParameterKeys.NoJSONCallback: FlickrAPI.Constants.ParameterValues.DisableJSONCallback,
            FlickrAPI.Constants.ParameterKeys.SafeSearch: FlickrAPI.Constants.ParameterValues.UseSafeSearch,
            FlickrAPI.Constants.ParameterKeys.Latitude: mapPin.latitude,
            FlickrAPI.Constants.ParameterKeys.Longitude: mapPin.longitude,
            FlickrAPI.Constants.ParameterKeys.PerPage: PerPage
        ]
        
        setViewEnabled(false)
        flickAPI.requestMaxPages(parameters) { (result, errorMessage) in
            guard errorMessage == nil else {
                self.displayError(errorMessage!)
                return
            }
            
            self.maxPages = result
            
            // Generate random page id
            let randomPageId = Int(arc4random_uniform(UInt32(self.maxPages)))
            self.requestPhotoList(randomPageId)
        }
    }
    
    func requestPhotoList(pageId: Int)  {
        let parameters: [String: AnyObject] = [
            FlickrAPI.Constants.ParameterKeys.APIKey: FlickrAPI.Constants.ParameterValues.APIKeys,
            FlickrAPI.Constants.ParameterKeys.Method: FlickrAPI.Constants.ParameterValues.Method_PhotsForLocation,
            FlickrAPI.Constants.ParameterKeys.Format: FlickrAPI.Constants.ParameterValues.ResponseFormat,
            FlickrAPI.Constants.ParameterKeys.Extras: FlickrAPI.Constants.ParameterValues.MediumURL,
            FlickrAPI.Constants.ParameterKeys.NoJSONCallback: FlickrAPI.Constants.ParameterValues.DisableJSONCallback,
            FlickrAPI.Constants.ParameterKeys.SafeSearch: FlickrAPI.Constants.ParameterValues.UseSafeSearch,
            FlickrAPI.Constants.ParameterKeys.Latitude: mapPin.latitude,
            FlickrAPI.Constants.ParameterKeys.Longitude: mapPin.longitude,
            FlickrAPI.Constants.ParameterKeys.PerPage: PerPage,
            FlickrAPI.Constants.ParameterKeys.Page: pageId
        ]
        
        setViewEnabled(false)
        
        flickAPI.requestImageList(parameters) { (result, errorMessage) in
            guard errorMessage == nil else {
                self.displayError(errorMessage!)
                return
            }
            
            print(result)
            self.setViewEnabled(true)
        }
    }
    
    // MARK: - CollectionView functions
    func configureCollectionViewFlowLayout() {
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - space * 2) / 3.0
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! FlickrImageCell
        return cell
    }

    @IBAction func collectionButtonOnClicked(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
