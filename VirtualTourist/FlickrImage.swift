//
//  FlickrImage.swift
//  VirtualTourist
//
//  Created by Andy on 16/6/2.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation
import CoreData


class FlickrImage: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(mapPin: MapPin, imagePath: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("FlickrImage", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imagePath = imagePath
        location = mapPin
        mapPin.images.addObject(self)
    }
}
