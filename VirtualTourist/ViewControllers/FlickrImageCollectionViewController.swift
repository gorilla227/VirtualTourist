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

class FlickrImageCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let PerPage: Int = 18
    var mapPin: MapPin!
    let flickrAPI = FlickrAPI.SharedInstance
    var maxPages: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        navigationController?.setToolbarHidden(false, animated: false)
        initializeMap()
        configureCollectionViewFlowLayout()
        
        // TODO: Need check persistent data first
        print(mapPin.images.count)
        if mapPin.images.count == 0 {
            fetchFlickrImage()
        }
//        requestMaxPages()
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
        flickrAPI.requestMaxPages(parameters) { (result, errorMessage) in
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
        
        flickrAPI.requestImageList(parameters) { (result, errorMessage) in
            guard errorMessage == nil else {
                self.displayError(errorMessage!)
                return
            }
            
            guard let imagePaths = result else {
                self.displayError("No image paths return")
                return
            }
            
            for imagePath in imagePaths {
                _ = FlickrImage(mapPin: self.mapPin, imagePath: imagePath, context: self.sharedContext)
                self.saveContext()
            }
            
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
//        let sectionInfo = fetchedResultController.sections![section] as NSFetchedResultsSectionInfo
//        return sectionInfo.numberOfObjects
        return mapPin.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! FlickrImageCell
        let flickrImage = mapPin.images.objectAtIndex(indexPath.row) as! FlickrImage
//        cell.configureCell(fetchedResultController.objectAtIndexPath(indexPath) as! FlickrImage)
        cell.configureCell(flickrImage)
        
        return cell
    }
    
    // MARK: - CoreData functions
    var sharedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "FlickrImage")
        let sortDescriptor = NSSortDescriptor(key: "imagePath", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.mapPin)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    func saveContext() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            collectionView.insertItemsAtIndexPaths([newIndexPath!])
        case .Delete:
            collectionView.deleteItemsAtIndexPaths([indexPath!])
        default:
            return
        }
    }
    
    func fetchFlickrImage() {
        do {
            print("FetchFlickrImages")
            try fetchedResultController.performFetch()
            if ((fetchedResultController.fetchedObjects?.isEmpty) != nil) {
                requestMaxPages()
            }
        } catch {
            print(error)
            abort()
        }
    }

    // MARK: - IBActions
    @IBAction func collectionButtonOnClicked(sender: AnyObject) {
    }

}
