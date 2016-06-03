//
//  MapPin.swift
//  VirtualTourist
//
//  Created by Andy on 16/6/2.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class MapPin: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass
    var coordinate: CLLocationCoordinate2D {
       return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("MapPin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        images = [FlickrImage]()
    }
}
