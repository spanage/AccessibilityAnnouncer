//
//  ViewController.swift
//  AnnouncerDemoApp
//
//  Created by Sommer Panage on 9/11/15.
//  Copyright © 2015 Sommer Panage. All rights reserved.
//

import UIKit
import AccessibilityAnnouncer

class ViewController: UIViewController {
    
    private let announcer = AccessibilityAnnouncer(defaultTimeout: 5.0)

    @IBOutlet var delayControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapShortAnnouncement(sender: UIButton) {
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.announcer.announce("Short.")
        }
    }
    
    @IBAction func didTapLongAnnouncement(sender: UIButton) {
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.announcer.announce("This is a long announcement with a lot to say.")
        }
    }
    
    private var delay: dispatch_time_t {
        let index = delayControl.selectedSegmentIndex
        let stringValue = delayControl.titleForSegmentAtIndex(index)!
        return dispatch_time(DISPATCH_TIME_NOW, Int64(Double(stringValue)! * Double(NSEC_PER_SEC)))
    }
}

