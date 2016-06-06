//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Andy Xu on 16/6/2.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsTipLabel: UILabel!
    
    let kCenterLat = "kCenterLat"
    let kCenterLon = "kCenterLon"
    let kSpanLat = "kSpanLat"
    let kSpanLon = "kSpanLon"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addEditButtonToNavigationBar()
        addGestureForMapView()
        fetchAllMapPins()
        loadMapPins()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - UI functions
    func addEditButtonToNavigationBar() {
        let editButton = editButtonItem()
        navigationItem.setRightBarButtonItem(editButton, animated: false)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        UIView.animateWithDuration(0.5) { 
            if editing {
                self.deletePinsTipLabel.alpha = 1.0
            } else {
                self.deletePinsTipLabel.alpha = 0.0
            }
        }
    }
    
    // MARK: - MapView functions
    
    func addGestureForMapView()  {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewMapPin(_:)))
        mapView.addGestureRecognizer(gesture)
    }
    
    func addNewMapPin(sender: AnyObject) {
        let gesture = sender as! UILongPressGestureRecognizer
        if gesture.state == UIGestureRecognizerState.Ended && !editing {
            let point = gesture.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            print(coordinate)
            
            _ = MapPin(coordinate: coordinate, context: sharedContext)
            saveContext()
        }
    }
    
    func loadMapPins() {
        mapView.addAnnotations((fetchedResultController.fetchedObjects as? [MapPin])!)
        
        if let centerLat = NSUserDefaults.standardUserDefaults().objectForKey(kCenterLat) as? Double,
        let centerLon = NSUserDefaults.standardUserDefaults().objectForKey(kCenterLon) as? Double,
        let spanLat = NSUserDefaults.standardUserDefaults().objectForKey(kSpanLat) as? Double,
        let spanLon = NSUserDefaults.standardUserDefaults().objectForKey(kSpanLon) as? Double {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
            mapView.setRegion(region, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if editing {
            // MARK: Delete mapPin
            print("Deleting mapPin in MOC")
            sharedContext.deleteObject(view.annotation as! MapPin)
            saveContext()
        } else {
            // MARK: Push image collection viewController
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegueWithIdentifier("ShowImageCollection", sender: view.annotation)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: kCenterLat)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: kCenterLon)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: kSpanLat)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: kSpanLon)
    }
    
    
    // MARK: - CoreData
    var sharedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "MapPin")
        let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
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
            let mapPin = anObject as! MapPin
            mapView.addAnnotation(mapPin)
        case .Delete:
            print("Removing mapPin from mapView")
            let mapPin = anObject as! MapPin
            mapView.removeAnnotation(mapPin)
        default:
            return
        }
    }
    
    func fetchAllMapPins() {
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error)
            abort()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowImageCollection" {
            let destVC = segue.destinationViewController as! FlickrImageCollectionViewController
            destVC.mapPin = sender as! MapPin
        }
    }
    
}
