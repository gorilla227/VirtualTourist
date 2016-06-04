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
    
    var mapPin: MapPin!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        navigationController?.setToolbarHidden(false, animated: false)
        initializeMap()
        configureCollectionViewFlowLayout()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath)
        return cell
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
