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

    @IBAction func didTapShortAnnouncement(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.announcer.announce("Short.")
        }
    }
    
    @IBAction func didTapLongAnnouncement(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.announcer.announce("This is a long announcement with a lot to say.")
        }
    }
    
    private var deadline: DispatchTime {
        let index = delayControl.selectedSegmentIndex
        let stringValue = delayControl.titleForSegment(at: index)!
        return .now() + .seconds(Int(stringValue)!)
    }
}

