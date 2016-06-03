//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Andy Xu on 16/6/2.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsTipLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addEditButtonToNavigationBar()
    }

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
